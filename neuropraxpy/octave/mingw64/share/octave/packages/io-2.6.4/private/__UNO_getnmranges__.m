## Copyright (C) 2017-2021 Philip Nienhuis
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
## @deftypefn {Function File} {@var{retval} =} __UNO_getnmranges__ (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2015-09-20

function [nmr] = __UNO_getnmranges__ (xls)

  nmr = cell (0, 3);

  ## Entire workbook
  unotmp = javaObject ("com.sun.star.uno.Type", "com.sun.star.beans.XPropertySet");
  docProps = xls.workbook.queryInterface (unotmp);
  urng = docProps.getPropertyValue ("NamedRanges");
  rnms = urng.getObject.getElementNames ();
  ## FIXME get ranges
  for ii = 1:numel (rnms)
    rng = urng.getObject.getByName (rnms(ii));
    nm = strrep (rng.getObject ().getContent (), "$", ""); ## ->  $3rdSheet.$D$2:$I$4
    nmr{end+1, 1} = rnms(ii);
    nmr{end, 2} = nm(1:index(nm, ".")-1);
    nmr{end, 3} = nm(index(nm, ".")+1:end);
  endfor

  ## Per sheet. First some preparations
  sheets = xls.workbook.getSheets ();
  sh_names = sheets.getElementNames ();
  if (! iscell (sh_names))
    ## Java array (LibreOffice 3.4.+), convert to cellstr
    sh_names = char (sh_names);
  else
    sh_names = {sh_names};
  endif
  ## For each sheet get named ranges
  for jj = 1:numel (sh_names)
    unotmp = javaObject ("com.sun.star.uno.Type", "com.sun.star.sheet.XSpreadsheet");
    sh = sheets.getByName(sh_names{jj}).getObject.queryInterface (unotmp);
    unotmp = javaObject ("com.sun.star.uno.Type", "com.sun.star.beans.XPropertySet");
    shProps = sh.queryInterface (unotmp);
    urng = shProps.getPropertyValue ("NamedRanges");
    rnms = urng.getObject.getElementNames ();
    for ii=1:numel (rnms)
      rng = urng.getObject.getByName (rnms(ii));
      nm = strrep (rng.getObject ().getContent (), "$", ""); ## ->  $3rdSheet.$D$2:$I$4
      nmr{end+1, 1} = rnms(ii);
      nmr{end, 2} = nm(1:index(nm, ".")-1);
      nmr{end, 3} = nm(index(nm, ".")+1:end);
    endfor
  endfor

endfunction
