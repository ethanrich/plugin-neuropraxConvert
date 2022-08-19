## Copyright (C) 2017 Philip Nienhuis
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
## @deftypefn {Function File}  [@var{olin}, @var{nlin}] = clipPolyline_clipper (@var{inlin}, @var{clippol})
## @deftypefnx {Function File} [@var{olin}, @var{nlin}] = clipPolyline_clipper (@var{inlin}, @var{clippol}, @var{op})
## Clip (possibly composite) polylines with polygon(s) using one of boolean
## methods.
##
## @var{inpol} = Nx2 matrix of (X, Y) coordinates constituting the polylines(s)
## to be clipped.  Polyline sections are separated by [NaN NaN] rows.
## @var{clippol} = another Nx2 matrix of (X, Y) coordinates representing the
## clip polygon(s).   @var{clippol} may comprise separate and/or concentric
## polygons (the latter with holes).
##
## Optional argument @var{op}, the boolean operation, can be:
##
## @itemize
## @item 0: difference @var{inpol} - @var{clippol}
##
## @item 1: intersection ("AND") of @var{inpol} and @var{clippol} (= default)
## @end itemize
##
## Output array @var{oline} will be an Nx2 array of polyline sections
## resulting from the requested boolean operation.
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2017-03-21
## Based on Clipper library, polyclipping.sf.net, 3rd Party, Matlab

function [olin, nlin] = clipPolyline_clipper (inpoly, clippoly, method=1)

  ## Input validation
  if (nargin < 2)
    print_usage ();
  endif
  if (! isnumeric (inpoly) || size (inpoly, 2) < 2)
    error (" clipPolyline: inpoly should be a numeric Nx2 array");
  endif
  if (! isnumeric (clippoly) || size (clippoly, 2) < 2)
    error (" clipPolyline: clippoly should be a numeric Nx2 array");
  elseif (! isnumeric (method) || method < 0 || method > 3)
    error (" clipPolyline: operation must be a numeric 0 or 1");
  endif

  [inpol, xy_mean, xy_magn] = __dbl2int64__ (inpoly, clippoly);

  clpol = __dbl2int64__ (clippoly, [], xy_mean, xy_magn);

  ## Perform boolean operation
  olin = clipper (inpol, clpol, method, -1);
  nlin = numel (olin);

  if (! isempty (olin))
    ## Morph struct output into [X,Y] array. Put NaNs between sub-polys. First X:
    [tmp(1:2:2*nlin, 1)] = deal ({olin.x});
    [tmp(2:2:2*nlin-1, 1)] = NaN;
    ## Convert back from in64 into double, wipe trailing NaN
    X = double (cell2mat (tmp));

    ## Y-coordinates:
    [tmp(1:2:2*nlin, 1)] = deal ({olin.y});
    [tmp(2:2:2*nlin-1, 1)] = NaN;
    Y = double (cell2mat (tmp));

    olin = ([X Y] / xy_magn) + xy_mean;
  else
    olin = zeros (0, 2);
  endif

endfunction
