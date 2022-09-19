# occurs

© Reuben Thomas 1992–2022  

**This program is a long-term experiment. I currently recommend [grep-syms](https://github.com/rrthomas/grep-syms) for practical use.**

`occurs` finds the number of occurrences of each symbol (where "symbol" can
be defined flexibly enough to be words, identifiers or XML tags), and list
them sorted lexically or by frequency, with or without the frequency and
total number of distinct symbols.

Occurs is implemented in various languages, each in its own subdirectory. Note that some of the language versions currently implement a simpler program, [syms](https://github.com/rrthomas/syms).

## Usage examples

Sort lexically: `occurs "$@" | sort`  
Sort by frequency: `occurs "$@" | sort -n -k 2`  
Unique lines (like uniq, but not just adjacent lines): `occurs -n -s "^(.*)$" "$@"`  
