// DO NOT EDIT!  Generated automatically by mk-version-h.

////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 1992-2022 The Octave Project Developers
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

#if ! defined (octave_version_h)
#define octave_version_h 1

#include "octave-config.h"

#define OCTAVE_VERSION "7.2.0"

#define OCTAVE_MAJOR_VERSION 7

#define OCTAVE_MINOR_VERSION 2

#define OCTAVE_PATCH_VERSION 0

// The "API version" is used as a way of checking that interfaces in the
// liboctave and libinterp libraries haven't changed in a backwardly
// incompatible way when loading .oct files.  A better way to do that is
// with library versioning, but not all systems support that.
// NOTE: This macro will be removed in a future version of Octave.  If
// you insist on checking for features using a version number, use the
// OCTAVE_MAJOR_VERSION, OCTAVE_MINOR_VERSION, and
// OCTAVE_PATCH_VERSION macros instead.
#define OCTAVE_API_VERSION "api-v57"

#define OCTAVE_RELEASE_DATE "2022-07-28"

#define OCTAVE_CANONICAL_HOST_TYPE "x86_64-w64-mingw32"

#define OCTAVE_COPYRIGHT "Copyright (C) 1993-2022 The Octave Project Developers."

#include <string>

extern OCTAVE_API std::string octave_www_statement (bool html = false);

extern OCTAVE_API std::string octave_contrib_statement (bool html = false);

extern OCTAVE_API std::string octave_bugs_statement (bool html = false);

extern OCTAVE_API std::string octave_name_version_and_copyright (void);

extern OCTAVE_API std::string
octave_name_version_copyright_copying_and_warranty
  (bool html = false, const std::string& extra_info = "");

extern OCTAVE_API std::string
octave_name_version_copyright_copying_warranty_and_bugs
  (bool html = false, const std::string& extra_info = "");

extern OCTAVE_API std::string octave_startup_message (bool html = false);

#endif
