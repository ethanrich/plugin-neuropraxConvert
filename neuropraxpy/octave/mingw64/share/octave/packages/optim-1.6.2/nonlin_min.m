## Copyright (C) 2012-2019 Olaf Till <i7tiol@t-online.de>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{p}, @var{objf}, @var{cvg}, @var{outp}] =} nonlin_min (@var{f}, @var{pin})
## @deftypefnx {Function File} {[@var{p}, @var{objf}, @var{cvg}, @var{outp}] =} nonlin_min (@var{f}, @var{pin}, @var{settings})
## Frontend for nonlinear minimization of a scalar objective function.
##
## The functions supplied by the user have a minimal interface; any
## additionally needed constants can be supplied by wrapping the user
## functions into anonymous functions.
##
## The following description applies to usage with vector-based
## parameter handling. Differences in usage for structure-based
## parameter handling will be explained separately.
##
## @var{f}: objective function. It gets a column vector of real
## parameters as argument. In gradient determination, this function
## may be called with an informational second argument (if the
## function accepts it), whose content depends on the function for
## gradient determination.
##
## @var{pin}: real column vector of initial parameters.
##
## @var{settings}: structure whose fields stand for optional settings
## referred to below. The fields can be set by @code{optimset()}.
##
## The returned values are the column vector of final parameters
## @var{p}, the final value of the objective function @var{objf}, an
## integer @var{cvg} indicating if and how optimization succeeded or
## failed, and a structure @var{outp} with additional information,
## curently with possible fields: @code{niter}, the number of
## iterations, @code{nobjf}, the number of objective function calls
## (indirect calls by gradient function not counted), @code{lambda}, the
## lambda of constraints at the result, and @code{user_interaction},
## information on user stops (see settings). The backend may define
## additional fields. @var{cvg} is greater than zero for success and
## less than or equal to zero for failure; its possible values depend on
## the used backend and currently can be @code{0} (maximum number of
## iterations exceeded), @code{1} (success without further specification
## of criteria), @code{2} (parameter change less than specified
## precision in two consecutive iterations), @code{3} (improvement in
## objective function less than specified), @code{-1} (algorithm aborted
## by a user function), or @code{-4} (algorithm got stuck).
##
## @c The following block will be cut out in the package info file.
## @c BEGIN_CUT_TEXINFO
##
## For settings, type @code{optim_doc ("nonlin_min")}.
##
## For desription of structure-based parameter handling, type
## @code{optim_doc ("parameter structures")}.
##
## For description of individual backends, type
## @code{optim_doc ("scalar optimization")} and choose the backend in
## the menu.
##
## @c END_CUT_TEXINFO
##
## @end deftypefn

## PKG_ADD: [~] = __all_opts__ ("nonlin_min");

