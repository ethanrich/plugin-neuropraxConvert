## Copyright (C) 2018-2019 Olaf Till <i7tiol@t-online.de>
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
## @deftypefn {Function File} __maybe_wrap_struct_based_callbacks__ ()
## Undocumented internal function.
## @end deftypefn

function f = __maybe_wrap_struct_based_callbacks__ (o, f, list)

  sopts = __struct_options__ ();

  for id = 1 : numel (list)

    fn = list{id};

    if (o.(sopts.(fn)))

      switch (fn)
        case {"f", "objf", "f_genicstr", "f_genecstr"}
          f.(fn) = wrap_fun_input (f.(fn), o);
        case {"dfdp", "df_genicstr", "df_genecstr"}
          f.(fn) = wrap_2nd_order_fun (f.(fn), o);
        case {"hessian"}
          f.(fn) = wrap_hessian (f.(fn), o);
        case {"imc"}
          f.imc = wrap_lin_constr (f.imc, f.ivc, o,
                                            "inequality");
        case {"emc"}
          f.emc = wrap_lin_constr (f.emc, f.evc, o,
                                            "equality");
      endswitch

    endif

  endfor

endfunction

function fun = wrap_fun_input (fun, o)

  if (o.pnonscalar)

    fun = @ (p, varargin) ...
            fun (cell2struct ...
                   (cellfun (@ reshape, mat2cell (p, o.ppartidx),
                             o.param_dims, "UniformOutput", false),
                    o.param_order, 1), varargin{:});

  else

    fun = @ (p, varargin) ...
            fun (cell2struct (num2cell (p), o.param_order, 1),
                 varargin{:});

  endif

endfunction

function fun = wrap_2nd_order_fun (fun, o)

  fun = wrap_fun_input (fun, o);

  fun = @ (varargin) horzcat (fields2cell (fun (varargin{:}),
                                           o.param_order){:});

endfunction

function fun = wrap_hessian (fun, o)

  fun = wrap_fun_input (fun, o);

  fun = @ (varargin) hessian_struct2mat (fun (varargin{:}),
                                         o.param_order);

endfunction

function [mc, vc] = wrap_lin_constr (mc, vc, o, context)

  idx = isfield (mc, o.param_order);
  if (rows (fieldnames (mc)) > sum (idx))
    error ("unknown fields in structure of linear %s constraints",
           context);
  endif
  smc = mc;
  mc = zeros (o.np, rows (vc));
  mc(idx(o.prepidx), :) = vertcat (fields2cell (smc,
                                                o.param_order(idx)){:});

endfunction

function m = hessian_struct2mat (s, pord)

  m = cell2mat (fields2cell ...
		(structcat (1, NA, fields2cell (s, pord){:}), pord));

  idx = isna (m);

  m(idx) = (m.')(idx);

endfunction
