## Copyright (C) 2014-2019 Olaf Till <i7tiol@t-online.de>
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

function [p_res, objf, cvg, outp] = __octave_sqp_wrapper__ (f, pin, hook)

  ## clear persisten variables
  select_constr ();
  select_d_constr ();

  n = length (pin);

  ## passed constraints
  mc = hook.mc; # matrix of linear constraints
  vc = hook.vc; # vector of linear constraints
  f_cstr = hook.f_cstr; # function of all constraints
  df_cstr = hook.df_cstr; # function of derivatives of all constraints
  n_gencstr = hook.n_gencstr; # number of non-linear constraints
  eq_idx = hook.eq_idx; # logical index of equality constraints in all
                                # constraints
  lbound = hook.lbound; # bounds, subset of linear inequality
  ubound = hook.ubound; # constraints in mc and vc

  ## passed function for gradient of objective function
  grad_f = hook.dfdp;

  ## passed function for hessian of objective function
  hessian = hook.hessian;

  ## passed options
  tolerance = hook.octave_sqp_tolerance;
  niter = hook.MaxIter;
  fixed = hook.fixed;

  ## some useful variables derived from passed variables
  ##
  n_cstr = size (vc, 1) + n_gencstr; # number of all constraints
  ac_idx = true (n_cstr, 1); # index of all constraints

  ## backend-specific checking of options and constraints
  ##
  ## ...

  ## fill constant fields of hook for derivative-functions; some fields
  ## may be backend-specific
  dfdp_hook.fixed = fixed; # this may be handled by the frontend, but
                                # the backend still may add to it

  ## process arguments for calling sqp
  grad_f = @  (p) grad_f (p, dfdp_hook)(:); # sqp expects column vector
  f_cstr = @ (p) f_cstr (p, ac_idx);
  df_cstr = @ (p) df_cstr (p, ac_idx,
                           setfield (dfdp_hook, "f", f_cstr (p)));
  if (isempty (hessian))
    passed_f = {f, grad_f};
  else
    passed_f = {f, grad_f, hessian};
  endif
  inequc = @ (p) select_constr (f_cstr, p, ! eq_idx);
  dinequc = @ (p) select_d_constr (df_cstr, p, ! eq_idx);
  equc = @ (p) select_constr (f_cstr, p, eq_idx);
  dequc = @ (p) select_d_constr (df_cstr, p, eq_idx);

  ## call sqp
  [p_res, objf, info, outp.niter, outp.nobjf, outp.lambda] = ...
      sqp (pin, passed_f, {equc, dequc}, {inequc, dinequc}, -Inf, Inf,
           niter, tolerance);

  ## map return code
  switch (info)
    case 101
      cvg = 1;
    case 102
      cvg = -4;
    case 103
      cvg = 0;
    case 104
      cvg = 2;
    otherwise
      warning ("return code %i of sqp not recognized", info);
      cvg = NA;
  endswitch

endfunction

function ret = select_constr (cf, p, idx)

  persistent storep = struct ();
  persistent storeret = [];

  if (! nargin ())
    storep = struct ();
    return;
  endif

  if (! isequal (storep, p))
    storep = p;
    storeret = cf (p);
  endif

  ret = storeret(idx);

endfunction

function ret = select_d_constr (dcf, p, idx)

  persistent storep = struct ();
  persistent storeret = [];

  if (! nargin ())
    storep = struct ();
    return;
  endif

  if (! isequal (storep, p))
    storep = p;
    storeret = dcf (p);
  endif

  ret = storeret(idx, :);

endfunction
