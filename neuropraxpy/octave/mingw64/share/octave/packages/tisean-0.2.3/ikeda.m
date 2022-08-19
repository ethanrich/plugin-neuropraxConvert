## Copyright (C) 1996-2015 Piotr Held
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public
## License as published by the Free Software Foundation;
## either version 3 of the License, or (at your option) any
## later version.
##
## Octave is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied
## warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
## PURPOSE.  See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public
## License along with Octave; see the file COPYING.  If not,
## see <http://www.gnu.org/licenses/>.

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on henon of TISEAN 3.0.1 https://github.com/heggus/Tisean"

## -*- texinfo -*-
## @deftypefn{Function File} {@var{output_array} =} ikeda (@var{L}, @dots{})
## @deftypefnx{Function File} {@var{output_array} =} ikeda (@var{L}, @var{paramName}, @var{paramValue}, @dots{})
##
## Generate Ikeda map
## 
## @iftex
## @tex
## $$ z_{n+1} = 1 + c * z_{n} * exp (a*i - {{b*i} \over {1+|z_{n}|}})$$
## @end tex
## @end iftex
## @ifnottex
## @example
##                                       b*i
## z(n+1) = 1 + c * z(n) * exp (a*i - ---------)
##                                    1+|z(n)|
## @end example
## @end ifnottex
##
## @strong{Input}
## 
## @table @var
## @item L
## The number of points (x,y), must be integer. Required value.
## @end table
##
## @strong{Parameters}
## 
## @table @var
## @item a 
## Defines parameter 'a' (default=0.4)
## @item b
## Defines parameter 'b' (default=6.0)
## @item c
## Defines parameter 'c' (default=0.9) 
## @item R
## Initial real value of 'z' (default=0.68587)
## @item I
## Initial imaginary value of 'z' (defaul=0.65876)
## @item ntrans
## Defines number of transient points (default=10000),
## must be positive integer scalar
## @end table
##
## @strong{Output}
##
## @var{output} is of length @var{L}. The first columns are the real values
## of the Ikeda Map and the second are the imaginary values of the Ikeda map.
## This is done to be work the same way that 'ikeda' in TISEAN works.
##
## @strong{Usage example}
##
## @code{out = ikeda(1000, "a", 1.25)}
## 
## After this command @var{out} will be a 1000x2 matrix with Henon map
## points as rows. It will generate 1000 points.
##
## @strong{Algorithm}
## On basis of TISEAN package ikeda
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on ikeda of TISEAN 3.0.1
## https://github.com/heggus/Tisean"

function output = ikeda (L, varargin)

% Define default parameters.
  a          = 0.4;
  b          = 6.0;
  c          = 0.9;
  x0         = 0.68587;
  y0         = 0.65876;  
  ntransient = 10000;

  isPositiveInteger = @(x) isreal(x) && isscalar (x) && (x > 0) && (x-round(x) == 0);

  if (nargin < 1)
    print_usage();
  elseif (isPositiveInteger (L) != true)
    error ('Octave:invalid-input-arg', "L must be a positive integer");
  endif

  #### Parse the input    
  p = inputParser ();
  p.FunctionName = "ikeda";  
  
  isRealScalar = @(x) isreal (x) && isscalar (x);
  p.addParamValue ("A",a,isRealScalar);
  p.addParamValue ("B",b,isRealScalar);
  p.addParamValue ("C",c,isRealScalar);
  p.addParamValue ("R",x0,isRealScalar);
  p.addParamValue ("I",y0,isRealScalar);

  isNonNegative = @(x) isreal(x) && isscalar (x) && (x >= 0) && (x-round(x) == 0);
  
  p.addParamValue ("ntrans",ntransient,isNonNegative);
  
  p.parse (varargin{:});

  # Asign input
  nmax = L;

  a          = p.Results.A;
  b          = p.Results.B;
  c          = p.Results.C;
  x0         = p.Results.R;
  y0         = p.Results.I;
  ntransient = p.Results.ntrans;

% Computing output  
  output = __ikeda__ (nmax, a, b, c, x0, y0, ntransient);

endfunction

%!test
%! ikd = [0.28571947432035805 0.64340009417266342;0.50841625820931591 -0.39972597757561129;0.87547944209544659 0.56858743316662752;0.70057389172681206 -0.89053147224601548;-1.9710645882970557E-002 -1.0429004993745194E-002;0.99222205960974108 -1.8501225510088638E-002;0.21620211688366087 -0.42823693940249830;1.3295528700280905 0.27892721893609196;1.0842998438472966 -1.2197367054961652;0.28153619668028618 -1.2810993040439602];
%! res = ikeda (10);
%! assert (res, ikd, 1e-16);
