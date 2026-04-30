import i3ipc
import re
import os
from functools import reduce
from argparse import RawTextHelpFormatter, ArgumentParser

parser = ArgumentParser(description='a better scratchpad', formatter_class=RawTextHelpFormatter)

parser.add_argument('classname',          action='store', type=str,
                    help='search by class')

parser.add_argument('--title',          action='store', type=str, default='',
                    help="search by title")

parser.add_argument('--command',          action='store', type=str, default='',
                    help="command to run if doesn't match any window")


args = parser.parse_args()

i3 = i3ipc.Connection()

tree = i3.get_tree()
scratchpad = tree.scratchpad()

def matchPattern(leaf, strict=False):
    if strict:
        return re.search(args.classname, leaf.window_class, flags=re.IGNORECASE) and (re.search(args.title, leaf.window_title, flags=re.IGNORECASE if args.title else True ))
    return re.search(args.classname, leaf.window_class, flags=re.IGNORECASE) or (args.title and re.search(args.title, leaf.window_title, flags=re.IGNORECASE))


def reset_ids():
    count = 0
    for leaf in scratchpad.leaves():
        if re.search(args.classname, leaf.window_class):
            leaf.command(f'mark --add {leaf.window_class}{count}')
            print(leaf.marks)
            count+=1

def extract_num(text):
    string_text = re.sub(r'[^0-9]', '', text)

    if not string_text:
        reset_ids()
        return -1

    return int(string_text)

focused_id = -1

if scratchpad.find_marked('focus') and re.search(args.classname, scratchpad.find_marked('focus')[0].window_class, flags=re.IGNORECASE):
    i3.command('[con_mark=focus] scratchpad show')
    exit()

for focused in tree.find_marked('focus'):
    if not re.search(args.classname, focused.window_class, flags=re.IGNORECASE): break
    i3.command('unmark focus')
    focused.command('move scratchpad')
    for mark in focused.marks:
        if focused.window_class in mark:
            focused_id = extract_num(mark)
            break

matched_leafs = [
    (leaf, extract_num(leaf.marks[0]) if leaf.marks else -1)
    for leaf in scratchpad.leaves()
    if matchPattern(leaf)
]


if len(set(matched_leafs)) != len(matched_leafs):
    reset_ids()

    matched_leafs = [
        (leaf, extract_num(leaf.marks[0]) if leaf.marks else -1)
        for leaf in scratchpad.leaves()
        if matchPattern(leaf)
    ]

if not matched_leafs:
    print([matchPattern(leaf, True) for leaf in tree.leaves()+scratchpad.leaves()])
    if not any(matchPattern(leaf, True) for leaf in tree.leaves()+scratchpad.leaves()):
        os.system(args.command)
    exit()

chosen_leaf, chosen_id = reduce(lambda p,n: n if n[1] == focused_id+1 % len(matched_leafs)+1 else p, matched_leafs, matched_leafs[0])

chosen_leaf.command('scratchpad show;mark --add focus')

