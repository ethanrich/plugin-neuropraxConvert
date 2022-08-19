/*

Copyright (C) 2008-2020 Michele Martone

This file is part of librsb.

librsb is free software; you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

librsb is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
License for more details.

You should have received a copy of the GNU Lesser General Public
License along with librsb; see the file COPYING.
If not, see <http://www.gnu.org/licenses/>.

*/
/* This header file is not intended to be included librsb programs: it is only for inspection. */
#ifndef RSB_CONFIG_H_INCLUDED
#define RSB_CONFIG_H_INCLUDED
/* rsb-config.h.  Generated from rsb-config.h.in by configure.  */
/* rsb-config.h.in.  Generated from configure.ac by autoheader.  */

/* Define if building universal (internal helper macro) */
/* #undef AC_APPLE_UNIVERSAL_BUILD */

/* C compiler. */
#define RSB_CC "x86_64-w64-mingw32-gcc"

/* Compilation flags. */
#define RSB_CFLAGS "-g -O2 -D__USE_MINGW_ANSI_STDIO=1 -fopenmp -std=c99"

/* */
#define RSB_COPYRIGHT_STRING "Copyright (c) 2008-2021 Michele Martone"

/* Define to 1 if you have the <assert.h> header file. */
#define RSB_HAVE_ASSERT_H 1

/* Define to 1 if you have the <complex.h> header file. */
#define RSB_HAVE_COMPLEX_H 1

/* Define to 1 if you have the <ctype.h> header file. */
#define RSB_HAVE_CTYPE_H 1

/* Define to 1 if you have the <dlfcn.h> header file. */
/* #undef HAVE_DLFCN_H */

/* Define to 1 if you have the <dmalloc.h> header file. */
/* #undef HAVE_DMALLOC_H */

/* Define to 1 if you don't have `vprintf' but do have `_doprnt.' */
/* #undef HAVE_DOPRNT */

/* Define to 1 if you have the `dup' function. */
#define RSB_HAVE_DUP 1

/* fileno(): C FILE to posix file descriptor. */
#define RSB_HAVE_FILENO 1

/* Define to 1 if you have the `fread' function. */
#define RSB_HAVE_FREAD 1

/* Define to 1 if you have the `fwrite' function. */
#define RSB_HAVE_FWRITE 1

/* Get an environment variable. */
#define RSB_HAVE_GETENV 1

/* If present, will give us host name. */
/* #undef HAVE_GETHOSTNAME */

/* Define to 1 if you have the <getopt.h> header file. */
#define RSB_HAVE_GETOPT_H 1

/* getopt_long is GNU candy */
#define RSB_HAVE_GETOPT_LONG 1

/* gettimeofday */
#define RSB_HAVE_GETTIMEOFDAY 1

/* Define to 1 if you have the <gsl/gsl_sort.h> header file. */
#define RSB_HAVE_GSL_GSL_SORT_H 1

/* Define to 1 if you have the <hwloc.h> header file. */
/* #undef HAVE_HWLOC_H */

/* Define to 1 if you have the <inttypes.h> header file. */
#define RSB_HAVE_INTTYPES_H 1

/* Define to 1 if you have the `isatty' function. */
#define RSB_HAVE_ISATTY 1

/* Define to 1 if you have the <libgen.h> header file. */
#define RSB_HAVE_LIBGEN_H 1

/* Define to 1 if you have the <limits.h> header file. */
#define RSB_HAVE_LIMITS_H 1

/* Define to 1 if you have the <malloc.h> header file. */
#define RSB_HAVE_MALLOC_H 1

/* Define to 1 if you have the <math.h> header file. */
#define RSB_HAVE_MATH_H 1

/* This function is obsolete. */
/* #undef HAVE_MEMALIGN */

/* Define to 1 if you have the <memory.h> header file. */
#define RSB_HAVE_MEMORY_H 1

/* Define to 1 if you have the `memset' function. */
#define RSB_HAVE_MEMSET 1

