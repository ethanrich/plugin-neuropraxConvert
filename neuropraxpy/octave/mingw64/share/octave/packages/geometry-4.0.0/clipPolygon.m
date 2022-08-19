## Copyright (C) 2017 - 2019 Philip Nienhuis
## Copyright (C) 2017 - 2019 Juan Pablo Carbajal
## Copyright (C) 2017 - 2019 Piyush Jain
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

## -*- texinfo -*-
## @deffn {} [@var{outpol}, @var{npol}] = clipPolygon (@var{inpol}, @var{clippol}, @var{op})
## @deffnx {} [@var{outpol}, @var{npol}] = clipPolygon (@var{inpol}, @var{clippol}, @var{op}, @var{library})
## @deffnx {} [@var{outpol}, @var{npol}] = clipPolygon (@dots{}, @var{args})
## Perform boolean operation on polygon(s) using one of several algorithms.
##
## @var{inpol} = Nx2 matrix of (X, Y) coordinates constituting the polygons(s)
## to be clipped (subject polygons).  Polygons are separated by [NaN NaN] rows.
##
## @var{clippol} = another Nx2 matrix of (X, Y) coordinates representing the
## clip polygon(s). @*
## @var{clippol} can also be a vector containing the bottom left and upper right
## coordinates of a clipping rectangle, or bounding box, in the format @*
## [xmin xmax ymin ymax].
##
## The argument @var{op}, the boolean operation, can be either an integer or a
## string. In the case of integer it should be between 0 and 3, correspoding to:
##
## @itemize
## @item 0: difference @var{inpol} - @var{clippol}
##
## @item 1: intersection ('AND') of @var{inpol} and @var{clippol} (= default)
##
## @item 2: exclusiveOR ('XOR') of @var{inpol} and @var{clippol}
##
## @item 3: union ('OR') of @var{inpol} and @var{clippol}
## @end itemize
##
## If @var{op} is a string should be one of @asis{'diff', 'and', 'xor', 'or'},
## the parsing of this option is case insensitive, i.e. @asis{'AND'} is the same
## as @asis{'and'}.
##
## The optional argument @var{library} specifies which library to use for clipping.
## Currently @asis{'clipper'}  and @asis{'mrf'} are implemented.  Option
## @asis{'clipper'} uses a MEX interface to the Clipper library, option
## @asis{'mrf'} uses the algorithm by Martinez, Rueda and Feito implemented
## with OCT files. @*
## Each library interprets polygons as holes differently, refer to the help
## of the specific function to learn how to pass polygons with holes.
##
## Output array @var{outpol} will be an Nx2 array of polygons resulting from
## the requested boolean operation, or in case of just one input argument an
## Nx1 array indicating winding direction of each subpolygon in input argument
## @var{inpol}.
##
## Optional output argument @var{npol} indicates the number of output polygons.
##
## @seealso{clipPolygon_clipper, clipPolygon_mrf, clipPolyline}
## @end deffn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2017-03-21

function [opol, npol] = clipPolygon (inpol, clipol, op, library = 'clipper', varargin)

  # Check number of required input arguments
  if (nargin < 3)
    print_usage ()
  endif

  if (any (size (clipol) == 1))
    ## Bottom left - upper right corner of clip rectangle input.
    ## Check if clipol geometry is acceptable.
    if (clipol(1) >= clipol(2) || clipol(3) >= clipol(4))
      error ('Octave:invalid-input-arg', ...
             ['clipPolygon: clip rectangle has zero or negative area - ' ...
              'check coordinates']);
    endif
    clipol = reshape (clipol(:)', 2, []);
    clipol = [clipol(1, :); clipol(1, :); clipol(2, :); clipol(2, :)];
    clipol = [clipol(:, 1) circshift(clipol(:, 2), -1)];
    op = 1;
  endif

  ## Very basic input check. Other checks are in called functions.
  if (size (inpol, 1) < 3 || size (clipol, 1) < 3)
    error ('Octave:invalid-input-arg', ...
      'clipPolygon: subject or clip polygons must have at least 3 vertices');
  endif

  ## Parse operations given as strings
  if (ischar (op) )
    [~, op_] = ismember (tolower (op), {'diff', 'and', 'xor', 'or'});
    if (op_ == 0) # wrong operation string
      error ('Octave:invalid-input-arg', ...
             'clipPolygon: operation "%s" unknown', op);
    endif
    op = op_ - 1;
  endif

  switch library

    case 'clipper'
      [opol, npol] = clipPolygon_clipper (inpol, clipol, op, varargin{:});

    case 'mrf'
      [opol, npol] = clipPolygon_mrf (inpol, clipol, op, varargin{:});

    otherwise
      error ('Octave:invalid-fun-call', ...
          'clipPolygon: unimplemented polygon clipping library: "%s"', library);

  endswitch

endfunction

%!error clipPolygon([],[],[],'abracadabra')
%!error clipPolygon([0 0; 0 1; 0.5 1],[-1 -1; -1 1; 0 1],'no-op')

%!demo
%! pol1  = [2 2; 6 2; 6 6; 2 6; 2 2; NaN NaN; 3 3; 3 5; 5 5; 5 3; 3 3];
%! pol2  = [1 2; 7 4; 4 7; 1 2; NaN NaN; 2.5 3; 5.5 4; 4 5.5; 2.5 3];
%!
%! subplot (3, 3, 1)
%! drawFilledPolygon (pol1, 'edgecolor', 'k', 'facecolor', 'c')
%! axis image
%! title ('1. Subject polygon')
%! axis off
%!
%! subplot (3, 3, 2)
%! drawFilledPolygon (pol1, 'linestyle', 'none', 'facecolor', 'c')
%! drawFilledPolygon (pol2, 'edgecolor', 'b', 'facecolor', 'y')
%! axis image
%! title ('2. Clip polygon')
%! axis off
%!
%! algo = {'clipper', 'mrf'};
%! for i = 1:numel (algo)
%!   subplot (3, 3, i+2);
%!   tic
%!   [opol, npol] = clipPolygon (pol1, pol2, 3, 'clipper');
%!   printf('%s took: %f seconds (union)\n', algo{i}, toc);
%!   drawFilledPolygon (opol, 'edgecolor', 'r', 'facecolor', 'g')
%!   axis image
%!   title (sprintf('Union - %s', algo{i}));
%!   axis off
%!
%!   subplot (3, 3, i+4);
%!   tic
%!   [opol, npol] = clipPolygon (pol1, pol2, 1, 'clipper');
%!   printf('%s took: %f seconds (and)\n', algo{i}, toc);
%!   drawFilledPolygon (opol, 'edgecolor', 'r', 'facecolor', 'g')
%!   axis image
%!   title (sprintf('And - %s', algo{i}));
%!   axis off
%!
%!   subplot (3, 3, i+6);
%!   tic
%!   [opol, npol] = clipPolygon (pol1, pol2, 2, 'clipper');
%!   printf('%s took: %f seconds (xor)\n', algo{i}, toc);
%!   drawFilledPolygon (opol, 'edgecolor', 'r', 'facecolor', 'g')
%!   axis image
%!   title (sprintf('Xor - %s', algo{i}));
%!   axis off
%! endfor
