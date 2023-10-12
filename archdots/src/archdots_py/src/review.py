import subprocess
import tty, termios, sys
import re
from typing import Literal
from rich import print
from rich.panel import Panel
from rich.table import Table
from rich.console import Console
import yaml
import os

pacdef_config_path = os.path.expanduser('~/.config/pacdef/pacdef.yaml')
aur_helper = 'yay'
if os.path.isfile(pacdef_config_path):
    with open(pacdef_config_path) as file:
        config = yaml.safe_load(file)
        if 'aur_helper' in config:
            aur_helper = config['aur_helper']

def getchar():
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    tty.setraw(sys.stdin.fileno())
    ch = sys.stdin.read(1)
    termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
    # Exit on ctrl-c, ctrl-d, ctrl-z, or ESC
    if ord(ch) in [3, 4, 26, 27]:
        sys.exit()
    return ch

def gum_choose(elements:list[str]|None=None, command=''):
    input_command = ''
    if command:
        input_command = command
    if elements:
        joined = "\n".join(elements)
        input_command = f'echo "{joined}"'

    if input_command:
        return subprocess.check_output(f'{input_command}|gum choose',shell=True).decode().strip()

    raise Exception('invalid elements')

def get_arch_packages():
    return subprocess.check_output("yay -Qe|awk '{ print $1 }'",shell=True).decode().strip().split('\n')

def get_file_packages(path: str):
    with open(path) as file:
        content = re.sub(r'^\s*#.*$', '', file.read(), flags=re.MULTILINE)

    group_types = re.findall(r'\[.+?\]', content)
    group_contents = filter_truthy(
        [filter_truthy(item.split('\n')) for item in re.split(r'\[.+?\]', content)]
    )
    group_dict = {re.sub(r'[\[\]]', '', k):set(v) for k,v in zip(group_types, group_contents)}

    return group_dict


def filter_truthy(items):
    return list(filter(lambda _:_, items))

installed_packages:dict[str,set[str]] = {
    'arch': set(get_arch_packages()),
    'python': set(),
}
pacdef_packages:dict[str,set[str]] = {}

pacdef_path = os.path.expanduser('~/.config/pacdef/groups')
pacdef_groups = os.listdir(pacdef_path) 

for group in pacdef_groups:
    packages = get_file_packages(f'{pacdef_path}/{group}')
    for domain in packages:
        if domain not in pacdef_packages:
            pacdef_packages[domain] = set()

        pacdef_packages[domain].update(packages[domain])



intersect_packages = {k:v.difference(pacdef_packages[k]) for k,v in installed_packages.items()}

def make_option(name:str, color='green'):
    return f'([{color}]{name[0]}[white]){name[1:]}'

TOptions_history = list[tuple[str,Literal['d', 's']|int]]

def print_options_history(history: TOptions_history):
    option_map = {
        'd': '[red]deleted',
        's': '[yellow]skipped',
    }
    table = Table(show_header=False)
    console = Console()
    for package, option in history:
        if option in option_map:
            table.add_row(package, option_map[option])
        elif isinstance(option, int):
            table.add_row(package, '[green]'+pacdef_groups[option])
        elif not option:
            table.add_row(package, '')
        else:
            table.add_row(package, f'unknown option: {option}')
    console.print(table)

history:dict[str, TOptions_history] = {}

zipped_packages = [(group, package) for (group, packages) in intersect_packages.items() for package in packages]

prev_group = ''
i = 0

while i < len(zipped_packages):

    group, package = zipped_packages[i]

    if prev_group and prev_group != group:
        print(Panel.fit(f'[white]{group}', style='green'))
        prev_group = group

    if group not in history:
        history[group] = []

    print(f'[white]assign [blue]{package}[white] to {make_option("group")}, {make_option("delete")}, {make_option("skip")}, {make_option("peek")}, {make_option("undo")}, {make_option("quit")}?')
    option = getchar()

    if option == 'g':
        print(', '.join(map((lambda item: f'({item[0]+1}){item[1]}'), enumerate(pacdef_groups))))
        option = getchar()
        if option.isdigit() and int(option) >= 1 and int(option) <= len(pacdef_groups):
            print(f'{package} -> [green]{pacdef_groups[int(option)-1]}')
            history[group].append((package, int(option)-1))
        else:
            print('invalid option')
            continue

    elif option == 'd':
        print(f'[red]deleted')
        history[group].append((package, 'd'))
    elif option == 's':
        print('[yellow]skipped')
        history[group].append((package, 's'))
    elif option == 'p':
        print_options_history(history[group])
        continue
    elif option == 'u':
        if i > 0:
            i -= 1
            del history[group][i]
        continue

    elif option == 'q':
        os._exit(1)
    else:
        print('invalid option')
        continue

    i+=1


print()

for group, options_history in history.items():
    print(f'[green]{group}')
    print_options_history(options_history)

while True:
    print(f'Keep changes? {make_option("yes")}/{make_option("no")}')
    option = getchar()

    if option == 'y':
        if 'arch' in history:
            deleted_packages = list(map(lambda item: item[0], filter(lambda item: item[1] == 'd', history['arch']))) 
            if deleted_packages:
                os.system(f'yay -R {" ".join(deleted_packages)}')

        history_groups:dict[str, dict[str, list[str]]] = {}
        for domain, options_history in history.items():
            for package, option in options_history:
                if isinstance(option, int):
                    i = int(option)
                    if pacdef_groups[i] not in history_groups:
                        history_groups[pacdef_groups[i]] = {}
                    if domain not in history_groups[pacdef_groups[i]]:
                        history_groups[pacdef_groups[i]][domain] = []

                    history_groups[pacdef_groups[i]][domain].append(package)

        for group, packages_by_domain in history_groups.items():
            with open(f'{pacdef_path}/{group}', 'r') as file:
                content = file.read()

            with open(f'{pacdef_path}/{group}', 'w') as file:
                for domain, packages in packages_by_domain.items():
                    replacement = '[{}]\n{}\n'.format(domain, "\n".join(packages))
                    file.write(re.sub(fr'\[{domain}\]', replacement, content))


        break
    elif option == 'n':
        break
    else:
        print('invalid option')

