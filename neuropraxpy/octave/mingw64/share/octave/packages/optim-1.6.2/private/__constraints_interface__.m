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

function [o, f, hook] = __constraints_interface__ (o, f, pin, hook)

  pin_fixed = pin(o.nonfixed);

  ## note initial values of linear constraits
  o.pin_cstr.inequ.lin_except_bounds = f.imc.' * pin_fixed + f.ivc;
  o.pin_cstr.equ.lin = f.emc.' * pin_fixed + f.evc;

  ## note number and initial values of general constraints
  if (isempty (f.f_genicstr))
    o.pin_cstr.inequ.gen = [];
    o.n_genicstr = 0;
  else
    o.n_genicstr = length (o.pin_cstr.inequ.gen = f.f_genicstr (pin_fixed));
  endif
  if (isempty (f.f_genecstr))
    o.pin_cstr.equ.gen = [];
    o.n_genecstr = 0;
  else
    o.n_genecstr = length (o.pin_cstr.equ.gen = f.f_genecstr (pin_fixed));
  endif

  ## include bounds into linear inequality constraints
  tp = eye (sum (o.nonfixed));
  lidx = o.lbound != - Inf;
  uidx = o.ubound != Inf;
  f.imc = cat (2, tp(:, lidx), - tp(:, uidx), f.imc);
  f.ivc = cat (1, - o.lbound(lidx, 1), o.ubound(uidx, 1), f.ivc);

  ## concatenate linear inequality and equality constraints
  f.mc = cat (2, f.imc, f.emc);
  f.vc = cat (1, f.ivc, f.evc);
  n_lincstr = rows (f.vc);

  ## concatenate general inequality and equality constraints
  if (o.n_genecstr > 0)
    if (o.n_genicstr > 0)
      nidxi = 1 : o.n_genicstr;
      nidxe = o.n_genicstr + 1 : o.n_genicstr + o.n_genecstr;
      f.f_gencstr = @ (p, idx, varargin) ...
	              cat (1,
	                   f.f_genicstr (p, idx(nidxi), varargin{:}),
	                   f.f_genecstr (p, idx(nidxe), varargin{:}));
      f.df_gencstr = ...
      @ (p, idx, hook) ...
	cat (1,
	     f.df_genicstr (p, @ (p, varargin) ...
			         f.possibly_pstruct_f_genicstr ...
			         (p, idx(nidxi),
                                  varargin{:}),
			    idx(nidxi),
			    setfield (hook, "f",
				      hook.f(nidxi(idx(nidxi))))),
	     f.df_genecstr (p, @ (p, varargin) ...
			         f.possibly_pstruct_f_genecstr ...
			         (p, idx(nidxe), varargin{:}),
			    idx(nidxe),
			    setfield (hook, "f",
				      hook.f(nidxe(idx(nidxe))))));
    else
      f.f_gencstr = f.f_genecstr;
      f.df_gencstr = @ (p, idx, hook) ...
	               f.df_genecstr (p,
		                      @ (p, varargin) ...
		                        f.possibly_pstruct_f_genecstr ...
		                        (p, idx, varargin{:}),
		                      idx,
		                      setfield (hook, "f", hook.f(idx)));
    endif
  else
    f.f_gencstr = f.f_genicstr;
    f.df_gencstr = ...
    @ (p, idx, hook) ...
      f.df_genicstr (p,
		     @ (p, varargin) ...
		       f.possibly_pstruct_f_genicstr (p, idx, varargin{:}),
		     idx,
		     setfield (hook, "f", hook.f(idx)));
  endif    
  o.n_gencstr = o.n_genicstr + o.n_genecstr;

  ## concatenate linear and general constraints, defining the final
  ## function interfaces
  if (o.n_gencstr > 0)
    nidxl = 1:n_lincstr;
    nidxh = n_lincstr + 1 : n_lincstr + o.n_gencstr;
    f.f_cstr = @ (p, idx, varargin) ...
	cat (1,
	     f.mc(:, idx(nidxl)).' * p + f.vc(idx(nidxl), 1),
	     f.f_gencstr (p, idx(nidxh), varargin{:}));
    f.df_cstr = @ (p, idx, hook) ...
	cat (1,
	     f.mc(:, idx(nidxl)).',
	     f.df_gencstr (p, idx(nidxh),
			 setfield (hook, "f",
				   hook.f(nidxh))));
  else
    f.f_cstr = @ (p, idx, varargin) f.mc(:, idx).' * p + f.vc(idx, 1);
    f.df_cstr = @ (p, idx, hook) f.mc(:, idx).';
  endif

  ## define eq_idx (logical index of equality constraints within all
  ## concatenated constraints
  o.eq_idx = false (n_lincstr + o.n_gencstr, 1);
  o.eq_idx(n_lincstr + 1 - rows (f.evc) : n_lincstr) = true;
  n_cstr = n_lincstr + o.n_gencstr;
  o.eq_idx(n_cstr + 1 - o.n_genecstr : n_cstr) = true;

  ## interface to constraints
  hook.mc = f.mc;
  hook.vc = f.vc;
  hook.f_cstr = f.f_cstr;
  hook.df_cstr = f.df_cstr;
  hook.n_gencstr = o.n_gencstr;
  hook.eq_idx = o.eq_idx;
  hook.lbound = o.lbound;
  hook.ubound = o.ubound;

  ## passed values of constraints for initial parameters
  hook.pin_cstr = o.pin_cstr;

endfunction