function [p, objf, cvg, outp] = nonlin_min (obj_f, pin, settings)

  ## some scalar defaults; some defaults are backend specific, so
  ## lacking elements in respective constructed vectors will be set to
  ## NA here in the frontend
  stol_default = .0001;
  cstep_default = 1e-20;

  defaults = optimset ("param_config", [],
		       "param_order", [],
		       "param_dims", [],
		       "f_inequc_pstruct", false,
		       "f_equc_pstruct", false,
		       "objf_pstruct", false,
		       "df_inequc_pstruct", false,
		       "df_equc_pstruct", false,
		       "grad_objf_pstruct", false,
		       "hessian_objf_pstruct", false,
		       "lbound", [],
		       "ubound", [],
		       "objf_grad", [],
		       "objf_hessian", [],
                       "inverse_hessian", false,
		       "cpiv", @ cpiv_bard,
		       "max_fract_change", [],
                       ## vector, TolX is a scalar
		       "fract_prec", [],
		       "diffp", [],
		       "diff_onesided", [],
                       "FinDiffRelStep", [],
                       "FinDiffType", [],
                       "TypicalX", [],
		       "complex_step_derivative_objf", false,
		       "complex_step_derivative_inequc", false,
		       "complex_step_derivative_equc", false,
		       "cstep", cstep_default,
		       "fixed", [],
		       "inequc", [],
		       "equc", [],
                       "f_inequc_idx", false,
                       "df_inequc_idx", false,
                       "f_equc_idx", false,
                       "df_equc_idx", false,
		       "TolFun", stol_default,
                       "TolX", [],
		       "MaxIter", [],
		       "Display", "off",
		       "Algorithm", "lm_feasible",
                       "niter_check_tolfun", [],
                       ## Matlabs UseParallel works differently
                       "parallel_local", false,
                       "parallel_net", [],
                       "user_interaction", {},
		       "T_init", [],
		       "T_min", [],
		       "mu_T", [],
		       "iters_fixed_T", [],
		       "iters_adjust_step", [],
		       "max_rand_step", [],
		       "stoch_regain_constr", false,
                       "trace_steps", false,
                       "siman_log", false,
		       "debug", false,
                       "FunValCheck", "off",
                       "save_state", "",
                       "recover_state", "",
                       "octave_sqp_tolerance", []);

  if (nargin == 1 && ischar (obj_f) && strcmp (obj_f, "defaults"))
    p = defaults;
    return;
  endif

  if (nargin < 2 || nargin > 3)
    print_usage ();
  endif

  if (nargin == 2)
    settings = struct ();
  endif

  ## apply 'static' defaults; affected by optimset bug #54952
  o = optimset (defaults, settings);

  if (ischar (obj_f))
    obj_f = str2func (obj_f);
  endif
  obj_f = __maybe_limit_arg_count__ (obj_f, 1, 2);
  f.objf = obj_f;

  if (ischar (o.cpiv))
    o.cpiv = str2func (o.cpiv);
  endif
  f.cpiv = o.cpiv;

  if (! (o.p_struct = isstruct (pin)))
    if (! isvector (pin) || columns (pin) > 1)
      error ("initial parameters must be either a structure or a column vector");
    endif
  endif

  #### collect remaining settings
  o.parallel_local = hook.parallel_local = ...
      __optimget_parallel_local__ (settings, false);
  o.parallel_net = hook.parallel_net = ...
      __optimget_parallel_net__ (settings, []);

  #### processing of settings and consistency checks

  ## map backend
  backend = map_matlab_algorithm_names (o.Algorithm);
  [backend, path_bounds] = map_backend (backend);

  ## apply defaults which depend on other settings
  o.df_pstruct = optimget (settings, "grad_objf_pstruct", o.objf_pstruct);
  o.hessian_pstruct = optimget (settings, "hessian_objf_pstruct",
                                o.objf_pstruct);
  o.df_inequc_pstruct = optimget (settings, "df_inequc_pstruct",
				o.f_inequc_pstruct);
  o.df_equc_pstruct = optimget (settings, "df_equc_pstruct",
			      o.f_equc_pstruct);

  o.dfdp = o.objf_grad;
  if (ischar (o.dfdp))
    o.dfdp = str2func (o.dfdp);
  endif
  f.dfdp = o.dfdp;

  if (o.complex_step_derivative_objf && ! isempty (f.dfdp))
    error ("both 'complex_step_derivative_objf' and 'objf_grad' are set");
  endif

  if (isempty (f.dfdp))
    if (o.complex_step_derivative_objf)
      f.dfdp = @ jacobs;
    else
      f.dfdp = @ __dfdp__;
    endif
    dfdp_specified = false;
  else
    f.dfdp = __maybe_limit_arg_count__ (f.dfdp, 1, 2);
    dfdp_specified = true;
  endif

  f.hessian = o.objf_hessian;

  if (isempty (o.FinDiffType))
    FinDiffType_onesided = [];
  else
    if (strcmpi (o.FinDiffType, "forward"))
      FinDiffType_onesided = true;
    elseif (strcmpi (o.FinDiffType, "central"))
      FinDiffType_onesided = false;
    else
      error ("invalid value of 'FinDiffType'");
    endif
  endif

  if (! iscell (o.user_interaction))
    o.user_interaction = {o.user_interaction};
  endif

  any_vector_conf = ! (isempty (o.lbound) && isempty (o.ubound) &&
		       isempty (o.max_fract_change) &&
		       isempty (o.fract_prec) && isempty (o.diffp) &&
                       isempty (o.TypicalX) &&
                       isempty (o.FinDiffRelStep) &&
		       isempty (o.diff_onesided) && isempty (o.fixed) &&
		       isempty (o.max_rand_step));

  ## process constraints
  [o, f] = __process_constraints__ (o, f);

  ## correct further "_pstruct" settings if functions are not supplied
  if (! dfdp_specified)
    o.df_pstruct = false;
  endif
  if (isempty (f.hessian))
    o.hessian_pstruct = false;
  endif

  ## check or provide parameter order and parameter dimension
  ## information

  need_param_order = ...
  o.p_struct || ! isempty (o.param_config) || o.f_inequc_pstruct ...
  || o.f_equc_pstruct || o.objf_pstruct || o.df_pstruct ...
  || o.hessian_pstruct || o.df_inequc_pstruct || o.df_equc_pstruct ...
  || o.imc_struct || o.emc_struct;

  param_order_unclear = ...
  any_vector_conf ...
  || ! ...
     (o.objf_pstruct ...
      && (o.f_inequc_pstruct || isempty (f.f_genicstr)) ...
      && (o.f_equc_pstruct || isempty (f.f_genecstr)) ...
      && (o.df_pstruct || ! dfdp_specified) ...
      && (o.hessian_pstruct || isempty (f.hessian)) ...
      && (o.df_inequc_pstruct || ! o.user_df_genicstr) ...
      && (o.df_equc_pstruct || ! o.user_df_genecstr) ...
      && (o.imc_struct || isempty (f.imc)) ...
      && (o.emc_struct || isempty (f.emc)));

  [o, f, pin] = __get_param_info__ (o, f, pin,
                                    need_param_order,
                                    param_order_unclear);

  ## dimensions of linear constraints, needs o.np from
  ## __get_param_info ()
  f = __linear_constraint_dimensions__ (f, o);

  ## necessary for checks during mapping of equivalent options
  diff_onesided_specified = ! isempty (o.diff_onesided);

  ## some useful vectors
  predef_vectors.zero = zeros (o.np, 1, o.parclass);
  predef_vectors.NA = NA (o.np, 1, o.parclass);
  predef_vectors.Inf = Inf (o.np, 1, o.parclass);
  predef_vectors.negInf = - predef_vectors.Inf;
  predef_vectors.false = false (o.np, 1);
  predef_vectors.true = true (o.np, 1);
  predef_vectors.sizevec = [o.np, 1];

  ## collect parameter-related configuration

  ## list of parameter related options, 1st column option name, 2nd
  ## column field name of default vector, 3rd column <expand scalar?>)
  prel_opts = { ...
                "lbound", "negInf", false;
                "ubound", "Inf", false;
                "max_fract_change", "NA", false;
                "fract_prec", "NA", false;
                "diffp", "NA", true;
                "TypicalX", "NA", true;
                "FinDiffRelStep", "NA", true;
                "diff_onesided", "false", true;
                "fixed", "false", false;
                "max_rand_step", "NA", false;
              };

  if (! isempty (o.param_config))
    ## use supplied configuration structure

    ## parameter-related configuration is either allowed by a structure
    ## or by vectors
    if (any_vector_conf)
      error ("if param_config is given, its potential items must not \
	  be configured in another way");
    endif

    ## supplement parameter names lacking in param_config
    nidx = ! isfield (o.param_config, o.param_order);
    o.param_config = cell2fields ({struct()}(ones (1, sum (nidx))),
			 o.param_order(nidx), 2, o.param_config);

    o.param_config = structcat (1, fields2cell (o.param_config, o.param_order){:});

    o = __apply_param_config_structure__ (o, prel_opts, predef_vectors);

  else
    ## use supplied configuration vectors

    o = __apply_param_config_vectors__ (o, prel_opts, predef_vectors);

  endif

  ## guaranty all (lbound <= ubound)
  if (any (o.lbound > o.ubound))
    error ("some lower bounds larger than upper bounds");
  endif

  ## pass bounds only if the backend respects bounds even during the
  ## course of optimization
  if (path_bounds)
    o.jac_lbound = o.lbound;
    o.jac_ubound = o.ubound;
  else
    o.jac_lbound = predef_vectors.negInf;
    o.jac_ubound = predef_vectors.Inf;
  endif

  ## check TypicalX
  if (! all (o.TypicalX))
    error ("TypicalX must not be zero.");
  endif

  ## map FinDiffRelStep and FinDiffType, if necessary
  if (! isempty (FinDiffType_onesided))
    if (diff_onesided_specified &&
        any (o.diff_onesided != FinDiffType_onesided))
      warning ("option 'FinDiffType' overrides option 'diff_onesided'");
    endif
    o.diff_onesided(:) = FinDiffType_onesided;
  endif
  if (! (isempty (o.FinDiffRelStep) || all (isna (o.FinDiffRelStep))))
    if (! all (isna (o.diffp)))
      warning ("option 'FinDiffRelStep' overrides option 'diffp'");
    endif
    o.diffp(o.diff_onesided) = o.FinDiffRelStep(o.diff_onesided);
    o.diffp(! o.diff_onesided) = o.FinDiffRelStep(! o.diff_onesided) / 2;
  endif


  #### consider whether functions are based on parameter structures or
  #### parameter vectors; wrappers for call to default function for
  #### jacobians

  flist = { ...
            "objf";
            "dfdp";
            "hessian";
            "f_genicstr";
            "df_genicstr";
            "f_genecstr";
            "df_genecstr";
            "imc";
            "emc";
          };

  f = __maybe_wrap_struct_based_callbacks__ (o, f, flist);

  ## note this stage
  f.possibly_pstruct_f_genicstr = f.f_genicstr;
  f.possibly_pstruct_f_genecstr = f.f_genecstr;

  ## bind objective function argument to standard gradient function;
  ## must not be done until objective function is adapted, if
  ## necessary, to structure-based parameters
  if (! dfdp_specified)
    f.dfdp = @ (p, hook) f.dfdp (p, f.objf, hook);
  endif

  #### some further values and checks

  if (any (o.fixed & (pin < o.lbound | pin > o.ubound)))
    warning ("some fixed parameters outside bounds");
  endif

  if (any (o.diffp <= 0))
    error ("some elements of 'diffp' non-positive");
  endif

  if (o.cstep <= 0)
    error ("'cstep' non-positive");
  endif

  if ((hook.TolFun = optimget (settings, "TolFun", stol_default)) < 0)
    error ("'TolFun' negative");
  endif

  if (any (o.fract_prec < 0))
    error ("some elements of 'fract_prec' negative");
  endif

  if (any (o.max_fract_change < 0))
    error ("some elements of 'max_fract_change' negative");
  endif


  #### handle fixing of parameters
  o.jac_fixed = o.fixed;
  if (all (o.fixed))
    error ("no free parameters");
  endif

  o.nonfixed = ! o.fixed;
  if (any (o.fixed))

    funs = { ...
             "objf";
             "dfdp";
             "hessian";
             "f_genicstr";
             "df_genicstr";
             "f_genecstr";
             "df_genecstr"};

    opts = { ...
             "lbound";
             "ubound";
             "max_fract_change";
             "fract_prec";
             "max_rand_step";
             "fixed"};

    [o, f, backend] = __handle_fixing__ ...
                        (o, f, pin, funs, opts, backend, true);

  endif

  #### supplement constants to jacobian functions

  fnames = {"dfdp", "df_genicstr", "df_genecstr"};
  pstruct = [o.df_pstruct, o.df_inequc_pstruct, o.df_equc_pstruct];
  ## 1st column fieldname of value passed to __jacobian_constants__,
  ## 2nd column fieldname of value passed to jacobian functions
  jac_scalar_parconf_names = ...
  { ...
    "diffp", "diffp";
    "TypicalX", "TypicalX";
    "diff_onesided", "diff_onesided";
    "jac_lbound", "lbound";
    "jac_ubound", "ubound";
  };
  f = __jacobian_constants__ (o, f, fnames, pstruct,
                              jac_scalar_parconf_names, true);


  #### prepare interface hook

  ## interfaces to constraints
  
  [o, f, hook] = __constraints_interface__ (o, f, pin, hook);

  ## passed values of constraints for initial parameters
  hook.pin_cstr = o.pin_cstr;

  ## passed function for gradient of objective function
  hook.dfdp = f.dfdp;

  ## passed function for hessian of objective function
  hook.hessian = f.hessian;

  ## passed function for complementary pivoting
  hook.cpiv = f.cpiv;

  ## passed options
  hook.max_fract_change = o.max_fract_change;
  hook.fract_prec = o.fract_prec;
  ## hook.TolFun = ; # set before
  ## hook.MaxIter = ; # set before
  hook.fixed = o.fixed;
  hook.user_interaction = o.user_interaction;
  hook.max_rand_step = o.max_rand_step;
  hook.MaxIter = o.MaxIter;
  hook.Display = o.Display;
  hook.testing = o.debug;
  hook.siman.T_init = o.T_init;
  hook.siman.T_min = o.T_min;
  hook.siman.mu_T = o.mu_T;
  hook.siman.iters_fixed_T = o.iters_fixed_T;
  hook.siman.iters_adjust_step = o.iters_adjust_step;
  hook.niter_check_tolfun =  o.niter_check_tolfun;
  hook.stoch_regain_constr = o.stoch_regain_constr;
  hook.trace_steps = o.trace_steps;
  hook.siman_log = o.siman_log;
  hook.save_state = o.save_state;
  hook.recover_state = o.recover_state;
  hook.octave_sqp_tolerance = o.octave_sqp_tolerance;
  hook.inverse_hessian = o.inverse_hessian;
  hook.TolX = o.TolX;
  hook.FunValCheck = o.FunValCheck;

  ## for simplicity, unconditionally reset __dfdp__
  __dfdp__ ("reset");

  #### call backend

  [p, objf, cvg, outp] = backend (f.objf, pin, hook);

  if (o.p_struct)
    if (o.pnonscalar)
      p = cell2struct ...
	  (cellfun (@ reshape, mat2cell (p, o.ppartidx),
		    o.param_dims, "UniformOutput", false),
	   o.param_order, 1);
    else
      p = cell2struct (num2cell (p), o.param_order, 1);
    endif
  endif

