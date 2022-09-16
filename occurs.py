#!/usr/bin/env python3

import os
import sys
import argparse
import locale
import re
import fileinput
from collections import Counter

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
parser.add_argument('-s', '--symbol', metavar='REGEXP', type=os.fsencode, default='[^\W\d_]+',
                    help='symbols are given by REGEXP')
parser.add_argument('-V', '--version', action='version',
                    version='%(prog)s 0.92 (16 Sep 2022) by Reuben Thomas <rrt@sc3d.org>')
parser.add_argument('file', metavar='FILE', nargs='*')

args = parser.parse_args()

# Set locale
locale.setlocale(locale.LC_ALL, '')

# Compile symbol-matching regexp
try:
    pattern = re.compile(args.symbol, re.LOCALE)
except re.error as err:
    parser.error(err.args[0])

# Process input
freq = Counter()
for line in fileinput.input(mode='rb', files=args.file or ['-']):
    freq.update(pattern.findall(line))

# Write output
for s in freq:
    sys.stdout.buffer.write(s + (b'' if args.nocount else b' ' + bytes(str(freq[s]), 'utf-8')) + b'\n')
if not args.nocount:
    sys.stdout.flush()
    print(f"Total symbols: {len(freq)}", file=sys.stderr)
