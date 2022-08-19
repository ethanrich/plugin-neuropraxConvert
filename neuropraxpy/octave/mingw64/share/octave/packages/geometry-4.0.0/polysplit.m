## Copyright (C) 2017 - Piyush Jain
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not,
## see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File}[@var{cellx},@var{celly}] = polysplit(@var{vecx},@var{vecy})
## Convert NaN separated polygon vectors to cell arrays of polygons.
##
## @var{vecx}/@var{vecy} is a row/column vector of points, with possibly couples of NaN values.
##
## The function separates each component separated by NaN values, and
## returns a cell array of polygons.
##
## @seealso{polyjoin,ispolycw}
## @end deftypefn

## Created: 2017-07-19

function [cellx,celly] = polysplit(vecx,vecy)

  if (nargin != 2)
    #case wrong number of input arguments
     print_usage();
  endif

  if (iscell (vecx))
    if (iscell (vecy))
      # case of having two cell array
      cellx = vecx;
      celly = vecy;
    else
      error ('Octave:invalid-input-arg', ...
            "polysplit: vecx and vecy have different forms");
    endif

  elseif (length (vecx)!=length (vecy))
    # case of having two vectors of different lengthes
    error ('Octave:invalid-input-arg', ...
            "polysplit: vecx and vecy are of different lengths");

  elseif (sum (isnan (vecx(:))) != sum (isnan (vecy(:)))) 
    error ('Octave:invalid-input-arg', ...
            "polysplit: vecx and vecy should have the same number of polygon segments");
      
  else 
    ##column vector
    if(size(vecx)(2) == 1 && size(vecy)(2) == 1)
      #split the cell arrays of x coordinates and y coordinates
      cellx = splitPolygons(vecx);
      celly = splitPolygons(vecy);
    ##row vector
    elseif(size(vecx)(1) == 1 && size(vecy)(1) == 1)
      vecx = vecx';
      vecy = vecy';
      cellx = splitPolygons(vecx);
      celly = splitPolygons(vecy);
      cellx = cellfun(@transpose,cellx,'UniformOutput',false);
      celly = cellfun(@transpose,celly,'UniformOutput',false);
    endif
  
    #Check and remove if there are any empty cells
    emptyCells = cellfun(@isempty,cellx);
    emptyCells = cellfun(@isempty,celly);
    cellx(emptyCells) = [];
    celly(emptyCells) = [];

  endif

endfunction


%!test
%! x=[1 ;2 ;NaN ;3 ;4]; y=[4 ;3 ;NaN ;2 ;1];
%! [cellx,celly]=polysplit(x,y);
%! assert (cellx, {[1; 2];[3; 4]});
%! assert (celly, {[4; 3];[2; 1]});


%!test
%! x=[1 2 NaN 3 4]; y=[4 3 NaN 2 1];
%! [cellx,celly]=polysplit(x,y);
%! assert (cellx, {[1 2];[3 4]});
%! assert (celly, {[4 3];[2 1]});

%!test
%! x=[0 ;2 ;2 ;0 ;0 ;NaN ;NaN]; y=[0 ;0 ;3 ;3 ;0 ;NaN ;NaN];
%! [cellx,celly]=polysplit(x,y);
%! assert (cellx, {[0 ;2 ;2 ;0 ;0]});
%! assert (celly, {[0 ;0 ;3 ;3 ;0]});