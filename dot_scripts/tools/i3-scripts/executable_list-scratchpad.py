import i3ipc
import sys
from os import system
from re import sub

args = sys.argv[1:]

numOnScrachpad=0
nameList={}

i3 = i3ipc.Connection()
for leaf in i3.get_tree().scratchpad().leaves():
    numOnScrachpad=numOnScrachpad+1
    nameList[leaf.window_class] = leaf.window_title
    # print(leaf.window_class)
if(len(args)>=1 and args[0] == '--list'):
    print('\n'.join(nameList))
elif(len(args)>=2 and args[0] == '--show' and args[1] in nameList):
    parsedName=sub(r'([\(\)\[\]])', r'\\\\\\\1', nameList[args[1]])
    system(f"i3-msg [title=\\\"{parsedName}\\\"] scratchpad show")
else:
    print(numOnScrachpad)


