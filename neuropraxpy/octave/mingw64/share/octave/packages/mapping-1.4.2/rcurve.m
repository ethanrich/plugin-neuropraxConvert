## Copyright (C) 2018-2022 Philip Nienhuis
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSEll. See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{r} =} rcurve (@var{spheroid}, @var{lat})
## @deftypefnx {Function File} {@var{r} =} rcurve (@var{type}, @var{spheroid}, @var{lat})
## @deftypefnx {Function File} {@var{r} =} rcurve (@dots{}, @var{angleUnit})
## Return the length of a curve based on its type: meridian, parallel, or
## transverse.
##
## Optional input argument @var{type} is one of "meridian", "parallel", or
## "transverse; default (when left empty or skipped) is "parallel".
## @var{spheroid} is the spheroid of choice (default: "wgs84").  @var{lat}
## is the latitude at which the curve length should be computed and can be
## a numeric scalar, vector or matrix.  Output argument @var{r} will have the
## same size and dimension(s) as @var{lat}.
##
## Optional input argument @var{angleUnit} can be either "radians" or "degrees"
## (= default); just "r" or "d" will do.  All character input is
## case-insensitive.
##
## Examples:
##
## @example
## r = rcurve ("parallel", "wgs84", 45)
## => r =
## 4.5176e+06
## Note: this is in meters
## @end example
##
## @example
## r = rcurve ("", 45)
## => r =
## 4.5176e+06
## @end example
##
## @example
## r = rcurve ("", "", 45)
## => r =
## 4.5176e+06
## @end example
##
## @example
## r = rcurve ("", "", pi/4, "radians")
## => r =
## 4.5176e+06
## @end example
##
## @example
## r = rcurve ("meridian", "wgs84", 45)
## => r =
## 6.3674e+06
## @end example
##
## @example
## r = rcurve ("transverse", "wgs84", 45)
## => r =
## 6.3888e+06
## @end example
##
## Also can use structures as inputs:
## @example
## r = rcurve("", referenceEllipsoid ("venus"), 45)
## => r =
## 4.2793e+06
## @end example
## @end deftypefn

## Function supplied by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9658

function r = rcurve (varargin)

  if (nargin < 2 || nargin > 4)
    print_usage ();
  elseif (nargin == 2)
    ## Neither type nor angleUnit specified
    type = "parallel";
    angleUnit = "degrees";
    spheroid = varargin{1};
    lat = varargin{2};
    ip = 1;
  elseif (nargin >= 3)
    if (isnumeric (varargin{2}) && isreal (varargin{2}))
      ## arg{1} = spheroid, type skipped
      type = "parallel";
      ip = 1;
    elseif (isnumeric (varargin{3}) && isreal (varargin{3}))
      ## arg{1} = type, no angleunit given
      angleUnit = "degrees";
      ip = 0;
    else
      error ("rcurve: real numeric input expected for Lat");
    endif
    type = varargin{ip + 1};
    spheroid = varargin{ip + 2};
    lat = varargin{ip + 3};
  endif
  if (nargin == 4)
    if (ischar (varargin{4}))
      angleUnit = varargin{4};
    else
      error ("rcurve: 'degrees' or 'radians' expected for angleUnits");
    endif
  endif

  if isempty (type)
    type = "parallel";
  endif

  if (isnumeric (spheroid))
    spheroid = num2str (spheroid);
  endif
  E = sph_chk (spheroid);

  if (! ischar (angleUnit) || ! ismember (lower (angleUnit(1)), {"d", "r"}))
    error ("rcurve: angleUnit should be one of 'degrees' or 'radians'")
  endif

  if (strncmpi (lower (angleUnit), "r", 1) == 1)
    c_l = cos (lat);
    s_l = sin (lat);
  else
    c_l = cosd (lat);
    s_l = sind (lat);
  endif

  ## Insight From: Algorithms for Global Positioning pg 370-372

  e2 = E.Eccentricity ^ 2;
  R = E.SemimajorAxis;
  e_p = e2 / (1 - e2);

  N = (R * sqrt ( 1 + e_p) ./ (sqrt (1 + e_p * c_l .^ 2)));
  switch type
    case {"meridian"}
      w = sqrt (1 - e2 .* s_l .^ 2);
      r = R * (1 - e2 ) ./ (w .^ 3);
    case {"parallel"}
      r = N .* c_l;
    case {"transverse"}
      r = N;
    otherwise
      error ("rcurve: type should be one of 'meridian', 'parallel', or 'transverse'")
  endswitch

endfunction


%!test
%! assert (rcurve ("", 45), 4517590.87885, 10e-6)

%% Row vector
%!test
%! assert (rcurve ("", [45; 20]), [4517590.87885; 5995836.38390], 10e-6)

%% Column vector
%!test
%! assert (rcurve ("", [45, 20]), [4517590.87885, 5995836.38390], 10e-6)

%% Matrix
%!test
%! assert (rcurve ("", [60 45; 35 20]), [3197104.58692, 4517590.87885; 5230426.84020, 5995836.38390], 10e-6)

%!test
%! assert (rcurve ("", "", 45), 4517590.87885, 10e-6)

%!test
%! assert (rcurve ("transverse", "", 45), 6388838.29012, 10e-6)

%!test
%! assert (rcurve ("meridian", "", 45), 6367381.81562, 10e-6)

%!error <angleUnit> rcurve ("","", 45, "km")
%!error <numeric input expected>  rcurve ("", "", "A")
%!error <numeric input expected>  rcurve ("", "", 45i)
%!error <type> rcurve ('All', "", 45)