/* If present, the mlockall function makes all allocations memory resident. */
/* #undef HAVE_MLOCKALL */

/* Define to 1 if you have the <omp.h> header file. */
#define RSB_HAVE_OMP_H 1

/* Define to 1 if you have the <oski/oski.h> header file. */
/* #undef HAVE_OSKI_OSKI_H */

/* Define to 1 if you have the <papi.h> header file. */
/* #undef HAVE_PAPI_H */

/* The POSIX aligned memory allocator.(The function posix_memalign() is
   available since glibc 2.1.91) */
/* #undef HAVE_POSIX_MEMALIGN */

/* Define to 1 if you have the <pthread.h> header file. */
#define RSB_HAVE_PTHREAD_H 1

/* Define to 1 if you have the `rand' function. */
#define RSB_HAVE_RAND 1

/* Define to 1 if you have the <regex.h> header file. */
/* #undef HAVE_REGEX_H */

/* Define to 1 if you have the <rpc/xdr.h> header file. */
/* #undef HAVE_RPC_XDR_H */

/* Define to 1 if you have the `sched_getaffinity' function. */
/* #undef HAVE_SCHED_GETAFFINITY */

/* Define to 1 if you have the <sched.h> header file. */
#define RSB_HAVE_SCHED_H 1

/* setenv */
/* #undef HAVE_SETENV */

/* Define to 1 if you have the <signal.h> header file. */
#define RSB_HAVE_SIGNAL_H 1

/* Define to 1 if you have the <stdarg.h> header file. */
#define RSB_HAVE_STDARG_H 1

/* Define to 1 if you have the <stdint.h> header file. */
#define RSB_HAVE_STDINT_H 1

/* Define to 1 if you have the <stdio.h> header file. */
#define RSB_HAVE_STDIO_H 1

/* Define to 1 if you have the <stdlib.h> header file. */
#define RSB_HAVE_STDLIB_H 1

/* Define to 1 if you have the <strings.h> header file. */
#define RSB_HAVE_STRINGS_H 1

/* Define to 1 if you have the <string.h> header file. */
#define RSB_HAVE_STRING_H 1

/* Define to 1 if you have the `strncmp' function. */
#define RSB_HAVE_STRNCMP 1

/* If present, the sysconf function gives lots of system info. */
/* #undef HAVE_SYSCONF */

/* Define to 1 if you have the <sys/mman.h> header file. */
/* #undef HAVE_SYS_MMAN_H */

/* Define to 1 if you have the <sys/resource.h> header file. */
/* #undef HAVE_SYS_RESOURCE_H */

/* Define to 1 if you have the <sys/stat.h> header file. */
#define RSB_HAVE_SYS_STAT_H 1

/* Define to 1 if you have the <sys/systemcfg.h> header file. */
/* #undef HAVE_SYS_SYSTEMCFG_H */

/* Define to 1 if you have the <sys/types.h> header file. */
#define RSB_HAVE_SYS_TYPES_H 1

/* Define to 1 if you have the <sys/utsname.h> header file. */
/* #undef HAVE_SYS_UTSNAME_H */

/* times */
/* #undef HAVE_TIMES */

/* Define to 1 if you have the <times.h> header file. */
/* #undef HAVE_TIMES_H */

/* Define to 1 if you have the <time.h> header file. */
#define RSB_HAVE_TIME_H 1

/* Define to 1 if you have the <unistd.h> header file. */
#define RSB_HAVE_UNISTD_H 1

/* Define to 1 if you have the `vprintf' function. */
#define RSB_HAVE_VPRINTF 1

/* Define to 1 if you have the <zlib.h> header file. */
#define RSB_HAVE_ZLIB_H 1

/* Define to the sub-directory where libtool stores uninstalled libraries. */
#define RSB_LT_OBJDIR ".libs/"

/* OSKI path to installed lua modules. User set OSKI_LUA_PATH environment
   variable at runtime will override this one, however. */
/* #undef OSKI_LUA_PATH */

