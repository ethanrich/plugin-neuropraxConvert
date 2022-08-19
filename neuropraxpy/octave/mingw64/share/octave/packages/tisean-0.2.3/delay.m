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
## @deftypefn{Function File} {@var{output} =} delay (@var{S})
## @deftypefnx{Function File} {@var{output} =} delay (@var{S}, @var{paramName}, @var{paramValue}, @dots{})
##
## Produce delay vectors
##
## @strong{Input}
##
## @table @var
## @item S
## This function always assumes that each time series is along the longer
## dimension of matrix @var{S}. It also assumes that every dimension (counting
## along the shorter dimension) of @var{S} is considered a component of the time
## series. So
## @example
##
## @var{S} = [[1:1000];[5:1004]]
##
## @end example
## would be considered a 2 component, 1000 element time series. Thus a typical
## call of 'henon' requires to choose one column of it. For instance:
## @example
##
## res = henon (5000);
## delay (res(:,1));
##
## @end example
## @end table
##
## @strong{Parameters}
##
## @table @var
## @item d
## Delay of the embedding vector. Can be either a vector of delays or a single
## value. Replaces flags '-d' and '-D' from TISEAN package. Example
## @example
##
## delay ([1:10], 'd', [2,4], 'm', 3)
##
## @end example
## This input will produce a delay vetor of the form
## @example
##
## (@var{x}(i),@var{x}(i-2),@var{x}(i-2-4))
##
## @end example
## It is important to remember to keep (lenght of 'D') == (value of flag '-M' from
## TISEAN == number of components of (@var{S})) whenever parameter 'D' is a vector.
## @item f
## The format of the embedding vector. Replaces flag '-F' from TISEAN. Example
## (assuming @var{a} and @var{b} are column vectors of the same length)
## @example
##
## delay ([@var{a},@var{b}], 'f', [3,2])
##
## @end example
## This input will produce a delay vector in the form
## @example
##
## (@var{a}(i),@var{a}(i-1),@var{a}(i-2),@var{b}(i),@var{b}(i-1))
##
## @end example
## @item m
## The embedding dimension. Replaces flag '-m' from TISEAN. Must be scalar
## integer. Also it needs to be integer multiple of number of components of
## (@var{S}) or else 'F' needs to be set. The following two examples are
## equivalent calls (@var{a}, @var{b}, @var{c} are column vectors of the same size)
## @example
##
## delay ([@var{a},@var{b},@var{c}], 'm', 9)
## delay ([@var{a},@var{b},@var{c}], 'f', [3,3,3])
##
## @end example
## @end table
##
## @strong{Output}
##
## Produces a matrix that contains delay vectors.
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on delay of TISEAN 3.0.1
## https://github.com/heggus/Tisean"

