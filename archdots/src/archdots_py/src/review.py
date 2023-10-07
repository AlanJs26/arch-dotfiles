import subprocess
import tty, termios, sys
import re
from rich import print

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

def filter_truthy(items):
    return list(filter(lambda _:_, items))


with open('/home/alan/.config/pacdef/groups/bspwm') as file:
    content = file.read()

group_types = re.findall(r'\[.+?\]', content)
group_contents = filter_truthy(
    [filter_truthy(item.split('\n')) for item in re.split(r'\[.+?\]', content)]
)

group_dict = {k:v for k,v in zip(group_types, group_contents)}

print(group_dict)
# print(content)

# alan = getchar()

# alan = gum_choose(command='pacdef group list')

# print(f'output: {alan}')
