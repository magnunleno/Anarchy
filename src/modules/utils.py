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

def comment_all_file(fname):
    fd = open(fname, 'r')
    lines = fd.readlines()
    fd.close()

    fd = open(fname, 'w')
    for line in lines:
        if line[0] == "#":
            fd.write(line)
        else:
            fd.write("#"+line)
    fd.close()

def uncomment_line(fname, target_line):
    fd = open(fname, 'r')
    lines = fd.readlines()
    fd.close()

    fd = open(fname, 'w')
    for line in lines:
        if target_line in line:
            fd.write(line[1:])
        else:
            fd.write(line)
    fd.close()

# print create_backup("test/mirrorlist")
# print restore_backup("test/mirrorlist.bkp")
# comment_all_file("test/mirrorlist")
# uncomment_line("test/mirrorlist", "Server = http://mirror.us.leaseweb.net/archlinux/$repo/os/$arch")
