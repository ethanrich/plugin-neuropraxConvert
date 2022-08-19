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
## @deftypefn {Function File} {} fmincon (@var{objf}, @var{x0})
## @deftypefnx {Function File} {} fmincon (@var{objf}, @var{x0}, @var{A}, @var{b})
## @deftypefnx {Function File} {} fmincon (@var{objf}, @var{x0}, @var{A}, @var{b}, @var{Aeq}, @var{beq})
## @deftypefnx {Function File} {} fmincon (@var{objf}, @var{x0}, @var{A}, @var{b}, @var{Aeq}, @var{beq}, @var{lb}, @var{ub})
## @deftypefnx {Function File} {} fmincon (@var{objf}, @var{x0},  @var{A}, @var{b}, @var{Aeq}, @var{beq}, @var{lb}, @var{ub}, @var{nonlcon})
## @deftypefnx {Function File} {} fmincon (@var{objf}, @var{x0}, @var{A}, @var{b}, @var{Aeq}, @var{beq}, @var{lb}, @var{ub}, @var{nonlcon}, @var{options})
## @deftypefnx {Function File} {} fmincon (@var{problem})
## @deftypefnx {Function File} {[@var{x}, @var{fval}, @var{cvg}, @var{outp}] =} fmincon (@dots{})
## Compatibility frontend for nonlinear minimization of a scalar
## objective function.
##
## This function is for Matlab compatibility and provides a subset of
## the functionality of @code{nonlin_min}.
##
## @var{objf}: objective function. It gets the real parameters as
## argument.
##
## @var{x0}: real vector or array of initial parameters.
##
## @var{A}, @var{b}: Inequality constraints of the parameters @code{p}
## with @code{A * p - b <= 0}.
##
## @var{Aeq}, @var{beq}: Equality constraints of the parameters @code{p}
## with @code{A * p - b = 0}.
##
## @var{lb}, @var{ub}: Bounds of the parameters @code{p} with @code{lb
## <= p <= ub}. Vectors or arrays. If the number of elements is
## smaller than the number of parameters, as many bounds as present
## are applied, starting with the first parameter. This is for
## compatibility with Matlab.
##
## @var{nonlcon}: Nonlinear constraints. Function returning the
## current values of nonlinear inequality constraints (constrained to
## @code{<= 0}) in the first output and the current values of nonlinear
## equality constraints in the second output.
##
## @var{options}: structure whose fields stand for optional settings
## referred to below. The fields can be set by @code{optimset()}.
##
## An argument can be set to @code{[]} to indicate that its value is
## not set.
##
## @code{fmincon} may also be called with a single structure
## argument with the fields @code{objective}, @code{x0}, @code{Aineq},
## @code{bineq}, @code{Aeq}, @code{beq}, @code{lb}, @code{ub},
## @code{nonlcon} and @code{options}, resembling
## the separate input arguments above. Additionally,
## the structure must have the field @code{solver}, set to
## @qcode{"fmincon"}.
##
## The returned values are the final parameters @var{x}, the final
## value of the objective function @var{fval}, an integer @var{cvg}
## indicating if and how optimization succeeded or failed, and a
## structure @var{outp} with additional information, curently with
## possible fields: @code{iterations}, the number of iterations,
## @code{funcCount}, the number of objective function calls (indirect
## calls by gradient function not counted), @code{constrviolation},
## the maximum of the constraint violations. The backend may define
## additional fields. @var{cvg} is greater than zero for success and
## less than or equal to zero for failure; its possible values depend
## on the used backend and currently can be @code{0} (maximum number
## of iterations exceeded), @code{1} (success without further
## specification of criteria), @code{2} (parameter change less than
## specified precision in two consecutive iterations), @code{3}
## (improvement in objective function less than specified), @code{-1}
## (algorithm aborted by a user function), or @code{-4} (algorithm got
## stuck).
##
## @subsubheading Options:
##
## @table @code
##
## @item Algorithm
## @code{interior-point}, @code{sqp}, and @code{sqp-legacy} are
## mapped to optims @code{lm_feasible} algorithm (the default) to
## satisfy constraints throughout the optimization. @code{active-set}
## is mapped to @code{octave_sqp}, which may perform better if
## constraints only need to be satisfied for the result. Other
## algorithms are available with @code{nonlin_min}.
##
## @item OutputFcn
## Similar to the setting @code{user_interaction} --- see
## @code{optim_doc()}. Differently, @code{OutputFcn} returns only one
## output argument, the  @var{stop} flag.
##
## @item GradObj
## If set to @code{"on"}, @var{objf} must return the gradient of the
## objective function as a second output. The default is @code{"off"}.
##
## @item GradConstr
## If set to @code{"on"}, @var{nonlcon} must return the Jacobians of
## the inequality- and equality-constraints as third and fourth
## output, respectively.
##
## @item HessianFcn
## If set to @code{"objective"}, @var{objf} must not only return the
## gradient as the second, but also the Hessian as the third output.
##
## @item Display, FinDiffRelStep, FinDiffType, TypicalX, MaxIter, TolFun, TolX,
## See documentation of these options in @code{optim_doc()}.
##
## @end table
##
## For description of individual backends, type
## @code{optim_doc ("scalar optimization")} and choose the backend in
## the menu.
##
## @end deftypefn

