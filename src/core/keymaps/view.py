#!/usr/bin/env python2
# encoding: utf-8

import dialog
from src.core.keymaps import keymaps
from src.core import env

KEYMAP_PATH = "/usr/share/kbd/keymaps/"

def choose_arch_layout(dialog, arch_layouts):
    keys = sorted(arch_layouts.keys(), key=lambda x : x[0])
    choices = []
    for (n,(arch,layout)) in enumerate(keys):
        choices.append((str(n+1).zfill(2), "%s/%s"%(arch, layout) if layout else arch))
    while True:
        (code, selected) = dialog.menu(
                _("First of all, we need to configure your keyboard "
                "layout. Choose your architecture/layout:"),
            title=_("Keyboard Layout"),
            choices=choices,
            width=40,
            height=25,
            menu_height=20,
            )
        if code in (dialog.DIALOG_CANCEL, dialog.DIALOG_ESC):
            if dialog.yesno(_("Are you sure you want to go back?")) != dialog.DIALOG_OK:
                continue
            return None
        return keys[int(selected)-1]

def choose_keymap(dialog, keymaps):
    keymaps.sort()
    choices = [(str(n+1).zfill(2), keymap.split(".map.gz")[0]) for n,keymap in enumerate(keymaps)]
    
    while True:
        (code, selected) = dialog.menu(
                _("Now please select a keymap:"),
            title=_("Keyboard Layout"),
            choices=choices,
            height=25,
            menu_height=20,
            width=40,
            )
        if code in (dialog.DIALOG_CANCEL, dialog.DIALOG_ESC):
            return None
        return keymaps[int(selected) - 1]
    
def layout_is_ok(dialog):
    (code, text) = dialog.inputbox(_("Please, test your keyboard layout:"),
            title=_("Keyboard Layout"),
            ok_label=_("It's Okay!"),
            cancel=_("I need to change"),
            width=50,
            )
    return code not in (dialog.DIALOG_CANCEL, dialog.DIALOG_ESC)

def run(dialog):
    global _
    global KEYMAP_PATH
    _ = env._
    d= dialog
    
    if env.TEST:
        KEYMAP_PATH = "./test/usr/share/kbd/keymaps/"

    arch_layouts = keymaps.list_layouts(KEYMAP_PATH)
    if layout_is_ok(dialog):
        return

    while True:
        key = choose_arch_layout(dialog, arch_layouts)
        if key is None:
            break
        keym = choose_keymap(dialog, arch_layouts[key])
        if keym is None:
            continue
        
        if not keymaps.set_keymap(KEYMAP_PATH, key[0], key[1], keym):
            if key[1] is None:
                keym = key[0]+"/"+keym
            else:
                keym = key[0]+"/"+key[1]+"/"+keym

            dialog.msgbox(
                    _("Error while trying to set the keymap: %s")%keym,
                   title=_("Error"),
                   )
            continue

        if layout_is_ok(dialog):
            break
    print "Done"
    


