import re

def match(command):
    return ('fatal: detected dubious ownership in repository at' in command.output.lower())


def get_new_command(command):
    match = re.search(r'git config --global --add safe\.directory.+', command.output)
    
    return match and f'{match[0]}; {command.script}'

requires_output = True
