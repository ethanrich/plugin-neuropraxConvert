## Copyright (C) 2018-2021 Markus Mützel
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
## @deftypefn {} {[@var{ustr}, @var{error_flag}] =} utf82unicode (@var{istr})
## Convert from UTF-8 encoded strings @var{istr} to Unicode codepoints @var{ustr}.
##
## UTF-8 characters with more than 2 bytes are dropped since Octave does not
## support characters >255.  This means that only the ISO 8859-1 (Latin-1)
## subset of Unicode can be mapped correctly.
##
## If an error occured @var{error_flag} is set to true.
## @end deftypefn

## Author: Markus Mützel <markus.muetzel@gmx.de>
## Created: 2016-10-12

function [ustr, error_flag] = utf82unicode (istr="")

  error_flag = false;
  istr = uint8 (istr);
  ibyte = 1;
  ustr = uint8 ([]);
  while (true)
    if (isequal (bitget (istr(ibyte), 8), 0))
      ## Single byte character
      ustr(end+1) = istr(ibyte);
      ibyte += 1;
    elseif (isequal (bitget (istr(ibyte), 6:8), [0 1 1]))
      ## Start of double-byte char
      if (isequal (bitget (istr(ibyte+1), 7:8), [0 1]))
        ## Decode byte if it is valid UTF-8
        ustr(end+1) = bitand (31, istr(ibyte))*64 + bitand (63, istr(ibyte+1));
      else
        error_flag = true;
      endif
      ibyte += 2;
    elseif (isequal (bitget (istr(ibyte), 6:8), [1 1 1]))
      ## Drop this character (Octave does not support chars > 255).
      error_flag = true;
      ## Detect how many bytes to drop
      ibyte += find (bitget (istr(ibyte), 8:-1:1) == 0, 1, "first") - 1;
    elseif (isequal (bitget (istr(ibyte), 7:8), [0 1]))
      ## Drop this character (must follow a start byte)
      error_flag = true;
      ibyte += 1;
    else
      ## Should not reach here but maybe for safety?
      error_flag = true;
      ibyte += 1;
    endif
    if (ibyte > numel (istr))
      break
    endif
  endwhile

endfunction