/* Name of package */
#define RSB_PACKAGE "librsb"

/* Define to the address where bug reports for this package should be sent. */
#define RSB_PACKAGE_BUGREPORT "michelemartone_AT_users_DOT_sourceforge_DOT_net"

/* Define to the full name of this package. */
#define RSB_PACKAGE_NAME "librsb"

/* Define to the full name and version of this package. */
#define RSB_PACKAGE_STRING "librsb 1.2.0.11"

/* Define to the one symbol short name of this package. */
#define RSB_PACKAGE_TARNAME "librsb"

/* Define to the home page for this package. */
#define RSB_PACKAGE_URL ""

/* Define to the version of this package. */
#define RSB_PACKAGE_VERSION "1.2.0.11"

/* Extra (undocumented) developer oriented control switches. */
/* #undef RSB_ALLOW_INTERNAL_GETENVS */

/* If set, the library will use smaller indices in blocks. */
#define RSB_BLOCK_SMALL_INDICES 1

/* Maximal number of supported threads (default 160). */
#define RSB_CONST_MAX_SUPPORTED_THREADS 160

/* If not null, the library will rely on this for memory hierarchy info,
   unless RSB_USER_SET_MEM_HIERARCHY_INFO is set. */
#define RSB_DETECTED_MEM_HIERARCHY_INFO "L3:16/64/32768K,L2:8/64/512K,L1:8/64/32K"

/* If defined, will not account for internally used memory. */
#define RSB_DISABLE_ALLOCATOR_WRAPPER 1

/* Performance Application Programming Interface. */
/* #undef RSB_HAVE_PAPI */

/* Inner error verbosity (internal debug level). */
#define RSB_INT_ERR_VERBOSITY 0

/* Error verbosity (often known as debug level). */
#define RSB_OUT_ERR_VERBOSITY 0

/* If set, sort operations will happen in place. */
#define RSB_SORT_IN_PLACE 0

/* If not null, the library will rely on this for memory hierarchy info. */
#define RSB_USER_SET_MEM_HIERARCHY_INFO ""

/* If undefined, NDEBUG will be defined. */
/* #undef RSB_USE_ASSERT */

/* experimental. */
#define RSB_WANT_ACTION_SIGNAL 1

/* If 1, will allow the user to set hard limits to the memory allocated by
   librsb. Trespass attempts will fail. */
#define RSB_WANT_ALLOCATOR_LIMITS 0

/* */
#define RSB_WANT_DMALLOC 0

/* On some architectures (notably modern Intel), floating point computations
   on non double aligned data make loose some clock cycle. */
#define RSB_WANT_DOUBLE_ALIGNED 1

/* Supported input/output functionality. */
#define RSB_WANT_IO_LEVEL 7

/* If set, RSB_WANT_KERNELS_DEBUG will enable comparative consistency checking
   of the multiplying kernels against a naive, trusted implementation. */
#define RSB_WANT_KERNELS_DEBUG 1

/* Enabling collection of time statistics in librsb operations (this
   introduces an overhead). */
/* #undef RSB_WANT_LIBRSB_STATS */

/* Looping kernels. */
/* #undef RSB_WANT_LOOPING_KERNELS */

/* No MKL support wanted in the benchmarking program. */
#define RSB_WANT_MKL 0

/* Support for reading matrices in parallel (Experimental, untested). */
#define RSB_WANT_OMPIO_SUPPORT 0

/* Recursive kernels parallelized with OpenMP. */
#define RSB_WANT_OMP_RECURSIVE_KERNELS 1

/* OSKI comparative benchmarking. */
/* #undef RSB_WANT_OSKI_BENCHMARKING */

/* Performance Counters. */
/* #undef RSB_WANT_PERFORMANCE_COUNTERS */

/* Enabling experimental RSB_NUM_THREADS environment variable. */
/* #undef RSB_WANT_RSB_NUM_THREADS */

/* If set, a reference, unoptimized Sparse BLAS Level 1 interface will be
   functional. */
