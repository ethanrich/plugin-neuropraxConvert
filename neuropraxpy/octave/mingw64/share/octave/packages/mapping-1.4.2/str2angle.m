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
## @deftypefn {} {@var{deg} =} str2angle (@var{txt})
## @deftypefnx {} {@var{deg} =} str2angle (@var{txt}, @var{verbose})
## Convert string type angular coordinates into numerical decimal degrees.
##
## @var{txt} can be a txt string or cellstr array containing one or more
## strings each representing an angular coordinate (latitude and/or
## longitude).  str2angle is quite picky as regards input formats, see below.
##
## If optional input argument @var{verbose} is set to 1 or true,
## str2angle will warn if the input cntains strings that couldn't
## be converted.  The default value is false (no warnings).
##
## Output argument @var{deg} contains an 1xN array of numerical degree
## value(s.  Unrecognizable input strings are either ignored or, if looking
## almost recognizable, set to NaN in the output.
##
## The angular strings should look like:
## @itemize
## @item
## an integer number comprising one to three leading digits (degrees), maybe
## preceded by a plus or minus character;
##
## @item
## one of a 'degree' character or even a 'D', 'E', 'W', 'N' or 'S'
## (capitalization ignored) optionally followed by a space.  In case of a
## 'W', 'w', 'S' or 's' character (western or southern hemisphere, resp.)
## the corresponding output value will be negated;
##
## @item
## a positive integer number comprising exactly two digits (minutes)
## immediately followed by either an apostroph (') or 'M' or 'm' character,
## optionally followed by a space;
##
## @item
## a positive integer or real number (seconds), immediately followed by
## either a '"' character (double quote), or an 's' or 'S' character, or
## two consecutive single quote characters ('');
##
## @item
## optionally, a character 'E', 'N', 'S' or 'W' indicating the hemisphere.
## @end itemize
##
## So-called packed DMS and degrees/minutes/seconds separated by hyphens or
## minus signs are not accepted.
##
## So, angular degree strings may look like e.g.: @*
## @verbatim
## 191E21'3.1",      12e 22'33.24",    13E 23' 33.344",
## 14w24' 33.4444",  15S25'33.544",    -16W26'33.644444'',
## 17s27'33.74444",  18N28'33.844",    +19d29m33.944444s,
## 20D20M33.0444Se,  21°51'4.1",       22°52'44.25",
## 23° 53'33.34",    24°54' 33.44N",    25° 55' 33.544",
## 26°56'33.644''S,   27°57' 33.744'',  28°58'33844"w.
## @end verbatim
##
## Note: the regular expression used to parse the input strings can be
## fooled.  In particularly bad cases it may loose track completely and
## give up, angle2str returns an empty scalar Inf value then to distinguish
## from partly convertible inputs.
##
## @seealso{angl2str}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2020-05-18

function deg = str2angle (txt, verbose = 0)

  fmt = [ '([-+]?[0123456789]{1,3})([^+-]\s?|°\s?)([+-]?[0123456789]{2})' ...
          '[''mM]\s?([+-]?[0123456789\.].*?)((?:["sS]|'''')[eEnNsSwW]?)' ];

  if (iscellstr (txt))
    txt = strjoin (txt, "   ");
  elseif (! ischar (txt))
    error ("str2angle: char string or cellstr expected, but got %s", ...
          class (txt));
  endif
  try
    rs = reshape (cell2mat (regexp (txt, fmt, "tokens")), 5, []);
    deg = [zeros(1, size (rs, 2)); str2double(rs([1 3 4], :))];
    ierr = find (deg(3, :) >= 60.0 | deg(3, :) < 0.0 | strcmp (rs(2, :), '-'));
    ierr = [ ierr (find (abs (deg(1, :)) > 360.0)) ];
    ierr = unique ([ierr (find (deg(4, :) >= 60.0 | deg(4, :) < 0.0))]);
    if (! isempty (ierr))
      if (verbose)
        warning ("angstr:inconv", "str2angle: inconvertible values set to NaN");
      endif
      deg(1, ierr) = deg(3, ierr) = deg(4, ierr) = 0;
    endif
    deg(1, :) = (abs (deg(2, :)) + (deg(3, :) + deg(4, :) / 60) / 60) .* sign (deg(2, :));
    deg(2:end, :) = [];
    deg(1, ierr) = NaN;
    ## Set coordinates in western or southern hemisphere to negative.
    ## 1. Check hemisphere indicators directly following degrees
    ineg = find (! cellfun (@isempty, regexpi (rs(2, :), '[sw]')));
    ## For trailing hemisphere indicaors, first remove seconds indicators
    rs(5, :) = regexprep (rs(5, :), '[''"Ss]', '');
    ## 2. Check for S or W hemisphere
    ineg = [ ineg (find (! cellfun (@isempty, regexpi (rs(5, :), '[sw]')))) ];
    deg(1, ineg) = -deg(1, ineg);
  catch
    if (verbose)
      warning ("angstr:inconv", "str2angle: inconvertible input");
    endif
    deg = Inf;
  end_try_catch

endfunction


%!test
%!shared tst, res
%! tst = '191E21''3.1"\n12e 22''33.24"\n13E 23'' 33.344"\n14w24'' 33.4444"\n';
%! tst = [tst '15S25''33.54444"\n16W26''33.644444''''\n17s27''33.7444444"\n'];
%! tst = [tst '18N28''33.84444444"\n19d29m33.944444444s\n20D20M33.04444444Se\n'];
%! tst = [tst '21°51''4.1"\n22°52''44.25"\n23° 53''33.34"\n24°54'' 33.44"N\n'];
%! tst = [tst '25° 55'' 33.544"\n26°56''33.644''''S\n27°57'' 33.744''''\n'];
%! tst = [tst '28°58''33.844"w'];
%! tst = strrep (tst, '\n', char(10));
%! res = [191.351, 12.376, 13.393, -14.409, -15.426, -16.443, -17.459, 18.476, ...
%!        19.493, 20.343, 21.851, 22.879, 23.893, 24.909, 25.926, 26.943, ...
%!        27.959, -28.976];
%! assert (str2angle (tst), res, 1e-3);

%!test
%! tstc = strsplit (tst, "\n");
%! assert (str2angle (tstc), res, 1e-3);

%!test
%! tstc = strjoin (strsplit (tst, "\n"), "   ");
%! assert (str2angle (tstc), res, 1e-3);

%!test
%! assert (str2angle ('24E77''33"  25W43''57.7"'), [NaN, -25.7333], 1e-3);

%!test
%! assert (str2angle ('; aggag'), Inf);

%!warning <inconvertible> str2angle ('24E77''33"', 1);
%!warning <inconvertible> str2angle (' -4D-32''-44.57"', 1);
%!error <char string or cellstr expected> str2angle (25);