endfunction

function backend = map_matlab_algorithm_names (backend)

  ## nothing done here at the moment

endfunction

function [backend, path_bounds] = map_backend (backend)

  switch (backend)
      ##    case "sqp_infeasible"
      ##      backend = "__sqp__";
      ##    case "sqp"
      ##      backend = "__sqp__";
    case "lm_feasible"
      backend = "__lm_feasible__";
      path_bounds = true;
    case "octave_sqp"
      backend = "__octave_sqp_wrapper__";
      path_bounds = false;
    case "siman"
      backend = "__siman__";
      path_bounds = true;
    case "samin"
      backend = "__samin__";
      path_bounds = false;
    case "d2_min"
      backend = "__d2_min__";
      path_bounds = false;
    otherwise
      error ("no backend implemented for algorithm '%s'", backend);
  endswitch

  backend = str2func (backend);

endfunction

function lval = assign (lval, lidx, rval)

  lval(lidx) = rval;

endfunction

%!demo
%! ## Example for default optimization (Levenberg/Marquardt with
%! ## BFGS), one non-linear equality constraint. Constrained optimum is
%! ## at p = [0; 1].
%! objective_function = @ (p) p(1)^2 + p(2)^2;
%! pin = [-2; 5];
%! constraint_function = @ (p) p(1)^2 + 1 - p(2);
%! [p, objf, cvg, outp] = nonlin_min (objective_function, pin, optimset ("equc", {constraint_function}))

