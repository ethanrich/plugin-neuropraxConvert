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

## -*- texinfo -*-
## @deftypefn{Function File} {@var{output} =} poincare (@var{X})
## @deftypefnx{Function File} {@var{output} =} poincare (@var{X}, @var{m}, @var{paramName}, @var{paramValue}, @dots{})
## @deftypefnx{Function File} {@var{output} =} poincare (@dots{}, 'FromAbove', @dots{})
##
## Make a Poincare section for time continuous scalar data sets
## along one of the coordinates of the embedding vector.
##
## @strong{Input}
##
## @table @var
## @item X
## Must be realvector. If it is a row vector then the output will 
## be a matrix that consists of row vectors as well. 
## @end table
##
##
## @strong {Parameters}
##
## @table @var
## @item m
## The embedding dimension used. It is synonymous to 
## flag '-m' from TISEAN [default = 2].
## @item d
## Delay used for the embedding [default = 1].
## @item q
## Component for the crossing [default = value of parameter 'm' (last one)].
## @item a
## @end table
##
## @strong {Switch}
##
## @table @var
## @item FromAbove
## If this switch is set the crossing will occur from above, instead of
## from below. This is equivalent to setting flag '-C1' from TISEAN.
## @end table
##
## @strong{Output}
##
## The output consists of the as many components as the value of parameter
## @var{m} (columns or rows depending on input). The first @code{M-1} are
## the coordinates of the vector at the crossing and the last component
## is the time between the last two crossings.
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on poincare of TISEAN 3.0.1
## https://github.com/heggus/Tisean"

function output = poincare (X, varargin)

  # Initial input validation
  if (nargin < 1)
    print_usage;
  endif

  if ((isvector (X) == false) || (isreal(X) == false))
    error ('Octave:invalid-input-arg', "X must be a realvector");
  endif

  # Default values
  embdim    = 2;
  delay     = 1;
  comp      = embdim;
  where     = sum (X) / length (X);

  #### Parse the input
  p = inputParser ();
  p.FunctionName = "poincare";

  isPositiveIntScalar = @(x) isreal(x) && isscalar (x) && ...
                             (x > 0) && (x-round(x) == 0);
  isNumericScalar     = @(x) isreal(x) && isscalar (x);

  p.addParamValue ("m", embdim, isPositiveIntScalar);
  p.addParamValue ("d", delay, isPositiveIntScalar);
  p.addParamValue ("q", comp, isPositiveIntScalar);
  p.addParamValue ("a", where, isNumericScalar);
  p.addSwitch ("FromAbove");

  p.parse (varargin{:});

  # Assign inputs
  embdim    = p.Results.m;
  dimset    = !ismember ('m', p.UsingDefaults);
  delay     = p.Results.d;
  comp      = p.Results.q;
  compset   = !ismember ('q', p.UsingDefaults);
  where     = p.Results.a;
  whereset  = !ismember ('a', p.UsingDefaults);
  direction = p.Results.FromAbove;

  # If the component for the crossing is not set and the 
  # embedding dimension is set then assign then make the component
  # for the crossing the last one.
  if (dimset && !compset)
    comp=embdim;
  endif

  # Input validation from main()
  # Check if the component for the crossing is not larger
  # than the embedding dimension.
  if (comp > embdim)
        error ('Octave:invalid-input-arg', ...
                "Component for the crossing is larger than dimension");
  endif

  # Check whether the set value of where is bigger
  # or smaller of the largest or smallest element of X
  if (whereset && ((where < min (X)) || (where > max (X))))
    error ('Octave:invalid-input-arg', ...
           "You want to cut outside the data interval which is [%e, %e]", ...
            min, max);
  endif

  # Estimating the size of the output based on poincare()
  top         = length (X) - (embdim - comp) * delay - 1;
  bottom      = (comp-1) * delay + 1;
  if (direction == false) # from below
    output_size = sum ((X(bottom:top) < where) & (X((bottom:top)+1) >= where));
  else # from above
    output_size = sum ((X(bottom:top) > where) & (X((bottom:top)+1) <= where));
  endif

  # Correct X to always have more rows than columns
  trnspsd = false;
  if (rows (X) < columns (X))
    X = X.';
    trnspsd = true;
  endif

  output = __poincare__ (X, embdim, delay, comp, where, direction, ...
                                  output_size);

  if (trnspsd)
    output = output.';
  endif

endfunction

%!shared in
%! idx = (1:1500).';
%! in  = (5 + mod (idx, 165) ./15) .* sin (idx.* 2 * pi /32);

%!fail("poincare(ones(1,100), 'a',2)");

%!test
%% res was generated using TISEAN poincare
%! res = [-8.732896 31.99873;-10.86617 31.99921;-12.99946 31.99945;-15.13276 31.9996;-6.266347 32.00327;-8.399575 31.99862;-10.53284 31.99915;-12.66613 31.99942;-14.79943 31.99958;-5.933037 32.00351;-8.066255 31.9985;-10.19952 31.99909;-12.3328 31.99939;-14.4661 31.99956;-5.599729 32.00378;-7.732935 31.99835;-9.866194 31.99903;-11.99948 31.99936;-14.13278 31.99954;-5.266423 32.00409;-7.399617 31.99819;-9.53287 31.99895;-11.66615 31.99932;-13.79945 31.99952;-15.8539 32.00443;-7.066301 31.998;-9.199547 31.99887;-11.33282 31.99927;-13.46612 31.99949;-15.5982 32.00483;-6.732986 31.99777;-8.866225 31.99878;-10.9995 31.99923;-13.13279 31.99947;-15.26609 31.99961;-6.399672 32.00318;-8.532903 31.99867;-10.66617 31.99917;-12.79946 31.99944;-14.93276 31.99959;-6.066361 32.00341;-8.199583 31.99855;-10.33285 31.99912;-12.46614 31.9994;-14.59944 31.99957];
%! out = poincare (in, 'd', 8);
%! assert (out, res, -1e-6);

%!test
%! out1 = poincare (in, 'd', 8, 'a', 5, 'm', 4, 'q',2);
%! out2 = poincare (in.', 'd', 8, 'a', 5, 'm', 4, 'q',2);
%! assert (out1.', out2);

%!test
%% res is generated using TISEAN poincare
%! res = [-5.563829; -5.461439; -5.390335; -1.853666; -6.040217; -5.754689; -5.584079; -5.474914; -5.400042; -1.78616; -5.78973; -5.605601; -5.489201; -5.410223; -1.715693; -5.828184; -5.628599; -5.504373; -5.420839; -5.360583; -5.870574; -5.653412; -5.520517; -5.432019; -5.368852; -5.916176; -5.680265; -5.537728; -5.443809; -5.377509; -5.96597; -5.709419; -5.556116; -5.45626; -5.386582; -1.879881; -6.018371; -5.741184; -5.575807; -5.469431; -5.396102; -1.813507; -5.77533; -5.596867; -5.483384; -5.406102; -1.744247];
%! out = poincare (in, 'd', 8, 'a', 5, 'm', 4, 'q',2);
%! assert (out(:,3), res, -1e-6);
