## Copyright (C) 2021 The Octave Project Developers
## Copyright (C) 2016 Òscar Monerris Belda
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
## @deftypefn {Function File} {[@var{y}, @var{mapping}] =} bin2gray (@var{x}, @var{type}, @var{M})
## Creates a Gray encoded data @var{y} with the same size as input @var{x} 
##
## Input:
## @itemize
## @item @var{x} Binary matrix data
##
## @item @var{type}: The modulation type 
## choices available:'qam', 'pam','psk','dpsk', and 'fsk'
##
## @item @var{M}: The modualtion order must be a power of 2
## @end itemize
##
## Output:
## @itemize
## @item @var{y}: The gray data of the @var{x} data.
## @item @var{mapping}: This provides the gray labesfor the given modulation.
## @end itemize
##
## Example 
## @example
## y = bin2gray ([0:3], 'qam', 16)
## y =
## 
##     0
##     1
##     3
##     2
## @end example
## 
## Example with matrix
## @example
## y = bin2gray ([0:3; 12:15], 'qam', 16)
## y =
##
##     0    1    3    2
##     8    9   11   10
## @end example
## @seealso{qammod}
## @end deftypefn

function [y, mapping] = bin2gray (x, type, M)

if (nargin < 3)
  print_usage();
endif

if (~isnumeric (M))
    error('bin2gray:: M must be an integer power of 2')
endif

if (M < 1)
    error('bin2gray:: M must be an integer power of 2')
endif

if (fix (log2 (M)) ~= log2 (M))
  error('bin2gray:: M must be an integer power of 2')
endif

if (max (x) > M - 1 || min (x) < 0)
  error('bin2gray:: x array out of [0,M-1] range')
endif



switch lower (type)

  case 'qam'
    # Two dimensional modulations
    
    if (mod (nextpow2 (M), 2) == 0)
      # Number of elements in the I and Q axis
      nbits = nextpow2 (M);
      nI = sqrt (M);
      
      # Split in two the number of bits
      data1D = (0: nI - 1)';
      mapping1D = bitxor (data1D, bitshift (data1D, -1));
      # Gray code half of the bytes
      bin1D = de2bi (mapping1D, nbits / 2);
      
      mapping = zeros (M, 1);
      for id=1: nI
        mapping((1 + nI * (id - 1)): nI * id) = bi2de ([bin1D ones(nI, 1) * bin1D(id, :)]);
      endfor
      
      # Build the constallation - detailed code
      # for id=0:M-1
      #  idi = floor(id/nI)+1;
      #  idq = mod(id,nI)+1;
      #  mapping(id+1) = bi2de([bin1D(idq,:) bin1D(idi,:)]);
      #endfor
      
      else
        if (M == 8)
          mapping = [];
        elseif (M == 32)
          mapping = [];
        else
          error('bin2gray:: log2(M) = 2*n+1 for n>2 is not implemented')
        endif
      endif

    case {'pam','psk','dpsk','fsk'}

      # One dimensional modulation
      IQ = (0: M - 1)';
      mapping = bitxor (IQ, bitshift (IQ, -1));

    otherwise
      error('bin2gray:: type is not valid')
endswitch

y = mapping (x + 1);

endfunction

%% Test input validation
%!error bin2gray ()
%!error bin2gray (1)
%!error bin2gray (1, 2)
%!error <mapping> bin2gray ([0:10], 'qam', 32)
%!error <M must be> bin2gray ([0:3], 'qam', 15)

%!test
%! assert (bin2gray ([0:3 12:15], 'qam', 16), [0 1 3 2 8 9 11 10]');

%!test
%! assert (bin2gray (0:3, 'psk', 16), [0 1 3 2]');

## Understanding the QAM gray coding
#
# For a square constellation the MSB (nbits/2)
# remain constant for the whole Q range and the 
# Q range is enconded using a 1D gray coding
# but, at the same time, the I axis is coded
# using a standard 1D gray sequence keeping 
# this value constant for all the Q's. 
#
#       -3       -1       +1     +3 
#                 |
#+3  00|10  01|10 | 11|10  10|10 -> Gray code the MSB
#                 |
#+1  00|11  01|11 | 11|11  10|11
#-----------------|------------------ -> I axis
#-1  00|01  01|01 | 11|01  10|01
#                 |
#-3  00|00  01|00 | 11|00  10|00
#                 |
#                 v
#                 Q axis