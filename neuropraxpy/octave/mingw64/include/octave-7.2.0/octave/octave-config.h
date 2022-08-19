// DO NOT EDIT!  Generated by mk-octave-config-h.sh.

////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2016-2022 The Octave Project Developers
//
// See the file COPYRIGHT.md in the top-level directory of this
// distribution or <https://octave.org/copyright/>.
//
// This file is part of Octave.
//
// Octave is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Octave is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Octave; see the file COPYING.  If not, see
// <https://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////

// All Octave source files should begin with
//
//   #if defined (HAVE_CONFIG_H)
//   #  include "config.h"
//   #endif
//
// All public Octave header files should have the form
//
//   #if ! defined (INCLUSION_GUARD_SYMBOL)
//   #define INCLUSION_GUARD_SYMBOL 1
//
//   #include "octave-config.h"
//
//   ... Contents of header file ...
//
//   #endif

// In Octave source files, INCLUSION_GUARD_SYMBOL should have the form
//
//   octave_NAME_h
//
// with NAME formed from the header file name with '-' replaced by '_'.
//
// It is safe to include octave-config.h unconditionally since it will
// expand to an empty file if it is included after Octave's
// autoconf-generated config.h file.
//
// Users of Octave's libraries should not need to include octave-config.h
// since all of Octave's header files already include it.

#if ! defined (octave_octave_config_h)
#define octave_octave_config_h 1

#if ! defined (OCTAVE_AUTOCONFIG_H_INCLUDED)

#  if defined (__cplusplus)
#    include <cinttypes>
#  else
#    include <inttypes.h>
#  endif

#  define OCTAVE_NAMESPACE_BEGIN namespace octave {
#  define OCTAVE_NAMESPACE_END }

#  if defined (__GNUC__)
#    if __GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 5)
#      define OCTAVE_DEPRECATED(ver, msg) __attribute__ ((__deprecated__ ("[" #ver "]: " msg)))
#    else
#      define OCTAVE_DEPRECATED(ver, msg) __attribute__ ((__deprecated__))
#    endif
#    define OCTAVE_NORETURN __attribute__ ((__noreturn__))
#    define OCTAVE_UNUSED __attribute__ ((__unused__))

#    define HAVE_OCTAVE_DEPRECATED_ATTR 1
#    define HAVE_OCTAVE_NORETURN_ATTR 1
#    define HAVE_OCTAVE_UNUSED_ATTR 1
#  else
#    define OCTAVE_DEPRECATED(ver, msg)
#    define OCTAVE_NORETURN
#    define OCTAVE_UNUSED

/* #    undef HAVE_OCTAVE_DEPRECATED_ATTR */
/* #    undef HAVE_OCTAVE_NORETURN_ATTR */
/* #    undef HAVE_OCTAVE_UNUSED_ATTR */
#  endif

#  if defined (__MINGW32__)
    /* MinGW requires special handling due to different format specifiers
     * on different platforms.  The macro __MINGW_PRINTF_FORMAT maps to
     * either gnu_printf or ms_printf depending on where we are compiling
     * to avoid warnings on format specifiers that are legal.
     * See: https://bugzilla.mozilla.org/show_bug.cgi?id=1331349  */
#    if defined (__cplusplus)
#      include <cstdio>
#    else
#      include <stdio.h>
#    endif

#    define OCTAVE_FORMAT_PRINTF(stringIndex, firstToCheck)        __attribute__ ((format (__MINGW_PRINTF_FORMAT, stringIndex, firstToCheck)))

#    define HAVE_OCTAVE_FORMAT_PRINTF_ATTR 1
#  elif defined (__GNUC__)
     /* The following attributes are used with gcc and clang compilers.  */
#    define OCTAVE_FORMAT_PRINTF(index, first)        __attribute__ ((__format__(printf, index, first)))

#    define HAVE_OCTAVE_FORMAT_PRINTF_ATTR 1
#  else
#    define OCTAVE_FORMAT_PRINTF(index, first)

/* #    undef HAVE_OCTAVE_FORMAT_PRINTF_ATTR */
#  endif

#  if ! defined (OCTAVE_FALLTHROUGH)
#    if defined (__cplusplus) && __cplusplus > 201402L
#      define OCTAVE_FALLTHROUGH [[fallthrough]]
#    elif defined (__GNUC__) && __GNUC__ < 7
#      define OCTAVE_FALLTHROUGH ((void) 0)
#    else
#      define OCTAVE_FALLTHROUGH __attribute__ ((__fallthrough__))
#    endif
#  endif

#  define OCTAVE_PROVIDE_DEPRECATED_SYMBOLS 1

