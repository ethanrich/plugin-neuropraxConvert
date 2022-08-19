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

function [o, f] = __process_constraints__ (o, f)

  [f.imc, f.ivc, f.f_genicstr, f.df_genicstr, o.user_df_genicstr] = ...
      collect_constraints (o.inequc,
			   o.complex_step_derivative_inequc,
                           "inequality constraints");
  [f.emc, f.evc, f.f_genecstr, f.df_genecstr, o.user_df_genecstr] = ...
      collect_constraints (o.equc,
			   o.complex_step_derivative_equc,
                           "equality constraints");

  o.imc_struct = isstruct (f.imc);
  o.emc_struct = isstruct (f.emc);

  ## correct "_pstruct" settings if functions are not supplied, handle
  ## constraint functions not honoring indices
  if (isempty (f.f_genicstr))
    o.f_inequc_pstruct = false;
  elseif (! o.f_inequc_idx)
    f.f_genicstr = @ (p, varargin) apply_idx_if_given ...
        (f.f_genicstr (p, varargin{:}), varargin{:});
  endif
  if (isempty (f.f_genecstr))
    o.f_equc_pstruct = false;
  elseif (! o.f_equc_idx)
    f.f_genecstr = @ (p, varargin) apply_idx_if_given ...
        (f.f_genecstr (p, varargin{:}), varargin{:});
  endif
  if (o.user_df_genicstr)
    if (! o.df_inequc_idx)
      f.df_genicstr = @ (varargin) f.df_genicstr (varargin{:})(varargin{3}, :);
    endif
  else
    o.df_inequc_pstruct = false;
  endif
  if (o.user_df_genecstr)
    if (! o.df_equc_idx)
      f.df_genecstr = @ (varargin) f.df_genecstr (varargin{:})(varargin{3}, :);
    endif
  else
    o.df_equc_pstruct = false;
  endif

endfunction

function [mc, vc, f_gencstr, df_gencstr, user_df] = ...
      collect_constraints (cstr, do_cstep, context)

  mc = vc = f_gencstr = df_gencstr = [];
  user_df = false;

  if (isempty (cstr)) return; endif

  for id = 1 : length (cstr)
    if (ischar (cstr{id}))
      cstr{id} = str2func (cstr{id});
    endif
  endfor

  if (isnumeric (tp = cstr{1}) || isstruct (tp))
    mc = tp;
    vc = cstr{2};
    if ((tp = length (cstr)) > 2)
      f_gencstr = cstr{3};
      if (tp > 3)
	df_gencstr = cstr{4};
	user_df = true;
      endif
    endif
  else
    lid = 0; # no linear constraints
    f_gencstr = cstr{1};
    if ((len = length (cstr)) > 1)
      if (isnumeric (c = cstr{2}) || isstruct (c))
	lid = 2;
      else
	df_gencstr = c;
	user_df = true;
	if (len > 2)
	  lid = 3;
	endif
      endif
    endif
    if (lid)
      mc = cstr{lid};
      vc = cstr{lid + 1};
    endif
  endif

  if (! isempty (f_gencstr))
    if (ischar (f_gencstr))
      f_gencstr = str2func (f_gencstr);
    endif
    if (__max_nargin_optim__ (f_gencstr) < 2)
      f_gencstr = @ (varargin) f_gencstr (varargin{1});
    elseif (__max_nargin_optim__ (f_gencstr) < 3)
      f_gencstr = @ (varargin) f_gencstr (varargin{1:2});
    endif
    f_gencstr = @ (varargin) ...
	tf_gencstr (f_gencstr, varargin{:});

    if (user_df)
      if (do_cstep)
	error ("both complex step derivative chosen and user Jacobian function specified for %s", context);
      endif
      if (ischar (df_gencstr))
	df_gencstr = str2func (df_gencstr);
      endif
      if (__max_nargin_optim__ (df_gencstr) < 2)
        df_gencstr = @ (varargin) df_gencstr (varargin{1});
      elseif (__max_nargin_optim__ (df_gencstr) < 3)
        df_gencstr = @ (varargin) df_gencstr (varargin{1:2});
      endif
      df_gencstr = @ (p, func, idx, hook) ...
	  df_gencstr (p, idx, hook);
    else
      if (do_cstep)
	df_gencstr = @ (p, func, idx, hook) jacobs (p, func, hook);
      else
	df_gencstr = @ (p, func, idx, hook) __dfdp__ (p, func, hook);
      endif
    endif
  endif

endfunction

function ret = tf_gencstr (f, varargin) # varargin: p[, idx[, info]]

  ## necessary since user function f_gencstr might return [] or a row
  ## vector

  if (isempty (ret = f (varargin{:})))
    ret = zeros (0, 1);
  elseif (columns (ret) > 1)
    ret = ret(:);
  endif

endfunction

function ret = apply_idx_if_given  (ret, varargin)

  if (nargin > 1)
    ret = ret(varargin{1});
  endif

endfunction
