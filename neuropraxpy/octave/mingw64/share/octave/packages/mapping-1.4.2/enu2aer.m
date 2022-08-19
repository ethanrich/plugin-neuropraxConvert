## Copyright (C) 2014-2022 Michael Hirsch
## Copyright (C) 2013-2022 Felipe Geremia Nievinski
## Copyright (C) 2020-2022 Philip Nienhuis
##
## Redistribution and use in source and binary forms, with or without modification, are permitted
## provided that the following conditions are met:
## 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the followin
## 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the follo
##    in the documentation and/or other materials provided with the distribution.
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
## INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
## IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EX
## (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUS
## HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENC
## ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## -*- texinfo -*-
## @deftypefn   {Function File} {@var{az}, @var{el}, @var{slantrange}@var{e}, @var{n}, @var{u} =} aer2enu (@var{e}, @var{n}, @var{u})
## @deftypefnx  {Function File} {@var{az}, @var{el}, @var{slantrange}@var{e}, @var{n}, @var{u} =} aer2enu (@var{e}, @var{n}, @var{u}, @var{angleUnit}))
## Convert cartesian ENU (East, North, Up) coordinates into spherical AER)
## (Azimuth, Elevation, Range) coordinates.
##
## Inputs:
## @itemize
## @item
## @var{e}, @var{n}, @var{u}:  East, North, Up cartesian coordinates (in
## consistent length units).
##
## @item
## @var{angleUnit} (optional): string for angular units ('degrees' or 'radians',
## case-insensitive, just the first character will do).  Default is 'degrees'.
## @end itemize
##
## Outputs:
## @itemize
## @item
## @var{az}: azimuth angle clockwise from local north (angle).
##
## @item
## @var{el}: elevation angle above local horizon (angle).
##
## @item
## @var{slantrange}: distance from origin in local spherical system (length
## unit same as input length units).
## @end itemize
##
## Example:
## @example
## [az, el, slantrange] = enu2aer (186.28, 286.84, 939.69)
## az = 33.001
## el = 70.000
## slantrange = 1000.00
## @end example
##
## In radians
## @example
## [az, el, slantrange] = enu2aer (353.55, 353.55, -866.03, "r")
## az = 0.78540
## el = 1.0472
## slantrange = 1000.0
## @end example
##
## @seealso{aer2enu, enu2ecef, enu2ecefv, enu2geodetic, enu2uvw}
##
## @end deftypefn

## Function adapted by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?8377

function [az, el, slantrange] = enu2aer (e, n, u, angleUnit = "degrees")

  if (nargin < 3)
    print_usage();
  endif

  if (! isnumeric (e) || ! isreal (e) || ...
      ! isnumeric (n) || ! isreal (n) || ...
      ! isnumeric (u) || ! isreal (u))
    error ("enu2aer: numeric values expected for first three inputs.");
  endif

  if (! all (size (n) == size (e)) || ! all (size (e) == size (u)))
    error ("enu2aer: non-matching dimensions of inputs.");
  endif

  r = hypot (e, n);
  slantrange = hypot (r, u);
  ## Radians
  el = atan2 (u, r);
  az = mod (atan2 (e, n), 2 * atan2 (0, -1));

  if ( strncmpi (angleUnit, "degrees", length (angleUnit)))
    ## Convert from degrees
    az = rad2deg (az);
    el = rad2deg (el);
  endif

endfunction

%!test
%! [az, el, slantrange] = enu2aer (186.277521, 286.84222, 939.69262);
%! assert ([az, el, slantrange], [33, 70, 1e3], 10e-6)

%!test
%! [az, el, slantrange] = enu2aer (186.277521, 286.84222, 939.69262, "rad");
%! assert ([az, el, slantrange], [0.57595865, 1.221730476, 1e3], 10e-6)

%!test
%! [az, el, sr] = enu2aer ([8450.4; 186.277521], [12473.7; 286.84222], ...
%!                         [1104.6; 939.69262]);
%! assert ([az, el, sr], [34.115966, 4.193108, 15107.037863; 33.000001, ...
%!                        70.0, 999.999997], 1e-6)

%!error <numeric> enu2aer ("s", 25, 1e3)
%!error <numeric> enu2aer (3i, 25, 1e3)
%!error <numeric> enu2aer (33, "s", 1e3)
%!error <numeric> enu2aer (33, 3i, 1e3)
%!error <numeric> enu2aer (33, 25, "s")
%!error <numeric> enu2aer (33, 25, 3i)
%!error <non-matching> enu2aer ([1 1], [2 2]', [4 5])
%!error <non-matching> enu2aer ([1 1], [2 2], [4 5 6])

