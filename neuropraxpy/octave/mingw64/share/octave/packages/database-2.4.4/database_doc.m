## Copyright (C) 2014-2019 Olaf Till <i7tiol@t-online.de>
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
## @deftypefn {Function File} {} database_doc ()
## @deftypefnx {Function File} {} database_doc (@var{keyword})
## Show database package documentation.
##
## Runs the info viewer Octave is configured with on the documentation
## in info format of the installed database package. Without argument,
## the top node of the documentation is displayed. With an argument,
## the respective index entry is searched for and its node displayed.
##
## @end deftypefn

function database_doc (keyword)

  if ((nargs = nargin ()) > 1)
    print_usage ()
  endif

  ## locate installed documentation
  persistent infopath = "";
  if (isempty (infopath))
    [local_list, global_list] = pkg ("list");
    if (! isempty (idx = ...
                   find (strcmp ("database",
                                 {structcat(1, local_list{:}).name}),
                         1)))
      idir = local_list{idx}.dir;
    elseif (! isempty (idx = ...
                       find (strcmp ("database",
                                     {structcat(1, global_list{:}).name}),
                             1)))
      idir = global_list{idx}.dir;
    else
      error ("no installed database package found");
    endif
    infopath = fullfile (idir, "doc/", "database.info");
    ## allow for .gz
    if (! exist (infopath, "file"))
      infopath = strcat (infopath, ".gz");
    endif
  endif

  ## display info
  INFO = info_program ();

  if (nargs)
    error_hint = ", maybe the keyword was not found in the index";
    status = system (sprintf ("%s %s --index-search \"%s\"",
                              INFO, infopath, keyword));
  else
    error_hint = "";
    status = system (sprintf ("%s %s", INFO, infopath));
  endif

  if (status)
    if (status == 127)
      error ("unable to find info program `%s'", INFO);
    else
      error ("info program `%s' returned error code %i%s",
             INFO, status, error_hint);
    endif
  endif

endfunction
