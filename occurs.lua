#!/usr/bin/env lua
spec = [=[
occurs 0.92
Copyright (c) 2022 Reuben Thomas <rrt@sc3d.org>

Usage: occurs [OPTION...] [FILE...]

Count the occurrences of each symbol in input.

The default symbol type is words (-s "[[:alpha:]]+"); other useful settings
include:

  non-white-space characters: -s "[^[:space:]]+"
  alphanumerics and underscores: -s "[[:alnum:]_]+"
  XML tags: -s "<([a-zA-Z_:][a-zA-Z_:.0-9-]*)[[:space:]>]"

Options:

  -s, --symbol=REGEXP      symbols are given by REGEXP
  -n, --nocount            don't show the frequencies or total
      --help               display this help, then exit
      --version            display version information, then exit
]=]

local std = require "std"
rex_posix = require "rex_posix"

-- Parse command-line args
os.setlocale ("")
local OptionParser = require "std.optparse"
local parser = OptionParser (spec)
_G.arg, opts = parser:parse (_G.arg)
local symbolPat = opts.symbol or "[[:alpha:]]+"

-- Compile symbol-matching regexp
local ok, pattern = pcall (rex_posix.new, symbolPat)
if not ok then
  die (pattern)
end

-- Process input
local freq = {}
std.io.process_files (function (file, number)
                        -- FIXME: make slurp work in pipes
                        for s in rex_posix.gmatch (std.io.slurp (), pattern) do
                          freq[s] = (freq[s] or 0) + 1
                        end
                      end)

-- Write output
local symbols = 0
for s in pairs (freq) do
  std.io.writelines (s .. (opts.nocount and "" or " " .. freq[s]))
  symbols = symbols + 1
end
if not opts.nocount then
  std.io.warn ("total symbols: " .. symbols)
end
