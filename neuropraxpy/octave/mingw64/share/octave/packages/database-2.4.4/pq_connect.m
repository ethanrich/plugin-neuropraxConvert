## Copyright (C) 2012-2019 Olaf Till <i7tiol@t-online.de>
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
## @deftypefn {Function File} {@var{connection} =} pq_connect (@var{settings})
## Establishes a connection to a postgresql server according to
## @var{settings} and returns an @code{octave_pq_connection} object
## @var{connection} which can be passed to other functions of the
## package. There can be multiple connections. An
## @code{octave_pq_connection} object contains information on a
## connection and will be internally altered by the packages functions
## even though it is only passed as an argument, i.e. Octaves 'pass by
## value' semantics are not adhered to in this case.
##
## @var{settings} can be set by @code{setdbopts} (copied from Octaves
## @code{optimset}) and can contain (defaults depend on Postgresql):
## @code{host} (hostname), @code{hostaddr} (numeric host address),
## @code{port} (port to connect to), @code{dbname} (database to connect
## to), @code{user} (user name to connect as), @code{password},
## @code{connect_timeout}, @code{options} (command-line options to send
## to the server at run-time, see Postgresql documentation),
## @code{sslmode} (@code{disable}, @code{allow}, @code{prefer},
## @code{require}, @code{verify-ca}, or @code{verify-full}; see
## Postgresql documentation of SSL support), @code{sslcert} (file name
## of client SSL certificate), @code{sslkey} (location of secret key for
## client certificate, file name or external OpenSSL engine
## (colon-separated engine name and an engine-specific key identifier)),
## @code{sslrootcert} (file name of root SSL certificate), @code{sslcrl}
## (file name of SSL certificate revocation list), @code{krbsrvname}
## (kerberos service name), @code{service} (service name in
## pq_service.conf to use for additional parameters).
##
## All these settings are passed to the server as they are, so it may be
## better to consult the postgresql documentation for them, e.g. the
## documentation of the PQconnectdb function in libpq.
## @seealso {pq_exec_params, pq_update_types}
## @end deftypefn

## PKG_ADD: [~] = __all_db_opts__ ("pq_connect");

