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
## @deftypefn {Function File} geoshow (@var{shps})
## @deftypefnx {Function File} geoshow (@var{shps}, @var{clr})
## Plot a mapstruct created by shaperead.
##
## @var{shps} is the name of a geostruct created by shaperead.
## 
## Optional argument @var{clr} can be a predefined color ("k", "c", etc.), an
## RGB triplet, or a 2 X 1 column vector of RGB triplets (each row containing
## a triplet). The uppermost row will be used for points and lines, the
## lowermost row for solid shape features (not yet implemented).
##
## @seealso{mapshow, shapedraw, shapeinfo, shaperead}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2014-11-17 based on a suggestion by Carnë Draug

function  geoshow (varargin)
  if (isshape (varargin{1}))
    ## Assume a shape struct
    plotshape (varargin{:});
    axis equal;
  else
    error ("geoshow: plotting of non-shapes is not yet implemented\n")
  endif

endfunction


function retval = isshape (s)

  retval = false;
  ## Check if s is a recognized shape file struct; just a brief check
  if (isstruct (s))
    ## Yep. Find out what type
    fldn = fieldnames (s);
    if (ismember ("Geometry", fldn) && ismember ("BoundingBox", fldn) && ...
        ismember ("Lon", fldn))
      ## Assume it is a Matlab-style geostruct
      retval = true;
    endif
  endif

endfunction
