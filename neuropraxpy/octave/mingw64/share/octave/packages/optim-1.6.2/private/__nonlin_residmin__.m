## Copyright (C) 2010-2019 Olaf Till <i7tiol@t-online.de>
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

## Internal function, called by nonlin_residmin --- see there --- and
## others. Calling __nonlin_residmin__ indirectly hides the argument
## "hook", usable by wrappers, from users. Currently, hook can contain
## the field "observations", so that dimensions of observations and
## returned values of unchanged model function can be checked against
## each other exactly one time.

function [p, resid, cvg, outp] = ...
      __nonlin_residmin__ (model_f, pin, settings, hook)

  ## some scalar defaults; some defaults are specific to the backend or
  ## to the derivative function, so lacking elements in respective
  ## constructed vectors will be set to NA here in the frontend
  stol_default = .0001;
  cstep_default = 1e-20;

  defaults = optimset ("param_config", [],
		       "param_order", [],
		       "param_dims", [],
		       "f_inequc_pstruct", false,
		       "f_equc_pstruct", false,
		       "f_pstruct", false,
		       "df_inequc_pstruct", [],
		       "df_equc_pstruct", [],
		       "df_pstruct", [],
		       "lbound", [],
		       "ubound", [],
		       "dfdp", [],
		       "cpiv", @ cpiv_bard,
		       "max_fract_change", [],
		       "fract_prec", [],
		       "diffp", [],
		       "diff_onesided", [],
                       "FinDiffRelStep", [],
                       "FinDiffType", [],
                       "TypicalX", [],
		       "complex_step_derivative_f", false,
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
		       "weights", [],
		       "TolFun", stol_default,
		       "MaxIter", [],
		       "Display", "off",
		       "Algorithm", "lm_svd_feasible",
                       ## Matlabs UseParallel works differently
                       "parallel_local", false,
                       "parallel_net", [],
		       "plot_cmd", [],
                       "user_interaction", {},
		       "debug", false,
                       "FunValCheck", "off",
		       "lm_svd_feasible_alt_s", false);

  if (nargin == 1 && ischar (model_f) && strcmp (model_f, "defaults"))
    p = defaults;
    return;
  endif

  if (nargin != 4)
    error ("incorrect number of arguments");
  endif

  ## apply 'static' defaults; affected by optimset bug #54952
  o = optimset (defaults, settings);

  if (ischar (model_f))
    model_f = str2func (model_f);
  endif
  model_f = __maybe_limit_arg_count__ (model_f, 1, 2);
  f.f = model_f;

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
      __optimget_parallel_local__ (o, false);
  o.parallel_net = hook.parallel_net = ...
      __optimget_parallel_net__ (o, []);

  #### processing of settings and consistency checks

  ## map backend
  backend = map_backend (map_matlab_algorithm_names (o.Algorithm));

  ## apply defaults which depend on other settings
  o.df_pstruct = optimget (o, "df_pstruct", o.f_pstruct);
  o.df_inequc_pstruct = optimget (o, "df_inequc_pstruct", o.f_inequc_pstruct);
  o.df_equc_pstruct = optimget (o, "df_equc_pstruct", o.f_equc_pstruct);

  if (ischar (o.dfdp))
    o.dfdp = str2func (o.dfdp);
  endif
  f.dfdp = o.dfdp;

  if (isempty (o.FinDiffType))
    o.FinDiffType_onesided = [];
  else
    if (strcmpi (o.FinDiffType, "forward"))
      o.FinDiffType_onesided = true;
    elseif (strcmpi (o.FinDiffType, "central"))
      o.FinDiffType_onesided = false;
    else
      error ("invalid value of 'FinDiffType'");
    endif
  endif

  if (o.complex_step_derivative_f && ! isempty (o.dfdp))
    error ("both 'complex_step_derivative_f' and 'dfdp' are set");
  endif

  if (isempty (f.dfdp))
    if (o.complex_step_derivative_f)
      f.dfdp = @ jacobs;
    else
      f.dfdp = @ __dfdp__ ;
    endif
    dfdp_specified = false;
  else
    f.dfdp = __maybe_limit_arg_count__ (f.dfdp, 1, 2);
    dfdp_specified = true;
  endif

  if (! iscell (o.user_interaction))
    o.user_interaction = {o.user_interaction};
  endif

  if (isempty (o.plot_cmd))
    o.plot_cmd = @ (f) 0;
  else
    warning ("setting 'plot_cmd' is deprecated, please use 'user_interaction'");
  endif

  o.any_vector_conf = ! (isempty (o.lbound) && isempty (o.ubound) &&
		       isempty (o.max_fract_change) &&
		       isempty (o.fract_prec) && isempty (o.diffp) &&
		       isempty (o.diff_onesided) && isempty (o.TypicalX) &&
                       isempty (o.FinDiffRelStep) &&
                       isempty (o.fixed));

  ## process constraints
  [o, f] = __process_constraints__ (o, f);

  ## correct further "_pstruct" settings if functions are not supplied
  if (! dfdp_specified)
    o.df_pstruct = false;
  endif
  
  ## check or provide parameter order and parameter dimension
  ## information

  need_param_order = ...
  o.p_struct || ! isempty (o.param_config) || o.f_inequc_pstruct ...
  || o.f_equc_pstruct || o.f_pstruct || o.df_pstruct ...
  || o.df_inequc_pstruct || o.df_equc_pstruct || o.imc_struct ...
  || o.emc_struct;

  param_order_unclear = ...
  o.any_vector_conf ...
  || ! ...
     (o.f_pstruct ...
      && (o.f_inequc_pstruct || isempty (f.f_genicstr)) ...
      && (o.f_equc_pstruct || isempty (f.f_genecstr)) ...
      && (o.df_pstruct || ! dfdp_specified) ...
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
              };

  if (! isempty (o.param_config))
    ## use supplied configuration structure

    ## parameter-related configuration is either allowed by a structure
    ## or by vectors
    if (o.any_vector_conf)
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

  ## check TypicalX
  if (! all (o.TypicalX))
    error ("TypicalX must not be zero.");
  endif

  ## map FinDiffRelStep and FinDiffType, if necessary
  if (! isempty (o.FinDiffType_onesided))
    if (diff_onesided_specified &&
        any (o.diff_onesided != o.FinDiffType_onesided))
      warning ("option 'FinDiffType' overrides option 'diff_onesided'");
    endif
    o.diff_onesided(:) = o.FinDiffType_onesided;
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
            "f";
            "dfdp";
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

  f_pin = f.f (pin); # Doing this in the frontend is useful for
                                # residual-based minimization (but not
                                # for scalar objective functions)
  ## for nonlin_curvefit
  if (isfield (hook, "observations"))
    if (any (size (f_pin) != size (obs = hook.observations)))
      error ("dimensions of observations and values of model function must match");
    endif
    f.f = @ (varargin) f.f (varargin{:}) - obs;
    f_pin -= obs;
    o.user_interaction = ...
        cellfun (@ (f_handle) @ (p, v, s) ...
                 f_handle (p, setfield (v, "model_y", v.residual + obs), s),
                 o.user_interaction(:), "UniformOutput", false);
  endif

  ## bind model function argument to standard gradient function; must
  ## not be done until model function is adapted, if necessary, to
  ## structure-based parameters and, if necessary, to the requirements
  ## of the frontend 'nonlin_curvefit'
  if (! dfdp_specified)
    f.dfdp = @ (p, hook) f.dfdp (p, f.f, hook);
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

  if ((hook.TolFun = o.TolFun) < 0)
    error ("'TolFun' negative");
  endif

  if (any (o.fract_prec < 0))
    error ("some elements of 'fract_prec' negative");
  endif

  if (any (o.max_fract_change < 0))
    error ("some elements of 'max_fract_change' negative");
  endif

  ## check weights dimensions
  weights = optimget (o, "weights", ones (size (f_pin)));
  if (any (size (weights) != size (f_pin)))
    error ("dimension of weights and residuals must match");
  endif
  if (any (weights(:) < 0))
    error ("some weights negative")
  endif

  #### handle fixing of parameters
  o.jac_lbound = o.lbound;
  o.jac_ubound = o.ubound;
  o.jac_fixed =  o.orig_fixed = o.fixed;
  if (all (o.fixed))
    error ("no free parameters");
  endif

  o.nonfixed = ! o.fixed;
  if (any (o.fixed))

    funs = { ...
             "f";
             "dfdp";
             "f_genicstr";
             "df_genicstr";
             "f_genecstr";
             "df_genecstr"};

    opts = { ...
             "lbound";
             "ubound";
             "max_fract_change";
             "fract_prec";
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

  ## passed function for derivative of model function
  hook.dfdp = f.dfdp;

  ## passed function for complementary pivoting
  hook.cpiv = f.cpiv;

  ## passed value of residual function for initial parameters
  hook.f_pin = f_pin;

  ## passed options
  hook.max_fract_change = o.max_fract_change;
  hook.fract_prec = o.fract_prec;
  ## hook.TolFun = ; # set before
  ## hook.MaxIter = ; # set before
  hook.weights = weights;
  hook.fixed = o.fixed;
  hook.user_interaction = o.user_interaction;
  hook.MaxIter = o.MaxIter;
  hook.Display = o.Display;
  hook.testing = o.debug;
  hook.new_s = o.lm_svd_feasible_alt_s;
  hook.FunValCheck = o.FunValCheck;
  hook.plot_cmd = o.plot_cmd;

  ## for simplicity, unconditionally reset __dfdp__
  __dfdp__ ("reset");

  #### call backend

  [p, resid, cvg, outp] = backend (f.f, pin, hook);

  ## process lambda output
  if (isfield (outp, "lambda"))
    ## lower bounds
    lidx = o.lbound != - Inf;
    t_lower = zeros (size (lidx));
    id_lb = 1 : sum (lidx);
    t_lower(lidx, 1) = outp.lambda(id_lb);
    outp.lambda(id_lb) = [];
    o.eq_idx(id_lb) = [];
    o.eq_idx = logical (o.eq_idx); # work around bug in Octave 3.8.(2-rc)
    lambda.lower = NA (size (o.orig_fixed));
    lambda.lower(o.nonfixed) = t_lower;
    ## upper bounds
    uidx = o.ubound != Inf;
    t_upper = zeros (size (uidx)); # (== size (lidx), of course)
    id_ub = 1 : sum (uidx);
    t_upper(uidx, 1) = outp.lambda(id_ub);
    outp.lambda(id_ub) = [];
    o.eq_idx(id_ub) = [];
    o.eq_idx = logical (o.eq_idx); # work around bug in Octave 3.8.(2-rc)
    lambda.upper = NA (size (o.orig_fixed));
    lambda.upper(o.nonfixed) = t_upper;
    ## linear constraints except bounds
    id_lin = 1 : (numel (outp.lambda) - o.n_gencstr);
    lambda.eqlin = outp.lambda(id_lin)(o.eq_idx(id_lin));
    lambda.ineqlin = outp.lambda(id_lin)((! o.eq_idx)(id_lin));
    outp.lambda(id_lin) = [];
    o.eq_idx(id_lin) = [];
    o.eq_idx = logical (o.eq_idx); # work around bug in Octave 3.8.(2-rc)
    ## general constraints (we take the same fieldnames as in Matlab,
    ## although general constraints might still be linear)
    lambda.eqnonlin = outp.lambda(o.eq_idx);
    lambda.ineqnonlin = outp.lambda(! o.eq_idx);
    ## consider structure-based parameter handling, only necessary for
    ## bounds
    if (! isempty (o.param_config))
      if (o.pnonscalar)
        lambda.lower = cell2struct ...
            (cellfun (@ reshape, mat2cell (lambda.lower, o.ppartidx),
                      o.param_dims, "UniformOutput", false),
             o.param_order, 1);
        lambda.upper = cell2struct ...
            (cellfun (@ reshape, mat2cell (lambda.upper, o.ppartidx),
                      o.param_dims, "UniformOutput", false),
             o.param_order, 1);
      else
        lambda.lower = cell2struct (num2cell (lambda.lower), o.param_order, 1);
        lambda.upper = cell2struct (num2cell (lambda.upper), o.param_order, 1);
      endif
    endif
    ## finish
    outp.lambda = lambda;
  endif

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

  switch (backend)
    case "levenberg-marquardt"
      backend = "lm_svd_feasible";
      warning ("algorithm 'levenberg-marquardt' mapped to 'lm_svd_feasible'");
  endswitch

endfunction

function backend = map_backend (backend)

  switch (backend)
    case "lm_svd_feasible"
      backend = "__lm_svd__";
    otherwise
      error ("no backend implemented for algorithm '%s'", backend);
  endswitch

  backend = str2func (backend);

endfunction

function lval = assign (lval, lidx, rval)

  lval(lidx) = rval;

endfunction
