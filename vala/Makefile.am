# Top-level Makefile.am
#
# Copyright (c) 2009-2022 Reuben Thomas

ACLOCAL_AMFLAGS = -I m4

AM_VALAFLAGS = --debug --vapidir=$(srcdir)

bin_PROGRAMS = occurs

EXTRA_DIST = $(VAPIS)

occurs_SOURCES = occurs.vala
occurs_CFLAGS = --include config.h $(GLIB_CFLAGS)
occurs_VALAFLAGS = $(AM_VALAFLAGS) --pkg config --pkg gee-0.8 --pkg posix --pkg gnu
occurs_LDADD = $(LDADD) $(GLIB_LIBS)
VAPIS =	config.vapi

CLOC = cloc

pg100.txt:
	wget https://www.gutenberg.org/ebooks/100.txt.utf-8 -O $@

check-local: pg100.txt occurs
	time ./occurs$(EXEEXT) pg100.txt >/dev/null

loc:
	$(CLOC) --no3 occurs.vala Makefile.am configure.ac
