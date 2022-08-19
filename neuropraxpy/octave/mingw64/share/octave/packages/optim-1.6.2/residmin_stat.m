## Copyright (C) 2011-2019 Olaf Till <i7tiol@t-online.de>
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
## @deftypefn {Function File} {@var{info} =} residmin_stat (@var{f}, @var{p}, @var{settings})
## Frontend for computation of statistics for a residual-based
## minimization.
##
## @var{settings} is a structure whose fields can be set by
## @code{optimset}. With @var{settings} the computation of certain
## statistics is requested by setting the fields
## @code{ret_<name_of_statistic>} to @code{true}. The respective
## statistics will be returned in a structure as fields with name
## @code{<name_of_statistic>}. Depending on the requested statistic and
## on the additional information provided in @var{settings}, @var{f} and
## @var{p} may be empty. Otherwise, @var{f} is the model function of an
## optimization (the interface of @var{f} is described e.g. in
## @code{nonlin_residmin}, please see there), and @var{p} is a real
## column vector with parameters resulting from the same optimization.
##
## Currently, the following statistics (or general information) can be
## requested (the @code{ret_} is prepended so that the option name is
## complete):
##
## @code{ret_dfdp}: Jacobian of model function with respect to
## parameters.
##
## @code{ret_covd}: Covariance matrix of data (typically guessed by
## applying a factor to the covariance matrix of the residuals).
##
## @code{ret_covp}: Covariance matrix of final parameters.
##
## @code{ret_corp}: Correlation matrix of final parameters.
##
## @c The following block will be cut out in the package info file.
## @c BEGIN_CUT_TEXINFO
##
## For further settings, type @code{optim_doc ("residmin_stat")}.
##
## For desription of structure-based parameter handling, type
## @code{optim_doc ("parameter structures")}.
##
## For backend information, type @code{optim_doc ("residual
## optimization")} and choose the backends type in the menu.
##
## @c END_CUT_TEXINFO
##
## @seealso{curvefit_stat}
## @end deftypefn

## PKG_ADD: [~] = __all_opts__ ("residmin_stat");

function ret = residmin_stat (varargin)

  if (nargin == 1)
    ret = __residmin_stat__ (varargin{1});
    return;
  endif

  if (nargin != 3)
    print_usage ();
  endif

  varargin{4} = struct ();

  ret = __residmin_stat__ (varargin{:});

endfunction

%!test
%! ## independents
%! indep = 1:5;
%! ## residual function:
%! f = @ (p) p(1) * exp (p(2) * indep) - [1, 2, 4, 7, 14];
%! ## parameters:
%! p = [.53203; .65307];
%!
%! settings = optimset ("objf_type", "wls",
%!                      "ret_dfdp", true, "ret_covd", true,
%!                      "ret_covp", true, "ret_corp", true);
%!
%! info = residmin_stat (f, p, settings);
%!
%! assert (info.corp, [1, -.98918; -.98918, 1], .0001);

%!test
%! ## independents
%! indep = 1:5;
%! ## residual function:
%! f = @ (p) p(1) * exp (p(2) * indep) - [1, 2, 4, 7, 14];
%! ## parameters:
%! p = single ([.53203; .65307]);
%!
%! settings = optimset ("objf_type", "wls",
%!                      "ret_dfdp", true, "ret_covd", true,
%!                      "ret_covp", true, "ret_corp", true);
%!
%! info = residmin_stat (f, p, settings);
%!
%! assert (info.corp, [1, -.98918; -.98918, 1], .0001);
%! assert (isa (info.dfdp, "single"));
%! assert (isa (info.covd, "single"));
%! assert (isa (info.covp, "single"));
%! assert (isa (info.corp, "single"));

%!test
%!shared x, misc, corp
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
%! corp = [1.000000, -0.396899, -0.402479, -0.019351, -0.167128;
%!         -0.396899, 1.000000, -0.462988, -0.053813, 0.214705;
%!         -0.402479, -0.462988, 1.000000, 0.127128, -0.187121;
%!         -0.019351, -0.053813, 0.127128, 1.000000, -0.035904;
%!         -0.167128, 0.214705, -0.187121, -0.035904, 1.000000];
%!
%! p = struct ("a", [.9925145; 2.005293; 3.999732],
%!             "b", 2.680371, "c", .4977683);
%!
%! pconf.a.TypicalX = .5 * ones (3, 1);
%! pconf.a. diffp = [.0001; .00001; .0001];
%! pconf.b.diff_onesided = true;
%!
%! settings = optimset ("param_config", pconf, "f_pstruct", true,
%!                      "objf_type", "wls",
%!                      "ret_dfdp", true, "ret_covd", true,
%!                      "ret_covp", true, "ret_corp", true);
%!
%! f = @ (p) ...
%!       subsasgn (x, struct ("type", "()", "subs", {{9, 3}}), p.c) ...
%!     * horzcat (p.a, p.a([3, 1, 2]), p.a([3, 2, 1])) ...
%!     - subsasgn (misc, struct ("type", "()", "subs", {{3, 2}}), p.b);
%!
%! info = residmin_stat (f, p, settings);
%!
%! assert (info.corp, corp, .0001);

%!test
%! p = [.9925145; 2.005293; 3.999732; 2.680371; .4977683];
%!
%! settings = optimset ("TypicalX", .5,
%!                      "diffp", [.0001; .00001; .0001; .00001; .0001],
%!                      "diff_onesided", true,
%!                      "objf_type", "wls",
%!                      "ret_dfdp", true, "ret_covd", true,
%!                      "ret_covp", true, "ret_corp", true);
%!
%! f = @ (p) ...
%!       subsasgn (x, struct ("type", "()", "subs", {{9, 3}}), p(5)) ...
%!     * horzcat (p([1, 2, 3]), p([3, 1, 2]), p([3, 2, 1])) ...
%!     - subsasgn (misc, struct ("type", "()", "subs", {{3, 2}}), p(4));
%!
%! info = residmin_stat (f, p, settings);
%!
%! assert (info.corp, corp, .0001);