%!demo
%! ## Example for simulated annealing, two parameters, "trace_steps"
%! ## is true;
%! t_init = .2;
%! t_min = .002;
%! mu_t = 1.002;
%! iters_fixed_t = 10;
%! init_p = [2; 2];
%! max_rand_step = [.2; .2];
%! [p, objf, cvg, outp] = nonlin_min (@ (p) (p(1)/10)^2 + (p(2)/10)^2 + .1 * (-cos(4*p(1)) - cos(4*p(2))), init_p, optimset ("algorithm", "siman", "max_rand_step", max_rand_step, "t_init", t_init, "T_min", t_min, "mu_t", mu_t, "iters_fixed_T", iters_fixed_t, "trace_steps", true));
%! p
%! objf
%! x = (outp.trace(:, 1) - 1) * iters_fixed_t + outp.trace(:, 2);
%! x(1) = 0;
%! plot (x, cat (2, outp.trace(:, 3:end), t_init ./ (mu_t .^ outp.trace(:, 1))))
%! legend ({"objective function value", "p(1)", "p(2)", "Temperature"})
%! xlabel ("subiteration")

%!test
%! ## independents
%! indep = 1:5;
%! ## objective function:
%! f = @ (p) sumsq (p(1) * exp (p(2) * indep) - [1, 2, 4, 7, 14]);
%! ## initial values:
%! init = [.25; .25];
%! ## linear constraints, A.' * parametervector + B >= 0
%! A = [1; -1]; B = 0; # p(1) >= p(2);
%! settings = optimset ("inequc", {A, B});
%!
%! assert (nonlin_min (f, init, settings), [.6203; .6203], .0001);

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
%! settings = optimset ("param_config", pconf, "objf_pstruct", true);
%!
%! f = @ (p) sumsq (( ...
%!       subsasgn (x, struct ("type", "()", "subs", {{9, 3}}), p.c) ...
%!     * horzcat (p.a, p.a([3, 1, 2]), p.a([3, 2, 1])) ...
%!     - p.d ...
%!     * subsasgn (misc, struct ("type", "()", "subs", {{3, 2}}), p.b))(:));
%!
%! [p, ~, ~, outp] = nonlin_min (f, pin, settings);
%!
%! assert (p.a, [1.0590; 1.9266; 4.0456], .005);
%! assert (p.b, 2.7061, .005);
%! assert (p.c, .3, .000001);
%! assert (p.d, 1);

%!test
%! pin = zeros (6, 1);
%! pin(6) = 1;
%!
%! settings = optimset ("lbound", [-Inf; 0; NA; 0; -Inf; -Inf],
%!                      "ubound", [Inf; Inf; Inf; Inf; .3; Inf],
%!                      "diff_onesided", true,
%!                      "fixed", [false; false; false; false; false; true]);
%!
%! f = @ (p) sumsq (( ...
%!       subsasgn (x, struct ("type", "()", "subs", {{9, 3}}), p(5)) ...
%!     * horzcat (p([1, 2, 3]), p([3, 1, 2]), p([3, 2, 1])) ...
%!     - p(6) ...
%!     * subsasgn (misc, struct ("type", "()", "subs", {{3, 2}}), p(4)))(:));
%!
%! p = nonlin_min (f, pin, settings);
%!
%! assert (p, [1.0590; 1.9266; 4.0456; 2.7061; .3; 1], .005);
