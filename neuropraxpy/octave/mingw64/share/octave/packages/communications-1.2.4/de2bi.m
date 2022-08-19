## Copyright (C) 2020 Nicholas Jankowski
## Copyright (C) 2015 Michael Hirsch
## Copyright (C) 2001 Laurent Mazet
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {@var{b} =} de2bi (@var{d})
## @deftypefnx {Function File} {@var{b} =} de2bi (@var{d}, @var{n})
## @deftypefnx {Function File} {@var{b} =} de2bi (@var{d}, @var{n}, @var{p})
## @deftypefnx {Function File} {@var{b} =} de2bi (@var{d}, @dots{}, @var{f})
##
## Convert a non-negative integer to bit vector.
##
## The variable @var{d} must be a vector of non-negative integers. @code{de2bi}
## then returns a matrix where each row represents the binary representation
## of elements of @var{d}. If @var{n} is defined then the returned matrix
## will have @var{n} columns. This number of columns can be either larger
## than the minimum needed and zeros will be added to the msb of the
## binary representation or smaller than the minimum in which case the
## least-significant part of the element is returned.
##
## If @var{p} is defined then it is used as the base for the decomposition
## of the returned values. That is the elements of the returned value are
## between '0' and 'p-1'. (@var{p} must have a value of 2 or higher.)
##
## The variable @var{f} defines whether the first or last element of @var{b}
## is considered to be the most-significant. Valid values of @var{f} are
## "right-msb" or "left-msb". By default @var{f} is "right-msb".
##
## @seealso{bi2de}
## @end deftypefn

function b = de2bi (d, varargin)

  if (nargin == 1)
    p = 2;
    n = floor ( log (max (max (d), 1)) ./ log (p) ) + 1;
    f = "right-msb";
  else
    n = [];
    p = []; 
    f = [];

    % first pull out non-numeric inputs
    msb_flag_chk = cellfun (@ischar, varargin);
    if any(msb_flag_chk)
      if sum (msb_flag_chk) > 1
        %should never be more than one string input
        print_usage ();
      else
        f = varargin{msb_flag_chk};
        varargin = varargin(~msb_flag_chk);
      endif
    else
      f = "right-msb";
    endif

    %varargin should now be length 0, 1, or 2, all non-char
    numer_inputs = numel (varargin);

    if numer_inputs == 2
      n = varargin{1};
      p = varargin{2};
    elseif numer_inputs == 1
      n = varargin{1};
      p = 2;
    elseif numer_inputs == 0
      p = 2;
      n = floor ( log (max (max (d), 1)) ./ log (p) ) + 1;
    else
      print_usage ();
    endif

    %if user passed any [] as inputs, set to defaults
    if isempty (p)
      p = 2;
    endif
    if isempty (n)
      n = floor ( log (max (max (d), 1)) ./ log (p) ) + 1;
    endif
    if isempty (f)
      f = "right-msb";
    endif
  endif

  ##TODO: previous versions permitted negative base, but did not actually output
  ## values according to negative-base system rules. If this is desired the p<0
  ## check can be removed and proper negative-base arithmetic can be added.
  ## Also removed p=0 and 1 which caused errors in n-calculation.  
  if (p < 2)
    error ("de2bi: conversion base must be 2 or greater");
  endif
  
  classorig = class(d);
  d = double(d(:));
  p = double(p);
  if (! (all (d == fix (d)) && all (d >= 0)))
    error ("de2bi: all elements of D must be non-negative integers");
  endif

  if (isempty (n))
    n = floor ( log (max (max (d), 1)) ./ log (p) ) + 1;
  endif

  power = ones (length (d), 1) * (p .^ [0 : n-1] );
  d = d * ones (1, n);
  b = floor (rem (d, p*power) ./ power);

  if (strcmp (f, "left-msb"))
    b = b(:,columns (b):-1:1);
  elseif (!strcmp (f, "right-msb"))
    error ("de2bi: invalid option '%s'", f);
  endif
  
  b=cast(b,classorig);

endfunction

%!shared x
%! x = randi ([0 2^16-1], 100, 1);
%!assert (de2bi (0), 0)
%!assert (de2bi (1), 1)
%!assert (de2bi (uint8(31), ones (1,5)))
%!assert (class(de2bi(uint8(31))), 'uint8')
%!assert (de2bi (255), ones (1, 8))
%!assert (de2bi (255, [], 256), 255)
%!assert (de2bi (1023, 8, 8), [7 7 7 1 0 0 0 0])
%!assert (size (de2bi (x, 16)), [100 16])
%!assert (de2bi (x, 16, "right-msb"), de2bi (x, 16))
%!assert (de2bi (x, 16, "left-msb"), fliplr (de2bi (x, 16)))
%!assert (de2bi (13, "right-msb"), [1 0 1 1])
%!assert (de2bi (13, "left-msb"), [1 1 0 1])
%!assert (de2bi (13, [], "right-msb"), [1 0 1 1])
%!assert (de2bi (13, [], [], "right-msb"), [1 0 1 1])

%% Test input validation
%!error de2bi ()
%!error de2bi (1, 2, 3, 4, 5)
%!error de2bi (1, 2, 3, 4)
%!error de2bi (1, 2, 3, "invalid")
%!error de2bi (0.1)
%!error de2bi (-1)
%!error de2bi (5,[],1)
%!error de2bi (5,[],0)
%!error de2bi (5,[],-2)
