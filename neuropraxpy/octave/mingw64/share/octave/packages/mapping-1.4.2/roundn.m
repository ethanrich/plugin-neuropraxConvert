## Copyright (C) 2015-2022 Markus Bergholz <markuman@gmail.com>
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
## @deftypefn  {Function File} {} roundn (@var{X})
## @deftypefnx {Function File} {} roundn (@var{X}, @var{n})
## Round to powers of 10.
##
## Returns the double nearest to 10^@var{n}, where @var{n}
## has to be an integer scalar.  @var{n} defaults to zero.
##
## @seealso{round ceil floor fix roundb}
## @end deftypefn

function ret = roundn (x, n = 0)

  if (nargin < 1 || nargin > 2)
    print_usage ();
  endif

  if (abs (mod (n, 1)) > 1e-14)
    error ("roundn: precision argument must be an exactly integer number");
  endif

  ret = round (x / 10^n) * 10^n;

endfunction

%!assert (roundn (pi), 3, 2e-15)
%!assert (roundn (e, -2), 2.7200, 2e-15)
%!assert (roundn (pi, -4), 3.1416, 2e-15)
%!assert (roundn (e, -3), 2.718, 2e-15)
%!assert (roundn ([0.197608841252122, 0.384415323084123; ...
%!                 0.213847642260694, 0.464622347858917], -2), ...
%!        [0.20, 0.38; 0.21, 0.46], 2e-15)
%!assert (roundn (401189, 3), 401000, 2e-15)
%!assert (roundn (5), 5, 2e-15)
%!assert (roundn (-5), -5, 2e-15)
