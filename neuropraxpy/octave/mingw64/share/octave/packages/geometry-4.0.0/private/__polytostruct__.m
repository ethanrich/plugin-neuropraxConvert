## Copyright (C) 2017 - Piyush Jain
## Copyright (C) 2017 - Juan Pablo Carbajal
## Copyright (C) 2017-2019 Philip Nienhuis
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.

function [opol] = __polytostruct__ (inpoly)

  idin = [ 0 find(isnan (inpoly (:, 1)))' numel(inpoly (:, 1))+1 ];
  ## Provisional preallocation. npolx is average nr. of vertices per polygon
  npolx = fix (size (inpoly, 1) / numel (idin) - 1);
  npoly = size (inpoly, 2);
  opol = repmat (struct ("x", zeros (npolx, npoly), "y", zeros (npolx, npoly)), ...
                         1, numel(idin) - 1);
  for ii=1:numel (idin) - 1
    opol(ii).x = inpoly(idin(ii)+1:idin(ii+1)-1, 1);
    opol(ii).y = inpoly(idin(ii)+1:idin(ii+1)-1, 2);
  endfor

endfunction
