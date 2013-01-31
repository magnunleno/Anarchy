#!/usr/bin/env python2
# encoding: utf-8

import re
score_re = re.compile("## Score: ([0-9].*?\.[0-9].*?), (.*)");

class Mirror(object):
    '''
    Class taht abstract all mirrorlist procedures
    '''
    __slots__ = (
            "rate",
            "url",
            "domain",
            )
    def __init__(self, rate, url):
        '''
        Create a new instance with the following attributes:
            @rate: A rating grade for this repository.
            @url: The url used for this repository.
            @domain: The domain (parto of the URL) used to identify
                     this repository. The lower, the best.
        '''
        self.rate = rate
        self.url = url
        self.domain = url.split("/")[2]

    def __str__(self):
        '''
        Instance string representation
        '''
        return "%s (%.1f)"%(self.domain, self.rate)

def scan_mirrorlist(fpath):
    '''
    Class method used for searching for repository
        @fpath: The path for the mirrorlist file
        @returns: Dictionary indexing all repositories based on
                  its contry.
    '''
    fd = open(fpath, 'r')
    mirrors = {}

    for line in fd:
        match = score_re.match(line)
        if not match:
            continue
        # Convert the first match gorup for float
        rate = float(match.groups()[0])
        # Convert the second match gorup for the country name
        country = match.groups()[1]
        # Get the next line, remove tailing \n and removes the
        # useless "Server = " string
        url = fd.next().strip().split(' ')[-1]

        if country in mirrors:
            mirrors[country].append(Mirror(rate, url))
        else:
            mirrors[country] = [Mirror(rate, url)]
    fd.close()
    return mirrors

########## For testing purposes ##########
#
# mirrors = scan_mirrorlist("./test/mirrorlist")
# for country in mirrors:
#     print country
#     for mirror in mirrors[country]:
#         print "\t%s"%mirror
