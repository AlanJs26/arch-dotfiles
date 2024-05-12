#!/usr/bin/env python3
#
# Promotes the focused window by swapping it with the largest window.

from i3ipc import Connection, Event
from sys import argv
import os

args = argv[1:]

def find_biggest_window (container):
    max_leaf = None
    max_area = 0
    focused_max_area = 0
    for leaf in container.leaves():
        rect = leaf.rect
        area = rect.width * rect.height
        if not leaf.focused and area > max_area:
            max_area = area
            max_leaf = leaf
        elif leaf.focused:
            focused_max_area = area
    if focused_max_area >= max_area:
        os.system('/home/alan/miniconda3/bin/python /home/alan/Documentos/tools/promote-window-lib/focus-last.py --switch')
        return False
    return max_leaf

i3 = Connection()

for reply in i3.get_workspaces():
    if reply.focused:
        workspace = i3.get_tree().find_by_id(reply.ipc_data["id"])
        biggest_window = find_biggest_window(workspace)
        if biggest_window != False:
            master = biggest_window 
            if len(args) and args[0] == '--switch':
                i3.command("swap container with con_id %s" % master.id)
            else:
                i3.command(f"[con_id={master.id}]focus")
