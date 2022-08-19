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
## @deftypefn {Function File} {} dms2degrees (@var{dms})
## Convert degrees, and minutes components into decimal degrees.
##
## @var{dms} must be a 3 column matrix with one row per angle, and each
## column correspoding to its degrees (an integer), minutes (a less than
## 60 integer, and seconds (a less than 60 value, possibly fractional)
## components.
##
## The sign of the angle must be defined on its first non-zero component only,
## i.e., if an angle is negative, the seconds component must be positive
## unless both minutes and degrees are zero, and the minutes component
## must be positive unless the degrees component is zero.
##
## @seealso{degrees2dm, degree2dms, dm2degrees}
## @end deftypefn

## Author: Carnë Draug <carandraug@octave.org>

function deg = dms2degrees (dms)

  if (nargin != 1)
    print_usage ();
  elseif (! isnumeric (dms) || ndims (dms) != 2 || columns (dms) != 3)
    error ("dms2degrees: DMS must be a numeric matrix with 3 columns");
  elseif (any (fix (dms(:,1)) != dms(:,1)))
    error ("dms2degrees: degrees component (first column) must be an integer");
  elseif (any (dms(:,2) >= 60))
    error ("dms2degrees: minutes component (second column) must be less than 60");
  elseif (any (dms(:,3) >= 60))
    error ("dms2degrees: seconds component (third column) must be less than 60");
  endif

  ## join the degrees and minutes parts
  adms = abs (dms);
  deg  = sum ([adms(:,1) adms(:,2)/60 adms(:,3)/3600], 2);

  ## change the sign if any part is negative and check that negative
  ## sign is present on the first non-zero part only
  negs = dms < 0;
  nnz_d = dms(:,1) != 0;
  nnz_m = dms(:,2) != 0;
  if (any ((nnz_d | nnz_m) & negs(:,3)))
    error ("dms2degrees: second must be positive if degree or minute is non-zero");
  elseif (any (nnz_d & negs(:,2)))
    error ("dms2degrees: minute must be positive if degree is non-zero");
  endif
  deg(any (negs, 2)) *= -1;

endfunction

%!test
%! hs  = 0.5/60;
%! deg = [ 10  10.5  -10.5  -10  -0.5  0.5  hs  0  -1/60 ]' + hs;
%! dms = [ 10    0   30
%!         10   30   30
%!        -10   29   30
%!         -9   59   30
%!          0  -29   30
%!          0   30   30
%!          0    1    0
%!          0    0   30
%!          0    0  -30];
%! for i = 1:rows (dms)
%!   assert (dms2degrees (dms(i,:)), deg(i), 2*10^-15);
%! endfor
%! assert (dms2degrees (dms), deg, eps*10);
%! assert (dms2degrees (single (dms)), single (deg), 3*10^-8);

%!error <less than 60> dms2degrees ([5 40 60])
%!error <less than 60> dms2degrees ([5 40 61])
%!error <3 columns> dms2degrees ([5 50])
%!error <must be positive> dms2degrees ([5 -40 9])
%!error <must be positive> dms2degrees ([-5 -40 9])
%!error <must be positive> dms2degrees ([0 -40 -9])
%!error <3 columns> dms2degrees (rand (7, 3, 3))

