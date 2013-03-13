#!/bin/sh
# occurs
# Count number of occurrences of words in a file
# Reuben Thomas   18/2/98, 13/3/13

# Doug McIlroy's solution:
# tr -cs A-Za-z '\n' | tr A-Z a-z | sort | uniq -c | sort -rn | sed ${1}q 

# Suggestion from Underhanded C contest 2006:
# tr "[:space:]" "[\n*]" | sort | awk 'length($0)>0' | uniq -c

# Until tr is fixed to work with multibyte encodings, this won't work properly
tr [:upper:] [:lower:] < $1 | tr -cs [:alpha:] '\n' | grep [[:print:]] | sort | uniq -c | sort
