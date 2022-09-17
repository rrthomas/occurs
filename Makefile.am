# Top-level Makefile.am
#
# Copyright (c) 2009, 2011-2012, 2020 Reuben Thomas

SUBDIRS = lib

ACLOCAL_AMFLAGS = -I m4

AM_CPPFLAGS = -I$(top_builddir)/lib -I$(top_srcdir)/lib
AM_CFLAGS = $(WARN_CFLAGS)
LDADD = $(top_builddir)/lib/libgnu.a
AM_VALAFLAGS = --debug --vapidir=$(srcdir)

bin_PROGRAMS = occurs occurs-vala

occurs_LDADD = $(LDADD) $(LIBOBJS)
occurs_SOURCES = occurs.c cmdline.c cmdline.h

cmdline.c: opts.ggo
	gengetopt < opts.ggo --unamed-opts

EXTRA_SRCS = opts.ggo occurs.lua occurs.py occurs.rb occurs.go occurs.sh
EXTRA_DIST = m4/gnulib-cache.m4 $(EXTRA_SRCS) $(VAPIS)

occurs_vala_SOURCES = occurs-vala.vala
occurs_vala_CFLAGS = --include config.h $(WARN_CFLAGS) $(GLIB_CFLAGS)
occurs_vala_VALAFLAGS = $(AM_VALAFLAGS) --pkg config --pkg gee-0.8 --pkg posix --pkg gnu
occurs_vala_LDADD = $(LDADD) $(GLIB_LIBS)
VAPIS =	config.vapi

CLOC = cloc --force-lang="perl",ggo

ChangeLog:
	git2cl > ChangeLog

pg100.txt:
	wget https://www.gutenberg.org/ebooks/100.txt.utf-8 -O $@

check-local: pg100.txt occurs
	time ./occurs$(EXEEXT) pg100.txt >/dev/null

loc:
	$(CLOC) --no3 occurs-vala.vala occurs.c $(EXTRA_SRCS) opts.ggo Makefile.am configure.ac
