## Copyright (C) 2019 Juan Pablo Carbajal
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
## along with this program. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @defun {} drawFilledPolygon (@var{p})
## @defunx {} drawFilledPolygon (@var{hax}, @var{p})
## @defunx {} clipPolygon (@dots{}, @var{prop}, @var{value}, @dots{})
## @defunx {@var{h} =} drawFilledPolygon (@dots{})
## Draw a filled polygon.
##
## Add a patch representing the polygon(s) @var{p} in the current axes.
##
## Multiple property-value pairs may be specified, but they must
## appear in pairs.  These arguments are passed to the function @code{patch}.
##
## If the first argument @var{hax} is an axes handle, then plot into this
## axes, rather than the current axes returned by @code{gca}.
##
## If @var{p} is a cell, each element of the cell is processed in sequence.
##
## The optional return value @var{h} is a vector of graphics handles to the
## created patch objects.
##
## For example:
##
## Draw a polygon with default filling color and red edges.
##
## @example
## @group
## pol = [1 2; 7 4; 4 7; 1 2; NaN NaN; 2.5 3; 5.5 4; 4 5.5; 2.5 3];
## h = drawFilledPolygon (pol, 'edgecolor', 'r');
## @end group
## @end example
##
## @seealso{drawPolygon, polygon2patch, patch}
## @end defun

## Author: Juan Pablo Carbajal <ajuanpi+dev@gmail.com>
## Created: 2019-12-15

function h = drawFilledPolygon (px, varargin)

  # Check input
  if (nargin < 1)
      print_usage ();
  endif

  # Check for empty polygons
  if (isempty (px))
      return
  endif

  # Store hold state
  state = ishold (gca);
  hold on;

  # Extract handle of axis to draw on
  ax = gca;
  if (isAxisHandle (px))
      ax          = px;
      px          = varargin{1};
      varargin(1) = [];
  end

  ## Manage cell arrays of polygons
  # Case of a set of polygons stored in a cell array
  if (iscell (px))
    np = numel (px);
    h_  = zeros(1, np);
    for i = 1:np
      h_(np - i + 1) = drawFilledPolygon (px{i}, varargin{:});
    endfor

  else
    # Check size vs number of arguments
    if (size (px, 2) == 1)
      # Case of polygon specified as two N-by-1 arrays with same length
      if (nargin < 2 || nargin == 2 && ~isnumeric (varargin{1}))
          error('Octave:invalid-input-arg', ...
               ['drawFilledPolygon: Should specify either a N-by-2 array,' ...
                ' or 2 N-by-1 vectors']);
      endif

      # Merge coordinates of polygon vertices
      py          = varargin{1};
      varargin(1) = [];

      if (length (py) ~= length (px))
          error('Octave:invalid-input-arg', ...
               ['drawFilledPolygon: X and Y coordinate arrays should have' ...
                ' same lengths (%d,%d)'], length (px), length (py))
      endif

      px = [px py];
    elseif (size (px, 2) > 2 || size (px, 2) < 1)
      error ('Octave:invalid-input-arg', ...
             'drawFilledPolygon: Should specify a N-by-2 array');
    endif

    # Set default format
    fmtdef = {'facecolor', [0.7 0.7 0.7], ...
                 'edgecolor', 'k', ...
                 'linewidth', 2};
    varargin = {fmtdef{:}, varargin{:}};
#    if (isempty (varargin))
#        varargin = formatdef;
#    else # set missing with defaults
#        [tfdef, idxarg] = ismember (formatdef(1:2:end), ...
#                                     tolower (varargin(1:2:end)));
#        if (any (tfdef))
#          idxdef = find (tfdef);
#          idxarg = idxarg(idxarg > 0);
#          varargin(2 * idxarg) = formatdef(2 * idxdef);
#        endif
#    endif

    pxpatch = polygon2patch (px);
    h_      = patch (ax, pxpatch(:,1), pxpatch(:,2), varargin{:});

  endif # whether input arg was a cell

  if (~state)
      hold off
  endif

  # Avoid returning argument if not required
  if (nargout > 0)
      h = h_;
  endif

endfunction


%!demo
%! figure (1)
%! clf;
%! pol = [1 2; 7 4; 4 7; 1 2; NaN NaN; 2.5 3; 5.5 4; 4 5.5; 2.5 3];
%! subplot(131)
%! drawFilledPolygon(pol)
%! axis tight equal off
%! subplot(132)
%! drawFilledPolygon(pol, 'facecolor', 'c', 'linestyle', '--', 'edgecolor', 'r')
%! axis tight equal off
%! subplot(133)
%! R = createRotation (polygonCentroid (splitPolygons(pol){1}), pi/6);
%! pol2 =  transformPoint (pol, R);
%! drawFilledPolygon(pol, 'linestyle', 'none')
%! drawFilledPolygon(gca, pol2, 'facealpha', 0.5)
%! axis tight equal off

%!demo
%! pol   = [2 2; 6 2; 6 6; 2 6; 2 2; NaN NaN; 3 3; 3 5; 5 5; 5 3; 3 3];
%! n     = 5;
%! alpha = linspace(0.1, 1, n);
%! theta = linspace(pi / 3, 0, n);
%!
%! cpol = cell(n, 1);
%! for i = 1:n
%!  cpol{i} = transformPoint (pol, createRotation (theta(i)));
%! endfor
%! h = drawFilledPolygon(cpol, 'linestyle', 'none');
%! for i = 1:n-1
%!  set(h(i), 'facealpha', alpha(i))
%! endfor
%! axis tight equal off
