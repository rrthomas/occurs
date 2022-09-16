import os
import system
import argparse
import re
import logging
import strformat
import std/tables


const progName = "occurs" # FIXME: allow newParser to take a variable, then use: lastPathPart(getAppFilename())

# Error messages
var logger = newConsoleLogger(fmtStr = &"{progName}: ")
addHandler(logger)
proc die(s: string) =
  warn(s)
  quit(1)

# Command-line arguments
var p = newParser(progName):
  help("Count the occurrences of each symbol in input.")
  option("-s", "--symbol", default = "\\p{L}+",
         help = "symbols are given by the regexp SYMBOL")
  flag("-n", "--nocount",
         help = "don't show the frequencies or total")
  flag("-V", "--version",
       help = "show program's version number and exit")
  arg("file", nargs = -1)
  nohelpflag()
  flag("-h", "--help", help = "show this help") # FIXME: downcase help message for --help

try:
  let opts = p.parse()
  if opts.help:
    echo """

The default symbol type is words (-s "\p{L}+"); other useful settings
include:

  non-white-space characters: -s "\S+"
  alphanumerics and underscores: -s "\w+"
  XML tags: -s "<([a-zA-Z_:][a-zA-Z_:.0-9-]*)[\s>]""""
    quit(0)
  if opts.version:
    echo &"{progName} 0.11 (16 Sep 2022) by Reuben Thomas <rrt@sc3d.org>"
    quit(0)

  # Compile symbol-matching regexp
  let pattern = re(opts.symbol)

  # Process input
  var freq = initOrderedTable[string, int]()
  for f in opts.file #[or ['-']]#:
    for line in f.lines:
      for s in findAll(line, pattern):
        if s notin freq:
          freq[s] = 0
        freq[s] += 1

  # Write output
  var symbols = 0
  for s, f in pairs(freq):
    let freq_output = if opts.nocount: "" else: &" {f}"
    echo &"{s}{freq_output}"
    symbols += 1
  if not opts.nocount:
    warn(&"total symbols: {symbols}")

except: die(getCurrentExceptionMsg())
