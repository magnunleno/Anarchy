#!/usr/bin/env python2
# encoding: utf-8

from os.path import exists
from os.path import abspath
from os.path import isfile
from shutil import copy

def create_backup(fname):
    if (not exists(fname)) or (not isfile(fname)):
        return None
    fname = abspath(fname)
    bkp_fname = fname+".bkp"
    try:
        copy(fname, bkp_fname)
    except IOError:
        bkp_fname = None
    return bkp_fname

def restore_backup(bkp_name):
    if (not exists(bkp_name)) or (not isfile(bkp_name)):
        return None
    bkp_fname = abspath(bkp_name)
    fname = bkp_fname.split('.bkp')[0]
    try:
        copy(bkp_fname, fname)
    except IOError:
        fname = None
    return fname


# print create_backup("README.md.bkp")
# print restore_backup("README.md.bkp")
