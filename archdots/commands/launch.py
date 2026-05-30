"""
ARCHDOTS
help: launch apps defined in config.yaml
arguments:
  - name: app
    required: false
    type: str
    nargs: '*'
    help: app alias
flags:
  - long: --list
    type: bool
    help: list all app aliases
ARCHDOTS
"""

# this prevents the language server to throwing warnings
args = args  # type: ignore

from archdots.config.manager import ConfigManager
import os

apps = " ".join(args["app"])

config = ConfigManager().load()

if "apps" not in config:
    exit()

if args["list"]:
    from rich import print

    print(config["apps"])
    exit()

if apps not in config["apps"]:
    from rich import print

    print(f'[red]unknown app named "{apps}"')
    exit(1)

os.system(config["apps"][apps])
