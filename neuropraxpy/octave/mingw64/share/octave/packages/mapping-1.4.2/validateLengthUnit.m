## Copyright (C) 2014-2022 Carnë Draug <carandraug@octave.org>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {} validateLengthUnit (@var{unit})
## @deftypefnx {Function File} {} validateLengthUnit (@var{unit}, @var{ind})
## @deftypefnx {Function File} {} validateLengthUnit (@var{unit}, @var{func})
## @deftypefnx {Function File} {} validateLengthUnit (@var{unit}, @var{func}, @var{name})
## @deftypefnx {Function File} {} validateLengthUnit (@var{unit}, @var{func}, @var{name}, @var{ind})
## Check validity and standardize unit of length.
##
## Confirms that the argument @var{input} is a valid length unit as
## described on the table below, and returns a string with its standard
## name.  If @var{unit} is not a valid length unit, throws an error with
## a message following the Octave guidelines.  For a more informative error
## message, the function name @var{func}, the argument name @var{name},
## and its position in the input @var{ind} can be defined.
##
## @table @asis
## @item @qcode{"meter"}
## m, meter(s), metre(s)
##
## @item @qcode{"centimeter"}
## cm, centimeter(s), centimetre(s)
##
## @item @qcode{"millimeter"}
## mm, millimeter(s), millimetre(s)
##
## @item @qcode{"micron"}
## micron(s)
##
## @item @qcode{"kilometer"}
## km, kilometer(s), kilometre(s)
##
## @item @qcode{"nautical mile"}
## nm, naut mi, nautical mile(s)
##
## @item @qcode{"foot"}
## ft, international ft, foot, international foot, feet, international feet
##
## @item @qcode{"inch"}
## in, inch, inches
##
## @item @qcode{"yard"}
## yd, yds, yard(s)
##
## @item @qcode{"mile"}
## mi, mile(s), international mile(s)
##
## @item @qcode{"U.S. survey foot"}
## sf, survey ft, US survey ft, U.S. survey ft, survey foot, US survey foot,
## U.S. survey foot, survey feet, US survey feet, U.S. survey feet
##
## @item @qcode{"U.S. survey mile (statute mile)"}
## sm, survey mile(s), statute mile(s), US survey mile(s), U.S. survey mile(s)
##
## @item @qcode{"Clarke's foot"}
## Clarke's foot, Clarkes foot
##
## @item @qcode{"German legal metre"}
## German legal metre, German legal meter
##
## @item @qcode{"Indian foot"}
## Indian foot
##
## @end table
##
## @seealso{units, unitsratio, validateattributes, validatestring}
## @end deftypefn

## Author: Carnë Draug <carandraug@octave.org>

