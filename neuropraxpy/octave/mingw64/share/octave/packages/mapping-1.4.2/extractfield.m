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
## @deftypefn {Function File} {} extractfield (@var{s}, @var{field})
## Extract field values from struct array.
##
## Concatenates all the values from the field member @var{field} in the
## structure array @var{s}.  The values are all concatenated into a row
## vector of the same type as the values.
##
## @group
## @example
## s(1).field = 1:3;
## s(2).field = 4:9;
## extractfield (s, "field")
## @result{} [ 1   2   3   4   5   6   7   8   9 ]
## @end example
## @end group
##
## If any of the values is a string, or if the class is not the same for
## all the elements, a cell array with the intact elements is returned
## instead.
##
## @group
## @example
## s(1).field = 1:3;
## s(2).field = uint8 (4:6);
## extractfield (s, "field")
## @result{[1, 1] } [ 1   2   3 ]
## @result{[1, 2] } [ 4   5   6 ]
## @end example
##
## @example
## s(1).field = "text";
## s(2).field = 1:3;
## extractfield (s, "field")
## @result{[1, 1] } text
## @result{[1, 2] } [ 1   2   3 ]
## @end example
## @end group
##
## @seealso{cell2mat, cellfun, getfield}
## @end deftypefn

## Author: Carnë Draug <carandraug@octave.org>

function vals = extractfield (s, name)

  if (nargin != 2)
    print_usage ();
  elseif (! isstruct (s))
    error ("extractfield: S must be a struct");
  elseif (! isfield (s, name))
    error ("extractfield: NAME is a not a field of S");
  endif

  vals = {s(:).(name)};
  ## If none of them is char and they are all of the same class,
  ## get a vector out of it
  if (! any (cellfun ("isclass", vals, "char")) &&
      all (cellfun ("isclass", vals, class (vals{1}))))

    ## matlab compatibility, all values in single row
    foo = @(x) vec (x, 2);
    vals = cell2mat (cellfun (foo, vals, "UniformOutput", false));
  endif

endfunction

%!test
%! a = {1:3, 4:6, [7:9]', 10:11, uint8(12:13), "text"};
%! s(1).a = a{1};
%! s(2).a = a{2};
%! assert (extractfield (s, "a"), 1:6);
%! s(3).a = a{3};
%! assert (extractfield (s, "a"), 1:9);
%! s(4).a = a{4};
%! assert (extractfield (s, "a"), 1:11);
%! s(5).a = a{5};
%! assert (extractfield (s, "a"), a(1:5));
%! s(6).a = a{6};
%! assert (extractfield (s, "a"), a);

## we don't mess up when transposing complex numbers
%!test
%! s(1).a = [4 5];
%! s(2).a = [6i 7i 8];
%! assert (extractfield (s, "a"), [4 5 6i 7i 8]);

%!test
%! s(1).a = 0;
%! s(2).a = false;
%! assert (extractfield (s, "a"), {0, false});

## check we don't mess up when there's other fields
%!test
%! s = struct ("a", mat2cell (1:10, 1, [3 3 4]),
%!             "b", mat2cell (11:20, 1, [5 2 3]));
%! assert (extractfield (s, "a"), 1:10);
%! assert (extractfield (s, "b"), 11:20);

%!error <S must be a struct> extractfield (5, "name")
%!error <not a field of S> extractfield (struct ("name", 5), "not a name")

