# configure.ac
#
# Copyright (c) 2009, 2011 Reuben Thomas

# Initialise autoconf and automake
AC_INIT([occurs],[0.592],[rrt@sc3d.org])
AM_INIT_AUTOMAKE([-Wall -Werror std-options foreign])

# Set up C compiler
AC_USE_SYSTEM_EXTENSIONS
AC_PROG_CC
gl_EARLY
AM_PROG_CC_C_O
gl_WARN_ADD([-Werror], [WERROR_CFLAGS])

# GCC warnings
# Set up the list of undesired warnings.
nw=
nw="$nw -Wsystem-headers"   # Don’t let system headers trigger warnings
gl_MANYWARN_ALL_GCC([warnings])
# Enable all GCC warnings not in this list.
gl_MANYWARN_COMPLEMENT([warnings], [$warnings], [$nw])
for w in $warnings; do
  gl_WARN_ADD([$w])
done
gl_INIT

# Generate output
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_FILES([Makefile lib/Makefile])
AC_OUTPUT
