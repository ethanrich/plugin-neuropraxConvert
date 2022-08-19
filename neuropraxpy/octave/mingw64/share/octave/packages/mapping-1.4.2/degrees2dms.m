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
## @deftypefn {Function File} {} degrees2dms (@var{deg})
## Convert decimal degrees to its degrees, minutes, and seconds components.
##
## Separates the fractional part of an angle in decimal degrees and converts
## it into minutes and seconds.  Each row of the output corresponds to one
## angle the first and second column to the degree and minute component
## (both integers), and the third to the seconds (which may have a
## fractional part).
##
## @example
## @group
## degrees2dms (10 + 20/60 + 20/3600)
## @result{}  [ 10   20   20 ]
##
## degrees2dms (10 + 20/60 + pi)
## @result{}  [ 10   28   29.734 ]
## @end group
## @end example
##
## The sign of the first non-zero component indicates the sign of
## the angle, i.e., if the degree and minute components are zero, the sign
## of the seconds indicates the sign of the angle, but if the degree component
## is non-zero, both the minute and second components will be positive
## independently of the sign of the angle.
##
## @example
## @group
## angles = [  10.5
##            -10.5
##             -0.5
##              0.5 ];
## degrees2dms (angles)
##   @result{}
##          10   30   0
##         -10   30   0
##          -0  -30   0
##           0   30   0
## @end group
## @end example
##
## @seealso{degrees2dm, dm2degrees, dms2degrees}
## @end deftypefn

## Author: Carnë Draug <carandraug@octave.org>

function dms = degrees2dms (deg)

  if (nargin != 1)
    print_usage ();
  endif

  if (! iscolumn (deg))
    warning ("Octave:array-to-vector",
             "degrees2dms: DEG reshaped into column vector");
  endif

  if (isinteger (deg))
    ## If the angles are integers, there is no decimal part
    ## so this is easy. Also, class must be conserved.
    dms = [deg(:) zeros(numel (deg), 2, class (deg))];
  else
    ## Everything else is valid and will be converted to double (including
    ## text and logical). Only class single will be conserved.
    d = fix (deg(:));
    m = fix ((deg(:) - d) * 60);
    s = rem (deg(:) * 3600, 60);
    dms = [d m s];

    ## We could have also calculated the seconds part with
    ##    (m - fm) * 60
    ## where m and fm are the minutes before and after fix(). While
    ## that performs almost twice as fast, it also leads to some
    ## precision errors.

    ## remove sign from any minute and second where its degree part is non-zero
    nnzd = logical (dms(:,1));
    dms(nnzd, 2:3) = abs (dms(nnzd, 2:3));
    ## remove sign from any second where its minute is non-zero
    nnzm = logical (dms(:,2));
    dms(nnzm, 3) = abs (dms(nnzm, 3));
  endif

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
%! for i = 1:rows (deg)
%!   assert (degrees2dms (deg(i)), dms(i,:));
%! endfor
%! assert (degrees2dms (deg), dms);
%! assert (degrees2dms (single (deg)), single (dms), 4*10^-6);
%!
%! warning ("error", "Octave:array-to-vector", "local")
%! got_warn = false;
%! try
%!   degrees2dms (deg');
%! catch
%!   got_warn = true;
%! end_try_catch
%! assert (got_warn, true)

%!assert (degrees2dms ("f"), [102 0 0])
%!assert (degrees2dms ("fm"), [102 0 0; 109 0 0])
%!assert (degrees2dms (true), [1 0 0])
%!assert (degrees2dms ([true false]), [1 0 0; 0 0 0])
%!assert (degrees2dms (uint8 ([5 48 9]')), uint8 ([5 0 0; 48 0 0; 9 0 0]))

