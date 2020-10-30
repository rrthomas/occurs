// occurs
// Counts the number of occurrences of each symbol in a text file
// Reuben Thomas (rrt@sc3d.org)


// FIXME: Cope with wide character encodings.

using Config;
using Posix;

string? get_symbol(Posix.Regex re, ref string line) {
	Posix.RegexMatch match[1];
	if (re.exec(line, match, 0) != 0)
		return null;
	string ret = line[match[0].so : match[0].eo];
	line = line.substring(match[0].eo);
	return ret;
}

/* Print help and exit */
void help() {
	Posix.stderr.printf(
		PACKAGE_NAME + " " + VERSION + " by Reuben Thomas (" + PACKAGE_BUGREPORT + ")\n" +
		"Counts the number of occurrences of each symbol in a file\n" +
		"\n" +
		"The default symbol type is words (-s \"([[:alpha:]]+)\"); other useful settings\n" +
		"include:\n" +
		"\n" +
		"   non-white-space characters: -s \"[^[:space:]]+\"\n" +
		"   alphanumerics and underscores: -s \"[[:alnum:]_]+\"\n" +
		"   XML tags: -s \"<([a-zA-Z_:][a-zA-Z_:.0-9-]*)[[:space:]>]\"\n" +
		"\n" +
		"Options:\n" +
		"\n" +
		"  -s, --symbol=REGEXP      symbols are given by REGEXP\n" +
		"  -n, --nocount            don't show the frequencies or total\n" +
		"      --help               display this help, then exit\n" +
		"      --version            display version information, then exit\n"
		);

	exit(EXIT_SUCCESS);
}


bool nocounts = false;
string symbol_arg;

/* Parse the command-line options; return the number of the first non-option
   argument */
int getopts(string[] args) {
	/* Options table */
	GetoptLong.Option longopts[] = {
		{ "nocount", GetoptLong.none, null, 'n' },
		{ "symbol",  GetoptLong.required, null, 's' },
		{ "help",    GetoptLong.none, null, 'h' },
		{ "version", GetoptLong.none, null, 'V' },
		{ null, 0, null, 0 }
	};

	int this_optind = optind != 0 ? optind : 1;
	int opt = GetoptLong.getopt_long(args, ":ns:hV", longopts, null);
	if (opt == 'n')
		nocounts = false;
	else if (opt == 's')
		symbol_arg = optarg;
	else if (opt == 'h')
		help();
	else if (opt == 'V') {
		Posix.stdout.printf (PACKAGE_NAME + " " + VERSION + "\n");
		exit(EXIT_SUCCESS);
	} else if (opt == ':')
		error(EXIT_FAILURE, errno, "option '%s' requires an argument", args[this_optind]);
	else if (opt == '?')
		error(EXIT_FAILURE, errno, "unrecognised option '%s'\nTry '%s --help' for more information.", args[this_optind], PACKAGE_NAME);

	return optind;
}

int main(string[] args) {
	GLib.Log.set_always_fatal (LEVEL_CRITICAL);
	Intl.setlocale(ALL, "");

	// Process command-line options
	symbol_arg = "[[:alpha:]]+";
	int first_arg = getopts(args);

	// Compile regex
	var re = Posix.Regex();
	int err = re.comp(symbol_arg, Posix.RegexCompileFlags.EXTENDED);
	if (err != 0)
		error(EXIT_FAILURE, errno, "%s", re.error(err));

	// Process input
	var hash = new Gee.HashMap<string, size_t?>();
	for (int i = first_arg; i <= args.length; i++) {
		if (i < args.length && args[i] != "-") {
			Posix.stdin.reopen(args[i], "r");
			if (Posix.stdin == null)
				error(EXIT_FAILURE, errno, "cannot open %s", quote(args[i]));
		}
		for (string? line = null; (line = GLib.stdin.read_line()) != null; ) {
			string? symbol = null;
			while ((symbol = get_symbol(re, ref line)) != null)
				if (hash.has_key(symbol))
					hash.@set(symbol, hash.@get(symbol) + 1);
				else
					hash.@set(symbol, 1);
		}
	}
	Posix.stdin.close();

	// Print out symbol data
	size_t symbols = 0;
	foreach (string symbol in hash.keys) {
		Posix.stdout.printf("%s", symbol);
		if (!nocounts)
			Posix.stdout.printf(" %zu", hash.@get(symbol));
		Posix.stdout.putc('\n');
		symbols++;
	}
	if (!nocounts)
		Posix.stderr.printf("Total symbols: %zu\n", symbols);

	return EXIT_SUCCESS;
}
