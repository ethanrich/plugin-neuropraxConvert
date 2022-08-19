## Copyright (C) 2007 Muthiah Annamalai <muthiah.annamalai@uta.edu>
## Copyright (C) 2015 Oliver Heimlich <oheim@posteo.de>
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
## @deftypefn {Function File} {@var{rval} =} base64decode (@var{code})
## @deftypefnx {Function File} {@var{rval} =} base64decode (@var{code}, @var{as_string})
## Convert a base64 @var{code}  (a string of printable characters according to RFC 2045) 
## into the original ASCII data set of range 0-255. If option @var{as_string} is 
## passed, the return value is converted into a string. Otherwise, the return
## value is a uint8 row vector.
##
## @example
## @group
## base64decode ('SGFrdW5hIE1hdGF0YQ==', true)
##   @result{} Hakuna Matata
## @end group
## @end example
##
## See: http://www.ietf.org/rfc/rfc2045.txt
##
## @seealso {base64encode}
## @end deftypefn

function Z = base64decode (X, as_string)
  if (nargin < 1 || nargin > 2)
    print_usage;
  elseif (nargin == 1)
    as_string = false;
  endif

  ## strip white space
  X((X == ' ') | (X == "\n") | (X == "\r")) = [];

  if (any (X(:) < 0) || any(X(:) > 255))
    error ("base64decode is expecting integers in the range 0 .. 255");
  endif

  ## convert into ascii code and 8 bit integers to save memory
  X = uint8 (X);

  ## decompose into the 4xN matrices - separation of encoded 3 byte blocks
  if (rows (X) ~= 4)
    if (rem (numel (X), 4) ~= 0)
      error ("base64decode is expecting blocks of 4 characters to decode");
    endif
    X = reshape (X, [4, numel(X)./4]);
  endif
  
  ## decode 6-bit values from the incoming matrix & 
  ## write the values into Va matrix.
  Va = ones (size(X), 'uint8') .* 65;

  iAZ = ((X >= 'A') & (X <= 'Z'));
  Va(iAZ) = X(iAZ) - 'A';

  iaz = ((X >= 'a') & (X <= 'z'));
  Va(iaz) = X(iaz) - 'a' + 26;

  i09 = ((X >= '0') & (X <= '9'));
  Va(i09) = X(i09) - '0' + 52;

  Va(X == '+') = 62;
  Va(X == '/') = 63;
  
  padding = (X == '=');
  Va(padding) = 0;
  
  if (any (any (Va == 65)))
    error ('base64decode is expecting valid characters A..Za..z0..9+/=');
  endif
  
  if (not (isempty (X)) && ...
      (find (padding, 1) < numel (X) - 1 || ...
        (X(end - 1) == '=' && X(end) ~= '=')))
    error ('base64decode is expecting max two padding characters at the end');
  endif
  
  ## decode 4x6 bit into 3x8 bit
  B = vertcat (...
        Va(1, :) .* 4 + (Va(2, :) - rem (Va(2, :), 16)) ./ 16, ...
        rem (Va(2, :), 16) .* 16 + (Va(3, :) - rem (Va(3, :), 4)) ./ 4, ...
        rem (Va(3, :), 4) .* 64 + Va(4, :));

  ## Convert blocks into row vector
  Z = B(:).';
  
  ## Remove byte blocks which have been introduced by padding
  if (not (isempty (X)))
    Z(end - sum (padding(end - 1 : end)) + 1 : end) = [];
  endif
  
  if (as_string)
    Z = char (Z);
  end

endfunction

%!assert(base64decode(base64encode('Hakuna Matata'),true),'Hakuna Matata')
%!assert(base64decode(base64encode([1:255])),uint8([1:255]))
%!assert(base64decode(base64encode('taken'),true),'taken')
%!assert(base64decode(base64encode('sax'),true),'sax')
%!assert(base64decode(base64encode('H'),true),'H')
%!assert(base64decode(base64encode('H'),false),uint8('H'))
%!assert(base64decode(base64encode('Ta'),true),'Ta')
