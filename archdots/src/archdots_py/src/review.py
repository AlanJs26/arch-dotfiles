import subprocess
from threading import Thread
import tty, termios, sys
import re
from typing import Literal
from rich import print
from rich.panel import Panel
from rich.table import Table
from rich.console import Console
import yaml
import os

TOptions_history = list[tuple[str,Literal['d', 's']|int]]
TPackages_by_domain = dict[str,set[str]]

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
        return ''
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
    return subprocess.check_output(f"{aur_helper} -Qe|awk '{{ print $1 }}'",shell=True).decode().strip().split('\n')

def get_python_packages():
    return subprocess.check_output("echo -e \"$(pip list --not-required --user)\"|tail -n+3|awk '{ print $1 }'",shell=True).decode().strip().split('\n')

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

def zip_packages(pacdef_packages: TPackages_by_domain, installed_packages: TPackages_by_domain) -> list[tuple[str,str]]:

    intersect_packages = {k:v.difference(pacdef_packages[k]) for k,v in installed_packages.items()}

    zipped_packages = [(domain, package) for (domain, packages) in intersect_packages.items() for package in packages]

    return zipped_packages

def make_option(name:str, color='green'):
    return f'([{color}]{name[0]}[white]){name[1:]}'

def print_options_history(history: dict[str, TOptions_history]):
    option_map = {
        'd': '[red]deleted',
        's': '[yellow]skipped',
    }
    table = Table(show_header=False)
    console = Console()
    
    for domain in history:
        for package, option in history[domain]:
            if option in option_map:
                table.add_row(package, option_map[option])
            elif isinstance(option, int):
                table.add_row(package, '[green]'+pacdef_groups[option])
            elif not option:
                table.add_row(package, '')
            else:
                table.add_row(package, f'unknown option: {option}')
        if len(history) > 1:
            table.add_section()

    console.print(table)

installed_packages:TPackages_by_domain = {
    'arch': set(get_arch_packages()),
    'python': set(),
}

# Get packages on pacdef group files
pacdef_packages:TPackages_by_domain = {}

pacdef_groups_path = os.path.expanduser('~/.config/pacdef/groups')
pacdef_groups = os.listdir(pacdef_groups_path) 

for group in pacdef_groups:
    packages = get_file_packages(f'{pacdef_groups_path}/{group}')
    for domain in packages:
        if domain not in pacdef_packages:
            pacdef_packages[domain] = set()

        pacdef_packages[domain].update(packages[domain])


zipped_packages = zip_packages(pacdef_packages, installed_packages)

# Get python packages assynchronously
def thread_python_packages():
    global installed_packages
    global zipped_packages
    installed_packages['python'] = set(get_python_packages())
    zipped_packages = zip_packages(pacdef_packages, installed_packages)


thread = Thread(target=thread_python_packages)
thread.start()

if(next(filter(lambda item: item[0] == 'arch', zipped_packages), None) == None):
    thread.join()


history:dict[str, TOptions_history] = {}

prev_group = ''
i = 0

while i < len(zipped_packages):

    domain, package = zipped_packages[i]

    if not prev_group or prev_group != domain:
        print(Panel.fit(f'[white]{domain}', style='green'))
        prev_group = domain

    if domain not in history:
        history[domain] = []

    print(f'[white]assign [blue]{package}[white] to {make_option("group")}, {make_option("delete")}, {make_option("skip")}, {make_option("peek")}, {make_option("undo")}, {make_option("quit")}?')
    option = getchar()

    if option == 'g':
        print(', '.join(map((lambda item: f'({item[0]+1}){item[1]}'), enumerate(pacdef_groups))))
        option = getchar()
        if option.isdigit() and int(option) >= 1 and int(option) <= len(pacdef_groups):
            print(f'{package} -> [green]{pacdef_groups[int(option)-1]}')
            history[domain].append((package, int(option)-1))
        else:
            print('invalid option')
            continue

    elif option == 'd':
        print(f'[red]deleted')
        history[domain].append((package, 'd'))
    elif option == 's':
        print('[yellow]skipped')
        history[domain].append((package, 's'))
    elif option == 'p':
        print_options_history(history)
        continue
    elif option == 'u':
        if i > 0:
            i -= 1
            next_domain = zipped_packages[i][0] if i > 0 else domain
            print(next_domain)
            del history[next_domain][i - sum(len(history[_domain]) for _domain in history if next_domain!=_domain)]
        continue

    elif option == 'q':
        os._exit(1)
    else:
        print('invalid option')
        continue

    i+=1

    if i >= len(zipped_packages) and len(installed_packages['python']) == 0:
        thread.join()


print()

for domain, options_history in history.items():
    print(f'[green]{domain}')
print_options_history(history)

while True:
    print(f'Keep changes? {make_option("yes")}/{make_option("no")}')
    option = getchar()

    if option == 'y':
        for domain in ['arch', 'python']:
            if domain in history:
                deleted_packages = list(map(lambda item: item[0], filter(lambda item: item[1] == 'd', history[domain]))) 
                if deleted_packages:
                    if domain == 'arch':
                        os.system(f'{aur_helper} -R {" ".join(deleted_packages)}')
                    elif domain == 'python':
                        os.system(f'pip uninstall --yes {" ".join(deleted_packages)}')

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
            with open(f'{pacdef_groups_path}/{group}', 'r') as file:
                content = file.read()

            with open(f'{pacdef_groups_path}/{group}', 'w') as file:
                for domain, packages in packages_by_domain.items():
                    replacement = '[{}]\n{}\n'.format(domain, "\n".join(packages))
                    file.write(re.sub(fr'\[{domain}\]', replacement, content))

        print('\n[green]Updating pacdef managed packages')

        break
    elif option == 'n':
        print('\n[yellow]Exiting...')
        break
    else:
        print('invalid option')

