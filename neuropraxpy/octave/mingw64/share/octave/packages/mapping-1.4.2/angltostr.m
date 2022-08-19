## Copyright (C) 2022 Philip Nienhuis
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <https://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {} {@var{strs} =} angltostr (@var{angles})
## @deftypefnx {} {@var{strs} =} angltostr (@var{angles}, @var{hemcode})
## @deftypefnx {} {@var{strs} =} angltostr (@var{angles}, @var{hemcode}, @var{unit})
## @deftypefnx {} {@var{strs} =} angltostr (@var{angles}, @var{hemcode}, @var{unit}, @var{prec})
## Convert numerical angle values (Lat and/or Lon) into cellstr text values.
##
## Inputs:
## @itemize
## @item
## @var{angles} is a scalar or any array of angular values in degrees.  In
## case @var{unit} is specified as radians, @var{angles} is supposed to be in
## radians as well.
##
## @item
## @var{hemcode} (optional), used for indicating the hemisphere, can be one
## of "ew", "ns", "pm" or "none" (default), all case-insensitive.  Depending
## on the sign of the input angle(s), the output strings have a trailing "E",
## "W", "N" or "S" character in case of @var{hemcode} = "ew" or "ns", a
## leading "+"or "-" in case of @var{hemcode} = "pm", or just a leading "-"
## or negative output values in case of @var{hemcode} = "none".  angltostr.m
## is forgiving: "we", "sn", "mp" and "no" are also accepted and any empty
## value will be recognized as "none".
##
## @item
## @var{unit} (optional, case-insensitive) describes the output format.
## * "degrees" (default): decimal degrees (~ -110.5320) @*
## * "degrees2dm": integer degrees and real minutes (94°55.980'W) @*
## * "degrees2dms": integer degrees and minutes and real seconds (~ 4°55'58.8"S) @*
## * "radians": real radian "values" (~ +3.141593)
##
## @item
## @var{prec} indicates the desired number of decimal places; it's equal to
## abs(@var{prec}).
## @end itemize
##
## The output is a cell array of strings, one cell for each angle value, the
## same shape as the input array.  To convert it to more Matlab-compatible
## output, just apply char() to get a char string or char array.
##
## Furthermore, unlike its Matlab sibling angl2str, angltostr will map
## output values into the [-180, 180] interval and adjust output hemisphere
## indicators ("E", "W", "N", "S" or just "-" or "+") accordingly.  For
## latitudes this works similarly only if "ns" was specified for @var{hemcode};
## in all other cases output must be postprocessed manually to map absolute
## latitudes > 90 degrees into (180-lat) * sign(lat); analogously for radians.
##
## @seealso{angl2str, str2angle}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2020-05-19

function str =  angltostr (ang, hemcode="none", unit="degrees", acc=-2)

  if (nargin < 1 || nargin > 4)
    print_usage ();
  elseif (! isnumeric (ang) || ! isreal (ang))
    error ("ang2str: numeric real input expected for first argument");
  elseif (! isempty (hemcode) && ! ischar (hemcode))
    error (" angltostr: character value expected for arg #2");
  elseif (! isempty (unit) && ! ischar (unit))
    error (" angltostr: character value expected for arg. #3 (unit)");
  elseif (! isnumeric (acc) || ! isreal (acc))
    error ("ang2str: numeric real input expected for 4th argument");
  endif
  if (isempty (unit))
    unit = "degrees";
  endif

  ## Hemisphere codings
  if (isempty (hemcode))
    hemcode = "none";
  endif
  ## Be a bit forgiving as regards unit indicators
  ih = mod (find (ismember ({"ew", "ns", "pm", "none", ...
                             "we", "sn", "mp", "no"}, lower (hemcode))) - 1, 4) + 1;
  if (isempty (ih))
    error (["angltostr: unknown signcode (arg.#2): %s, should be one of ", ...
           "'ew', 'ns', 'pm' or 'none'"], hemcode);
  endif

  ## Prepare for finding proper hemisphere
  israd = strcmpi (unit, "radians");
  if (israd)
    ang = rad2deg (ang);
  endif
  ## Wrap angles into [-180, 180] and latitudes (if detected) in [-90 90]
  ang = wrapTo180 (ang);
  if (ih == 2)
    ## Normalize latitudes
    iflp = abs (ang) > 90;
    ang(iflp) = (180 - abs (ang(iflp))) .* sign (ang(iflp));
  endif
  if (israd)
    ang = deg2rad (ang);
  endif

  ## Split up in degrees, minutes and seconds
  degs = sign (ang) .* floor (abs (ang));
  mins = abs (ang - degs) * 60;
  secs = (mins - floor (mins)) * 60;
  is = sign (ang);
  ## Set zero values to positive
  is(abs(is) < 1) = 1;
  is (is < 0) = 0;
  ang = abs (ang);
  degs = abs (degs);

  ## Nr. of decimals to print
  decs = abs (acc);
  wdth = decs + 3;
  if (decs <= 0)
    wdth--;
  endif

  ## Hemisphere specific leading and trailing characters
  hc = {" ", " ", " W", " E"; ...
        " ", " ", " S", " N"; ...
        "-", "+",   "",   ""; ...
        "-", " ",   "",   ""};

  ## Print the strings
  str = str = cell (size (ang));
  switch (unit)
    case "degrees"
      fmt = sprintf ("%%%d.%df°", wdth+1, decs);
      for ii=1:numel (ang)
        str{ii} = sprintf (fmt, ang(ii));
      endfor
    case "degrees2dm"
      fmt = sprintf ("%%3d°_%%%d.%df'", wdth, decs);
      for ii=1:numel (ang)
        str{ii} = sprintf (fmt, degs(ii), mins(ii));
      endfor
    case "degrees2dms"
      mins = floor (mins);
      fmt = sprintf ("%%3d°_%%2d'_%%%d.%df\"", wdth, decs);
      for ii=1:numel (ang)
        str{ii} = sprintf (fmt, degs(ii), mins(ii), secs(ii));
      endfor
    case "radians"
      fmt = sprintf ("%%%d.%df_R", wdth, decs);
      for ii=1:numel (ang)
        str{ii} = sprintf (fmt, ang(ii));
      endfor
  otherwise
      error ("angltostr: unknown unit code (arg #3) - %s", unit);
  endswitch

  str = strrep (str, " ", "0");
  str = strrep (str, "_", " ");
  for ii=1:numel (ang)
    str{ii} = sprintf ([" %s%s%s "], hc{ih, 1+is(ii)}, str{ii}, hc{ih, 3+is(ii)});
  endfor

  str = regexprep (str, '^ ([-+ ])(0)(.*)$', "  $1$3");
  if (! strcmpi (unit, "radians"))
    str = regexprep (str, '^  ([-+ ])(0)(.*)$', "   $1$3");
  else
    str = regexprep (str, '^[ ]{1}(.*)$', "$1");
  endif
  if (ih <= 2)
    str = regexprep (str, '^[ ]{1}(.*)$', "$1");
  endif