## PKG_ADD: [~] = __all_opts__ ("fmincon");

### fmincon (obj_f, pin, A, b, Aeq, beq, lb, ub, nonlcon, settings)
function [p, objf, cvg, outp] = fmincon (varargin)

  ## some scalar defaults; some defaults are backend specific, so
  ## lacking elements in respective constructed vectors will be set to
  ## NA here in the frontend
  stol_default = 1e-6;

  defaults = optimset ( ...
		       "Algorithm", "lm_feasible",
		       "Display", "off",
                       "FinDiffRelStep", [],
                       "FinDiffType", [],
		       "MaxIter", [],
		       "TolFun", stol_default,
                       "OutputFcn", {},
                       "GradConstr", "off",
                       "GradObj", "off",
                       "TolX", [],
                       "TypicalX", [],
                       "HessianFcn", []);

  if ((nargs = nargin ()) == 1 && ischar (varargin{1})
      && strcmp (varargin{1}, "defaults"))
    p = defaults;
    return;
  endif

  if (nargs == 1)

    problem = varargin{1};

    if (! isstruct (problem))
      error ("fmincon: PROBLEM must be a structure");
    endif
    if (! strcmp (problem.solver, "fmincon"))
      error ('fmincon: problem.solver must be set to "fmincon"');
    endif

    varargin = evaluate_problem_structure (problem,
                                           {{true, "objective"},
                                            {true, "x0"},
                                            {false, "Aineq"},
                                            {false, "bineq"},
                                            {false, "Aeq"},
                                            {false, "beq"},
                                            {false, "lb"},
                                            {false, "ub"},
                                            {false, "nonlcon"},
                                            {false, "options"}});
                                            
    nargs = numel (varargin);

  endif

  if (! ismember (nargs, [2, 4, 6, 8, 9, 10]))
    print_usage ();
  endif

  varargin = horzcat (varargin, cell (1, 10 - nargs));

  if (isempty (settings = varargin{10}))
    settings = struct ();
  endif

  ## apply 'static' defaults; affected by optimset bug #54952
  o = optimset (defaults, settings);

  if (ischar (f.objf = varargin{1}))
    f.objf = str2func (f.objf);
  endif
  f.objf = @ (p, varargin) f.objf (p);

  #### processing of settings and consistency checks

  ## map backend
  backend = map_matlab_algorithm_names (o.Algorithm);
  [backend, path_bounds] = map_backend (backend);

  o.diffp = [];
  o.diff_onesided = [];
  o.max_fract_change = [];
  o.fract_prec = [];
  o.cstep = false;
  o.parallel_local = false;
  o.parallel_net = [];
  o.f_inequc_idx = false;
  o.df_inequc_idx = false;
  o.f_equc_idx = false;
  o.df_equc_idx = false;

  if (strcmp (o.GradObj, "on"))
    f.dfdp = @ (p, varargin) out_2_wrapper (f.objf, p);
    dfdp_specified = true;
  else
    f.dfdp = @ __dfdp__;
    dfdp_specified = false;
  endif    

  if (strcmp (o.HessianFcn, "objective"))
    f.hessian = @ (p) out_3_wrapper (f.objf, p);
  else
    f.hessian = [];
  endif    

  if (ischar (nonlcon = varargin{9}))
    nonlcon = str2func (nonlcon);
  endif

  if (! isempty (nonlcon))
    nonlcon = @ (p, varargin) nonlcon (p);
  endif

  ## handle argument shapes in a way compatible to Matlab

  pin = varargin{2};
  ps_orig = size (pin);
  pin = pin(:);

  lbound = varargin{7}(:);
  ubound = varargin{8}(:);

  if (ps_orig(2) > 1)

    f.objf = @ (p, varargin) f.objf (reshape (p, ps_orig), varargin{:});

    if (dfdp_specified)
      f.dfdp = @ (p, varargin) f.dfdp (reshape (p, ps_orig), varargin{:});
    endif

    if (! isempty (f.hessian))
      f.hessian = ...
      @ (p, varargin) f.hessian (reshape (p, ps_orig), varargin{:});
    endif

    if (! isempty (nonlcon))
      nonlcon = @ (p, varargin) nonlcon (reshape (p, ps_orig), varargin{:});
    endif

  endif

  ## 

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

  if (! iscell (o.OutputFcn))
    o.OutputFcn = {o.OutputFcn};
  endif
  for id = 1 : numel (o.OutputFcn)
    fcn = o.OutputFcn{id};
    fcn = @ (varargin) output_fcn_wrapper (fcn, varargin{:});
    o.OutputFcn{id} = fcn;
  endfor
  o.user_interaction = o.OutputFcn;

  ## process constraints
  o.lbound = lbound;
  o.ubound = ubound;
  o.complex_step_derivative_inequc = false;
  o.complex_step_derivative_equc = false;
  o.inequc = o.equc = {};
  if (! isempty (Aineq = varargin{3}))
    bineq = varargin{4};
    o.inequc = {-Aineq.', bineq};
  endif
  if (! isempty (Aeq = varargin{5}))
    beq = varargin{6};
    o.equc = {-Aeq.', beq};
  endif
  if (! isempty (nonlcon))
    o.inequc{end + 1} = @ (varargin) - out_1_wrapper (nonlcon, varargin{:});
    o.equc{end + 1} = @ (varargin) - out_2_wrapper (nonlcon, varargin{:});
    if (strcmp (o.GradConstr, "on"))
      o.inequc{end + 1} = @ (varargin) - out_3_wrapper (nonlcon, varargin{:});
      o.equc{end + 1} = @ (varargin) - out_4_wrapper (nonlcon, varargin{:});
    endif
  endif

  [o, f] = __process_constraints__ (o, f);

  o.np = numel (pin);
  o.plabels = num2cell (num2cell ((1:o.np).'));

  ## dimensions of linear constraints, needs o.np
  f = __linear_constraint_dimensions__ (f, o);

  ## some useful vectors
  predef_vectors.zero = zeros (o.np, 1);
  predef_vectors.NA = NA (o.np, 1);
  predef_vectors.Inf = Inf (o.np, 1);
  predef_vectors.negInf = - predef_vectors.Inf;
  predef_vectors.false = false (o.np, 1);
  predef_vectors.true = true (o.np, 1);
  predef_vectors.sizevec = [o.np, 1];

  ## collect parameter-related configuration

  ## list of parameter related options, 1st column option name, 2nd
  ## column field name of default vector, 3rd column <expand
  ## scalar?>, 4th column <expand vector?>
  prel_opts = { ...
                "lbound", "negInf", false, true;
                "ubound", "Inf", false, true;
                "max_fract_change", "NA", false, false;
                "fract_prec", "NA", false, false;
                "diffp", "NA", true, false;
                "TypicalX", "NA", true, false;
                "FinDiffRelStep", "NA", true, false;
                "diff_onesided", "false", true, false;
              };

  ## use supplied configuration vectors
  o = __apply_param_config_vectors__ (o, prel_opts, predef_vectors);

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
    o.diff_onesided(:) = FinDiffType_onesided;
  endif
  if (! (isempty (o.FinDiffRelStep) || all (isna (o.FinDiffRelStep))))
    o.diffp(o.diff_onesided) = o.FinDiffRelStep(o.diff_onesided);
    o.diffp(! o.diff_onesided) = o.FinDiffRelStep(! o.diff_onesided) / 2;
  endif


  ## note this stage
  f.possibly_pstruct_f_genicstr = f.f_genicstr;
  f.possibly_pstruct_f_genecstr = f.f_genecstr;

  ## bind objective function argument to standard gradient function;
  ## in other frontends, it must not be done until objective function
  ## is adapted, if necessary, to structure-based parameters
  if (! dfdp_specified)
    f.dfdp = @ (p, hook) f.dfdp (p, f.objf, hook);
  endif

  #### some further values and checks

  if (any (o.diffp <= 0))
    error ("some elements of 'diffp' non-positive");
  endif

  if ((hook.TolFun = optimget (settings, "TolFun", stol_default)) < 0)
    error ("'TolFun' negative");
  endif

  #### supplement constants to jacobian functions

  fnames = {"dfdp", "df_genicstr", "df_genecstr"};
  pstruct = false (1, 3);
  o.jac_fixed = predef_vectors.false;
  ## 1st column fieldname of value passed to __jacobian_constants__,
  ## 2nd column fieldname of value passed to jacobian functions
  jac_scalar_parconf_names = ...
  { ...
    "diffp", "diffp";
    "TypicalX", "TypicalX";
    "diff_onesided", "diff_onesided";
    "lbound", "lbound";
    "ubound", "ubound";
  };
  f = __jacobian_constants__ (o, f, fnames, pstruct,
                              jac_scalar_parconf_names, false);

  #### prepare interface hook

  ## interfaces to constraints
  o.nonfixed = predef_vectors.true;  
  [o, f, hook] = __constraints_interface__ (o, f, pin, hook);

  ## passed values of constraints for initial parameters
  hook.pin_cstr = o.pin_cstr;

  ## passed function for gradient of objective function
  hook.dfdp = f.dfdp;

  ## passed function for hessian of objective function
  hook.hessian = f.hessian;

  ## passed function for complementary pivoting
  hook.cpiv = @ cpiv_bard;

  ## passed options
  hook.max_fract_change = o.max_fract_change;
  hook.fract_prec = o.fract_prec;
  ## hook.TolFun = ; # set before
  ## hook.MaxIter = ; # set before
  hook.user_interaction = o.user_interaction;
  hook.MaxIter = o.MaxIter;
  hook.Display = o.Display;
  hook.TolX = o.TolX;
  hook.fixed = predef_vectors.false;
  hook.octave_sqp_tolerance = [];

  ## for simplicity, unconditionally reset __dfdp__
  __dfdp__ ("reset");

  #### call backend

  [p, objf, cvg, outp] = backend (f.objf, pin, hook);

  if (ps_orig(2) > 1)

    p = reshape (p, ps_orig);

  endif

  if (isargout (4))

    constr = f.f_cstr (p, true (numel (f.vc) + o.n_gencstr, 1));

    if (isempty (constr))
      outp.constrviolation = [];
    else
      tp = 0;
      if (! isempty (inequc = constr(! o.eq_idx)))
        tp = max (tp, max (- inequc));
      endif
      if (! isempty (equc = constr(o.eq_idx)))
        tp = max (tp, max (abs (equc)));
      endif
      outp.constrviolation = tp;
    endif

  endif

endfunction

function backend = map_matlab_algorithm_names (backend)

  switch (backend)
    case {"interior-point", "sqp", "sqp-legacy"}
      backend = "lm_feasible";
    case {"active-set"}
      backend = "octave_sqp";
  endswitch

endfunction

function [backend, path_bounds] = map_backend (backend)

  switch (backend)
    case "lm_feasible"
      backend = "__lm_feasible__";
      path_bounds = true;
    case "octave_sqp"
      backend = "__octave_sqp_wrapper__";
      path_bounds = false;
    otherwise
      error ("this fmincon has no backend for algorithm '%s'", backend);
  endswitch

  backend = str2func (backend);

endfunction

function out = out_1_wrapper (fcn, varargin)

  out = fcn (varargin{:});

endfunction

function out = out_2_wrapper (fcn, varargin)

  [~, out] = fcn (varargin{:});

endfunction

function out = out_3_wrapper (fcn, varargin)

  [~, ~, out] = fcn (varargin{:});

endfunction

function out = out_4_wrapper (fcn, varargin)

  [~, ~, ~, out] = fcn (varargin{:});

endfunction

function [stop, info] = output_fcn_wrapper (fcn, varargin)

  stop = fcn (varargin{:});

  info = [];

endfunction

%!demo
%! ## Example for default optimization (Levenberg/Marquardt with
%! ## BFGS), one non-linear equality constraint. Constrained optimum is
%! ## at p = [0; 1].
%! objective_function = @ (p) p(1)^2 + p(2)^2;
%! pin = [-2; 5];
%! constraint_function = @ (p) - (p(1)^2 + 1 - p(2));
%! [p, objf, cvg, outp] = fmincon (objective_function, pin, [], [], [], [], [], [], @ (p) {[], constraint_function(p)}{:})

%!test
%! ## equality constraint
%! objective_function = @ (p) p(1)^2 + p(2)^2;
%! pin = [-2; 5];
%! constraint_function = @ (p) - (p(1)^2 + 1 - p(2));
%! [p, objf, cvg, outp] = fmincon (objective_function, pin, [], [], [], [], [], [], @ (p) {[], constraint_function(p)}{:}, optimset ("Algorithm", "lm_feasible"));
%! assert (p, [0; 1], 1e-6)

%!test
%! ## inequality constraint
%! objective_function = @ (p) p(1)^2 + p(2)^2;
%! pin = [2; 6];
%! constraint_function = @ (p) p(1)^2 + 1 - p(2);
%! [p, objf, cvg, outp] = fmincon (objective_function, pin, [], [], [], [], [], [], @ (p) {constraint_function(p), []}{:}, optimset ("Algorithm", "lm_feasible"));
%! assert (p, [0; 1], 1e-6)

%!test
%! ## independents
%! indep = 1:5;
%! ## objective function:
%! f = @ (p) sumsq (p(1) * exp (p(2) * indep) - [1, 2, 4, 7, 14]);
%! ## initial values:
%! init = [.25; .25];
%! ## linear constraints, A * parametervector + B >= 0
%! A = [1, -1]; B = 0; # p(1) >= p(2);
%!
%! assert (fmincon (f, init, -A, B), [.6203; .6203], .0001);

%!test
%! ## problem structure
%! indep = 1:5;
%! problem = struct ("objective",
%!                   @ (p) sumsq (p(1) * exp (p(2) * indep) - [1, 2, 4, 7, 14]),
%!                   "x0", [.25; .25],
%!                   "Aineq", [-1, 1],
%!                   "bineq", 0,
%!                   "solver", "fmincon");
%! assert (fmincon (problem), [.6203; .6203], .0001);

%!test
%! ## Octave sqp solver with a lot of inequality constraints
%! objf = @ (p) sumsq (p(4:9));
%! init = [300; -100; -.1997; -127; -151; 379; 421; 460; 426];
%! lbound = [-Inf; -Inf; -Inf; 0; 0; 0; 0; 0; 0];
%! inequc = @ (p) vertcat ( ...
%!                         p(1) + p(2) * exp (-5 * p(3)) + p(4) - 127,
%!                         p(1) + p(2) * exp (-3 * p(3)) + p(5) - 151,
%!                         p(1) + p(2) * exp (-p(3)) + p(6) - 379,
%!                         p(1) + p(2) * exp (p(3)) + p(7) - 421,
%!                         p(1) + p(2) * exp (3 * p(3)) + p(8) - 460,
%!                         p(1) + p(2) * exp (5 * p(3)) + p(9) - 426,
%!                         -p(1) - p(2) * exp (-5 * p(3)) + p(4) + 127,
%!                         -p(1) - p(2) * exp (-3 * p(3)) + p(5) + 151,
%!                         -p(1) - p(2) * exp (-p(3)) + p(6) + 379,
%!                         -p(1) - p(2) * exp (p(3)) + p(7) + 421,
%!                         -p(1) - p(2) * exp (3 * p(3)) + p(8) + 460,
%!                         -p(1) - p(2) * exp (5 * p(3)) + p(9) + 426);
%! [p, objf, cvg, outp] = fmincon (objf, init, [], [], [], [], lbound, [],
%!                                 @ (p) {- inequc(p), []}{:},
%!                                 optimset ("Algorithm", "octave_sqp"));
%! assert (p, [5.2330e+02; -1.5694e+02; -1.9966e-01; 2.9607e+01;
%!             8.6615e+01; 4.7326e+01; 2.6235e+01; 2.2915e+01;
%!             3.9470e+01], .01);


%!test
%! ## Same as above with re-ordered parameters to test bound vectors
%! ## with less elements than parameters.
%! objf = @ (p) sumsq (p(1:6));
%! init = [-127; -151; 379; 421; 460; 426; 300; -100; -.1997];
%! lbound = [0; 0; 0; 0; 0; 0];
%! inequc = @ (p) vertcat ( ...
%!                         p(7) + p(8) * exp (-5 * p(9)) + p(1) - 127,
%!                         p(7) + p(8) * exp (-3 * p(9)) + p(2) - 151,
%!                         p(7) + p(8) * exp (-p(9)) + p(3) - 379,
%!                         p(7) + p(8) * exp (p(9)) + p(4) - 421,
%!                         p(7) + p(8) * exp (3 * p(9)) + p(5) - 460,
%!                         p(7) + p(8) * exp (5 * p(9)) + p(6) - 426,
%!                         -p(7) - p(8) * exp (-5 * p(9)) + p(1) + 127,
%!                         -p(7) - p(8) * exp (-3 * p(9)) + p(2) + 151,
%!                         -p(7) - p(8) * exp (-p(9)) + p(3) + 379,
%!                         -p(7) - p(8) * exp (p(9)) + p(4) + 421,
%!                         -p(7) - p(8) * exp (3 * p(9)) + p(5) + 460,
%!                         -p(7) - p(8) * exp (5 * p(9)) + p(6) + 426);
%! [p, objf, cvg, outp] = fmincon (objf, init, [], [], [], [], lbound, [],
%!                                 @ (p) {- inequc(p), []}{:},
%!                                 optimset ("Algorithm", "octave_sqp"));
%! assert (p, [2.9607e+01; 8.6615e+01; 4.7326e+01; 2.6235e+01;
%!             2.2915e+01; 3.9470e+01; 5.2330e+02; -1.5694e+02;
%!             -1.9966e-01], .01);