#define RSB_WANT_SPARSE_BLAS_LEVEL_1 1

/* If set, the library will be much more verbose. Should be enabled for
   debugging purposes only. */
#define RSB_WANT_VERBOSE_MESSAGES 0

/* experimental. */
#define RSB_WANT_XDR_SUPPORT 0

/* Support for reading gzipped matrices. */
#define RSB_WANT_ZLIB_SUPPORT 0

/* HWLOC API support. */
#define RSB_WITH_HWLOC 0

/* LIKWID marker API support. */
#define RSB_WITH_LIKWID 0

/* Sparse BLAS interface compilation. */
/* #undef RSB_WITH_SPARSE_BLAS_INTERFACE */

/* The size of `char', as computed by sizeof. */
#define RSB_SIZEOF_CHAR 1

/* The size of `complex', as computed by sizeof. */
#define RSB_SIZEOF_COMPLEX 0

/* The size of `double', as computed by sizeof. */
#define RSB_SIZEOF_DOUBLE 8

/* The size of `double complex', as computed by sizeof. */
#define RSB_SIZEOF_DOUBLE_COMPLEX 0

/* The size of `float', as computed by sizeof. */
#define RSB_SIZEOF_FLOAT 4

/* The size of `float complex', as computed by sizeof. */
#define RSB_SIZEOF_FLOAT_COMPLEX 0

/* The size of `int', as computed by sizeof. */
#define RSB_SIZEOF_INT 4

/* The size of `long', as computed by sizeof. */
#define RSB_SIZEOF_LONG 4

/* The size of `long double', as computed by sizeof. */
#define RSB_SIZEOF_LONG_DOUBLE 16

/* The size of `long int', as computed by sizeof. */
#define RSB_SIZEOF_LONG_INT 4

/* The size of `long long int', as computed by sizeof. */
#define RSB_SIZEOF_LONG_LONG_INT 8

/* The size of `short int', as computed by sizeof. */
#define RSB_SIZEOF_SHORT_INT 2

/* The size of `size_t', as computed by sizeof. */
#define RSB_SIZEOF_SIZE_T 8

/* The size of `void *', as computed by sizeof. */
#define RSB_SIZEOF_VOID_P 8

/* Define to 1 if you have the ANSI C header files. */
#define RSB_STDC_HEADERS 1

/* SVN REVISION */
#define RSB_SVN_REVISION "Unversioned directory"

/* Version number of package */
#define RSB_VERSION "1.2.0.11"

/* Define WORDS_BIGENDIAN to 1 if your processor stores words with the most
   significant byte first (like Motorola and SPARC, unlike Intel). */
#if defined AC_APPLE_UNIVERSAL_BUILD
# if defined __BIG_ENDIAN__
#  define WORDS_BIGENDIAN 1
# endif
#else
# ifndef WORDS_BIGENDIAN
/* #  undef WORDS_BIGENDIAN */
# endif
#endif

/* Define to empty if `const' does not conform to ANSI C. */
/* #undef const */

/* Define to `__inline__' or `__inline' if that's what the C compiler
   calls it, or to nothing if 'inline' is not supported under any name.  */
#ifndef __cplusplus
/* #undef inline */
#endif

/* Define to the equivalent of the C99 'restrict' keyword, or to
   nothing if this is not supported.  Do not define if restrict is
   supported directly.  */
#define RSB_restrict __restrict
/* Work around a bug in Sun C++: it does not support _Restrict or
   __restrict__, even though the corresponding Sun C compiler ends up with
   "#define restrict _Restrict" or "#define restrict __restrict__" in the
   previous line.  Perhaps some future version of Sun C++ will work with
   restrict; if so, hopefully it defines __RESTRICT like Sun C does.  */
#if defined __SUNPRO_CC && !defined __RESTRICT
# define _Restrict
# define __restrict__
#endif

/* Define to `unsigned int' if <sys/types.h> does not define. */
/* #undef size_t */
#endif /* RSB_CONFIG_H_INCLUDED */
