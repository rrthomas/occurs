# configure.ac
#
# Copyright (c) 2009-2022 Reuben Thomas

# Initialise autoconf and automake
AC_INIT([occurs],[0.592],[rrt@sc3d.org])
AM_INIT_AUTOMAKE([-Wall -Werror std-options foreign])

# Checks for programs
gl_EARLY
AM_PROG_CC_C_O
PKG_PROG_PKG_CONFIG
AX_CHECK_GNU_MAKE(,[AC_MSG_WARN([GNU make is required to build from Vala sources])])

# Vala
AM_PROG_VALAC(0.52,,[AC_MSG_WARN([valac not found or too old: cannot compile Vala sources])])
PKG_CHECK_MODULES(GLIB, [glib-2.0 gobject-2.0 gio-2.0 gee-0.8])

# Initialize gnulib
gl_INIT

# Generate output
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_FILES([Makefile])
AC_OUTPUT
