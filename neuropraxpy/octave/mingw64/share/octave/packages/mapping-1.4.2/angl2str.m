## Copyright (C) 2018-2022 Ricardo Fantin da Costa
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {} {@var{string} =} angl2str (@var{angles}, @var{sign_notation}, @var{unit}, @var{n})
## Convert angles to notation as angles represents latitudes or longitudes.
## Unless specified in unit, the angle is expected to be in degrees.
## The resulted string is intended to show angles in map.
##
## The @var{sign_notation} specifies how the positive/negative sign is
## shown.  The possibles values are "ew" (east/west), "ns" (north/south),
## "pm" (plus/minus) or "none".  Default value is "none".
##
## The possible @var{unit} values are "radians", "degrees", "degrees2dm" or
## "degrees2dms".  "dms" stands for degrees minutes and seconds.
##
## The parameter @var{n} indicates how many digits will have the last angle part.
##
## Octave uses ° for degrees, Matlab uses ^@{@backslashchar{}circ@} latex output.
## @seealso{str2angle}
## @end deftypefn

## Author: Ricardo Fantin da Costa <ricardofantin@gmail.com>
## Created: 2018-03-27

function [string] = angl2str (angles, sign_notation = "none", unit = "degrees", n = -2)
  if (nargin < 1 || nargin > 4)
    error (["angl2str: incorrect number of arguments. Expected from 1 to 4 " ...
            "arguments, received " nargin "."]);
  endif

  if (!isnumeric (angles))
    error (["angl2str: expected numeric angles. Received " (class (angles)) ...
            " angles type."]);
  endif

  if (!isnumeric (n))
    error (["angl2str: expected a numeric value as fourth argument n. " ...
            "Received " n "."]);
  endif

  original = sign_notation;
  sign_notation = lower(sign_notation);
  if (!ismember (sign_notation, {"ew", "ns", "pm", "none"}))
    error (["angl2str.m: second argument, sign_notation, should be \"ew\" " ...
            "(east/west), \"ns\" (north/south), \"pm\" (plus/minus) or " ...
            "\"none\". Received " original "."]);
  endif

  original = unit;
  unit = lower(unit);
  if (!ismember (unit, {"radians", "degrees", "degrees2dm", "degrees2dms"}))
    error (["angl2str.m: unit should be \"radians\", \"degrees\", "...
            "\"degrees2dm\" or \"degrees2dms\". Received " original "."]);
  endif

  if (!iscolumn (angles))
    angles = angles(:);
  endif

  l = ones (length (angles), 1);
  signs = char (l);
  switch (sign_notation)
    case "ew"
      signs(angles == 0) = " ";
      signs(angles <  0) = "W";
      signs(angles >  0) = "E";
    case "ns"
      signs(angles == 0) = " ";
      signs(angles <  0) = "S";
      signs(angles >  0) = "N";
    case "pm"
      signs(angles >  0) = "+";
      signs(angles <  0) = "-";
      if (isempty (find (angles != 0, 1)))
        signs(angles == 0) = "";
      else
        signs(angles == 0) = " ";
      endif
    case "none"
      has_negative = find (angles < 0, 1);
      if (length (has_negative) == 0)
        signs(:) = "";
      else
        signs(angles >= 0) = " ";
        signs(angles <  0) = "-";
      endif
    otherwise

  endswitch
  angles = abs (angles);

  ## first the verification, after the loop. For speed.
  switch (unit)
    case "radians"
      ## %100 is to right align
      number_part = num2str (roundn (angles, n),
                             ["%100." (num2str(max (-n, 0))) "f"]);
    case "degrees"
      l = ones (length (angles), 1);
      number_part = [(num2str (roundn (angles, n),
                      ["%100." (num2str(max (-n, 0))) "f"])) (char ("°".*l))];
    case "degrees2dm"
      d = floor (angles);                       ## degrees
      intermediary_calc = (angles - d) * 60;    ## minutes
      m = roundn (intermediary_calc, n);
      d(m >= 60 | (m == 0 & intermediary_calc >= 30)) += 1;
      degrees_part = num2str (d);
      minutes_part = round2str(m, n);
      number_part = [degrees_part (char (l.*"° ")) minutes_part (char (l.*"'"))];
    case "degrees2dms"
      d = floor (angles);                       ## degrees
      aux = m = (angles - d) * 60;              ## minutes
      m = floor (m);
      intermediary_calc = (aux - m) * 60;
      s = roundn (intermediary_calc, n);        ## seconds
      m(s >= 60 | (s == 0 & intermediary_calc >= 30)) += 1;
      s(s >= 60) =  0;
      d(m == 60) += 1;
      m(m == 60) =  0;
      degrees_part = num2str (d);
      minutes_part = round2str (m);
      seconds_part = round2str (s, n);
      number_part = [degrees_part (char (l.*"° ")) minutes_part ...
                     (char (l.*"' ")) seconds_part (char (l.*'"'))];
  endswitch

  space_char = char (l*" ");
  if (strcmp (unit, "radians") && ismember (sign_notation, ["ew", "ns"]))
    R_char = char (l*"R");
    string = [space_char number_part space_char R_char space_char signs space_char];
  elseif (strcmp (unit, "radians"))
    ## sign_notation is 'pm' or 'none'
    R_char = char (l.*"R");
    string = [space_char signs number_part space_char R_char space_char];
  elseif (ismember (sign_notation, ["ew", "ns"]))
    ## unit is degrees, degrees2dm or degrees2dms
    string = [space_char number_part space_char signs space_char];
  else
    ## sign_notation is "pm" or "none" and unit is degrees, degrees2dm or degrees2dms
    string = [space_char signs number_part space_char];
  endif

endfunction


## Round numbers, convert to char and complete with leading 0 to guarantee
## two digits in integer part

function [str] = round2str(number, dig = 0)

  if (dig >= 0)
    str = num2str (roundn (number, dig), "%02.f");
  else
    post_point_digits = max (-dig, 0);
    final_length = 2 + 1 + post_point_digits;
    format = ["%0" (num2str (final_length)) "." (num2str (post_point_digits)) "f"];
    str = num2str (roundn (number, dig), format);
  endif

endfunction


