#!/usr/bin/env python2
# encoding: utf-8

import gettext

_ = None
TEST = False

def load_language(language):
    lang = gettext.translation('Anarchy', './locale', languages=[language], fallback=True)
    lang.install()
    global _
    _ = lang.gettext
    return _

def set_test(flag=True):
    global TEST
    TEST = flag
