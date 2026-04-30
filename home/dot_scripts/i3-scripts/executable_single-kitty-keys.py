import os
import i3ipc
import sys

args = sys.argv[1:]
if len(args) > 3 or len(args) < 2:
    print('invalid arguments')
    exit()

classname=args[0]
keys=args[1]
timeout = args[2] if len(args) == 3 else 3

foundClass=False

i3 = i3ipc.Connection()
tree = i3.get_tree()

allMatchedWindows = tree.find_classed(classname) 

launchCommand = f'kitty --listen-on unix:/tmp/mykitty --class {classname} --title {classname}a &'
launchCommand2 = f'kitty @ launch --type os-window --title {classname}a --os-window-class {classname}'
runCommand = f'kitty @ --to unix:/tmp/mykitty send-text --match title:^{classname}a$ "{keys}"'
if len(allMatchedWindows)>0:
    os.system(runCommand)
else:
    os.system(launchCommand)
    os.system(f"sleep {timeout}&&"+runCommand)
    # os.system(f'kitty @ send-text --match title:^{classname}a$ "{keys}"')
