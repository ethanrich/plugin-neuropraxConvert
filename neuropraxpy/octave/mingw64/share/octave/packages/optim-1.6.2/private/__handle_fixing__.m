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

function [o, f, backend] = __handle_fixing__ ...
                             (o, f, pin, funs, opts, backend, linconstr)

  persistent is_gradient = struct ("objf", false,
                                   "f", false,
                                   "f_genicstr", false,
                                   "f_genecstr", false,
                                   "hessian", false,
                                   "dfdp", true,
                                   "df_genicstr", true,
                                   "df_genecstr", true);

  persistent is_hessian = struct ("objf", false,
                                  "f", false,
                                  "f_genicstr", false,
                                  "f_genecstr", false,
                                  "hessian", true,
                                  "dfdp", false,
                                  "df_genicstr", false,
                                  "df_genecstr", false);

  if (is_function_handle (backend))
    backend = @ (f, pin, hook) ...
	        backend_wrapper (backend, o.fixed, f, pin, hook);
  endif

  for id = 1 : numel (funs)

    fun = funs{id};

    if (! isempty (f.(fun)))
      if (is_gradient.(fun))
        f.(fun) = @ (p, varargin) ...
                    f.(fun) (assign (pin, o.nonfixed, p),
                             varargin{:})(:, o.nonfixed);
      elseif (is_hessian.(fun))
        f.(fun) = @ (p, varargin) ...
                    f.(fun) (assign (pin, o.nonfixed, p),
                             varargin{:})(o.nonfixed, o.nonfixed);
      else
        f.(fun) = @ (p, varargin) ...
                    f.(fun) (assign (pin, o.nonfixed, p), varargin{:});
      endif
    endif

  endfor

  if (linconstr)

    ## linear inequality constraints
    f.ivc += f.imc(o.fixed, :).' * (tp = pin(o.fixed));
    f.imc = f.imc(o.nonfixed, :);

    ## linear equality constraints
    f.evc += f.emc(o.fixed, :).' * tp;
    f.emc = f.emc(o.nonfixed, :);

  endif

  ## last of all, because o.fixed may be changed by it
  for id = 1 : numel (opts)

    opt = opts{id};

    o.(opt) = o.(opt)(o.nonfixed, :);

  endfor

endfunction

function lval = assign (lval, lidx, rval)

  lval(lidx) = rval;

endfunction

function [p, resid, cvg, outp] = backend_wrapper (backend, fixed, f, p, hook)

  [tp, resid, cvg, outp] = backend (f, p(! fixed), hook);

  p(! fixed) = tp;

endfunction
