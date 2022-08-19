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
## @deftypefn {Function File} {} dm2degrees (@var{dm})
## Convert degrees, minutes, and seconds components into decimal degrees.
##
## @var{dm} must be a 2 column matrix with one row per angle, each
## column correspoding to its degrees (an integer), and minutes (a less
## than 60 value, possibly fractional) components.
##
## The sign of the angle must be defined on its first non-zero component only,
## i.e., if an angle is negative, the minutes component must be positive
## unless its degrees component is zero.
##
## @seealso{degrees2dm, degree2dms, dms2degrees}
## @end deftypefn

## Author: Carnë Draug <carandraug@octave.org>

function deg = dm2degrees (dm)

  if (nargin != 1)
    print_usage ();
  elseif (! isnumeric (dm) || ndims (dm) != 2 || columns (dm) != 2)
    error ("dm2degrees: DM must be a numeric matrix with 2 columns");
  elseif (any (fix (dm(:,1)) != dm(:,1)))
    error ("dm2degrees: degrees component (first column) must be an integer");
  elseif (any (dm(:,2) >= 60))
    error ("dm2degrees: minutes component (second column) must be less than 60");
  endif

  ## join the degrees and minutes parts
  adm = abs (dm);
  deg = sum ([adm(:,1) adm(:,2)/60], 2);

  ## change the sign if any part is negative and check that negative
  ## sign is present on the first non-zero part only
  negs = dm < 0;
  if (any (dm(:,1) != 0 & negs(:,2)))
    error ("dm2degrees: minutes must be positive if degree is non-zero");
  endif
  deg(any (negs, 2)) *= -1;

endfunction

%!test
%! deg = [10 10.5 -10.5 -0.5 0.5]';
%! dm = [ 10    0
%!        10   30
%!       -10   30
%!         0  -30
%!         0   30];
%! for i = 1:rows (dm)
%!   assert (dm2degrees (dm(i,:)), deg(i));
%! endfor
%! assert (dm2degrees (dm), deg);
%! assert (dm2degrees (single (dm)), single (deg));

%!error <less than 60> dm2degrees ([5 60])
%!error <less than 60> dm2degrees ([5 61])
%!error <2 columns> dm2degrees ([5 50 3])
%!error <must be positive> dm2degrees ([5 -40])
%!error <must be positive> dm2degrees ([-5 -40])
%!error dm2degrees (rand (7, 2, 3))
