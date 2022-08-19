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
## @deftypefn{Function File} {@var{output_array} =} henon (@var{L}, @dots{})
## @deftypefnx{Function File} {@var{output_array} =} henon (@var{L}, @var{paramName}, @var{paramValue}, @dots{})
##
## Generate Henon map
## 
## @iftex
## @tex
## $$ x_{n+1} = 1 - ax_n^2 + by_n $$
## $$ y_{n+1} = x_n$$
## @end tex
## @end iftex
## @ifnottex
## @example
## x(n+1) = 1 - a * x(n) * x(n) + b * y(n)
## y(n+1) = x(n)
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
## Defines parameter 'a' (default=1.4)
## @item b
## Defines parameter 'b' (default=0.3) 
## @item x
## Initial 'x' (default=0.68587)
## @item y
## Initial 'y' (defaul=0.65876)
## @item ntrans
## Defines number of transient points (default=10000), must be positive
## integer scalar
## @end table
##
## @strong{Output}
##
## @var{output_array} is of length @var{L}. It contains points on the
## Henon Map.
##
## @strong{Usage example}
##
## @code{out = henon(1000, "a", 1.25)}
## 
## After this command @var{out} will be a 1000x2 matrix with Henon map 
## points as rows. It will generate 1000 points.
##
## @strong{Algorithm}@*
## On basis of TISEAN package henon
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on henon of TISEAN 3.0.1
## https://github.com/heggus/Tisean"

function output = henon (L, varargin)

% Define default parameters.
  a          = 1.4;
  b          = 0.3;
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
  p.FunctionName = "henon";  
  
  p.addParamValue ("A",a,@isnumeric);
  p.addParamValue ("B",b,@isnumeric);
  p.addParamValue ("X",x0,@isnumeric);
  p.addParamValue ("Y",y0,@isnumeric);
  
  isNonNegative = @(x) isreal(x) && isscalar (x) && (x >= 0) && (x-round(x) == 0);
  
  p.addParamValue ("ntrans",ntransient,isNonNegative);
  
  p.parse (varargin{:});

  # Asign input
  nmax = L;  

  a          = p.Results.A;
  b          = p.Results.B;
  x0         = p.Results.X;
  y0         = p.Results.Y;
  ntransient = p.Results.ntrans;

% Computing output  
  output = __henon__ (nmax, a, b, x0, y0, ntransient);

endfunction

%!test
%! hen = [0.67778; 0.41367; 0.96376; -0.17626; 1.24563; -1.22512; -0.72760; -0.10869; 0.76518; 0.14769];
%! res = henon (10);
%! 
%! assert (res(:,1), hen, 1e-5);

