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
## @deftypefn {Function File} [@var{retval}] = getxmlattv (@var{xmlnode}, @var{att})
## Get value of attribute @var{att} in xml node (char string) @var{xmlnode},
## return empty if attribute isn't present.
##
## @seealso{getxmlnode}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@ at users.sf.net>
## Created: 2013-09-08

function [retval] = getxmlattv (xmlnode, att)

  retval = "";

  ## Get end of first tag
  iend = index (xmlnode, ">");
  ## Get start of value string. Concat '="' to ensure minimal ambiguity
  vals = index (xmlnode, [att '="']);
  if (vals == 0)
    ## Attribute not in current tag
    return
  elseif (vals)
    vals = vals + length (att) + 2;
    vale = regexp (xmlnode(vals:end), '"[ >/]', "once");
    if (! isempty (vale))
      retval = xmlnode(vals:vals+vale-2);
    endif
  endif

endfunction
