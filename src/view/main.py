#!/usr/bin/env python2
# encoding: utf-8

import dialog as Dialog
from os import system

from src.view import mirrorlist
from src import env

# For future implementations
STEPS = {
        #"Set Keyboard Layout" : loadkeys,
        "Select Source" : mirrorlist,
        #"Prepare Hard Drive(s)" : harddrives,
        #"Additional Repositories": repositories,
        #"Extra Packages": extrapkg,
        #"Install System": install,
        #"Configure System" : postinstall,
        }

def welcome(dialog):
    msg = _("This is the Anarchy Project installer v%(version)s, codename "
            "'%(codename)s'.\n\n"
            "We will guide you through the amazing Arch Linux installation "
            "Process.\n\n"
            "Please, read with attention every message, they were written "
            "carefully to guide you and teach you how to install this "
            "distribution.")+\
            "\n\n                         - "+_("The Anarchy Team")

    dialog.msgbox(msg%{"version":"0.2.0", "codename":"Aborto Elétrico"}, 
            title=_("Welcome!"), width=50, height=20)

def choose_language():
    d = Dialog.Dialog(dialog="dialog")
    langs = {
            "English": "en",
            "Português": "pt_BR",
            }

    # Choose language
    while 1:
        (code, lang) = d.menu("Please choose a language:",
            choices=sorted(langs.items(), key=lambda x:x[0]),
            backtitle="Anarchy Project",
            cancel="Exit",
            ok_label="Select",
            )
        if code in (d.DIALOG_CANCEL, d.DIALOG_ESC):
            exit(1)
        break
    return langs[lang]

def run():
    _ = env.load_language(choose_language())
    dialog = Dialog.Dialog(dialog="dialog")
    dialog.add_persistent_args([
        "--backtitle", _("Anarchy Project"),
        "--cancel-label", _("Back"),
        "--ok-label", _("Okay"),
        "--yes-label", _("Yes"),
        "--no-label", _("No"),
        ])

    welcome(dialog)
    # Loadkeys (/usr/share/kbd/keymaps/)
    # Partition
    # makefs
    # mount
    mirrorlist.run(dialog)
    # if 64 bits: Ask for multilib
    # pacstrap base base devel
    # pacstrap grub
    # pacstrap Extra packages
    # genfstab

    # Post installation
    # Hostname
    # vconsole (KEYMAP, FONT and FONT_MAP)
    # Locale (/etc/locale.gen, /etc/local.conf, locale-gen and some exports)
    # Timezone and time
    # networking
    # Build ramdisk
    # Install grub
    # Change password

    system("clear")
