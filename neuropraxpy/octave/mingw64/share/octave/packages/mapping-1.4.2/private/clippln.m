## Copyright (C) 2014-2022 Philip Nienhuis
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
## @deftypefn {Function File} [@var{val}, @var{npts}, @var{pprt}] = clipplg (@var{val}, @var{npts}, @var{pprt}, @var{sbox}, @var{styp})
## Undocumented internal function for clipping (poly)lines within a bounding
## box and copying M and Z-values from nearest old vertex.
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2014-12-01

function [valn, tnpt, tnpr] = clippln (val, tnpt, tnpr, sbox, styp=3)

  ## Clip (intersection)
  if (mod (styp, 10) == 3)
    [valn, nparts] = clipPolyline_clipper (val(:, 1:2), sbox, 1);
  else
    [valn, nparts] = clipPolygon_clipper (val(:, 1:2), sbox, 1);
  endif

  ## Set up pointers to subpolygons
  idn = [0 find(isnan (valn(:, 1)))' size(valn, 1)+1];
  tnpr = idn(1:end-1);
  ## Setup Z/M/nr/type columns
  for ii=1:nparts
    dists = distancePoints (val(:, 1:2), valn(idn(ii)+1:idn(ii+1)-1, 1:2));
    [mind, idm] = min (dists);
    ## Simply copy over Z & M values & no. and type of nearest "old" vertex
    valn(idn(ii)+1:idn(ii+1)-1, 3:6) = val(idm, 3:6);
  endfor
  ## Fix up pointers and vertices
  valn(idn(2:end-1), :) = [];
  tnpr = tnpr - [0 : numel(tnpr)-1];
  tnpt = size (valn, 1);

endfunction
