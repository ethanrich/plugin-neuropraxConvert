## Copyright (c) 2014-2022 Michael Hirsch, Ph.D.
## Copyright (c) 2013-2022, Felipe Geremia Nievinski
## Copyright (C) 2019-2022 Philip Nienhuis
##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
## 1. Redistributions of source code must retain the above copyright notice,
##    this list of conditions and the following disclaimer.
## 2. Redistributions in binary form must reproduce the above copyright notice,
##    this list of conditions and the following disclaimer in the documentation
##    and/or other materials provided with the distribution.
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
## THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
## LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
## CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
## SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
## OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
## WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
## (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
## SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{n}, @var{e}, @var{d} =} aer2ned (@var{az}, @var{el}, @var{slantrange})
## @deftypefnx {Function File} {@var{n}, @var{e}, @var{d} =} aer2ned (@var{az}, @var{el}, @var{slantrange}, @var{angleUnit})
## Convert Azimuth, Elevation and Range (AER) coordinates to North, East, Down
## (NED) coordinates.
##
## Inputs:
## @itemize
## @item
## @var{az}, @var{el}, @var{slantrange}: look angles and distance to target
## point (ange, angle, length).  Scalars, vectors and nD-arrays are accepted
## and should have the same dimensions and length units.
##
## @item
## @var{angleUnit}: string for angular units ('degrees' or 'radians',
## case-insensitive, just the first character will do).  Default is 'degrees'.
## @end itemize
##
## Outputs:
## @itemize
## @item
## @var{n}, @var{e}, @var{d}: North, East, Down coordinates of points.
## (same length units as inputs).
## @end itemize
##
## Examples:
## @example
## [n, e, d] = aer2ned (33, 70, 1e3)
## n =  286.84
## e =  186.28
## d = -939.69
## @end example
##
## With radians
## @example
## [n, e, d] = aer2ned (pi/4, pi/3,1e3, "radians")
## n =  353.55
## e =  353.55
## d = -866.03
## @end example
##
## @seealso{ned2aer, aer2ecef, aer2enu, aer2geodetic}
##
## @end deftypefn

## Function adapted by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?8377

function [n, e, d] = aer2ned (az, el, slantrange, angleUnit = "degrees")

  if (nargin < 3)
    print_usage();
  endif

  if (! isnumeric (az)         || ! isreal (az) || ...
      ! isnumeric (el)         || ! isreal (el) || ...
      ! isnumeric (slantrange) || ! isreal (slantrange))
    error ("aer2ned: numeric values expected for first three inputs.");
  endif

  if (! all (size (az) == size (el)) || ! all (size (el) == size (slantrange)))
    error ("aer2ned: non-matching dimensions of inputs.");
  endif

  if (! ischar (angleUnit))
    error ("aer2ned: character value expected for 'angleUnit'");
  elseif (strncmpi (angleUnit, "degrees", length (angleUnit)))
    az = deg2rad (az);
    el = deg2rad (el);
  elseif (! strncmpi (angleUnit, "radians", length (angleUnit)))
    error ("aer2ned: illegal input for 'angleUnit'");
  endif

   ## Calculation of AER2NED
   d = -slantrange .* sin (el);
   r = slantrange .* cos (el);
   e = r .* sin (az);
   n = r .* cos (az);

endfunction

%!test
%! [n, e, d] = aer2ned (33, 70, 1e3);
%! assert ([n, e, d], [286.84222, 186.277521, -939.69262], 10e-6)
%! [e, n, u] = aer2ned (0.57595865, 1.221730476, 1e3, "rad");
%! assert ([e, n, u], [286.84222, 186.277521, -939.69262], 10e-6)

%!error <numeric> aer2ned("s", 25, 1e3)
%!error <numeric> aer2ned(3i, 25, 1e3)
%!error <numeric> aer2ned(33, "s", 1e3)
%!error <numeric> aer2ned(33, 3i, 1e3)
%!error <numeric> aer2ned(33, 25, "s")
%!error <numeric> aer2ned(33, 25, 3i)
%!error <non-matching> aer2ned ([1 1], [2 2]', [4 5])
%!error <non-matching> aer2ned ([1 1], [2 2], [4 5 6])
%!error <character> aer2ned (1, 2, 3, 4);
%!error <illegal> aer2ned (33, 70, 1e3, "f");
%!error <illegal> aer2ned (33, 70, 1e3, "degreef");