function output = delay(S,varargin)

  if (nargin < 1)
    print_usage;
  endif

  if ((!ismatrix (S)) || (!isreal(S)))
    error ('Octave:invalid-input-arg', "S is not a realmatrix");
  endif

  # Define default values for delay variables
  indim       = 1;

  embdim      = 2;
  dimset      = 0; # is not the default?

  d           = 1;

  formatdelay = [indim,indim];
  formatset   = 0; # is not the default?

  delaylist   = d;
  mdelayset   = 0; # is not the default?

  #### Parse the input
  p = inputParser ();
  p.FunctionName = "delay";

  isPositiveIntScalar = @(x) isreal(x) && isscalar (x) && ...
                             (x > 0) && (x-round(x) == 0);
  isPositiveIntVector = @(x) isreal(x) && isvector (x) && ...
                             all (x > 0) && all (x-round(x) == 0);

  p.addParamValue ("d", d, isPositiveIntVector);
  p.addParamValue ("m", embdim, isPositiveIntScalar);
  p.addParamValue ("f", formatdelay, isPositiveIntVector);

  p.parse (varargin{:});

  # Assign inputs
  embdim         = p.Results.m;
  embset         = !ismember ('m',p.UsingDefaults);

  # Placed old '-d' and '-D' flags into parameter 'd'
  if (!ismember ('d',p.UsingDefaults))
      d = p.Results.d;
    if (length (d) > 1)
      mdelayset = 1;
      delaylist = p.Results.d;
    endif
  endif

  formatdelay = p.Results.f;
  formatset   = !ismember('f', p.UsingDefaults);

  # Correct S to always have more rows than columns
  trnspsd = false;
  if (rows (S) < columns (S))
    S = S.';
    trnspsd = true;
  endif

  # Assume all input is time series (ommit '-M' from original)
  if (indim != columns (S))
    dimset = 1;
    indim  = columns (S);
  endif

  # Input checking from original main()
  # Check that if delays were not given the embeding dimension is a multiple of
  # the input data dimension.
  if (!formatset)
    if (mod (embdim, indim))
      error ('Octave:invalid-input-arg',...
             ["Inconsistent parameter 'm' and number of components of S.",...
              " Please set parameter 'f'"]);
    endif

    formatdelay = ones(1,indim) * floor (embdim / indim);

  endif

  # Check that if delays were not given in a vector if so then
  # create a default vector out of the given scalar delay.
  if (!mdelayset)
    delaylist = ones(1,sum (formatdelay)) * d;
  endif

  # Input checking from original create_delay_list()
  # Check if the vector of delays given has the proper length
  # that is that it is equal to the difference between the embedding
  # dimension and the number of components.
  if (mdelayset && (length (delaylist) != (embdim - indim)))
    error ('Octave:invalid-input-arg', "Wrong number of delays");
  endif

  # Input checking from original create_format_list()
  if (formatset)
    # Check if the list of format delays is as long as the number
    # components.
    if (dimset && (length (formatdelay) != indim))
      error ('Octave:invalid-input-arg',...
             "Parameter 'f' length is not equal to the number of components");
    endif
    # Check if the sum of the formats is equal to the embedding dimensions
    # if it is set.
    if (embset && (sum (formatdelay) != embdim))
      error ('Octave:invalid-input-arg',...
             "The dimensions given in parameter 'm' and 'f' are not equal!");
    endif

    # If the number of input components is not set then set it.
    if (!dimset)
      indim = length (formatdelay);
    endif
    # If the embedding dimension is not set then set it.
    if (!embset)
      embdim = sum (formatdelay);
    endif
  endif

  output = __delay__ (S, length(S), indim, formatdelay, delaylist);

  if (trnspsd)
    output = output.';
  endif

endfunction

%!test delay(1:10,'m',3,'d',6);

%!test
%! a  = 1:5;
%! d1 = 2:5;
%! d2 = 1:4;
%! d  = delay (a);
%! assert (d, [d1;d2], 1e-6);

%!test
%! a  = 1:5;
%! d1 = 3:5;
%! d2 = 1:3;
%! d  = delay (a,'d',2);
%! assert (d, [d1;d2], 1e-6);

%!test
%! a  = 1:10;
%! dg = [3 1 3 1;4 2 4 2;5 3 5 3;6 4 6 4;7 5 7 5;8 6 8 6;9 7 9 7;10 8 10 8];
%! d  = delay ([a;a].','d',2,'m',4);
%! assert (d, dg, 1e-6);

%!test
%! a  = 1:10;
%! dg = [3 2 3 1;4 3 4 2;5 4 5 3;6 5 6 4;7 6 7 5;8 7 8 6;9 8 9 7;10 9 10 8];
%! d  = delay ([a;a].','d',[1 2],'m',4);
%! assert (d, dg, 1e-6);

%!test
%! a  = 1:10;
%! dg = [4 3 1;5 4 2;6 5 3;7 6 4;8 7 5;9 8 6;10 9 7];
%! d  = delay (a.','d',[1 2],'m',3);
%! assert (d, dg, 1e-6);

%!test
%! a  = 1:10;
%! dg = [5 5 3 1; 6 6 4 2; 7 7 5 3; 8 8 6 4; 9 9 7 5; 10 10 8 6];
%! d  = delay ([a;a].','d',2,'f',[1,3],'m',4);
%! assert (d, dg, 1e-6);
