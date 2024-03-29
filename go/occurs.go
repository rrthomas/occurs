///usr/bin/env go run $0 $@ ; exit

package main

import (
	"bufio"
	"flag"
	"fmt"
	"os"
	"regexp"

	"github.com/famz/SetLocale"
)

var progname = "occurs"
var version = "0.92 (03 Oct 2019)"
var author = "Reuben Thomas <rrt@sc3d.org>"

// Command-line arguments
var nocount *bool = flag.Bool("nocount", false, "don't show the frequencies or total")
var symbol *string = flag.String("symbol", "[A-Za-z]+", "symbols are given by REGEXP")
var versionFlag *bool = flag.Bool("version", false, "output version information and exit")
var helpFlag *bool = flag.Bool("help", false, "display this help and exit")

func usage() {
	os.Stderr.WriteString(progname + " " + version + "\n\n" +
		"Count the occurrences of each symbol in a file.\n\n")
	flag.Usage()
	os.Stderr.WriteString("\n" +
		"The default symbol type is words (-s \"[A-Za-z]+\"); other useful settings\n" +
		"include:\n" +
		"\n" +
		"  non-white-space characters: -s \"[ \\t\\n\\f\\v]+\"\n" +
		"  alphanumerics and underscores: -s \"[A-Za-z0-9_]+\"\n" +
		"  XML tags: -s \"<([a-zA-Z_:][a-zA-Z_:.0-9-]*)[\\s>]\"\n")
}

func showVersion() {
	os.Stderr.WriteString(progname + " " + version + " " + author + "\n")
}

func main() {
	defer func() {
		if r := recover(); r != nil {
			fmt.Fprintf(os.Stderr, "%s: %s\n", progname, r)
			os.Exit(1)
		}
	}()

	SetLocale.SetLocale(SetLocale.LC_ALL, "")

	// Parse command-line args
	flag.Parse()
	if *versionFlag {
		showVersion()
		os.Exit(0)
	}
	if *helpFlag {
		usage()
		os.Exit(0)
	}

	// Compile symbol-matching regexp
	pattern, err := regexp.Compile(*symbol)
	if err != nil {
		panic(err)
	}

	// Process input
	symbols := 0
	freq := make(map[string]int)
	args := flag.Args()
	if flag.NArg() == 0 {
		args = append(args, "-")
	}
	for i := range args {
		var h *os.File
		f := args[i]
		if f != "-" {
			var err error
			h, err = os.Open(f)
			if err != nil {
				panic(err)
			}
		} else {
			h = os.Stdin
		}

		// Read file into symbol table
		scanner := bufio.NewScanner(h)
		for scanner.Scan() {
			syms := pattern.FindAllStringSubmatch(scanner.Text(), -1)
			for _, matches := range syms {
				s := string(matches[1])
				if freq[s] == 0 {
					symbols++
				}
				freq[s] += 1
			}
		}
		h.Close()
	}

	// Print out symbol data
	for s, _ := range freq {
		fmt.Print(s)
		if !*nocount {
			fmt.Printf(" %d", freq[s])
		}
		fmt.Print("\n")
	}
	if !*nocount {
		fmt.Fprintf(os.Stderr, "Total symbols: %d\n", symbols)
	}
}