#  if defined (__cplusplus)
template <typename T>
static inline void
octave_unused_parameter (const T&)
{ }
#  else
#    define octave_unused_parameter(param) (void) param;
#  endif

/* Defined to 1 if Octave libraries were built with visibility flags */
/* #  undef OCTAVE_ENABLE_LIB_VISIBILITY_FLAGS */

#  if defined (OCTAVE_ENABLE_LIB_VISIBILITY_FLAGS)
#    if defined (_WIN32) || defined (__CYGWIN__)
#      if defined (__GNUC__)
         /* GCC */
#        define OCTAVE_EXPORT __attribute__ ((dllexport))
#        define OCTAVE_IMPORT __attribute__ ((dllimport))
#      else
         /* MSVC */
#        define OCTAVE_EXPORT __declspec(dllexport)
#        define OCTAVE_IMPORT __declspec(dllimport)
#      endif
#    else
       /* All other platforms. */
#      define OCTAVE_EXPORT __attribute__ ((visibility ("default")))
#      define OCTAVE_IMPORT
#    endif
#  else
#      define OCTAVE_EXPORT
#      define OCTAVE_IMPORT
#  endif

/* API macro for liboctave */
#if defined (OCTAVE_DLL)
#  define OCTAVE_API OCTAVE_EXPORT
#else
#  define OCTAVE_API OCTAVE_IMPORT
#endif

/* API macro for libinterp */
#if defined (OCTINTERP_DLL)
#  define OCTINTERP_API OCTAVE_EXPORT
#else
#  define OCTINTERP_API OCTAVE_IMPORT
#endif

/* API macro for the Array class in liboctave and liboctinterp */
#if (defined (OCTAVE_DLL) || defined (OCTINTERP_DLL))
#  define OCTARRAY_API OCTAVE_EXPORT
#else
#  define OCTARRAY_API OCTAVE_IMPORT
#endif

/* API macro for libinterp/graphics */
#if defined (OCTGRAPHICS_DLL)
#  define OCTGRAPHICS_API OCTAVE_EXPORT
#else
#  define OCTGRAPHICS_API OCTAVE_IMPORT
#endif

/* API macro for libgui */
#if defined (OCTGUI_DLL)
#  define OCTGUI_API OCTAVE_EXPORT
#else
#  define OCTGUI_API OCTAVE_IMPORT
#endif

typedef int64_t octave_idx_type;
typedef int32_t octave_f77_int_type;

#  define OCTAVE_HAVE_F77_INT_TYPE 1

/* time type in API is always 64 bits wide */
#  define OCTAVE_TIME_T int64_t

#  if defined (__cplusplus) && ! defined (OCTAVE_THREAD_LOCAL)
#    define OCTAVE_THREAD_LOCAL
#  endif

#  define OCTAVE_FLOAT_TRUNCATE volatile

#  define OCTAVE_ENABLE_64 1
#  define OCTAVE_ENABLE_OPENMP 1
#  define OCTAVE_HAVE_LONG_LONG_INT 1
#  define OCTAVE_HAVE_UNSIGNED_LONG_LONG_INT 1
/* #  undef OCTAVE_HAVE_STD_PMR_POLYMORPHIC_ALLOCATOR */
#  define OCTAVE_HAVE_OVERLOAD_CHAR_INT8_TYPES 1
#  define OCTAVE_SIZEOF_F77_INT_TYPE 4
#  define OCTAVE_SIZEOF_IDX_TYPE 8
#  define OCTAVE_SIZEOF_INT 4

#  if defined (OCTAVE_ENABLE_64)
#    define OCTAVE_IDX_TYPE_FORMAT PRId64
#  else
#    define OCTAVE_IDX_TYPE_FORMAT PRId32
#  endif

#  define gid_t int
#  define uid_t int
#  define nlink_t int
/* typedef short dev_t; */
/* typedef unsigned long ino_t; */

/* #  undef OCTAVE_INT_USE_LONG_DOUBLE */
/* #  undef OCTAVE_ENSURE_LONG_DOUBLE_OPERATIONS_ARE_NOT_TRUNCATED */

/* #  undef F77_USES_CRAY_CALLING_CONVENTION */
/* #  undef F77_USES_F2C_CALLING_CONVENTION */
#  define F77_USES_GFORTRAN_CALLING_CONVENTION 1
/* #  undef F77_USES_VISUAL_FORTRAN_CALLING_CONVENTION */

#  define F77_FUNC(name,NAME) name ## _
#  define F77_FUNC_(name,NAME) name ## _

#endif

#endif
