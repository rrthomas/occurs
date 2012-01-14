// occurs
// Counts the number of occurrences of each symbol in a text file
// Reuben Thomas (rrt@sc3d.org)


// FIXME: Cope with wide character encodings.

#include <config.h>

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <locale.h>
#include <regex.h>
#include "xalloc.h"
#include "hash.h"
#include "error.h"
#include "quote.h"

#include "cmdline.h"


struct gengetopt_args_info args_info;

// Type to hold symbol-frequency pairs
typedef struct freq_symbol {
  char *symbol;
  size_t count;
} *freq_symbol_t;

static size_t
symbolhash(const void *v, size_t n)
{
  return hash_string(((const struct freq_symbol *) v)->symbol, n);
}

static bool
symboleq(const void *v, const void *w)
{
  return strcmp(((const struct freq_symbol *) v)->symbol, ((const struct freq_symbol *) w)->symbol) == 0;
}

static char *
get_symbol(regex_t *re, char *s, char **end)
{
  regmatch_t match[1];
  if (regexec(&re, s, 1, match, 0) != 0)
    return NULL;
  *end = s + match[0].rm_eo;
  return s + match[0].rm_so;
}

int
main(int argc, char *argv[])
{
  setlocale(LC_ALL, "");

  // Process command-line options
  if (cmdline_parser(argc, argv, &args_info) != 0)
    exit(EXIT_FAILURE);
  if (args_info.help_given)
    cmdline_parser_print_help();
  if (args_info.version_given)
    cmdline_parser_print_version();

  // Compile regex
  regex_t re;
  int err = regcomp(&re, args_info.symbol_arg, REG_EXTENDED);
  if (err != 0) {
    size_t errlen = regerror(err, &re, NULL, 0);
    char *errbuf = xmalloc(errlen);
    regerror(err, &re, errbuf, errlen);
    error(EXIT_FAILURE, errno, "%s", errbuf);
  }

  // Process input
  Hash_table *hash = hash_initialize(256, NULL, symbolhash, symboleq, NULL);
  for (unsigned i = 0; i <= args_info.inputs_num; i++) {
    if (i < args_info.inputs_num && strcmp(args_info.inputs[i], "-") != 0) {
      if (!freopen(args_info.inputs[i], "r", stdin))
        error(EXIT_FAILURE, errno, "cannot open %s", quote(args_info.inputs[i]));
    }
    size_t len;
    for (char *line = NULL; getline(&line, &len, stdin) != -1; line = NULL) {
      char *symbol = NULL, *p = line;
      for (char *end; (symbol = get_symbol(&re, p, &end)); p = end) {
        struct freq_symbol fw2 = {symbol, 0};
        // Temporarily insert a NUL to make the symbol a string
        char c = *end;
        *end = '\0';
        freq_symbol_t fw = hash_lookup(hash, &fw2);
        if (fw) {
          fw->count++;
        } else {
          fw = XMALLOC(struct freq_symbol);
          size_t symlen = end - symbol;
          *fw = (struct freq_symbol) {.symbol = xmalloc(symlen + 1), .count = 1};
          strncpy(fw->symbol, symbol, symlen);
          fw->symbol[symlen] = '\0';
          assert(hash_insert(hash, fw));
        }
        *end = c; // Restore the overwritten character
      }
      free(line);
    }
    fclose(stdin);
  }

  // Print out symbol data
  size_t symbols = 0;
  for (freq_symbol_t fw = hash_get_first(hash); fw != NULL; fw = hash_get_next(hash, fw), symbols++) {
    printf("%s", fw->symbol);
    if (!args_info.nocount_given)
      printf(" %zd", fw->count);
    putchar('\n');
  }
  if (!args_info.nocount_given)
    fprintf(stderr, "Total symbols: %zd\n", symbols);

  return EXIT_SUCCESS;
}
