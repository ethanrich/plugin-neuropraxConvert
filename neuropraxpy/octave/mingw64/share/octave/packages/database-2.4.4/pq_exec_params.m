## Copyright (C) 2013-2019 Olaf Till <i7tiol@t-online.de>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} pq_exec_params (@var{connection}, @var{command})
## @deftypefnx {Loadable Function} pq_exec_params (@var{connection}, @var{command}, @var{params})
## @deftypefnx {Loadable Function} pq_exec_params (@var{connection}, @var{command}, @var{settings})
## @deftypefnx {Loadable Function} pq_exec_params (@var{connection}, @var{command}, @var{params}, @var{settings})
##
## Sends the string @var{command}, which must contain a single SQL
## command, over the connection @var{connection}. Parameters in
## @var{command} can be replaced by $1, $2, etc and their values given
## in the one-dimensional cell-array @var{params}. Parameters of
## composite type sent this way must have their type defined in the
## database. For typeconversions, the package maintains a notion of
## defined types, which should be refreshed with @code{pq_update_types}
## if types are defined or dropped after establishing the connection, or
## if the schema search path changes. @var{settings} is a structure of
## settings, it can be created by @code{setdbopts}.
##
## Settings currently understood by @code{pq_exec_params}:
##
## @table @code
## @item param_types
## One-dimensional cell-array with type specifications for parameters in
## @var{params}. If present, must have the same length as @var{params}.
## Entries may be empty if no specification is necessary (see below).
## Type specifications are strings corresponding to the entries returned
## by @code{SELECT typname FROM pg_type WHERE typarray != 0 OR typtype =
## 'c';}, optionally having @code{[]} appended (without space) to
## indicate an array. Type specifications can be schema-qualified,
## otherwise they refer to the visible type with that name.
## @item copy_in_path, copy_out_path
## Path to files at the client side for @code{copy from stdin} and
## @code{copy to stdout}, respectively.
## @item copy_in_from_variable
## Logical scalar, default @code{false}. If @code{true}, @code{copy from
## stdin} uses data from an Octave variable instead of from a file.
## @item copy_in_data
## 2-dimensional cell-array with columns of suitable type (see below) --
## will be used instead of a file as data for @code{copy from stdin} if
## @code{copy_in_from_variable} is @code{true}.
## @item copy_in_types
## If some columns in @code{copy_in_data} need a type specification (see
## below), @code{copy_in_types} has to be set to a cell-array with type
## specifications, with an entry (possibly empty) for each column.
## @item copy_in_with_oids
## If you want to copy in with oids when using data from an Octave
## variable, the first column of the data must contain the OIDs and
## @code{copy_in_with_oids} has to be set to @code{true} (default
## @code{false}); @code{with oids} should be specified together with
## @code{copy from stdin} in the command, otherwise Postgresql will
## ignore the copied oids.
## @end table
##
## There is no way to @code{copy to stdout} into an Octave variable, but
## a @code{select} command can be used for this purpose.
##
## @code{copy from stdin} from an Octave variable is only supported in
## binary mode, so this has to be specified in the SQL command.
##
## The output depends on the type of command.
## @itemize
## @item queries (commands potentially returning data):
## The output will be a structure with fields @code{data} (containing
## a cell array with the data, columns correspond to returned database
## columns, rows correspond to returned tuples), @code{columns}
## (containing the column headers), and @code{types} (a
## structure-vector with the postgresql data types of the columns,
## subfields @code{name} (string with typename), @code{is_array}
## (boolean), @code{is_composite} (boolean), @code{is_enum} (boolean),
## and @code{elements} (if @code{is_composite == true},
## structure-vector of element types, containing fields corresponding
## to those of @code{types})).
## @item copy commands:
## Nothing is returned (this may change in the future).
## @item other commands:
## The output will be the number of affected rows in the database.
## @end itemize
##
##
## @c The following block will be cut out in the package info file.
## @c BEGIN_CUT_TEXINFO
##
## For the mapping of currently implemented Postgresql types to Octave
## types, type @code{database_doc ("Postgresql data types")}.
##
## @c END_CUT_TEXINFO
##
## @seealso {pq_update_types, pq_conninfo}
## @end deftypefn

## PKG_ADD: [~] = __all_db_opts__ ("pq_exec_params");

function ret = pq_exec_params (conn, varargin)

  ## This wrapper is necessary to work around calling PKG_ADD
  ## instructions of each added path immediately, before all paths of a
  ## package are added. In 'pkg install', m-function path is set before
  ## oct-function path, and left set, so this would work here. But in
  ## 'pkg build', if the package is not already installed, these paths
  ## are temporarily and separately set.

  if ((nargs = nargin) == 0)
    print_usage ();
  endif

  if (nargs == 1 && ischar (conn) && strcmp (conn, "defaults"))

    ret = setdbopts ("param_types", [], ...
                     "copy_in_path", "", ...
                     "copy_out_path", "", ...
                     "copy_in_data", [], ...
                     "copy_in_with_oids", false, ...
                     "copy_in_types", [], ...
                     "copy_in_from_variable", false);

  else

    t_ret = __pq_exec_params__ (conn, varargin{:});

    if (! ischar (t_ret)) ## marker for a copy command
      ret = t_ret;
    endif

  endif

endfunction