function conn = pq_connect (settings)

  if (nargin != 1)
    print_usage ()
  endif

  if (ischar (settings) && strcmp (settings, "defaults"))
    conn = setdbopts ("host", [], ...
                      "hostaddr", [], ...
                      "port", [], ...
                      "dbname", [], ...
                      "user", [], ...
                      "password", [], ...
                      "connect_timeout", [], ...
                      "options", [], ...
                      "sslmode", [], ...
                      "sslcert", [], ...
                      "sslkey", [], ...
                      "sslrootcert", [], ...
                      "sslcrl", [], ...
                      "krbsrvname", [], ...
                      "service", []);
    return;
  endif

  if (! isempty (to = getdbopts (settings, "connect_timeout")) && ...
      isnumeric (to))
    settings = setdbopts (settings, "connect_timeout", num2str (to));
  endif

  if (isfield (settings, "password") && isempty (settings.password))
    ## I know this is far from elegant, but it seems robust and I'm to
    ## lazy now to find out a more decent way.
    printf ("password: ");
    fflush (stdout);
    password = "";
    while (true)
      c = kbhit ();
      if (c == "\n")
        printf ("\n");
        break;
      else
        password = sprintf ("%s%s", password, c);
      endif
    endwhile
    settings.password = password;
  endif

  optstring = "";

  for [val, key] = settings
    if (isempty (val))
      val = "";
    endif
    val = strrep (val, '\', '\\');
    val = strrep (val, "'", "''");
    optstring = sprintf ("%s%s='%s' ", optstring, key, val);
  endfor

  conn = __pq_connect__ (optstring);

endfunction

%!demo
%! conn = pq_connect (setdbopts ("dbname", "test"));
%! pq_exec_params (conn, "create table testtable (t text, i int2, b bytea);")
%! pq_exec_params (conn, "insert into testtable values ($1, $2, $3);", {"name1", 1, uint8([2, 4, 5])})
%! pq_exec_params (conn, "insert into testtable values ($1, $2, $3);", {"name2", 2, uint8([7, 9, 3, 1])})
%! pq_exec_params (conn, "select * from testtable;")
%! pq_exec_params (conn, "drop table testtable;")
%! pq_close (conn);

%!demo
%! ## recursive type, array-composite-array
%! conn = pq_connect (setdbopts ("dbname", "test"));
%! pq_exec_params (conn, "create type complex_bool_array_type as (b bool, ba bool[]);")
%! pq_exec_params (conn, "create table complex_bool_array_array (a complex_bool_array_type[]);")
%! pq_update_types (conn);
%! pq_exec_params (conn, "insert into complex_bool_array_array values ($1);", {struct("ndims", 1, "data", {{{true, struct("ndims", 2, "data", {{true, false; true, true}})}; {false, struct("ndims", 1, "data", {{false; true}})}}})}, setdbopts ("param_types", {"complex_bool_array_type[]"}))
%! data = pq_exec_params (conn, "select * from complex_bool_array_array;").data;
%! ## copy in from variable
%! pq_exec_params (conn, "copy complex_bool_array_array from stdin with binary;", setdbopts ("copy_in_data", data, "copy_in_from_variable", true, "copy_in_types", {"complex_bool_array_type[]"}))
%! pq_exec_params (conn, "select * from complex_bool_array_array;")
%! ## recursive type, composite-composite-array
%! pq_exec_params (conn, "create type complex_complex_bool_array_type as (b bool, c complex_bool_array_type);")
%! pq_exec_params (conn, "create table complex_complex_bool_array (a complex_complex_bool_array_type);")
%! pq_update_types (conn);
%! pq_exec_params (conn, "insert into complex_complex_bool_array values ($1);", {{false, {true, struct("ndims", 2, "data", {{true, false; true, true}})}}}, setdbopts ("param_types", {"complex_complex_bool_array_type"}))
%! data = pq_exec_params (conn, "select * from complex_complex_bool_array").data;
%! ## copy in from variable
%! pq_exec_params (conn, "copy complex_complex_bool_array from stdin with binary;", setdbopts ("copy_in_data", data, "copy_in_from_variable", true, "copy_in_types", {"complex_complex_bool_array_type"}))
%! pq_exec_params (conn, "select * from complex_complex_bool_array")
%! pq_exec_params (conn, "drop table complex_complex_bool_array;")
%! pq_exec_params (conn, "drop table complex_bool_array_array;")
%! pq_exec_params (conn, "drop type complex_complex_bool_array_type;")
%! pq_exec_params (conn, "drop type complex_bool_array_type;")
%! pq_close (conn);

%!test
%! conn = pq_connect (setdbopts ("dbname", "test"));
%! assert (islogical (t = pq_exec_params (conn, "select ($1);", {true}).data{1}) && t == true);
%! assert (strcmp (typeinfo (t = pq_exec_params (conn, "select ($1);", {uint32(3)}).data{1}), "uint32 scalar") && t == 3);
%! assert (strcmp (typeinfo (t = pq_exec_params (conn, "select ($1);", {.5}).data{1}), "scalar") && t == .5);
%! assert (strcmp (typeinfo (t = pq_exec_params (conn, "select ($1);", {single(.5)}).data{1}), "float scalar") && t == .5);
%! assert ((strcmp (ti = typeinfo (t = pq_exec_params (conn, "select ($1);", {"abc"}).data{1}), "string") || strcmp (ti, "sq_string")) && strcmp (t, "abc"));
%! assert (strcmp (typeinfo (t = pq_exec_params (conn, "select ($1);", {uint8([2, 3])}).data{1}), "uint8 matrix") && isequal (t, [2; 3]));
%! t = {20, struct("b", "abc")};
%! assert (isequal (t, bytea2var (pq_exec_params (conn, "select ($1);", {var2bytea(t)}).data{1})));
%! assert (strcmp (typeinfo (t = pq_exec_params (conn, "select ($1);", {int16(-2)}).data{1}), "int16 scalar") && t == int16 (-2));
%! assert (strcmp (typeinfo (t = pq_exec_params (conn, "select ($1);", {int32(-2)}).data{1}), "int32 scalar") && t == int32 (-2));
%! assert (strcmp (typeinfo (t = pq_exec_params (conn, "select ($1);", {int64(-2)}).data{1}), "int64 scalar") && t == int64 (-2));
%! pq_close (conn);
