## Copyright (C) 2017-2022 Philip Nienhuis
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

function [opol, xy_mean, xy_magn] = __dbl2int64__ (inpoly, clippoly=[], xy_mean=[], xy_magn=[])

  if (isempty (clippoly))
    clippoly = zeros (0, size (inpoly, 2));
  endif
  if (isempty (xy_mean))
    ## Convert & scale to int64 (that's what Clipper works with)
    ## Find (X, Y) translation
    xy_mean = mean ([inpoly; clippoly] (isfinite ([inpoly; clippoly](:, 1)), :));
    ## Find (X, Y) magnitude
    xy_magn = max ([inpoly; clippoly] (isfinite ([inpoly; clippoly](:, 1)), :)) ...
            - min ([inpoly; clippoly] (isfinite ([inpoly; clippoly](:, 1)), :));
    ## Apply (X,Y) multiplication (floor (log10 (intmax ("int64"))) = 18)
    xy_magn = 10^(17 - ceil (max (log10 (xy_magn))));
  endif

  ## Scale inpoly coordinates to optimally use int64
  inpoly(:, 1:2) -= xy_mean;
  inpoly         *= xy_magn;

  idin = [ 0 find(isnan (inpoly (:, 1)))' numel(inpoly (:, 1))+1 ];
  ## Provisional preallocation. npolx is average nr. of vertices per polygon
  npolx = fix (size (inpoly, 1) / numel (idin)-1);
  npoly = size (inpoly, 2);
  opol = repmat (struct ("x", zeros (npolx, npoly), "y", zeros (npolx, npoly)), ...
                         1, numel(idin) - 1);
  for ii=1:numel (idin) - 1
    opol(ii).x = int64 (inpoly(idin(ii)+1:idin(ii+1)-1, 1));
    opol(ii).y = int64 (inpoly(idin(ii)+1:idin(ii+1)-1, 2));
  endfor

endfunction
