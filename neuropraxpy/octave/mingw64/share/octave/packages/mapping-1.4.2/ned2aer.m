## Copyright (C) 2014-2022 Michael Hirsch, Ph.D.
## Copyright (C) 2013-2022, Felipe Geremia Nievinski
## Copyright (C) 2020-2022 Philip Nienhuis
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
## @deftypefn {Function File} {@var{az}, @var{el}, @var{slantrange} =} ned2aer (@var{n}, @var{e}, @var{d})
## @deftypefnx {Function File} {@var{az}, @var{el}, @var{slantrange} =} ned2aer (@var{n}, @var{e}, @var{d}, @var{angleUnit})
## Convert NED (North, East, Down)coordinates to AER (Azimuth, Elevation,
## slantRange) coordinates.
##
## Inputs:
## @itemize
## @item
## @var{n}, @var{e}, @var{d}: North, East, Down coordinates of test points
## in consistent length units.
##
## @item
## @var{angleUnit}: string for angular units ('degrees' or 'radians',
## case-insensitive, just the first character will do).  Default is 'degrees'.
## @end itemize
##
## Outputs:
## @itemize
## @item
## @var{az}: azimuth angle clockwise from local north (degrees).
##
## @item
## @var{el}: elevation angle above local horizon (degrees).
##
## @item
## @var{slantrange}: distance from origin in local spherical system (same as
## input units).
## @end itemize
##
## Examples:
## @example
## [az, el, slantrange] = ned2aer (286.84, 186.28, -939.69)
## az =  33.001
## el =  70.000
## slantrange = 1000.00
## @end example
##
## With radians:
## @example
## [az, el, slantrange] = ned2aer (353.55, 353.55, -866.03, "r")
## az =  0.78540
## el =  1.0472
## slantrange =  1000.0
## @end example
##
## @seealso{aer2ned, ned2ecef, ned2ecefv, ned2geodetic}
## @end deftypefn

## Function adapted by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9918

function [az, el, slantrange] = ned2aer (n, e, d, angleUnit = "degrees")

  if nargin < 3
    print_usage();
  endif

  if (! isnumeric (n) || ! isreal (n) || ...
      ! isnumeric (e) || ! isreal (e) || ...
      ! isnumeric (d) || ! isreal (d))
    error ("ned2aer: numeric real values expected for first three inputs.");
  endif

  if (! all (size (n) == size (e)) || ! all (size (e) == size (d)))
    error ("ned2aer: non-matching dimensions of inputs.");
  endif

  r = hypot (e, n);
  slantrange = hypot (r, d);
  ## radians
  el = -atan2 (d, r);
  az = mod (atan2 (e, n), 2 * atan2 (0, -1));

  if (nargin == 3)
    az = rad2deg (az);
    el = rad2deg (el);
  endif

endfunction

%!test
%! [az, el, slantrange] = ned2aer (286.84222, 186.277521, -939.69262);
%! assert ([az, el, slantrange], [33, 70, 1e3], 10e-6)
%! [az, el, slantrange] = ned2aer (286.84222, 186.277521, -939.69262, "rad");
%! assert ([az, el, slantrange], [0.57595865, 1.221730476, 1e3], 10e-6)

%!error <numeric> ned2aer ("s", 25, 1e3)
%!error <numeric> ned2aer (3i, 25, 1e3)
%!error <numeric> ned2aer (33, "s", 1e3)
%!error <numeric> ned2aer (33, 3i, 1e3)
%!error <numeric> ned2aer (33, 25, "s")
%!error <numeric> ned2aer (33, 25, 3i)
%!error <non-matching> ned2aer ([1 1], [2 2]', [4 5])
%!error <non-matching> ned2aer ([1 1], [2 2], [4 5 6])

