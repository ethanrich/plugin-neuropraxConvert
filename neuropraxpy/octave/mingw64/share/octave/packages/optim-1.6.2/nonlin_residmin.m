## Copyright (C) 2010-2019 Olaf Till <i7tiol@t-online.de>
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
## @deftypefn {Function File} {[@var{p}, @var{resid}, @var{cvg}, @var{outp}] =} nonlin_residmin (@var{f}, @var{pin})
## @deftypefnx {Function File} {[@var{p}, @var{resid}, @var{cvg}, @var{outp}] =} nonlin_residmin (@var{f}, @var{pin}, @var{settings})
## Frontend for nonlinear minimization of residuals returned by a model
## function.
##
## The functions supplied by the user have a minimal
## interface; any additionally needed constants (e.g. observed values)
## can be supplied by wrapping the user functions into anonymous
## functions.
##
## The following description applies to usage with vector-based
## parameter handling. Differences in usage for structure-based
## parameter handling will be explained separately.
##
## @var{f}: function returning the array of residuals. It gets a
## column vector of real parameters as argument. In gradient
## determination, this function may be called with an informational
## second argument (if the function accepts it), whose content depends
## on the function for gradient determination.
##
## @var{pin}: real column vector of initial parameters.
##
## @var{settings}: structure whose fields stand for optional settings
## referred to below. The fields can be set by @code{optimset()}.
##
## The returned values are the column vector of final parameters
## @var{p}, the final array of residuals @var{resid}, an integer
## @var{cvg} indicating if and how optimization succeeded or failed, and
## a structure @var{outp} with additional information, curently with the
## fields: @code{niter}, the number of iterations and
## @code{user_interaction}, information on user stops (see settings).
## The backend may define additional fields. If the backend supports it,
## @var{outp} has a field @code{lambda} with determined Lagrange
## multipliers of any constraints, seperated into subfields @code{lower}
## and @code{upper} for bounds, @code{eqlin} and @code{ineqlin} for
## linear equality and inequality constraints (except bounds),
## respectively, and @code{eqnonlin} and @code{ineqnonlin} for general
## equality and inequality constraints, respectively. @var{cvg} is
## greater than zero for success and less than or equal to zero for
## failure; its possible values depend on the used backend and currently
## can be @code{0} (maximum number of iterations exceeded), @code{2}
## (parameter change less than specified precision in two consecutive
## iterations), or @code{3} (improvement in objective function -- e.g.
## sum of squares -- less than specified), or @code{-1} (algorithm
## aborted by a user function).
##
## @c The following block will be cut out in the package info file.
## @c BEGIN_CUT_TEXINFO
##
## For settings, type @code{optim_doc ("nonlin_residmin")}.
##
## For desription of structure-based parameter handling, type
## @code{optim_doc ("parameter structures")}.
##
## For description of individual backends (currently only one), type
## @code{optim_doc ("residual optimization")} and choose the backend in
## the menu.
##
## @c END_CUT_TEXINFO
##
## @seealso{nonlin_curvefit}
## @end deftypefn

## PKG_ADD: [~] = __all_opts__ ("nonlin_residmin");

function [p, resid, cvg, outp] = nonlin_residmin (varargin)

  if (nargin == 1)
    p = __nonlin_residmin__ (varargin{1});
    return;
  endif

  if (nargin < 2 || nargin > 3)
    print_usage ();
  endif

  if (nargin == 2)
    varargin{3} = struct ();
  endif

  varargin{4} = struct ();

  [p, resid, cvg, outp] = __nonlin_residmin__ (varargin{:});

endfunction

%!demo
%!  ## Example for linear inequality constraints
%!  ## (see also the same example in 'demo nonlin_curvefit')
%!
%!  ## independents
%!  indep = 1:5;
%!  ## residual function:
%!  f = @ (p) p(1) * exp (p(2) * indep) - [1, 2, 4, 7, 14];
%!  ## initial values:
%!  init = [.25; .25];
%!  ## linear constraints, A.' * parametervector + B >= 0
%!  A = [1; -1]; B = 0; # p(1) >= p(2);
%!  settings = optimset ("inequc", {A, B});
%!
%!  ## start optimization
%!  [p, residuals, cvg, outp] = nonlin_residmin (f, init, settings)

%!test
%! ## independents
%! indep = 1:5;
%! ## residual function:
%! f = @ (p) p(1) * exp (p(2) * indep) - [1, 2, 4, 7, 14];
%! ## initial values:
%! init = [.25; .25];
%! ## linear constraints, A.' * parametervector + B >= 0
%! A = [1; -1]; B = 0; # p(1) >= p(2);
%! settings = optimset ("inequc", {A, B});
%!
%! assert (nonlin_residmin (f, init, settings), [.6203; .6203], .0001);

