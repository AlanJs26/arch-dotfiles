"""
ARCHDOTS
help: run a collection of commands defined in config.yaml
arguments:
  - name: collection
    required: false
    type: str
    nargs: '*'
    help: collection(s) to be executed. Leave empty for all
flags:
  - long: --restart
    type: bool
    help: force commands to be restarted
  - long: --list
    type: bool
    help: list all configured colletions
  - long: --export
    type: bool
    help: export each collection as a shell script and print it contents
ARCHDOTS
"""

# this prevents the language server to throwing warnings
args = args  # type: ignore

from typing import Literal
from archdots.settings import read_config
from archdots.exceptions import CommandException
from rich import print
from os.path import expandvars, basename
from os import system
from pydantic import BaseModel
import psutil


class CollectionModel(BaseModel):
    name: str
    match_method: Literal["cmdline", "name"] = "cmdline"
    commands: list[str]
    priority: int = 1
    daemon: bool = True
    run_with: list[str] = []


config: dict = read_config()

if not "autostart" in config:
    raise CommandException('there is no "autostart" entry in config.yaml')

if args["list"]:
    print(config["autostart"])
    exit()

processes = list(psutil.process_iter())

collections = sorted(
    [CollectionModel.model_validate(c) for c in config["autostart"]],
    key=lambda c: c.priority,
    reverse=True,
)

if target_collections := args["collection"]:
    collections = list(
        filter(
            lambda c: c.name in target_collections
            or any(el in target_collections for el in c.run_with),
            collections,
        )
    )

if args["export"]:
    script_txt = "#!/usr/bin/bash\n"
    script_txt += (
        r'function print_title () { echo -e "\033[0;36m::\033[0m $@"; }' + "\n"
    )
    for collection in collections:
        script_txt += f"# {collection.name}\n"
        for cmd in collection.commands:

            if collection.daemon:
                cmd_basename = basename(cmd.split()[0])
                if collection.match_method == "name" and len(cmd_basename) < 15:
                    script_txt += f"pgrep -x \"{cmd_basename}\" >/dev/null || (print_title '{cmd}'; {cmd}) &\n"
                else:
                    script_txt += f"pgrep -f \"{cmd}\" >/dev/null || (print_title '{cmd}'; {cmd}) &\n"
            else:
                script_txt += f"print_title '{cmd}'; {cmd}\n"
        script_txt += "\n"
    print(script_txt)
    exit()


def run_process(command):
    print("[cyan]:: " + command)
    system(f"(sleep 1&&{command})&")


def match_process(p: psutil.Process, command: str, method: str) -> bool:
    try:
        match method:
            case "cmdline":
                cmdline = " ".join(p.cmdline())
                if expandvars(command) in cmdline:
                    return True
            case "name":
                command_name = basename(command.split()[0])
                if command_name in p.name():
                    return True
    except (psutil.NoSuchProcess, psutil.ZombieProcess):
        pass
    return False


for collection in collections:
    for command in collection.commands:
        if not collection.daemon:
            print("[cyan]:: " + command)
            if system(command) != 0:
                raise CommandException(f'command "{command}" has exited with error')
            continue

        found_processes = {}
        for p in processes:
            if match_process(p, command, collection.match_method):
                if command not in found_processes:
                    found_processes[command] = []
                found_processes[command].append(p)

        if command in found_processes:
            if args["restart"]:
                for p in found_processes[command]:
                    p.kill()
                run_process(command)
                if found_processes:
                    print("[yellow]:: killed background processes")
        else:
            run_process(command)
    print(
        f'[green]:: executed collection "{collection.name}"',
        (
            f"[green](match_method: {collection.match_method})"
            if collection.daemon
            else ""
        ),
        f'[green]{"(daemon)" if collection.daemon else ""}',
    )
