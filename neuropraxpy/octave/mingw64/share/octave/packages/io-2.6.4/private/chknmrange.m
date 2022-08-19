## Copyright (C) 2015-2021 Philip Nienhuis
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} [ @var{range}, @var{wsh}, @var{xls}] = chkrange (@var{xls}, @var{range}, @var{wsh})
## Internal function. Checks if range is Named range & act accordingly
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhu01 <pr.nienhuis@users.sf.net>
## Created: 2015-09-29

function [datrange, wsh, xls] = chknmrange (xls, datrange, wsh)

    mtch = cell2mat (regexp (datrange, ...
                     '(^[A-Za-z]+[0-9]+){1}(:[A-Za-z]+[0-9]+$)?', "tokens"));
    if (isempty (mtch) || ! strcmp ([mtch{:}], datrange))
      ## Apparently not a range. Try range names
      if (! isfield (xls, "nmranges"))
        xls.nmranges = getnmranges (xls);
      endif
      idx = find (strncmpi (datrange, xls.nmranges(:, 1), numel (datrange)));
      if (isempty (idx))
        error ("no range '%s' in workbook '%s'\n", datrange, xls.filename);
      else
        if (numel (idx) > 1)
          ## Multiple sheets with same Named range
          if (isnumeric (wsh))
            ## No way to assess worksheet name here. Just take the first match
            idx = idx(1);
            printf ("multiple Range name matches for '%s', but no sheet *name* specified\n", ...
                    datrange);
            warning ("Data read from first match = sheet '%s'\n", xls.nmranges{idx, 2});
          elseif (ischar (wsh))
            jdx = find (strncmpi (wsh, xls.nmranges(idx, 2), numel (wsh)));
            if (isempty (jdx))
              ## No match with specified wsh => just pick the first
              idx = idx(1);
              warning ("Named Range '%s' not defined in sheet '%s'\n         Sheet '%s' taken\n", ...
                       datrange, wsh, xls.nmranges{idx, 2});
            else
              ## In case of multiple matches, just pick the first
              idx = idx(jdx(1));
            endif
          else
            error ("Illegal sheet name or index specified\n");
          endif
        endif
        ## Get range and -optionally- sheet it refers to
        datrange = xls.nmranges{idx, 3};
        if (! isempty (xls.nmranges{idx, 2}))
          wsh = xls.nmranges{idx, 2};
        endif
      endif
    endif

endfunction