%!test
%!error (angl2str ("string_instead_of_number"));
%!error (angl2str (1, "SIGN_NOTATION_UNKNOWN"));
%!error (angl2str (1, "none", "UNIT_UNKNOWN"));
%!error (angl2str (1, "none", "degrees", "string_instead_of_number"));
%!assert (angl2str ([-181; 181; -361; 361]), ...
%!        [" -181.00° ";"  181.00° ";" -361.00° ";"  361.00° "]);
%!assert (angl2str ([-181; 181; -361; 361], "ew"), ...
%!        [" 181.00° W ";" 181.00° E ";" 361.00° W ";" 361.00° E "]);
%!assert (angl2str ([-181; 181; -361; 361], "ns"), ...
%!        [" 181.00° S ";" 181.00° N ";" 361.00° S ";" 361.00° N "]);
%!assert (angl2str ([1 2;3 4]),[" 1.00° ";" 3.00° ";" 2.00° ";" 4.00° "]);
%!assert (angl2str ([55555 1.22]), [" 55555.00° ";"     1.22° "]);
%!assert (angl2str (-12, "ew", "radians", -5), " 12.00000 R W ");
%!assert (angl2str (-12, "ew", "radians", -2), " 12.00 R W ");
%!assert (angl2str (-12, "ew", "radians", 0), " 12 R W ");
%!assert (angl2str (-12, "ew", "radians", 1), " 10 R W ");
%!assert (angl2str (-12, "ew", "radians", 5), " 0 R W ");
%!assert (angl2str (-12, "ew", "degrees", -5), " 12.00000° W ");
%!assert (angl2str (-12, "ew", "degrees", -2), " 12.00° W ");
%!assert (angl2str (-12, "ew", "degrees", 0), " 12° W ");
%!assert (angl2str (-12, "ew", "degrees", 1), " 10° W ");
%!assert (angl2str (-12, "ew", "degrees", 5), " 0° W ");
%!assert (angl2str (-12, "ew", "degrees2dm", -5), " 12° 00.00000' W ");
%!assert (angl2str (-12, "ew", "degrees2dm", -2), " 12° 00.00' W ");
%!assert (angl2str (-12, "ew", "degrees2dm", 0), " 12° 00' W ");
%!assert (angl2str (-12, "ew", "degrees2dm", 1), " 12° 00' W ");
%!assert (angl2str (-12, "ew", "degrees2dm", 5), " 12° 00' W ");
%!assert (angl2str (-12, "ew", "degrees2dms", -5), " 12° 00' 00.00000\" W ");
%!assert (angl2str (-12, "ew", "degrees2dms", -2), " 12° 00' 00.00\" W ");
%!assert (angl2str (-12, "ew", "degrees2dms", 0), " 12° 00' 00\" W ");
%!assert (angl2str (-12, "ew", "degrees2dms", 1), " 12° 00' 00\" W ");
%!assert (angl2str (-12, "ew", "degrees2dms", 5), " 12° 00' 00\" W ");
%!assert (angl2str (-12, "ns", "radians", -5), " 12.00000 R S ");
%!assert (angl2str (-12, "ns", "radians", -2), " 12.00 R S ");
%!assert (angl2str (-12, "ns", "radians", 0), " 12 R S ");
%!assert (angl2str (-12, "ns", "radians", 1), " 10 R S ");
%!assert (angl2str (-12, "ns", "radians", 5), " 0 R S ");
%!assert (angl2str (-12, "ns", "degrees", -5), " 12.00000° S ");
%!assert (angl2str (-12, "ns", "degrees", -2), " 12.00° S ");
%!assert (angl2str (-12, "ns", "degrees", 0), " 12° S ");
%!assert (angl2str (-12, "ns", "degrees", 1), " 10° S ");
%!assert (angl2str (-12, "ns", "degrees", 5), " 0° S ");
%!assert (angl2str (-12, "ns", "degrees2dm", -5), " 12° 00.00000' S ");
%!assert (angl2str (-12, "ns", "degrees2dm", -2), " 12° 00.00' S ");
%!assert (angl2str (-12, "ns", "degrees2dm", 0), " 12° 00' S ");
%!assert (angl2str (-12, "ns", "degrees2dm", 1), " 12° 00' S ");
%!assert (angl2str (-12, "ns", "degrees2dm", 5), " 12° 00' S ");
%!assert (angl2str (-12, "ns", "degrees2dms", -5), " 12° 00' 00.00000\" S ");
%!assert (angl2str (-12, "ns", "degrees2dms", -2), " 12° 00' 00.00\" S ");
%!assert (angl2str (-12, "ns", "degrees2dms", 0), " 12° 00' 00\" S ");
%!assert (angl2str (-12, "ns", "degrees2dms", 1), " 12° 00' 00\" S ");
%!assert (angl2str (-12, "ns", "degrees2dms", 5), " 12° 00' 00\" S ");
%!assert (angl2str (-12, "pm", "radians", -5), " -12.00000 R ");
%!assert (angl2str (-12, "pm", "radians", -2), " -12.00 R ");
%!assert (angl2str (-12, "pm", "radians", 0), " -12 R ");
%!assert (angl2str (-12, "pm", "radians", 1), " -10 R ");
%!assert (angl2str (-12, "pm", "radians", 5), " -0 R ");
%!assert (angl2str (-12, "pm", "degrees", -5), " -12.00000° ");
%!assert (angl2str (-12, "pm", "degrees", -2), " -12.00° ");
%!assert (angl2str (-12, "pm", "degrees", 0), " -12° ");
%!assert (angl2str (-12, "pm", "degrees", 1), " -10° ");
%!assert (angl2str (-12, "pm", "degrees", 5), " -0° ");
%!assert (angl2str (-12, "pm", "degrees2dm", -5), " -12° 00.00000' ");
%!assert (angl2str (-12, "pm", "degrees2dm", -2), " -12° 00.00' ");
%!assert (angl2str (-12, "pm", "degrees2dm", 0), " -12° 00' ");
%!assert (angl2str (-12, "pm", "degrees2dm", 1), " -12° 00' ");
%!assert (angl2str (-12, "pm", "degrees2dm", 5), " -12° 00' ");
%!assert (angl2str (-12, "pm", "degrees2dms", -5), " -12° 00' 00.00000\" ");
%!assert (angl2str (-12, "pm", "degrees2dms", -2), " -12° 00' 00.00\" ");
%!assert (angl2str (-12, "pm", "degrees2dms", 0), " -12° 00' 00\" ");
%!assert (angl2str (-12, "pm", "degrees2dms", 1), " -12° 00' 00\" ");
%!assert (angl2str (-12, "pm", "degrees2dms", 5), " -12° 00' 00\" ");
%!assert (angl2str (-12, "none", "radians", -5), " -12.00000 R ");
%!assert (angl2str (-12, "none", "radians", -2), " -12.00 R ");
%!assert (angl2str (-12, "none", "radians", 0), " -12 R ");
%!assert (angl2str (-12, "none", "radians", 1), " -10 R ");
%!assert (angl2str (-12, "none", "radians", 5), " -0 R ");
%!assert (angl2str (-12, "none", "degrees", -5), " -12.00000° ");
%!assert (angl2str (-12, "none", "degrees", -2), " -12.00° ");
%!assert (angl2str (-12, "none", "degrees", 0), " -12° ");
%!assert (angl2str (-12, "none", "degrees", 1), " -10° ");
%!assert (angl2str (-12, "none", "degrees", 5), " -0° ");
%!assert (angl2str (-12, "none", "degrees2dm", -5), " -12° 00.00000' ");
%!assert (angl2str (-12, "none", "degrees2dm", -2), " -12° 00.00' ");
%!assert (angl2str (-12, "none", "degrees2dm", 0), " -12° 00' ");
%!assert (angl2str (-12, "none", "degrees2dm", 1), " -12° 00' ");
%!assert (angl2str (-12, "none", "degrees2dm", 5), " -12° 00' ");
%!assert (angl2str (-12, "none", "degrees2dms", -5), " -12° 00' 00.00000\" ");
%!assert (angl2str (-12, "none", "degrees2dms", -2), " -12° 00' 00.00\" ");
%!assert (angl2str (-12, "none", "degrees2dms", 0), " -12° 00' 00\" ");
%!assert (angl2str (-12, "none", "degrees2dms", 1), " -12° 00' 00\" ");
%!assert (angl2str (-12, "none", "degrees2dms", 5), " -12° 00' 00\" ");
%!assert (angl2str (-5.3333, "ew", "radians", -5), " 5.33330 R W ");
%!assert (angl2str (-5.3333, "ew", "radians", -2), " 5.33 R W ");
%!assert (angl2str (-5.3333, "ew", "radians", 0), " 5 R W ");
%!assert (angl2str (-5.3333, "ew", "radians", 1), " 10 R W ");
%!assert (angl2str (-5.3333, "ew", "radians", 5), " 0 R W ");
%!assert (angl2str (-5.3333, "ew", "degrees", -5), " 5.33330° W ");
%!assert (angl2str (-5.3333, "ew", "degrees", -2), " 5.33° W ");
%!assert (angl2str (-5.3333, "ew", "degrees", 0), " 5° W ");
%!assert (angl2str (-5.3333, "ew", "degrees", 1), " 10° W ");
%!assert (angl2str (-5.3333, "ew", "degrees", 5), " 0° W ");
%!assert (angl2str (-5.3333, "ew", "degrees2dm", -5), " 5° 19.99800' W ");
%!assert (angl2str (-5.3333, "ew", "degrees2dm", -2), " 5° 20.00' W ");
%!assert (angl2str (-5.3333, "ew", "degrees2dm", 0), " 5° 20' W ");
%!assert (angl2str (-5.3333, "ew", "degrees2dm", 1), " 5° 20' W ");
%!assert (angl2str (-5.3333, "ew", "degrees2dm", 5), " 5° 00' W ");
%!assert (angl2str (-5.3333, "ew", "degrees2dms", -5), " 5° 19' 59.88000\" W ");
%!assert (angl2str (-5.3333, "ew", "degrees2dms", -2), " 5° 19' 59.88\" W ");
%!assert (angl2str (-5.3333, "ew", "degrees2dms", 0), " 5° 20' 00\" W ");
%!assert (angl2str (-5.3333, "ew", "degrees2dms", 1), " 5° 20' 00\" W ");
%!assert (angl2str (-5.3333, "ew", "degrees2dms", 5), " 5° 20' 00\" W ");
%!assert (angl2str (-5.3333, "ns", "radians", -5), " 5.33330 R S ");
%!assert (angl2str (-5.3333, "ns", "radians", -2), " 5.33 R S ");
%!assert (angl2str (-5.3333, "ns", "radians", 0), " 5 R S ");
%!assert (angl2str (-5.3333, "ns", "radians", 1), " 10 R S ");
%!assert (angl2str (-5.3333, "ns", "radians", 5), " 0 R S ");
%!assert (angl2str (-5.3333, "ns", "degrees", -5), " 5.33330° S ");
%!assert (angl2str (-5.3333, "ns", "degrees", -2), " 5.33° S ");
%!assert (angl2str (-5.3333, "ns", "degrees", 0), " 5° S ");
%!assert (angl2str (-5.3333, "ns", "degrees", 1), " 10° S ");
%!assert (angl2str (-5.3333, "ns", "degrees", 5), " 0° S ");
%!assert (angl2str (-5.3333, "ns", "degrees2dm", -5), " 5° 19.99800' S ");
%!assert (angl2str (-5.3333, "ns", "degrees2dm", -2), " 5° 20.00' S ");
%!assert (angl2str (-5.3333, "ns", "degrees2dm", 0), " 5° 20' S ");
%!assert (angl2str (-5.3333, "ns", "degrees2dm", 1), " 5° 20' S ");
%!assert (angl2str (-5.3333, "ns", "degrees2dm", 5), " 5° 00' S ");
%!assert (angl2str (-5.3333, "ns", "degrees2dms", -5), " 5° 19' 59.88000\" S ");
%!assert (angl2str (-5.3333, "ns", "degrees2dms", -2), " 5° 19' 59.88\" S ");
%!assert (angl2str (-5.3333, "ns", "degrees2dms", 0), " 5° 20' 00\" S ");
%!assert (angl2str (-5.3333, "ns", "degrees2dms", 1), " 5° 20' 00\" S ");
%!assert (angl2str (-5.3333, "ns", "degrees2dms", 5), " 5° 20' 00\" S ");
%!assert (angl2str (-5.3333, "pm", "radians", -5), " -5.33330 R ");
%!assert (angl2str (-5.3333, "pm", "radians", -2), " -5.33 R ");
%!assert (angl2str (-5.3333, "pm", "radians", 0), " -5 R ");
%!assert (angl2str (-5.3333, "pm", "radians", 1), " -10 R ");
%!assert (angl2str (-5.3333, "pm", "radians", 5), " -0 R ");
%!assert (angl2str (-5.3333, "pm", "degrees", -5), " -5.33330° ");
%!assert (angl2str (-5.3333, "pm", "degrees", -2), " -5.33° ");
%!assert (angl2str (-5.3333, "pm", "degrees", 0), " -5° ");
%!assert (angl2str (-5.3333, "pm", "degrees", 1), " -10° ");
%!assert (angl2str (-5.3333, "pm", "degrees", 5), " -0° ");
%!assert (angl2str (-5.3333, "pm", "degrees2dm", -5), " -5° 19.99800' ");
%!assert (angl2str (-5.3333, "pm", "degrees2dm", -2), " -5° 20.00' ");
%!assert (angl2str (-5.3333, "pm", "degrees2dm", 0), " -5° 20' ");
%!assert (angl2str (-5.3333, "pm", "degrees2dm", 1), " -5° 20' ");
%!assert (angl2str (-5.3333, "pm", "degrees2dm", 5), " -5° 00' ");
%!assert (angl2str (-5.3333, "pm", "degrees2dms", -5), " -5° 19' 59.88000\" ");
%!assert (angl2str (-5.3333, "pm", "degrees2dms", -2), " -5° 19' 59.88\" ");
%!assert (angl2str (-5.3333, "pm", "degrees2dms", 0), " -5° 20' 00\" ");
%!assert (angl2str (-5.3333, "pm", "degrees2dms", 1), " -5° 20' 00\" ");
%!assert (angl2str (-5.3333, "pm", "degrees2dms", 5), " -5° 20' 00\" ");
%!assert (angl2str (-5.3333, "none", "radians", -5), " -5.33330 R ");
%!assert (angl2str (-5.3333, "none", "radians", -2), " -5.33 R ");
%!assert (angl2str (-5.3333, "none", "radians", 0), " -5 R ");
%!assert (angl2str (-5.3333, "none", "radians", 1), " -10 R ");
%!assert (angl2str (-5.3333, "none", "radians", 5), " -0 R ");
%!assert (angl2str (-5.3333, "none", "degrees", -5), " -5.33330° ");
%!assert (angl2str (-5.3333, "none", "degrees", -2), " -5.33° ");
%!assert (angl2str (-5.3333, "none", "degrees", 0), " -5° ");
%!assert (angl2str (-5.3333, "none", "degrees", 1), " -10° ");
%!assert (angl2str (-5.3333, "none", "degrees", 5), " -0° ");
%!assert (angl2str (-5.3333, "none", "degrees2dm", -5), " -5° 19.99800' ");
%!assert (angl2str (-5.3333, "none", "degrees2dm", -2), " -5° 20.00' ");
%!assert (angl2str (-5.3333, "none", "degrees2dm", 0), " -5° 20' ");
%!assert (angl2str (-5.3333, "none", "degrees2dm", 1), " -5° 20' ");
%!assert (angl2str (-5.3333, "none", "degrees2dm", 5), " -5° 00' ");
%!assert (angl2str (-5.3333, "none", "degrees2dms", -5), " -5° 19' 59.88000\" ");
%!assert (angl2str (-5.3333, "none", "degrees2dms", -2), " -5° 19' 59.88\" ");
%!assert (angl2str (-5.3333, "none", "degrees2dms", 0), " -5° 20' 00\" ");
%!assert (angl2str (-5.3333, "none", "degrees2dms", 1), " -5° 20' 00\" ");
%!assert (angl2str (-5.3333, "none", "degrees2dms", 5), " -5° 20' 00\" ");
%!assert (angl2str (0, "ew", "radians", -5), " 0.00000 R   ");
%!assert (angl2str (0, "ew", "radians", -2), " 0.00 R   ");
%!assert (angl2str (0, "ew", "radians", 0), " 0 R   ");
%!assert (angl2str (0, "ew", "radians", 1), " 0 R   ");
%!assert (angl2str (0, "ew", "radians", 5), " 0 R   ");
%!assert (angl2str (0, "ew", "degrees", -5), " 0.00000°   ");
%!assert (angl2str (0, "ew", "degrees", -2), " 0.00°   ");
%!assert (angl2str (0, "ew", "degrees", 0), " 0°   ");
%!assert (angl2str (0, "ew", "degrees", 1), " 0°   ");
%!assert (angl2str (0, "ew", "degrees", 5), " 0°   ");
%!assert (angl2str (0, "ew", "degrees2dm", -5), " 0° 00.00000'   ");
%!assert (angl2str (0, "ew", "degrees2dm", -2), " 0° 00.00'   ");
%!assert (angl2str (0, "ew", "degrees2dm", 0), " 0° 00'   ");
%!assert (angl2str (0, "ew", "degrees2dm", 1), " 0° 00'   ");
%!assert (angl2str (0, "ew", "degrees2dm", 5), " 0° 00'   ");
%!assert (angl2str (0, "ew", "degrees2dms", -5), " 0° 00' 00.00000\"   ");
%!assert (angl2str (0, "ew", "degrees2dms", -2), " 0° 00' 00.00\"   ");
%!assert (angl2str (0, "ew", "degrees2dms", 0), " 0° 00' 00\"   ");
%!assert (angl2str (0, "ew", "degrees2dms", 1), " 0° 00' 00\"   ");
%!assert (angl2str (0, "ew", "degrees2dms", 5), " 0° 00' 00\"   ");
%!assert (angl2str (0, "ns", "radians", -5), " 0.00000 R   ");
%!assert (angl2str (0, "ns", "radians", -2), " 0.00 R   ");
%!assert (angl2str (0, "ns", "radians", 0), " 0 R   ");
%!assert (angl2str (0, "ns", "radians", 1), " 0 R   ");
%!assert (angl2str (0, "ns", "radians", 5), " 0 R   ");
%!assert (angl2str (0, "ns", "degrees", -5), " 0.00000°   ");
%!assert (angl2str (0, "ns", "degrees", -2), " 0.00°   ");
%!assert (angl2str (0, "ns", "degrees", 0), " 0°   ");
%!assert (angl2str (0, "ns", "degrees", 1), " 0°   ");
%!assert (angl2str (0, "ns", "degrees", 5), " 0°   ");
%!assert (angl2str (0, "ns", "degrees2dm", -5), " 0° 00.00000'   ");
%!assert (angl2str (0, "ns", "degrees2dm", -2), " 0° 00.00'   ");
%!assert (angl2str (0, "ns", "degrees2dm", 0), " 0° 00'   ");
%!assert (angl2str (0, "ns", "degrees2dm", 1), " 0° 00'   ");
%!assert (angl2str (0, "ns", "degrees2dm", 5), " 0° 00'   ");
%!assert (angl2str (0, "ns", "degrees2dms", -5), " 0° 00' 00.00000\"   ");
%!assert (angl2str (0, "ns", "degrees2dms", -2), " 0° 00' 00.00\"   ");
%!assert (angl2str (0, "ns", "degrees2dms", 0), " 0° 00' 00\"   ");
%!assert (angl2str (0, "ns", "degrees2dms", 1), " 0° 00' 00\"   ");
%!assert (angl2str (0, "ns", "degrees2dms", 5), " 0° 00' 00\"   ");
%!assert (angl2str (0, "pm", "radians", -5), " 0.00000 R ");
%!assert (angl2str (0, "pm", "radians", -2), " 0.00 R ");
%!assert (angl2str (0, "pm", "radians", 0), " 0 R ");
%!assert (angl2str (0, "pm", "radians", 1), " 0 R ");
%!assert (angl2str (0, "pm", "radians", 5), " 0 R ");
%!assert (angl2str (0, "pm", "degrees", -5), " 0.00000° ");
%!assert (angl2str (0, "pm", "degrees", -2), " 0.00° ");
%!assert (angl2str (0, "pm", "degrees", 0), " 0° ");
%!assert (angl2str (0, "pm", "degrees", 1), " 0° ");
%!assert (angl2str (0, "pm", "degrees", 5), " 0° ");
%!assert (angl2str (0, "pm", "degrees2dm", -5), " 0° 00.00000' ");
%!assert (angl2str (0, "pm", "degrees2dm", -2), " 0° 00.00' ");
%!assert (angl2str (0, "pm", "degrees2dm", 0), " 0° 00' ");
%!assert (angl2str (0, "pm", "degrees2dm", 1), " 0° 00' ");
%!assert (angl2str (0, "pm", "degrees2dm", 5), " 0° 00' ");
%!assert (angl2str (0, "pm", "degrees2dms", -5), " 0° 00' 00.00000\" ");
%!assert (angl2str (0, "pm", "degrees2dms", -2), " 0° 00' 00.00\" ");
%!assert (angl2str (0, "pm", "degrees2dms", 0), " 0° 00' 00\" ");
%!assert (angl2str (0, "pm", "degrees2dms", 1), " 0° 00' 00\" ");
%!assert (angl2str (0, "pm", "degrees2dms", 5), " 0° 00' 00\" ");
%!assert (angl2str (0, "none", "radians", -5), " 0.00000 R ");
%!assert (angl2str (0, "none", "radians", -2), " 0.00 R ");
%!assert (angl2str (0, "none", "radians", 0), " 0 R ");
%!assert (angl2str (0, "none", "radians", 1), " 0 R ");
%!assert (angl2str (0, "none", "radians", 5), " 0 R ");
%!assert (angl2str (0, "none", "degrees", -5), " 0.00000° ");
%!assert (angl2str (0, "none", "degrees", -2), " 0.00° ");
%!assert (angl2str (0, "none", "degrees", 0), " 0° ");
%!assert (angl2str (0, "none", "degrees", 1), " 0° ");
%!assert (angl2str (0, "none", "degrees", 5), " 0° ");
%!assert (angl2str (0, "none", "degrees2dm", -5), " 0° 00.00000' ");
%!assert (angl2str (0, "none", "degrees2dm", -2), " 0° 00.00' ");
%!assert (angl2str (0, "none", "degrees2dm", 0), " 0° 00' ");
%!assert (angl2str (0, "none", "degrees2dm", 1), " 0° 00' ");
%!assert (angl2str (0, "none", "degrees2dm", 5), " 0° 00' ");
%!assert (angl2str (0, "none", "degrees2dms", -5), " 0° 00' 00.00000\" ");
%!assert (angl2str (0, "none", "degrees2dms", -2), " 0° 00' 00.00\" ");
%!assert (angl2str (0, "none", "degrees2dms", 0), " 0° 00' 00\" ");
%!assert (angl2str (0, "none", "degrees2dms", 1), " 0° 00' 00\" ");
%!assert (angl2str (0, "none", "degrees2dms", 5), " 0° 00' 00\" ");
%!assert (angl2str (1, "ew", "radians", -5), " 1.00000 R E ");
%!assert (angl2str (1, "ew", "radians", -2), " 1.00 R E ");
%!assert (angl2str (1, "ew", "radians", 0), " 1 R E ");
%!assert (angl2str (1, "ew", "radians", 1), " 0 R E ");
%!assert (angl2str (1, "ew", "radians", 5), " 0 R E ");
%!assert (angl2str (1, "ew", "degrees", -5), " 1.00000° E ");
%!assert (angl2str (1, "ew", "degrees", -2), " 1.00° E ");
%!assert (angl2str (1, "ew", "degrees", 0), " 1° E ");
%!assert (angl2str (1, "ew", "degrees", 1), " 0° E ");
%!assert (angl2str (1, "ew", "degrees", 5), " 0° E ");
%!assert (angl2str (1, "ew", "degrees2dm", -5), " 1° 00.00000' E ");
%!assert (angl2str (1, "ew", "degrees2dm", -2), " 1° 00.00' E ");
%!assert (angl2str (1, "ew", "degrees2dm", 0), " 1° 00' E ");
%!assert (angl2str (1, "ew", "degrees2dm", 1), " 1° 00' E ");
%!assert (angl2str (1, "ew", "degrees2dm", 5), " 1° 00' E ");
%!assert (angl2str (1, "ew", "degrees2dms", -5), " 1° 00' 00.00000\" E ");
%!assert (angl2str (1, "ew", "degrees2dms", -2), " 1° 00' 00.00\" E ");
%!assert (angl2str (1, "ew", "degrees2dms", 0), " 1° 00' 00\" E ");
%!assert (angl2str (1, "ew", "degrees2dms", 1), " 1° 00' 00\" E ");
%!assert (angl2str (1, "ew", "degrees2dms", 5), " 1° 00' 00\" E ");
%!assert (angl2str (1, "ns", "radians", -5), " 1.00000 R N ");
%!assert (angl2str (1, "ns", "radians", -2), " 1.00 R N ");
%!assert (angl2str (1, "ns", "radians", 0), " 1 R N ");
%!assert (angl2str (1, "ns", "radians", 1), " 0 R N ");
%!assert (angl2str (1, "ns", "radians", 5), " 0 R N ");
%!assert (angl2str (1, "ns", "degrees", -5), " 1.00000° N ");
%!assert (angl2str (1, "ns", "degrees", -2), " 1.00° N ");
%!assert (angl2str (1, "ns", "degrees", 0), " 1° N ");
%!assert (angl2str (1, "ns", "degrees", 1), " 0° N ");
%!assert (angl2str (1, "ns", "degrees", 5), " 0° N ");
%!assert (angl2str (1, "ns", "degrees2dm", -5), " 1° 00.00000' N ");
%!assert (angl2str (1, "ns", "degrees2dm", -2), " 1° 00.00' N ");
%!assert (angl2str (1, "ns", "degrees2dm", 0), " 1° 00' N ");
%!assert (angl2str (1, "ns", "degrees2dm", 1), " 1° 00' N ");
%!assert (angl2str (1, "ns", "degrees2dm", 5), " 1° 00' N ");
%!assert (angl2str (1, "ns", "degrees2dms", -5), " 1° 00' 00.00000\" N ");
%!assert (angl2str (1, "ns", "degrees2dms", -2), " 1° 00' 00.00\" N ");
%!assert (angl2str (1, "ns", "degrees2dms", 0), " 1° 00' 00\" N ");
%!assert (angl2str (1, "ns", "degrees2dms", 1), " 1° 00' 00\" N ");
%!assert (angl2str (1, "ns", "degrees2dms", 5), " 1° 00' 00\" N ");
%!assert (angl2str (1, "pm", "radians", -5), " +1.00000 R ");
%!assert (angl2str (1, "pm", "radians", -2), " +1.00 R ");
%!assert (angl2str (1, "pm", "radians", 0), " +1 R ");
%!assert (angl2str (1, "pm", "radians", 1), " +0 R ");
%!assert (angl2str (1, "pm", "radians", 5), " +0 R ");
%!assert (angl2str (1, "pm", "degrees", -5), " +1.00000° ");
%!assert (angl2str (1, "pm", "degrees", -2), " +1.00° ");
%!assert (angl2str (1, "pm", "degrees", 0), " +1° ");
%!assert (angl2str (1, "pm", "degrees", 1), " +0° ");
%!assert (angl2str (1, "pm", "degrees", 5), " +0° ");
%!assert (angl2str (1, "pm", "degrees2dm", -5), " +1° 00.00000' ");
%!assert (angl2str (1, "pm", "degrees2dm", -2), " +1° 00.00' ");
%!assert (angl2str (1, "pm", "degrees2dm", 0), " +1° 00' ");
%!assert (angl2str (1, "pm", "degrees2dm", 1), " +1° 00' ");
%!assert (angl2str (1, "pm", "degrees2dm", 5), " +1° 00' ");
%!assert (angl2str (1, "pm", "degrees2dms", -5), " +1° 00' 00.00000\" ");
%!assert (angl2str (1, "pm", "degrees2dms", -2), " +1° 00' 00.00\" ");
%!assert (angl2str (1, "pm", "degrees2dms", 0), " +1° 00' 00\" ");
%!assert (angl2str (1, "pm", "degrees2dms", 1), " +1° 00' 00\" ");
%!assert (angl2str (1, "pm", "degrees2dms", 5), " +1° 00' 00\" ");
%!assert (angl2str (1, "none", "radians", -5), " 1.00000 R ");
%!assert (angl2str (1, "none", "radians", -2), " 1.00 R ");
%!assert (angl2str (1, "none", "radians", 0), " 1 R ");
%!assert (angl2str (1, "none", "radians", 1), " 0 R ");
%!assert (angl2str (1, "none", "radians", 5), " 0 R ");
%!assert (angl2str (1, "none", "degrees", -5), " 1.00000° ");
%!assert (angl2str (1, "none", "degrees", -2), " 1.00° ");
%!assert (angl2str (1, "none", "degrees", 0), " 1° ");
%!assert (angl2str (1, "none", "degrees", 1), " 0° ");
%!assert (angl2str (1, "none", "degrees", 5), " 0° ");
%!assert (angl2str (1, "none", "degrees2dm", -5), " 1° 00.00000' ");
%!assert (angl2str (1, "none", "degrees2dm", -2), " 1° 00.00' ");
%!assert (angl2str (1, "none", "degrees2dm", 0), " 1° 00' ");
%!assert (angl2str (1, "none", "degrees2dm", 1), " 1° 00' ");
%!assert (angl2str (1, "none", "degrees2dm", 5), " 1° 00' ");
%!assert (angl2str (1, "none", "degrees2dms", -5), " 1° 00' 00.00000\" ");
%!assert (angl2str (1, "none", "degrees2dms", -2), " 1° 00' 00.00\" ");
%!assert (angl2str (1, "none", "degrees2dms", 0), " 1° 00' 00\" ");
%!assert (angl2str (1, "none", "degrees2dms", 1), " 1° 00' 00\" ");
%!assert (angl2str (1, "none", "degrees2dms", 5), " 1° 00' 00\" ");
%!assert (angl2str (27, "ew", "radians", -5), " 27.00000 R E ");
%!assert (angl2str (27, "ew", "radians", -2), " 27.00 R E ");
%!assert (angl2str (27, "ew", "radians", 0), " 27 R E ");
%!assert (angl2str (27, "ew", "radians", 1), " 30 R E ");
%!assert (angl2str (27, "ew", "radians", 5), " 0 R E ");
%!assert (angl2str (27, "ew", "degrees", -5), " 27.00000° E ");
%!assert (angl2str (27, "ew", "degrees", -2), " 27.00° E ");
%!assert (angl2str (27, "ew", "degrees", 0), " 27° E ");
%!assert (angl2str (27, "ew", "degrees", 1), " 30° E ");
%!assert (angl2str (27, "ew", "degrees", 5), " 0° E ");
%!assert (angl2str (27, "ew", "degrees2dm", -5), " 27° 00.00000' E ");
%!assert (angl2str (27, "ew", "degrees2dm", -2), " 27° 00.00' E ");
%!assert (angl2str (27, "ew", "degrees2dm", 0), " 27° 00' E ");
%!assert (angl2str (27, "ew", "degrees2dm", 1), " 27° 00' E ");
%!assert (angl2str (27, "ew", "degrees2dm", 5), " 27° 00' E ");
%!assert (angl2str (27, "ew", "degrees2dms", -5), " 27° 00' 00.00000\" E ");
%!assert (angl2str (27, "ew", "degrees2dms", -2), " 27° 00' 00.00\" E ");
%!assert (angl2str (27, "ew", "degrees2dms", 0), " 27° 00' 00\" E ");
%!assert (angl2str (27, "ew", "degrees2dms", 1), " 27° 00' 00\" E ");
%!assert (angl2str (27, "ew", "degrees2dms", 5), " 27° 00' 00\" E ");
%!assert (angl2str (27, "ns", "radians", -5), " 27.00000 R N ");
%!assert (angl2str (27, "ns", "radians", -2), " 27.00 R N ");
%!assert (angl2str (27, "ns", "radians", 0), " 27 R N ");
%!assert (angl2str (27, "ns", "radians", 1), " 30 R N ");
%!assert (angl2str (27, "ns", "radians", 5), " 0 R N ");
%!assert (angl2str (27, "ns", "degrees", -5), " 27.00000° N ");
%!assert (angl2str (27, "ns", "degrees", -2), " 27.00° N ");
%!assert (angl2str (27, "ns", "degrees", 0), " 27° N ");
%!assert (angl2str (27, "ns", "degrees", 1), " 30° N ");
%!assert (angl2str (27, "ns", "degrees", 5), " 0° N ");
%!assert (angl2str (27, "ns", "degrees2dm", -5), " 27° 00.00000' N ");
%!assert (angl2str (27, "ns", "degrees2dm", -2), " 27° 00.00' N ");
%!assert (angl2str (27, "ns", "degrees2dm", 0), " 27° 00' N ");
%!assert (angl2str (27, "ns", "degrees2dm", 1), " 27° 00' N ");
%!assert (angl2str (27, "ns", "degrees2dm", 5), " 27° 00' N ");
%!assert (angl2str (27, "ns", "degrees2dms", -5), " 27° 00' 00.00000\" N ");
%!assert (angl2str (27, "ns", "degrees2dms", -2), " 27° 00' 00.00\" N ");
%!assert (angl2str (27, "ns", "degrees2dms", 0), " 27° 00' 00\" N ");
%!assert (angl2str (27, "ns", "degrees2dms", 1), " 27° 00' 00\" N ");
%!assert (angl2str (27, "ns", "degrees2dms", 5), " 27° 00' 00\" N ");
%!assert (angl2str (27, "pm", "radians", -5), " +27.00000 R ");
%!assert (angl2str (27, "pm", "radians", -2), " +27.00 R ");
%!assert (angl2str (27, "pm", "radians", 0), " +27 R ");
%!assert (angl2str (27, "pm", "radians", 1), " +30 R ");
%!assert (angl2str (27, "pm", "radians", 5), " +0 R ");
%!assert (angl2str (27, "pm", "degrees", -5), " +27.00000° ");
%!assert (angl2str (27, "pm", "degrees", -2), " +27.00° ");
%!assert (angl2str (27, "pm", "degrees", 0), " +27° ");
%!assert (angl2str (27, "pm", "degrees", 1), " +30° ");
%!assert (angl2str (27, "pm", "degrees", 5), " +0° ");
%!assert (angl2str (27, "pm", "degrees2dm", -5), " +27° 00.00000' ");
%!assert (angl2str (27, "pm", "degrees2dm", -2), " +27° 00.00' ");
%!assert (angl2str (27, "pm", "degrees2dm", 0), " +27° 00' ");
%!assert (angl2str (27, "pm", "degrees2dm", 1), " +27° 00' ");
%!assert (angl2str (27, "pm", "degrees2dm", 5), " +27° 00' ");
%!assert (angl2str (27, "pm", "degrees2dms", -5), " +27° 00' 00.00000\" ");
%!assert (angl2str (27, "pm", "degrees2dms", -2), " +27° 00' 00.00\" ");
%!assert (angl2str (27, "pm", "degrees2dms", 0), " +27° 00' 00\" ");
%!assert (angl2str (27, "pm", "degrees2dms", 1), " +27° 00' 00\" ");
%!assert (angl2str (27, "pm", "degrees2dms", 5), " +27° 00' 00\" ");
%!assert (angl2str (27, "none", "radians", -5), " 27.00000 R ");
%!assert (angl2str (27, "none", "radians", -2), " 27.00 R ");
%!assert (angl2str (27, "none", "radians", 0), " 27 R ");
%!assert (angl2str (27, "none", "radians", 1), " 30 R ");
%!assert (angl2str (27, "none", "radians", 5), " 0 R ");
%!assert (angl2str (27, "none", "degrees", -5), " 27.00000° ");
%!assert (angl2str (27, "none", "degrees", -2), " 27.00° ");
%!assert (angl2str (27, "none", "degrees", 0), " 27° ");
%!assert (angl2str (27, "none", "degrees", 1), " 30° ");
%!assert (angl2str (27, "none", "degrees", 5), " 0° ");
%!assert (angl2str (27, "none", "degrees2dm", -5), " 27° 00.00000' ");
%!assert (angl2str (27, "none", "degrees2dm", -2), " 27° 00.00' ");
%!assert (angl2str (27, "none", "degrees2dm", 0), " 27° 00' ");
%!assert (angl2str (27, "none", "degrees2dm", 1), " 27° 00' ");
%!assert (angl2str (27, "none", "degrees2dm", 5), " 27° 00' ");
%!assert (angl2str (27, "none", "degrees2dms", -5), " 27° 00' 00.00000\" ");
%!assert (angl2str (27, "none", "degrees2dms", -2), " 27° 00' 00.00\" ");
%!assert (angl2str (27, "none", "degrees2dms", 0), " 27° 00' 00\" ");
%!assert (angl2str (27, "none", "degrees2dms", 1), " 27° 00' 00\" ");
%!assert (angl2str (27, "none", "degrees2dms", 5), " 27° 00' 00\" ");
%!assert (angl2str (77.77777, "ew", "radians", -5), " 77.77777 R E ");
%!assert (angl2str (77.77777, "ew", "radians", -2), " 77.78 R E ");
%!assert (angl2str (77.77777, "ew", "radians", 0), " 78 R E ");
%!assert (angl2str (77.77777, "ew", "radians", 1), " 80 R E ");
%!assert (angl2str (77.77777, "ew", "radians", 5), " 0 R E ");
%!assert (angl2str (77.77777, "ew", "degrees", -5), " 77.77777° E ");
%!assert (angl2str (77.77777, "ew", "degrees", -2), " 77.78° E ");
%!assert (angl2str (77.77777, "ew", "degrees", 0), " 78° E ");
%!assert (angl2str (77.77777, "ew", "degrees", 1), " 80° E ");
%!assert (angl2str (77.77777, "ew", "degrees", 5), " 0° E ");
%!assert (angl2str (77.77777, "ew", "degrees2dm", -5), " 77° 46.66620' E ");
%!assert (angl2str (77.77777, "ew", "degrees2dm", -2), " 77° 46.67' E ");
%!assert (angl2str (77.77777, "ew", "degrees2dm", 0), " 77° 47' E ");
%!assert (angl2str (77.77777, "ew", "degrees2dm", 1), " 77° 50' E ");
%!assert (angl2str (77.77777, "ew", "degrees2dm", 5), " 78° 00' E ");
%!assert (angl2str (77.77777, "ew", "degrees2dms", -5), " 77° 46' 39.97200\" E ");
%!assert (angl2str (77.77777, "ew", "degrees2dms", -2), " 77° 46' 39.97\" E ");
%!assert (angl2str (77.77777, "ew", "degrees2dms", 0), " 77° 46' 40\" E ");
%!assert (angl2str (77.77777, "ew", "degrees2dms", 1), " 77° 46' 40\" E ");
%!assert (angl2str (77.77777, "ew", "degrees2dms", 5), " 77° 47' 00\" E ");
%!assert (angl2str (77.77777, "ns", "radians", -5), " 77.77777 R N ");
%!assert (angl2str (77.77777, "ns", "radians", -2), " 77.78 R N ");
%!assert (angl2str (77.77777, "ns", "radians", 0), " 78 R N ");
%!assert (angl2str (77.77777, "ns", "radians", 1), " 80 R N ");
%!assert (angl2str (77.77777, "ns", "radians", 5), " 0 R N ");
%!assert (angl2str (77.77777, "ns", "degrees", -5), " 77.77777° N ");
%!assert (angl2str (77.77777, "ns", "degrees", -2), " 77.78° N ");
%!assert (angl2str (77.77777, "ns", "degrees", 0), " 78° N ");
%!assert (angl2str (77.77777, "ns", "degrees", 1), " 80° N ");
%!assert (angl2str (77.77777, "ns", "degrees", 5), " 0° N ");
%!assert (angl2str (77.77777, "ns", "degrees2dm", -5), " 77° 46.66620' N ");
%!assert (angl2str (77.77777, "ns", "degrees2dm", -2), " 77° 46.67' N ");
%!assert (angl2str (77.77777, "ns", "degrees2dm", 0), " 77° 47' N ");
%!assert (angl2str (77.77777, "ns", "degrees2dm", 1), " 77° 50' N ");
%!assert (angl2str (77.77777, "ns", "degrees2dm", 5), " 78° 00' N ");
%!assert (angl2str (77.77777, "ns", "degrees2dms", -5), " 77° 46' 39.97200\" N ");
%!assert (angl2str (77.77777, "ns", "degrees2dms", -2), " 77° 46' 39.97\" N ");
%!assert (angl2str (77.77777, "ns", "degrees2dms", 0), " 77° 46' 40\" N ");
%!assert (angl2str (77.77777, "ns", "degrees2dms", 1), " 77° 46' 40\" N ");
%!assert (angl2str (77.77777, "ns", "degrees2dms", 5), " 77° 47' 00\" N ");
%!assert (angl2str (77.77777, "pm", "radians", -5), " +77.77777 R ");
%!assert (angl2str (77.77777, "pm", "radians", -2), " +77.78 R ");
%!assert (angl2str (77.77777, "pm", "radians", 0), " +78 R ");
%!assert (angl2str (77.77777, "pm", "radians", 1), " +80 R ");
%!assert (angl2str (77.77777, "pm", "radians", 5), " +0 R ");
%!assert (angl2str (77.77777, "pm", "degrees", -5), " +77.77777° ");
%!assert (angl2str (77.77777, "pm", "degrees", -2), " +77.78° ");
%!assert (angl2str (77.77777, "pm", "degrees", 0), " +78° ");
%!assert (angl2str (77.77777, "pm", "degrees", 1), " +80° ");
%!assert (angl2str (77.77777, "pm", "degrees", 5), " +0° ");
%!assert (angl2str (77.77777, "pm", "degrees2dm", -5), " +77° 46.66620' ");
%!assert (angl2str (77.77777, "pm", "degrees2dm", -2), " +77° 46.67' ");
%!assert (angl2str (77.77777, "pm", "degrees2dm", 0), " +77° 47' ");
%!assert (angl2str (77.77777, "pm", "degrees2dm", 1), " +77° 50' ");
%!assert (angl2str (77.77777, "pm", "degrees2dm", 5), " +78° 00' ");
%!assert (angl2str (77.77777, "pm", "degrees2dms", -5), " +77° 46' 39.97200\" ");
%!assert (angl2str (77.77777, "pm", "degrees2dms", -2), " +77° 46' 39.97\" ");
%!assert (angl2str (77.77777, "pm", "degrees2dms", 0), " +77° 46' 40\" ");
%!assert (angl2str (77.77777, "pm", "degrees2dms", 1), " +77° 46' 40\" ");
%!assert (angl2str (77.77777, "pm", "degrees2dms", 5), " +77° 47' 00\" ");
%!assert (angl2str (77.77777, "none", "radians", -5), " 77.77777 R ");
%!assert (angl2str (77.77777, "none", "radians", -2), " 77.78 R ");
%!assert (angl2str (77.77777, "none", "radians", 0), " 78 R ");
%!assert (angl2str (77.77777, "none", "radians", 1), " 80 R ");
%!assert (angl2str (77.77777, "none", "radians", 5), " 0 R ");
%!assert (angl2str (77.77777, "none", "degrees", -5), " 77.77777° ");
%!assert (angl2str (77.77777, "none", "degrees", -2), " 77.78° ");
%!assert (angl2str (77.77777, "none", "degrees", 0), " 78° ");
%!assert (angl2str (77.77777, "none", "degrees", 1), " 80° ");
%!assert (angl2str (77.77777, "none", "degrees", 5), " 0° ");
%!assert (angl2str (77.77777, "none", "degrees2dm", -5), " 77° 46.66620' ");
%!assert (angl2str (77.77777, "none", "degrees2dm", -2), " 77° 46.67' ");
%!assert (angl2str (77.77777, "none", "degrees2dm", 0), " 77° 47' ");
%!assert (angl2str (77.77777, "none", "degrees2dm", 1), " 77° 50' ");
%!assert (angl2str (77.77777, "none", "degrees2dm", 5), " 78° 00' ");
%!assert (angl2str (77.77777, "none", "degrees2dms", -5), " 77° 46' 39.97200\" ");
%!assert (angl2str (77.77777, "none", "degrees2dms", -2), " 77° 46' 39.97\" ");
%!assert (angl2str (77.77777, "none", "degrees2dms", 0), " 77° 46' 40\" ");
%!assert (angl2str (77.77777, "none", "degrees2dms", 1), " 77° 46' 40\" ");
%!assert (angl2str (77.77777, "none", "degrees2dms", 5), " 77° 47' 00\" ");
%!assert (angl2str ([-181.6999; -181.699999; -181.6999999999; -181.7; 181.71], ...
%!                  "ew", "degrees2dms", -4), ...
%!        [' 181° 41'' 59.6400" W '; ' 181° 41'' 59.9964" W '; ...
%!         ' 181° 42'' 00.0000" W '; ' 181° 42'' 00.0000" W '; ...
%!         ' 181° 42'' 36.0000" E ']);