endfunction


%!test
%!shared ang
%! ang = [-291.43 -180.0, -110.5320, -85.5, -80.425, -4.9330, 0, 3.0104, 90.0001, 180.0000, 233.425];
%! str = angltostr (ang, "none", "degrees", -3);
%! res = {"   68.570° ", " -180.000° ", " -110.532° ", "  -85.500° ", ...
%!        "  -80.425° ", "   -4.933° ", "    0.000° ", "    3.010° ", ...
%!        "   90.000° ", "  180.000° ", " -126.575° "};
%! assert (str, res);

%!test
%! str =  angltostr (ang, "ew", "degrees2dm", -3);
%! res = {"  68° 34.200' E ", " 180° 00.000' W ", " 110° 31.920' W ", ...
%!        "  85° 30.000' W ", "  80° 25.500' W ", "   4° 55.980' W ", ...
%!        "   0° 00.000' E ", "   3° 00.624' E ", "  90° 00.006' E ", ...
%!        " 180° 00.000' E ", " 126° 34.500' W "};
%! assert (str, res);

%!test
%! str = angltostr (ang, "NS", "degrees2dms", -1);
%! res = {"  68° 34' 12.0\" N ", "   0° 00' 00.0\" N ", "  69° 28' 04.8\" S ", ...
%!        "  85° 30' 00.0\" S ", "  80° 25' 30.0\" S ", "   4° 55' 58.8\" S ", ...
%!        "   0° 00' 00.0\" N ", "   3° 00' 37.4\" N ", "  89° 59' 59.6\" N ", ...
%!        "   0° 00' 00.0\" N ", "  53° 25' 30.0\" S "};
%! assert (str, res);

%!test
%! str = angltostr (ang, "EW", "degrees2dms", -1);
%! res = {"  68° 34' 12.0\" E ", " 180° 00' 00.0\" W ", " 110° 31' 55.2\" W ", ...
%!        "  85° 30' 00.0\" W ", "  80° 25' 30.0\" W ", "   4° 55' 58.8\" W ", ...
%!        "   0° 00' 00.0\" E ", "   3° 00' 37.4\" E ", "  90° 00' 00.4\" E ", ...
%!        " 180° 00' 00.0\" E ", " 126° 34' 30.0\" W "};
%! assert (str, res);

%!test
%! str = angltostr (deg2rad (ang), "pm", "radians", -6);
%! res = {" +1.196772 R ", " -3.141593 R ", " -1.929147 R ", " -1.492257 R ", ...
%!        " -1.403681 R ", " -0.086097 R ", " +0.000000 R ", " +0.052541 R ", ...
%!        " +1.570798 R ", " +3.141593 R ", " -2.209151 R "};
%! assert (str, res);

%!error <numeric real input> angltostr ("oo");
%!error <numeric real input> angltostr (2+3i);
%!error <unknown signcode> angltostr (45, "ff");
%!error <character value expected>  angltostr (33, 65);
%!error <character value> angltostr (45, "ew", struct ());
%!error <unknown unit code> angltostr (88, "pm", "degs");
%!error <numeric real input> angltostr (45, "ew", "radians", "acc");
%!error <numeric real input> angltostr (45, "ew", "radians", 3+2i);
%!error <unknown unit code> angltostr (45, "ns", "degs");

