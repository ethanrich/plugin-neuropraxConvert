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
## @deftypefn{Function File} {@var{output} =} c2d (@var{c1_out})
## @deftypefnx{Function File} {@var{output} =} c2d (@var{c1_out}, @var{iav})
##
## This program calculates the local slopes by fitting straight lines onto
## c1 correlation sum data (the 'c1' field of the c1 output).
##
## @strong{Inputs}
##
## @table @var
## @item c1_out
## The output of function c1.
## @item iav
## Set what range the average should be calculated on 
## (-@var{iav}, @dots{}, +@var{iav}) [default = 1].
## @end table
##
## @strong{Output}
##
## The output is a struct array of the same length as the input.
## It contains the following fiels:
##
## @table @var
## @item dim
## The dimension for each matrix @var{d}.
## @item d
## Contains the local slopes of the logarithm of the correlation sum.
## @end table
##
## @seealso{c1, d2}
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on c2t of TISEAN 3.0.1 
## https://github.com/heggus/Tisean"

function output = c2d (c1_out, iav)

  if (nargin != 1 && nargin != 2)
    print_usage;
  endif


  # Assign default value if not provided
  if (nargin == 1)
    iav = 1;
  endif

  # Input validation
  if ((!isfield (c1_out, "dim")) || (!isfield (c1_out, "c1")))
    error ('Octave:invalid-input-arg', "c1_out must be the output of c1");
  endif

  if (iav < 1)
    error ("Octave:invalid-input-arg", "iav is too small");
  endif

  isPositiveInteger = @(x) isreal(x) && isscalar (x) && (x > 0) ...
                           && (x-round(x) == 0);
  if (!isPositiveInteger(iav))
    error ("Octave:invalid-input-arg", "iav must be a positive integer");
  endif

  # Calculate output
  d_out = cell (length (c1_out),1);
  # Calculate output for each struct in the input struct array
  for i = 1:size(c1_out,1)
    tmp     = c1_out(i);

    # Limit to only the first positive correlation sums
    # (do not calculate output for any past first negative sum)
    idx_lt0 = min (find (tmp.c1(:,2) <= 0));
    if (!isempty (idx_lt0))
      tmp.c1  = tmp.c1(1:idx_lt0-1,:);
    endif

    # Create log of input
    emat = log (tmp.c1(:,1));
    cmat = log (tmp.c1(:,2));

    # Calculate slopes (output)
    idx  = iav+1:length(emat)-iav;
    sidx = idx.' + (-iav:iav); # this is instead of loops in original TISEAN
    sx   = sum (emat(sidx), 2);
    sa   = sum ((emat(sidx)-sx/(2*iav+1)).^2, 2);
    a    = sum (cmat(sidx).*(emat(sidx)-sx/(2*iav+1)), 2);
    a    = a ./ sa;

    d_out{i} = [(exp (0.5*(emat(idx+iav) + emat(idx-iav)))), a];
  endfor

  output = struct ("dim", {c1_out.dim}.', "d", d_out);
endfunction

%!test
%! c2d_res = [0.0802038833 1.30005336;0.129080057 1.26480043;0.183470041 1.31809092;0.25040397 1.31098711;0.315470815 1.24258268;0.393951952 1.35819948;0.498613715 1.54006541;0.63493669 1.72518802;0.775567234 1.81067181;0.925195694 1.87816846;1.08199906 2.0603919;1.2544421 2.44373727;1.42295694 3.00687265;1.60953939 3.80531406;1.79531026 4.09372187;0.127373591 1.40561604;0.193788737 1.33527219;0.270300597 1.433846;0.353568524 1.41282487;0.441288173 1.41831315;0.533717155 1.58177018;0.651995957 1.82422757;0.808923244 2.11301899;0.942690194 2.21815157;1.07797575 2.36958146;1.22073698 2.72570252;1.38917232 3.26388025;1.53312647 3.84382915;1.69071579 4.38460922;1.84578943 4.4093585;0.140068099 1.46819866;0.21520929 1.39887428;0.301112086 1.4297173;0.374655783 1.3967756;0.474572212 1.42229402;0.591202319 1.59270585;0.71742928 1.85023475;0.87131691 2.03683972;1.01490164 2.27680421;1.18083644 2.5573194;1.30776179 2.91171169;1.4800781 3.71028256;1.6081382 4.36042261;1.76051617 5.08404732;1.90384173 4.97274971];
%% reset random generator
%%! clear __c1__
%! c1_r = c1 (henon(1000), 'mindim', 8, 'd', 2, 't', 50, 'n',500, 'i', 0.5);
%! res  = c2d (c1_r,2);
%% rows 1,2,16,17 and are excluded because TISEAN 'c1' uses floats
%% and the ported function 'c1' uses doubles
%! good_idx = [3:15,19:45];
%! assert (cell2mat({res.d}.')(good_idx,:), c2d_res(good_idx,:), -2.5e-5);
%% bad_idx are used as the idx of those that were further apart than the rest
%! bad_idx = setdiff (1:length(c2d_res),good_idx);
%! assert (cell2mat({res.d}.')(bad_idx,:), c2d_res(bad_idx,:), 5e-3);

%% testing input validation
%!error <small> c2d (struct ("dim", 1,"c1", 2),0);
%!error <integer> c2d (struct ("dim", 1,"c1", 2),1.5);