function std_unit = validateLengthUnit (unit, varargin)

  ## keep it persistent to save us the trouble of building the struct
  ## each time we are called
  persistent units = struct (
    ## keys are all lowercase since the search must be case-insensitive
    "m",                      "meter",
    "meter",                  "meter",
    "meters",                 "meter",
    "metre",                  "meter",
    "metres",                 "meter",

    "cm",                     "centimeter",
    "centimeter",             "centimeter",
    "centimeters",            "centimeter",
    "centimetre",             "centimeter",
    "centimetres",            "centimeter",

    "mm",                     "millimeter",
    "millimeter",             "millimeter",
    "millimeters",            "millimeter",
    "millimetre",             "millimeter",
    "millimetres",            "millimeter",

    "micron",                 "micron",
    "microns",                "micron",

    "km",                     "kilometer",
    "kilometer",              "kilometer",
    "kilometers",             "kilometer",
    "kilometre",              "kilometer",
    "kilometres",             "kilometer",

    "nm",                     "nautical mile",
    "naut mi",                "nautical mile",
    "nautical mile",          "nautical mile",
    "nautical miles",         "nautical mile",

    "ft",                     "foot",
    "international ft",       "foot",
    "foot",                   "foot",
    "international foot",     "foot",
    "feet",                   "foot",
    "international feet",     "foot",

    "in",                     "inch",
    "inch",                   "inch",
    "inches",                 "inch",

    "yd",                     "yard",
    "yds",                    "yard",
    "yard",                   "yard",
    "yards",                  "yard",

    "mi",                     "mile",
    "mile",                   "mile",
    "miles",                  "mile",
    "international mile",     "mile",
    "international miles",    "mile",

    "sf",                     "U.S. survey foot",
    "survey ft",              "U.S. survey foot",
    "us survey ft",           "U.S. survey foot",
    "u.s. survey ft",         "U.S. survey foot",
    "survey foot",            "U.S. survey foot",
    "us survey foot",         "U.S. survey foot",
    "u.s. survey foot",       "U.S. survey foot",
    "survey feet",            "U.S. survey foot",
    "us survey feet",         "U.S. survey foot",
    "u.s. survey feet",       "U.S. survey foot",

    "sm",                     "U.S. survey mile (statute mile)",
    "survey mile",            "U.S. survey mile (statute mile)",
    "survey miles",           "U.S. survey mile (statute mile)",
    "statute mile",           "U.S. survey mile (statute mile)",
    "statute miles",          "U.S. survey mile (statute mile)",
    "us survey mile",         "U.S. survey mile (statute mile)",
    "us survey miles",        "U.S. survey mile (statute mile)",
    "u.s. survey mile",       "U.S. survey mile (statute mile)",
    "u.s. survey miles",      "U.S. survey mile (statute mile)",
    "u.s. survey mile (statute mile)", "U.S. survey mile (statute mile)",

    "clarke's foot",          "Clarke's foot",
    "clarkes foot",           "Clarke's foot",

    "german legal metre",     "German legal metre",
    "german legal meter",     "German legal metre",

    "indian foot",            "Indian foot"
  );

  ## Built start of error message from the extra optional arguments
  func_name = "";
  arg_id    = "input";
  if (nargin < 1)
    print_usage ()
  elseif (nargin > 1)
    second = varargin{1};
    if (ischar (second))
      func_name = [second ": "];
    elseif (nargin == 2 && isindex (second))
      arg_id = sprintf ("input #%i", second);
    else
      error ("validateLengthUnit: 2nd input argument must be IND or FUNC");
    endif

    if (nargin > 2)
      arg_id = varargin{2};
      if (! ischar (arg_id))
        error ("validateLengthUnit: NAME must be a string");
      endif

      if (nargin > 3)
        arg_ind = varargin{3};
        if (! isindex (arg_ind))
          error ("validateLengthUnit: IND must be a positive integer");
        endif
        arg_id = sprintf ("%s (argument #%i)", arg_id, arg_ind);
      endif
    endif
  endif

  if (! ischar (unit))
    ## if it's not a string, error message must be different
    error ("%s%s must be a string", func_name, arg_id);
  endif
  lunit = tolower (unit);
  if (isfield (units, lunit))
    std_unit = units.(lunit);
  else
    error ("%sunknown unit `%s' for %s", func_name, unit, arg_id);
  endif

endfunction

%!error <input #7> validateLengthUnit ("bad", 7)
%!error <foo: unknown unit `bad'> validateLengthUnit ("bad", "foo")
%!error <foo: unknown unit `bad' for ARG> validateLengthUnit ("bad", "foo", "ARG")
%!error <foo: unknown unit `bad' for ARG \(argument #7\)> validateLengthUnit ("bad", "foo", "ARG", 7)
%!error <must be a string> validateLengthUnit (9)
%!error <input #7 must be a string> validateLengthUnit (9, 7)
%!error <foo: input must be a string> validateLengthUnit (9, "foo")
%!error <foo: ARG must be a string> validateLengthUnit (9, "foo", "ARG")
%!error <foo: ARG \(argument #7\) must be a string> validateLengthUnit (9, "foo", "ARG", 7)

## typical usage and case insensitivity
%!assert (validateLengthUnit ("m"), "meter")
%!assert (validateLengthUnit ("meter"), "meter")
%!assert (validateLengthUnit ("meters"), "meter")
%!assert (validateLengthUnit ("mETErs"), "meter")

## names with spaces and dots
%!assert (validateLengthUnit ("us survey feet"), "U.S. survey foot")
%!assert (validateLengthUnit ("US survey feet"), "U.S. survey foot")
%!assert (validateLengthUnit ("U.S. survey feet"), "U.S. survey foot")
%!assert (validateLengthUnit ("u.s. survey feet"), "U.S. survey foot")

## names with apostrophes
%!assert (validateLengthUnit ("clarke's foot"), "Clarke's foot")

