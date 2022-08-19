## Copyright (C) 2013-2021 Philip Nienhuis
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {Function File} {@var{retval} =} __OCT_spsh_info__ (@var{x} @var{y})
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2013-09-10
## Updates:
##

function [ sh_names ] = __OCT_spsh_info__ (ods)

  sh_names(:, 1) = ods.sheets.sh_names;
  for ii=1:numel (ods.sheets.sh_names)
    if (ods.sheets.type(ii) == 1)
      [ tr, lr, lc, rc ] = getusedrange (ods, ods.sheets.shId(ii));
      if (tr)
        sh_names(ii, 2) = sprintf ("%s:%s", calccelladdress (tr, lc),...
                          calccelladdress (lr, rc));
      else
        sh_names(ii, 2) = "Empty";
      endif
    elseif (ods.sheets.type(ii) == 2)
      sh_names(ii, 2) = "Chart";
    else
      sh_names(ii, 2) = "Other type";
    endif
  endfor

endfunction
