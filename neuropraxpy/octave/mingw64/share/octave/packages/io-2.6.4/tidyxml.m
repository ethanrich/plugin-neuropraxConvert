## Copyright (C) 2016-2021 Philip Nienhuis
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
## @deftypefn {} {@var{ostr} =} tidyxml (@var{istr}, @var{conv_fcn})
## Optionally convert character using the function handle in @var{conv_fcn},
## remove characters (<32 >255) from text string or cell array @var{istr}
## and return the result in @var{ostr}.
##
## tidyxml is useful for converting strings in XML that have been partly
## or wholly encoded as double-byte characters.  Such strings occur when
## dealing with a.o., spreadsheet programs reading/writing from/to
## XML-based formats and cannot be processed by Octave as Octave doesn't
## support unicode.  For (optionally: nested) nested cell arrays tidyxml
## is called recursively and only processes cells containing text strings.
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2016-01-13

function [ostr] = tidyxml (istr="", conv_fcn=[])

  if (iscell (istr))
    idx = find (cellfun (@ischar, istr));
    ostr = istr;
    ostr(idx) = cellfun (@(instr) tidyxml (instr, conv_fcn), istr(idx), "uni", 0);
  elseif (! ischar (istr))
    print_usage ();
  elseif (isempty (istr))
    ostr = "";
  else
    if (isempty (conv_fcn))
      ustr = uint8 (istr);
    else
      if (nargout (conv_fcn) > 1)
        [ustr, error_flag] = conv_fcn (istr);
        if (error_flag)
          warning ("Encoding conversion failed; some characters might be lost");
        endif
      else
        try
          ustr = conv_fcn (istr);
        catch err
          warning ("Encoding conversion failed; some characters might be lost");
          ustr = istr;
        end_try_catch
      endif
    endif
    ostr = char (ustr(ustr > 31 & ustr < 256));
  endif

endfunction
