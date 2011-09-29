#!/usr/bin/env python3

import sys
import argparse
import locale
import re

# Command-line arguments
parser = argparse.ArgumentParser(prog='occurs',
                                 description='Count the occurrences of each symbol in a file.',
                                 epilog='''
The default symbol type is words (-s "([^\W\d_]+)"); other useful settings
include:

  non-white-space characters: -s "(\S+)"
  alphanumerics and underscores: -s "(\w+)"
  XML tags: -s "<([a-zA-Z_:][a-zA-Z_:.0-9-]*)[\s>]"
''',
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
parser.add_argument('-n', '--nocount', action='store_true',
                    help='don\'t show the frequencies or total')
parser.add_argument('-s', '--symbol', metavar='REGEXP', default='[^\W\d_]+',
                    help='symbols are given by REGEXP')
parser.add_argument('-V', '--version', action='version',
                    version='%(prog)s 0.9 (27 Sep 2011) by Reuben Thomas <rrt@sc3d.org>')
parser.add_argument('file', metavar='FILE', nargs='*')

args = parser.parse_args()

# Set locale
locale.setlocale(locale.LC_ALL, '')

# Compile symbol-matching regexp
try:
    pattern = re.compile(args.symbol, re.LOCALE)
except re.error as err:
    parser.error(err.args[0])

# Process a file
def occurs(h, f):
    freq = {}
    for line in h:
        for s in pattern.findall(line):
            if s in freq:
                freq[s] += 1
            else:
                freq[s] = 1
    if not args.nocount:
        print("{}: {} symbols".format(f, len(freq)), file=sys.stderr)
    for _, s in enumerate(freq):
        print(s, end='')
        if not args.nocount:
            print(' {}'.format(freq[s]), end='')
        print('')

if len(args.file) == 0:
    args.file.append('-')
for i, f in enumerate(args.file):
    h = open(f, 'U') if f != '-' else sys.stdin
    occurs(h, f)
    h.close()
    if i < len(args.file) - 1:
        print('')