%!test
%! ## independents
%! indep = 1:5;
%! ## residual function:
%! f = @ (p) p(1) * exp (p(2) * indep) - [1, 2, 4, 7, 14];
%! ## initial values:
%! init = single ([.25; .25]);
%! ## linear constraints, A.' * parametervector + B >= 0
%! A = [1; -1]; B = 0; # p(1) >= p(2);
%! settings = optimset ("inequc", {A, B},
%!                      "complex_step_derivative_f", true);
%!
%! result = nonlin_residmin (f, init, settings);
%! assert (result, [.6203; .6203], .0001);
%! assert (isa (result, "single"));

%!test
%!shared x, misc
%! x = [.871, .643, .550;
%!      .228, .669, .854;
%!      .528, .229, .170;
%!      .110, .354, .337;
%!      .911, .056, .493;
%!      .476, .154, .918;
%!      .655, .421, .077;
%!      .649, .140, .199;
%!      .995, .045,   NA;
%!      .130, .016, .195;
%!      .823, .690, .690;
%!      .768, .992, .389;
%!      .203, .740, .120;
%!      .302, .519, .221;
%!      .991, .450, .249;
%!      .224, .030, .502;
%!      .428, .127, .772;
%!      .552, .494, .110;
%!      .461, .824, .714;
%!      .799, .494, .295];
%!
%! misc = [4.36, 5.21, 5.35; 
%!         4.99, 3.30, 3.10; 
%!         1.67,   NA, 2.75;
%!         2.17, 1.48, 1.49;
%!         2.98, 4.69, 4.23;
%!         4.46, 3.87, 3.15;
%!         1.79, 3.18, 3.57;
%!         1.71, 3.13, 3.07;
%!         3.07, 5.01, 4.58;
%!         0.94, 0.93, 0.74;
%!         4.97, 5.37, 5.35;
%!         4.32, 4.85, 5.46;
%!         2.17, 1.78, 2.43;
%!         2.22, 2.18, 2.44;
%!         2.88, 4.90, 5.11;
%!         2.29, 1.94, 1.46;
%!         3.76, 3.39, 2.71;
%!         1.99, 2.93, 3.31;
%!         4.95, 4.08, 4.19;
%!         2.96, 4.26, 4.48];
%!
%! pin = struct ("a", .1 * ones (3, 1), "b", .1, "c", .1, "d", 1);
%!
%! pconf.a.lbound = [-Inf, 0, NA];
%! pconf.b.diff_onesided = true;
%! pconf.b.lbound = 0;
%! pconf.c.ubound = .3;
%! pconf.d.fixed = true;
%!
%! settings = optimset ("param_config", pconf, "f_pstruct", true);
%!
%! f = @ (p) ...
%!       subsasgn (x, struct ("type", "()", "subs", {{9, 3}}), p.c) ...
%!     * horzcat (p.a, p.a([3, 1, 2]), p.a([3, 2, 1])) ...
%!     - p.d * subsasgn (misc, struct ("type", "()", "subs", {{3, 2}}), p.b);
%!
%! [p, ~, ~, outp] = nonlin_residmin (f, pin, settings);
%!
%! assert (p.a, [1.0590; 1.9266; 4.0456], .0001);
%! assert (p.b, 2.7061, .0001);
%! assert (p.c, .3, .000001);
%! assert (p.d, 1);
%! assert (isempty (outp.lambda.ineqlin));
%! assert (isempty (outp.lambda.eqlin));
%! assert (isempty (outp.lambda.ineqnonlin));
%! assert (isempty (outp.lambda.eqnonlin));
%! assert (! any (outp.lambda.lower.a));
%! assert (! outp.lambda.lower.b);
%! assert (! outp.lambda.lower.c);
%! assert (! any (outp.lambda.upper.a));
%! assert (! outp.lambda.upper.b);
%! assert (outp.lambda.upper.c > 0);

%!test
%! pin = zeros (6, 1);
%! pin(6) = 1;
%!
%! settings = optimset ("lbound", [-Inf; 0; NA; 0; -Inf; -Inf],
%!                      "ubound", [Inf; Inf; Inf; Inf; .3; Inf],
%!                      "diff_onesided", true,
%!                      "fixed", [false; false; false; false; false; true]);
%!
%! f = @ (p) ...
%!       subsasgn (x, struct ("type", "()", "subs", {{9, 3}}), p(5)) ...
%!     * horzcat (p([1, 2, 3]), p([3, 1, 2]), p([3, 2, 1])) ...
%!     - p(6) * subsasgn (misc, struct ("type", "()", "subs", {{3, 2}}), p(4));
%!
%! p = nonlin_residmin (f, pin, settings);
%!
%! assert (p, [1.0590; 1.9266; 4.0456; 2.7061; .3; 1], .0001);
