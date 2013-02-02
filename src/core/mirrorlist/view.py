#!/usr/bin/env python2
# encoding: utf-8

import dialog
from src.core import utils
from src.core.mirrorlist import mirrorlist
from src.core import env

_ = None
MIRRORLIST = "/etc/pacman.d/mirrorlist"
MIRRORLIST_BKP = None
REPOS = []

def welcome(dialog):
    dialog.msgbox(
            _("Nice! Now that we have successfully prepared our Hard Drives, "
            "let's set up out mirrorlist.\n\n I've made a backup of your "
            "mirrorlist file at '%(bkp)s'")%{'bkp':MIRRORLIST_BKP},
           title=_("Mirrolist"),
           width=50,
           height=12)

def choose_country(dialog, mirrors, countries):
    while 1:
        (code, country) = dialog.menu(
                _("I've taken a look at your mirrorlist and found the "
            "following available countries:"),
            choices=[(c, _("Mirrors: %i")%(len(mirrors[c]))) for c in countries],
            height=25,
            menu_height=30,
            title=_("Mirrorlist"),
            )
        if code in (dialog.DIALOG_CANCEL, dialog.DIALOG_ESC):
            if not REPOS:
                dialog.msgbox(_("Please chose at least one mirror!"),
                        title=_("Attention"),
                        )
                continue
            return None
        return country

def check_mirrors_from_country(dialog, mirrors, country):
    mirror_list = mirrors[country]
    cmp = lambda x,y : x.rate > y.rate
    mirror_list.sort(cmp)
    while 1:
        choices = []
        for n,mirror in enumerate(mirror_list):
            choices.append(
                        (str(n+1), _("%(domain)s (Rate: %(rate).1f)")%{
                            "domain":mirror.domain, "rate":mirror.rate},
                        1 if mirror in REPOS else 0,
                        )
                    )

        (code, repos) = dialog.checklist(text=_("Mark your desired mirrors:"),
                #height=15, width=54, list_height=7,
                choices=choices, title=_("Choose your mirrors"),
                list_height=10,
                )
        if code in (dialog.DIALOG_CANCEL, dialog.DIALOG_ESC):
            return None

        if not repos:
            dialog.msgbox(
                    _("Please select at least one mirror."
                    "To choose one mirror press SPACE.\n\n"
                    "To return to the country list select CANCEL."),
                    title=_("Attention"),
                    )
            continue
        else:
            return [mirror_list[int(idx) - 1] for idx in repos]

def run(dialog, repos = []):
    global _
    _ = env._
    global MIRRORLIST

    if env.TEST:
        MIRRORLIST= "./test/mirrorlist"

    global MIRRORLIST_BKP
    global REPOS
    REPOS = repos

    MIRRORLIST_BKP = utils.create_backup(MIRRORLIST)
    welcome(dialog)
 
    mirrors = mirrorlist.scan_mirrorlist(MIRRORLIST)
    countries = mirrors.keys()
    countries.sort()
    while True:
        country = choose_country(dialog, mirrors, countries)
        if (country is None) and REPOS:
            break

        repos = check_mirrors_from_country(dialog, mirrors, country)
        if repos is None:
            continue
        else:
            for repo in repos:
                REPOS.append(repo)
            if dialog.yesno(_("Do you want to choose more mirrors?")) != dialog.DIALOG_OK:
                break

    utils.comment_all_file(MIRRORLIST)
    utils.uncomment_many_lines(MIRRORLIST, [repo.url for repo in REPOS])
    return REPOS
