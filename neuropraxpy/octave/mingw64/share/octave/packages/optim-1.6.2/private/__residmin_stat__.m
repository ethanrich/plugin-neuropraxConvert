## Copyright (C) 2011-2019 Olaf Till <i7tiol@t-online.de>
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

## Internal function, called by residmin_stat --- see there --- and
## others. Calling __residmin_stat__ indirectly hides the argument
## "hook", usable by wrappers, from users. Currently, hook can contain
## the field "observations". Since much uf the interface code is taken
## from __nonlin_residmin__, it may be that not everything is ideal for
## the present case; but I think it's allright to leave it so.
##
## Some general considerations while making this function:
##
## Different Functions for optimization statistics should be made for
## mere objective function optimization (to be made yet) and
## residual-derived minimization (this function), since there are
## different computing aspects. Don't put the contained functionality
## (statistics) into the respective optimization functions (or
## backends), since different optimization algorithms can share a way to
## compute statistics (e.g. even stochastic optimizers can mimize
## (weighted) squares of residuals). Also, don't use the same frontend
## for optimization and statistics, since the differences in the
## interface for both uses may be confusing otherwise, also the optimset
## options only partially overlap.

function ret = __residmin_stat__ (model_f, pfin, settings, hook)

  ## scalar defaults
  cstep_default = 1e-20;

  defaults = optimset ("param_config", [],
		       "param_order", [],
		       "param_dims", [],
		       "f_pstruct", false,
		       "df_pstruct", false,
		       "dfdp", [],
		       "diffp", [],
		       "diff_onesided", [],
                       "FinDiffRelStep", [],
                       "FinDiffType", [],
                       "TypicalX", [],
		       "complex_step_derivative_f", false,
		       "cstep", cstep_default,
		       "fixed", [],
		       "weights", [],
		       "residuals", [],
		       "covd", [],
                       ## no default, e.g. "wls"
		       "objf_type", [],
		       "ret_dfdp", false,
		       "ret_covd", false,
		       "ret_covp", false,
		       "ret_corp", false,
                       ## Matlabs UseParallel works differently
                       "parallel_local", false,
                       "parallel_net", []);

  if (nargin == 1 && ischar (model_f) && strcmp (model_f, "defaults"))
    ret = defaults;
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

  if (! (o.p_struct = isstruct (pfin)))
    if (! isempty (pfin) && (! isvector (pfin) || columns (pfin) > 1))
      error ("parameters must be either a structure or a column vector");
    endif
  endif

  #### collect remaining settings
  o.parallel_local = hook.parallel_local = ...
      __optimget_parallel_local__ (settings, false);
  o.parallel_net = hook.parallel_net = ...
      __optimget_parallel_net__ (settings, []);

  #### processing of settings and consistency checks

  if (ischar (o.dfdp))
    o.dfdp = str2func (o.dfdp);
  endif
  f.dfdp = o.dfdp;
  dfdp_specified = ! isempty (f.dfdp);

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

  any_vector_conf = ! (isempty (o.diffp) && isempty (o.diff_onesided) &&
                       isempty (o.TypicalX) &&
                       isempty (o.FinDiffRelStep) &&
		       isempty (o.fixed));

  ## correct "_pstruct" settings if functions are not supplied
  if (! dfdp_specified) o.df_pstruct = false; endif
  if (isempty (f.f)) o.f_pstruct = false; endif

  ## check or provide parameter order and parameter dimension
  ## information

  need_param_order = ...
  o.p_struct || ! isempty (o.param_config) || o.f_pstruct || o.df_pstruct;

  param_order_unclear = ...
  any_vector_conf ...
  || ! ...
     ((o.f_pstruct || isempty (f.f)) ...
      && (o.df_pstruct || ! dfdp_specified));

  [o, f, pfin] = __get_param_info__ (o, f, pfin,
                                     need_param_order,
                                     param_order_unclear);
  ##

  ## dfdp checks
  if (o.complex_step_derivative_f && dfdp_specified)
    error ("both 'complex_step_derivative_f' and 'dfdp' are set");
  endif
  if (dfdp_specified)
    if (! isa (f.dfdp, "function_handle"))
      if (isnumeric (f.dfdp))
        if (numel (size_dfdp = size (f.dfdp)) > 2 ||
            any (size_dfdp != [prod(size(o.residuals)), o.np]))
	  error ("jacobian has wrong size");
        endif
      elseif (! o.df_pstruct)
        error ("jacobian has wrong type");
      endif
      f.dfdp = @ (varargin) f.dfdp; # simply make a function returning it
    else
      f.dfdp = __maybe_limit_arg_count__ (f.dfdp, 1, 2);
    endif
    have_dfdp = true;
  else
    if (isempty (f.f))
      have_dfdp = false;
    else
      if (o.complex_step_derivative_f)
        f.dfdp = @ jacobs;
      else
        f.dfdp = @ __dfdp__ ;
      endif
      have_dfdp = true;
    endif
  endif

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
            "f";
            "dfdp";
          };

  f = __maybe_wrap_struct_based_callbacks__ (o, f, flist);

  if (isempty (o.residuals))
    if (isempty (f.f))
      error ("neither model function nor residuals given");
    endif
    o.residuals = f.f (pfin);
  endif

  ## for nonlin_curvefit
  if (isfield (hook, "observations"))
    if (any (size (o.residuals) != size (obs = hook.observations)))
      error ("dimensions of observations and values of model function must match");
    endif
    f.f = @ (varargin) f.f (varargin{:}) - obs;
    o.residuals -= obs;
  endif

  ## bind model function argument to standard gradient function; must
  ## not be done until model function is adapted, if necessary, to
  ## structure-based parameters and, if necessary, to the requirements
  ## of the frontend 'nonlin_curvefit'
  if (! dfdp_specified)
    f.dfdp = @ (p, hook) f.dfdp (p, f.f, hook);
  endif


  #### further values and checks

  ## check weights dimensions
  weights = optimget (settings, "weights", ones (size (o.residuals)));
  if (any (size (weights) != size (o.residuals)))
    error ("dimension of weights and residuals must match");
  endif

  if (any (o.diffp <= 0))
    error ("some elements of 'diffp' non-positive");
  endif

  if (o.cstep <= 0)
    error ("'cstep' non-positive");
  endif

  need_dfdp = false;
  need_objf_label = false;
  if (o.ret_dfdp)
    need_dfdp = true;
  endif
  if (o.ret_covd)
    need_objf_label = true;
    if (o.np == 0)
      error ("number of parameters must be known for 'covd', specify either parameters or a jacobian matrix");
    endif
  endif
  if (o.ret_covp)
    need_objf_label = true;
    need_dfdp = true;
  endif
  if (o.ret_corp)
    need_objf_label = true;
    need_dfdp = true;
  endif
  if (need_objf_label)
    if (isempty (o.objf_type))
      error ("label of objective function must be specified");
    else
      funs = map_objf (o.objf_type);
    endif
  else
    funs = struct ();
  endif
  if (! have_dfdp && need_dfdp)
    error ("jacobian required and default function for jacobian requires a model function");
  endif

  ####

  ## Everything which is computed is stored in a hook structure which is
  ## passed to and returned by every backend function. This hook is not
  ## identical to the returned structure, since some more results could
  ## be computed by the way.

  #### handle fixing of parameters

  orig_p = pfin;
  o.jac_fixed = o.fixed;

  if (all (o.fixed) && ! isempty (o.fixed))
    error ("no free parameters");
  endif

  ## The policy should be that everything which is computed is left as
  ## it is up to the end --- since other computations might need it in
  ## this form --- and supplemented with values corresponding to fixed
  ## parameters (mostly NA, probably) not until then.
  ##
  ## The jacobian backend is the only backend which has the whole
  ## parameter vector available (including fixed elements), possibly
  ## handling fixing internally (e.g. by omitting computation).

  o.nonfixed = ! o.fixed;

  np_after_fixing = sum (o.nonfixed);

  if (any (o.fixed))

    if (! isempty (pfin))
      pfin = pfin(o.nonfixed);
    endif

    ## model function
    f.f = @ (p, varargin) f.f (assign (pfin, o.nonfixed, p), varargin{:});

    ## jacobian of model function
    if (have_dfdp)
      f.dfdp = @ (p, hook) ...
	  f.dfdp (assign (orig_p, o.nonfixed, p), hook)(:, o.nonfixed);
    endif
    
  endif

  #### supplement constants to jacobian function

  fnames = {"dfdp"};
  pstruct = [o.df_pstruct];
  ## 1st column fieldname of value passed to __jacobian_constants__,
  ## 2nd column fieldname of value passed to jacobian functions
  jac_scalar_parconf_names = ...
  { ...
    "diffp", "diffp";
    "TypicalX", "TypicalX";
    "diff_onesided", "diff_onesided";
  };
  f = __jacobian_constants__ (o, f, fnames, pstruct,
                              jac_scalar_parconf_names, false);

  #### prepare interface hook

  ## passed final parameters of an optimization
  hook.pfin = pfin;

  ## passed function for derivative of model function
  hook.dfdp = f.dfdp;

  ## passed function for complementary pivoting
  ## hook.cpiv = cpiv; # set before

  ## passed value of residual function for initial parameters
  hook.residuals = o.residuals;

  ## passed weights
  hook.weights = weights;

  ## passed dimensions
  hook.np = np_after_fixing;
  hook.nm = prod (size (o.residuals));

  ## passed statistics functions
  hook.funs = funs;

  ## passed covariance matrix of data (if given by user)
  if (! isempty (o.covd))
    covd_dims = size (o.covd);
    if (length (covd_dims) != 2 || any (covd_dims != hook.nm))
      error ("wrong dimensions of covariance matrix of data");
    endif
    hook.covd = o.covd;
  endif

  ## for simplicity, unconditionally reset __dfdp__
  __dfdp__ ("reset");

  #### do the actual work

  if (o.ret_dfdp)
    hook.jac = hook.dfdp (hook.pfin, hook);
  endif

  if (o.ret_covd)
    hook = funs.covd (hook);
  endif

  if (o.ret_covp || o.ret_corp)
    hook = funs.covp_corp (hook);
  endif

  #### convert (consider fixing ...) and return results

  ret = struct ();

  if (o.ret_dfdp)
    ret.dfdp = zeros (hook.nm, o.np, class (hook.pfin));
    ret.dfdp(:, o.nonfixed) = hook.jac;
  endif

  if (o.ret_covd)
    ret.covd = hook.covd;
  endif

  if (o.ret_covp)
    if (any (o.fixed))
      ret.covp = NA (o.np);
      ret.covp(o.nonfixed, o.nonfixed) = hook.covp;
    else
      ret.covp = hook.covp;
    endif
  endif

  if (o.ret_corp)
    if (any (o.fixed))
      ret.corp = NA (o.np);
      ret.corp(o.nonfixed, o.nonfixed) = hook.corp;
    else
      ret.corp = hook.corp;
    endif
  endif

endfunction

function funs = map_objf (objf)

  switch (objf)
    case "wls" # weighted least squares
      funs.covd = str2func ("__covd_wls__");
      funs.covp_corp = str2func ("__covp_corp_wls__");
    otherwise
      error ("no statistics implemented for objective function '%s'",
	     objf);
  endswitch

endfunction

function lval = assign (lval, lidx, rval)

  lval(lidx) = rval;

endfunction
