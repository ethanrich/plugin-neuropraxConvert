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
## @deftypefn {Function File} {} unitsratio (@var{to}, @var{from})
## Return ratio for conversion between units.
##
## Returns the conversion ratio between two units, @var{to} and @var{from}, so
## that:
##
## @group
## @example
## unitsratio ("meter", "centimeter")
## @result{ratio } 100
##
## unitsratio ("inch", "foot")
## @result{ratio } 12
## @end example
## @end group
##
## This allows for easy conversion between units, for example:
##
## @group
## @example
## unitsratio ("mile", "km") * 156
## @result{156 km in miles }96.93391
## @end example
## @end group
##
## For conversion between angle units, @qcode{"degrees"} and
## @qcode{"radians"} are supported.  For conversion between length units,
## supports units defined in @code{validateLengthUnit}.
##
## @seealso{units, validateLengthUnit}
## @end deftypefn

## Author: Carnë Draug <carandraug@octave.org>

function ratio = unitsratio (to, from)

  if (nargin != 2)
    print_usage ();
  endif

  try
    valid_to    = validatestring (to, {"radians", "degrees"});
    valid_from  = validatestring (from, {"radians", "degrees"});
  catch
    valid_to   = validateLengthUnit (to, "unitsratio", "TO");
    valid_from = validateLengthUnit (from, "unitsratio", "FROM");
  end_try_catch

  persistent ratios = struct (
    ## angle units
    "degrees", struct (
      "degrees", 1,
      "radians", pi / 180
    ),
    "radians", struct (
      "degrees", 180 / pi,
      "radians", 1
    ),

    ## length units
    "meter", struct (
      "meter",                            1,
      "centimeter",                       100,
      "millimeter",                       1000,
      "micron",                           10^6,
      "kilometer",                        0.001,
      "nautical mile",                    1 / 1852,
      "foot",                             1 / 0.3048,
      "inch",                             1 / 0.0254,
      "yard",                             1 / 0.9144,
      "mile",                             1 / 1609.344,
      "U.S. survey foot",                 3937 / 1200,
      "U.S. survey mile (statute mile)",  3937 / (1200 * 5280), # 5280 survey foot
      "Clarke's foot",                    1 / 0.3047972654,
      "German legal metre",               1 / 1.0000135965,
      "Indian foot",                      1 / 0.3047996
    ),

    ## same as meter times 0.01
    "centimeter", struct (
      "meter",                            0.01,
      "centimeter",                       0.01 * 100,
      "millimeter",                       0.01 * 1000,
      "micron",                           0.01 * 10^6,
      "kilometer",                        0.01 * 0.001,
      "nautical mile",                    0.01 / 1852,
      "foot",                             0.01 / 0.3048,
      "inch",                             0.01 / 0.0254,
      "yard",                             0.01 / 0.9144,
      "mile",                             0.01 / 1609.344,
      "U.S. survey foot",                 0.01 * (3937 / 1200),
      "U.S. survey mile (statute mile)",  0.01 * 3937 / (1200 * 5280),
      "Clarke's foot",                    0.01 / 0.3047972654,
      "German legal metre",               0.01 / 1.0000135965,
      "Indian foot",                      0.01 / 0.3047996
    ),

    ## same as meter times 0.001
    "millimeter", struct (
      "meter",                            0.001,
      "centimeter",                       0.001 * 100,
      "millimeter",                       0.001 * 1000,
      "micron",                           0.001 * 10^6,
      "kilometer",                        0.001 * 0.001,
      "nautical mile",                    0.001 / 1852,
      "foot",                             0.001 / 0.3048,
      "inch",                             0.001 / 0.0254,
      "yard",                             0.001 / 0.9144,
      "mile",                             0.001 / 1609.344,
      "U.S. survey foot",                 0.001 * (3937 / 1200),
      "U.S. survey mile (statute mile)",  0.001 * 3937 / (1200 * 5280),
      "Clarke's foot",                    0.001 / 0.3047972654,
      "German legal metre",               0.001 / 1.0000135965,
      "Indian foot",                      0.001 / 0.3047996
    ),

    ## same as meter times 10^-6
    "micron", struct (
      "meter",                            10^-6,
      "centimeter",                       10^-6 * 100,
      "millimeter",                       10^-6 * 1000,
      "micron",                           10^-6 * 10^6,
      "kilometer",                        10^-6 * 0.001,
      "nautical mile",                    10^-6 / 1852,
      "foot",                             10^-6 / 0.3048,
      "inch",                             10^-6 / 0.0254,
      "yard",                             10^-6 / 0.9144,
      "mile",                             10^-6 / 1609.344,
      "U.S. survey foot",                 10^-6 * (3937 / 1200),
      "U.S. survey mile (statute mile)",  10^-6 * 3937 / (1200 * 5280),
      "Clarke's foot",                    10^-6 / 0.3047972654,
      "German legal metre",               10^-6 / 1.0000135965,
      "Indian foot",                      10^-6 / 0.3047996
    ),

    ## same as meter times 1000
    "kilometer", struct (
      "meter",                            1000,
      "centimeter",                       1000 * 100,
      "millimeter",                       1000 * 1000,
      "micron",                           1000 * 1000000,
      "kilometer",                        1000 * 0.001,
      "nautical mile",                    1000 / 1852,
      "foot",                             1000 / 0.3048,
      "inch",                             1000 / 0.0254,
      "yard",                             1000 / 0.9144,
      "mile",                             1000 / 1609.344,
      "U.S. survey foot",                 1000 * (3937 / 1200),
      "U.S. survey mile (statute mile)",  1000 * 3937 / (1200 * 5280),
      "Clarke's foot",                    1000 / 0.3047972654,
      "German legal metre",               1000 / 1.0000135965,
      "Indian foot",                      1000 / 0.3047996
    ),

    ## exactly 1852 meters
    "nautical mile", struct (
      "meter",                            1852,
      "centimeter",                       1852 * 100,
      "millimeter",                       1852 * 1000,
      "micron",                           1852 * 10^6,
      "kilometer",                        1852 * 0.001,
      "nautical mile",                    1,
      "foot",                             2315000 / 381, # thank you wikipedia
      "inch",                             27780000 / 381,
      "yard",                             2315000 / 1143, # thank you wikipedia
      "mile",                             1852 / 1609.344, # from how many meters are in a mile
      "U.S. survey foot",                 1852 * 3937 / 1200, # from how many meters are in US survey foot
      "U.S. survey mile (statute mile)",  57875 / 50292,
      "Clarke's foot",                    1852 / 0.3047972654,
      "German legal metre",               1852 / 1.0000135965,
      "Indian foot",                      1852 / 0.3047996 # from how many meters are in an indian foot
    ),

    ## exactly 0.3048 meters. Also 12 inch
    "foot", struct (
      "meter",                            0.3048,
      "centimeter",                       0.3048 * 100,
      "millimeter",                       0.3048 * 1000,
      "micron",                           0.3048 * 10^6,
      "kilometer",                        0.3048 * 0.001,
      "nautical mile",                    381 / 2315000,  # inverse from nautical mile to foot
      "foot",                             1,
      "inch",                             12,
      "yard",                             1 / 3,
      "mile",                             1 / 5280,
      "U.S. survey foot",                 0.3048 / (1200 / 3937),
      "U.S. survey mile (statute mile)",  (5280 * 3977) / (0.3048 * 1200),
      "Clarke's foot",                    0.3048 / 0.3047972654,
      "German legal metre",               0.3048 / 1.0000135965,
      "Indian foot",                      0.3048 / 0.3047996
    ),

    ## exactly 0.0254 meters
    "inch", struct (
      "meter",                            0.0254,
      "centimeter",                       0.0254 * 100,
      "millimeter",                       0.0254 * 1000,
      "micron",                           0.0254 * 10^6,
      "kilometer",                        0.0254 * 0.001,
      "nautical mile",                    381 / 27780000, # inverse from nautical mile to inch
      "foot",                             1 / 12,
      "inch",                             1,
      "yard",                             1 / 36,
      "mile",                             1 / (5280 * 12),
      "U.S. survey foot",                 0.0254 / (1200 / 3937),
      "U.S. survey mile (statute mile)",  (5280 * 3977) / (0.0254 * 1200),
      "Clarke's foot",                    0.0254 / 0.3047972654,
      "German legal metre",               0.0254 / 1.0000135965,
      "Indian foot",                      0.0254 / 0.3047996
    ),

    ## exactly 0.9144 meters. Also 3 feet
    "yard", struct (
      "meter",                            0.9144,
      "centimeter",                       0.9144 * 100,
      "millimeter",                       0.9144 * 1000,
      "micron",                           0.9144 * 10^6,
      "kilometer",                        0.9144 * 0.001,
      "nautical mile",                    1143 / 2315000, # inverse from nautical mile to yard
      "foot",                             3,
      "inch",                             36,
      "yard",                             1,
      "mile",                             3 / 5280,
      "U.S. survey foot",                 0.9144 / (1200 / 3937),
      "U.S. survey mile (statute mile)",  (5280 * 3977) / (0.9144 * 1200),
      "Clarke's foot",                    0.9144 / 0.3047972654,
      "German legal metre",               0.9144 / 1.0000135965,
      "Indian foot",                      0.9144 / 0.3047996
    ),

    ## exactly 1609.344 meters. Also 5280 feet
    "mile", struct (
      "meter",                            1609.344,
      "centimeter",                       1609.344 * 100,
      "millimeter",                       1609.344 * 1000,
      "micron",                           1609.344 * 10^6,
      "kilometer",                        1609.344 * 0.001,
      "nautical mile",                    1609.344 / 1852,
      "foot",                             5280,
      "inch",                             5280 * 12,
      "yard",                             5280 / 3,
      "mile",                             1,
      "U.S. survey foot",                 1609.344 / (1200 / 3937),
      "U.S. survey mile (statute mile)",  (5280 * 3977) / (1609.344 * 1200),
      "Clarke's foot",                    1609.344 / 0.3047972654,
      "German legal metre",               1609.344 / 1.0000135965,
      "Indian foot",                      1609.344 / 0.3047996
    ),

    ## exactly 1200 / 3937
    "U.S. survey foot", struct (
      "meter",                                    1200 / 3937,
      "centimeter",                       100   * 1200 / 3937,
      "millimeter",                       1000  * 1200 / 3937,
      "micron",                           10^6  * 1200 / 3937,
      "kilometer",                        0.001 * 1200 / 3937,
      "nautical mile",                    1200 / (1852 * 3937),
      "foot",                             (1200 / 3937) / 0.3048,
      "inch",                             (1200 / 3937) / 0.0254,
      "yard",                             (1200 / 3937) / 0.9144,
      "mile",                             (1200 / 3937) / 1609.344,
      "U.S. survey foot",                 1,
      "U.S. survey mile (statute mile)",  1 / 5280,
      "Clarke's foot",                    1200 / (0.3047972654 * 3937),
      "German legal metre",               1200 / (1.0000135965 * 3937),
      "Indian foot",                      1200 / (0.3047996 * 3937)
    ),

    ## the U.S. survey mile is 5280 survey feet (survey foot = 1200 / 3937 meters)
    "U.S. survey mile (statute mile)", struct (
      "meter",                                    5280 * 1200 / 3937,
      "centimeter",                       100   * 5280 * 1200 / 3937,
      "millimeter",                       1000  * 5280 * 1200 / 3937,
      "micron",                           10^6  * 5280 * 1200 / 3937,
      "kilometer",                        0.001 * 5280 * 1200 / 3937,
      "nautical mile",                    50292 / 57875,
      "foot",                             (0.3048 * 1200) / (5280 * 3977),
      "inch",                             (0.0254 * 1200) / (5280 * 3977),
      "yard",                             (0.9144 * 1200) / (5280 * 3977),
      "mile",                             (1609.344 * 1200) / (5280 * 3977),
      "U.S. survey foot",                 5280,
      "U.S. survey mile (statute mile)",  1,
      "Clarke's foot",                    (5280 * 1200) / (0.3047972654 * 3937),
      "German legal metre",               (5280 * 1200) / (1.0000135965 * 3937),
      "Indian foot",                      (5280 * 1200) / (0.3047996 * 3937)
    ),

      ## Defined as 0.3047972654 meters (from georepository.com)
    "Clarke's foot", struct (
      "meter",                            0.3047972654,
      "centimeter",                       0.3047972654 * 100,
      "millimeter",                       0.3047972654 * 1000,
      "micron",                           0.3047972654 * 10^6,
      "kilometer",                        0.3047972654 * 0.001,
      "nautical mile",                    0.3047972654 / 1852,
      "foot",                             0.3047972654 / 0.3048,
      "inch",                             0.3047972654 / 0.0254,
      "yard",                             0.3047972654 / 0.9144,
      "mile",                             0.3047972654 / 1609.344,
      "U.S. survey foot",                 (0.3047972654 * 3937) / 1200,
      "U.S. survey mile (statute mile)",  (0.3047972654 * 3937) / (5280 * 1200),
      "Clarke's foot",                    1,
      "German legal metre",               0.3047972654 / 1.0000135965,
      "Indian foot",                      0.3047972654 / 0.3047996
    ),

    ## Defined as 1.0000135965 meters (longer than a meter by 13.5965 micrometers)
    "German legal metre", struct (
      "meter",                            1.0000135965,
      "centimeter",                       1.0000135965 * 100,
      "millimeter",                       1.0000135965 * 1000,
      "micron",                           1.0000135965 * 10^6,
      "kilometer",                        1.0000135965 * 0.001,
      "nautical mile",                    1.0000135965 / 1852,
      "foot",                             1.0000135965 / 0.3048,
      "inch",                             1.0000135965 / 0.0254,
      "yard",                             1.0000135965 / 0.9144,
      "mile",                             1.0000135965 / 1609.344,
      "U.S. survey foot",                 (1.0000135965 * 3937) / 1200,
      "U.S. survey mile (statute mile)",  (1.0000135965 * 3937) / (5280 * 1200),
      "Clarke's foot",                    1.0000135965 / 0.3047972654,
      "German legal metre",               1,
      "Indian foot",                      1.0000135965 / 0.3047996
    ),

    ## The Indian survey foot is defined as exactly 0.3047996 m (wikipedia)
    "Indian foot", struct (
      "meter",                            0.3047996,
      "centimeter",                       0.3047996 * 100,
      "millimeter",                       0.3047996 * 1000,
      "micron",                           0.3047996 * 10^6,
      "kilometer",                        0.3047996 * 0.001,
      "nautical mile",                    0.3047996 / 1852,
      "foot",                             0.3047996 / 0.3048,
      "inch",                             0.3047996 / 0.0254,
      "yard",                             0.3047996 / 0.9144,
      "mile",                             0.3047996 / 1609.344,
      "U.S. survey foot",                 (0.3047996 * 3937) / 1200,
      "U.S. survey mile (statute mile)",  (0.3047996 * 3937) / (5280 * 1200),
      "Clarke's foot",                    0.3047996 / 0.3047972654,
      "German legal metre",               0.3047996 / 1.0000135965,
      "Indian foot",                      1
    )
  );

  try
    ratio = ratios.(valid_from).(valid_to);
  catch
    error ("unitsratio: unknown conversion from %s to %s", from, to);
  end_try_catch

endfunction

%!assert (unitsratio ("inch", "foot"), 12)
%!assert (unitsratio ("m", "cm"), 0.01)
%!assert (unitsratio ("cm", "m"), 100)
%!assert (unitsratio ("meter", "meter"), 1)
%!assert (unitsratio ("degrees", "radians"), 180 / pi)
%!assert (unitsratio ("radians", "degrees"), pi / 180)

%!error <unknown unit> unitsratio ("NOT A UNIT", "meter")
%!error <unknown unit> unitsratio ("meter", "NOT A UNIT")

