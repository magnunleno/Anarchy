#!/usr/bin/env python2
# encoding: utf-8

from os import walk
from os import system
from os.path import join


def get_arch_layouts(keymap_path):
    archs = walk(keymap_path).next()[1]

    for arch in archs:
        layouts = walk(join(keymap_path, arch)).next()[1]

        if not layouts:
            yield (arch, None)

        for layout in layouts:
            yield (arch, layout)

def list_layouts(keymap_path):
    keymaps = {}
    for arch, layout in get_arch_layouts(keymap_path):
        files = None
        if layout:
            files = walk(join(keymap_path, arch, layout)).next()[2]
        else:
            files = walk(join(keymap_path, arch)).next()[2]
        files = [fname for fname in files if fname.endswith('.map.gz')]
        if not files:
            continue
        keymaps[(arch, layout)] = files
    return keymaps

def set_keymap(root, arch, layout, keymap):
    ret = None
    if layout is None:
        ret = system("loadkeys "+join(root, arch, keymap))
    else:
        ret = system("loadkeys "+join(root, arch, layout, keymap))
    return ret == 0

# keymapping = list_layouts()
# for key in keymapping:
#     keymaps = None
#     if key[1]:
#         keymaps = map(lambda x : key[0]+"/"+key[1]+": "+x, keymapping[key])
#     else:
#         keymaps = map(lambda x : key[0]+": "+x, keymapping[key])
# 
#     for keymap in keymaps:
#         print keymap
