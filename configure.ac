dnl configure.ac
dnl
dnl Copyright (c) 2009, 2011 Reuben Thomas

dnl Initialise autoconf and automake
AC_INIT([occurs],[0.592],[rrt@sc3d.org])
AM_INIT_AUTOMAKE([-Wall -Werror std-options])
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

dnl Set up C compiler
AC_USE_SYSTEM_EXTENSIONS
AC_PROG_CC
gl_EARLY
AM_PROG_CC_C_O

dnl Vala
AM_PROG_VALAC(0.52,,[AC_MSG_WARN([valac not found or too old: cannot compile Vala sources])])
PKG_CHECK_MODULES(GLIB, [glib-2.0 gobject-2.0 gio-2.0 gee-0.8])

gl_WARN_ADD([-Werror], [WERROR_CFLAGS])

dnl GCC warnings
dnl Set up the list of undesired warnings.
nw=
nw="$nw -Wsystem-headers"   # Don’t let system headers trigger warnings
nw="$nw -Wundef"            # All compiler preprocessors support #if UNDEF
nw="$nw -Wtraditional"      # All compilers nowadays support ANSI C
nw="$nw -Wdeclaration-after-statement" # We require C99.
gl_MANYWARN_ALL_GCC([warnings])
dnl Enable all GCC warnings not in this list.
gl_MANYWARN_COMPLEMENT([warnings], [$warnings], [$nw])
for w in $warnings; do
  gl_WARN_ADD([$w])
done
gl_INIT

dnl Generate output
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_FILES(Makefile lib/Makefile)
AC_OUTPUT
