## Copyright (C) 2014-2022 Carnë Draug <carandraug@octave.org>
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{x}, @var{y}, @dots{}] =} removeExtraNanSeparators (@var{x}, @var{y}, @dots{})
## Remove groups of NaN and leave a single separator.
##
## For any number of vectors, @var{x}, @var{y}, @var{z}, @dots{}, reduce
## groups of contiguous NaNs into a single NaN separator.  The vectors must
## all have the same dimensions and the NaNs must be locations.  Leading NaNs
## are removed, and trailing NaNs are reduced to one.
##
## @example
## @group
## removeExtraNanSeparators ([NaN NaN 3 4 5 NaN NaN 8 NaN], [NaN NaN 7 6 5 NaN NaN 2 NaN])
## @result{x } [3 4 5 NaN 8 NaN]
## @result{y } [7 6 5 NaN 2 NaN]
## @end group
## @end example
##
## @seealso{diff, isnan, isna}
## @end deftypefn

## Author: Carnë Draug <carandraug@octave.org>

function [varargout] = removeExtraNanSeparators (varargin)

  if (nargin < 1)
    print_usage ();
  elseif (! isvector (varargin{1}) || ! size_equal (varargin{:}))
    error ("removeExtraNanSeparators: X, Y, Z, ... must be vectors with equal sizes");
  endif

  ## one row per input argument
  if (iscolumn (varargin{1}))
    ins = cell2mat (varargin)';
  else
    ins = cell2mat (varargin');
  endif

  nans = isnan (ins);

  if (any (nans(:)))
    if (any (any (nans) != all (nans)))
      error ("removeExtraNanSeparators: NaN and NA positions must be equal on X, Y, Z, ...");
    endif
    ## This will create a mask that selects the first change from a non-NaN
    ## into a NaN. If there are leaading NaN it will not identify them but
    ## it will identify the first of trailing NaNs.
    nan_sep = diff ([true nans(1,:)]) == 1;

    line_mask = ! nans(1,:) | nan_sep;
    full_mask = repmat (line_mask, [nargin 1]);

    elems = nnz (line_mask);
    outs  = reshape (ins(full_mask), [nargin elems]);
    if (iscolumn (varargin{1}))
      varargout = mat2cell (outs', elems, ones (nargin, 1));
    else
      varargout = mat2cell (outs, ones (nargin, 1), elems);
    endif

  else
    ## there are no NaNs, so give the input back
    varargout = varargin;
  endif

endfunction

## We remove trailing NaN and leave only one at the end
%!assert (nthargout (1:2, @removeExtraNanSeparators,
%!         [NaN NaN 3 4 5 6 NaN NaN], [NaN NaN 4 5 5 7 NaN NaN]),
%!        {[        3 4 5 6 NaN    ], [        4 5 5 7 NaN     ]});

## We leave individual NaN in the middle intact
%!assert (nthargout (1:2, @removeExtraNanSeparators,
%!         [NaN NaN 3 4 NaN 6 NaN], [NaN NaN 2 4 NaN 3 NaN]),
%!        {[        3 4 NaN 6 NaN], [        2 4 NaN 3 NaN]});

## We turn a group of NaN into a single separator
%!assert (nthargout (1:2, @removeExtraNanSeparators,
%!         [NaN 2 NaN NaN 6 NaN], [NaN 1 NaN NaN 8 NaN]),
%!        {[    2 NaN     6 NaN], [    1 NaN     8 NaN]});
%!assert (nthargout (1:2, @removeExtraNanSeparators,
%!         [1 2 NaN NaN 6 NaN], [8 1 NaN NaN 8 NaN]),
%!        {[1 2 NaN     6 NaN], [8 1 NaN     8 NaN]});

## We don't mess up when there's no trailing(s) NaN
%!assert (nthargout (1:2, @removeExtraNanSeparators,
%!         [1 2 NaN NaN 6], [8 1 NaN NaN 8]),
%!        {[1 2 NaN     6], [8 1 NaN     8]});

## We don't mess up when there's no NaN's at all
%!assert (nthargout (1:2, @removeExtraNanSeparators, 1:9, 1:9), {1:9 1:9})
%!assert (nthargout (1:2, @removeExtraNanSeparators, 9:-1:-9, 9:-1:-9), {9:-1:-9 9:-1:-9})

## We don't mess up for x, y, z, etc
%!assert (nthargout (1:3, @removeExtraNanSeparators,
%!         [1 2 NaN NaN 6], [8 1 NaN NaN 8], [5 6 NaN NaN 7]),
%!        {[1 2 NaN     6], [8 1 NaN     8], [5 6 NaN     7]});

## We don't mess up when we get column vector instead of row vectors
%!assert (nthargout (1:3, @removeExtraNanSeparators,
%!         [1 2 NaN NaN 6]', [8 1 NaN NaN 8]', [5 6 NaN NaN 7]'),
%!        {[1 2 NaN     6]', [8 1 NaN     8]', [5 6 NaN     7]'});


%!error <must be vectors> removeExtraNanSeparators (rand (5), rand (5))
%!error <equal sizes> removeExtraNanSeparators (rand (5, 1), rand (6, 1))
%!error <must be vectors> removeExtraNanSeparators (rand (5, 1), rand (5, 1), rand (5))
%!error <equal sizes> removeExtraNanSeparators (rand (5, 1), rand (5, 1), rand (6, 1))

%!error <NaN and NA positions> removeExtraNanSeparators ([NaN NaN 3 4 5 6 NaN], [NaN 2 3 4 5 6 NaN])
%!error <NaN and NA positions> removeExtraNanSeparators ([NaN NaN 3 4 5 6 NaN], [NaN NaN 3 4 5 6 NaN], [NaN 2 3 4 5 6 NaN])

