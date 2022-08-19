## Copyright (C) 2014-2022 Michael Hirsch
## Copyright (C) 2013-2022 Felipe Geremia Nievinski
## Copyright (C) 2019-2022 Philip Nienhuis
##
## Redistribution and use in source and binary forms, with or without modification, are permitted
## provided that the following conditions are met:
## 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
## 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
##    in the documentation and/or other materials provided with the distribution.
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
## INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
## IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
## (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
## HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
## ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## -*- texinfo -*-
## @deftypefn  {Function File} {@var{e}, @var{n}, @var{u} =} aer2enu (@var{az}, @var{el}, @var{slantrange})
## @deftypefnx {Function File} {@var{e}, @var{n}, @var{u} =} aer2enu (@var{az}, @var{el}, @var{slantrange}, @var{angleUnit})
## Convert spherical Azimuth, Elevation and Range (AER) coordinates into
## cartesian East, North, Up (ENU) coordinates.
##
## Inputs:
## @itemize
## @var{az}, @var{el}, @var{slantrange}: look angles and distance to target
## points (angle, angle, length).  Scalars, vectors and nD-arrays are accepted
## and should have the same dimensions and length units.
##
## @item
## @var{az}: azimuth angle clockwise from local north.
##
## @item
## @var{el}: elevation angle above local horizon.
##
## @item
## @var{slantrange}: distance from origin in local spherical system.
##
## @item
## (Optional) angleUnit: string for angular units (radians or degrees).
## Default is 'd': degrees
## @end itemize
##
## Outputs:
##
## @itemize
## @item
## @var{e}, @var{n}, @var{u}:  East, North, Up Cartesian coordinates
## (length units and dimensions same as @var{slantrange}).
## @end itemize
##
## Example:
## @example
## [e, n, u] = aer2enu (33, 70, 1e3)
## e =  186.28
## n =  286.84
## u =  939.69
## @end example
##
## In radians
## @example
## [e, n, u] = aer2enu (pi/4, pi/3,1e3, "radians")
## e =  353.55
## n =  353.55
## u =  866.03
## @end example
##
## @seealso{enu2aer, aer2ecef, aer2geodetic, aer2ned}
##
## @end deftypefn

## Function adapted by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?8377

function [e, n, u] = aer2enu (az, el, slantrange, angleUnit = "degrees")

  if (nargin < 3 || nargin > 4)
    print_usage();
  endif

  if (! isnumeric (az) || ! isreal (az) || ...
      ! isnumeric (el) || ! isreal (el) || ...
      ! isnumeric (slantrange) || ! isreal (slantrange))
    error ("aer2enu : numeric input values expected");
  endif

  if (! all (size (az) == size (el)) || ! all (size (el) == size (slantrange)))
    error ("aer2enu: non-matching dimensions of inputs.");
  endif

  if (! ischar (angleUnit))
    error ("aer2enu: character value expected for 'angleUnit'");
  elseif (strncmpi (angleUnit, "degrees", length (angleUnit)))
    az = deg2rad (az);
    el = deg2rad (el);
  elseif (! strncmpi (angleUnit, "radians", length (angleUnit)))
    error ("aer2enu: illegal input for 'angleUnit'");
  endif

  ## Calculation of AER2ENU
  u = slantrange .* sin (el);
  r = slantrange .* cos (el);
  e = r .* sin (az);
  n = r .* cos (az);

endfunction


%!test
%! [e, n, u] = aer2enu (33, 70, 1e3);
%! assert ([e, n, u], [186.277521, 286.84222, 939.69262], 10e-6)
%! [e, n, u] = aer2enu (0.57595865, 1.221730476, 1e3, "rad");
%!  assert ([e, n, u], [186.277521, 286.84222, 939.69262], 10e-6)

%!error <numeric> aer2enu("s", 25, 1e3)
%!error <numeric> aer2enu(3i, 25, 1e3)
%!error <numeric> aer2enu(33, "s", 1e3)
%!error <numeric> aer2enu(33, 3i, 1e3)
%!error <numeric> aer2enu(33, 25, "s")
%!error <numeric> aer2enu(33, 25, 3i)
%!error <non-matching> aer2enu ([1 1], [2 2]', [4 5])
%!error <non-matching> aer2enu ([1 1], [2 2], [4 5 6])
%!error <character> aer2enu (1, 2, 3, 4);
%!error <Invalid call> aer2enu (1, 2)
%!error <illegal> aer2enu (33, 70, 1e3, "f");
%!error <illegal> aer2enu (33, 70, 1e3, "degreef");

