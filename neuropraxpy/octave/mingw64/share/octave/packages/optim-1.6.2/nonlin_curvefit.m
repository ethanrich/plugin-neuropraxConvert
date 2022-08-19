## Copyright (C) 2010-2019 Olaf Till <i7tiol@t-online.de>
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
## @deftypefn {Function File} {[@var{p}, @var{fy}, @var{cvg}, @var{outp}] =} nonlin_curvefit (@var{f}, @var{pin}, @var{x}, @var{y})
## @deftypefnx {Function File} {[@var{p}, @var{fy}, @var{cvg}, @var{outp}] =} nonlin_curvefit (@var{f}, @var{pin}, @var{x}, @var{y}, @var{settings})
## Frontend for nonlinear fitting of values, computed by a model
## function, to observed values.
##
## Please refer to the description of @code{nonlin_residmin}. The
## differences to @code{nonlin_residmin} are the additional arguments
## @var{x} (independent values, mostly, but not necessarily, an array of
## the same dimensions or the same number of rows as @var{y}) and
## @var{y} (array of observations), the returned value @var{fy} (final
## guess for observed values) instead of @var{resid}, that the model
## function has a second obligatory argument which will be set to
## @var{x} and is supposed to return guesses for the observations (with
## the same dimensions), and that the possibly user-supplied function
## for the jacobian of the model function has also a second obligatory
## argument which will be set to @var{x}.
##
## @c The following block will be cut out in the package info file.
## @c BEGIN_CUT_TEXINFO
##
## Also, if the setting @code{user_interaction} is given, additional
## information is passed to these functions. Type @code{optim_doc
## ("Common optimization options")} for this setting.
##
## @c END_CUT_TEXINFO
##
## @seealso{nonlin_residmin}
## @end deftypefn

function [p, fy, cvg, outp] = nonlin_curvefit (f, pin, x, y, settings)

  if (nargin == 1)
    p = __nonlin_residmin__ (f);
    return;
  endif

  if (nargin < 4 || nargin > 5)
    print_usage ();
  endif

  if (nargin == 4)
    settings = struct ();
  endif

  f = __maybe_limit_arg_count__ (f, 2, 3);

  if (! isempty (dfdp = optimget (settings, "dfdp")))
    if (ischar (dfdp))
      dfdp = str2func (dfdp);
    endif
    dfdp = __maybe_limit_arg_count__ (dfdp, 2, 3);
    ## settings = optimset \
    ## (settings, "dfdp", @ (p, varargin) dfdp (p, x, varargin{:}));
    settings.dfdp =  @ (p, varargin) dfdp (p, x, varargin{:});
  endif

  if (! isempty (uia = optimget (settings, "user_interaction", {})))
    if (! iscell (uia))
      uia = {uia};
    endif
    uia = cellfun (@ (f_handle) @ (p, v, s) ...
                   f_handle (p, cell2fields ({x, y},
                                             {"model_x", "observations"},
                                             2, v),
                             s),
                   uia(:), "UniformOutput", false);
    settings.user_interaction = uia;
  endif

  [p, fy, cvg, outp] = __nonlin_residmin__ ...
      (@ (p, varargin) f (p, x, varargin{:}), pin, settings,
       struct ("observations", y));

  fy += y;

endfunction

%!demo
%!  ## Example for linear inequality constraints
%!  ## (see also the same example in 'demo nonlin_residmin')
%!
%!  ## independents and observations
%!  indep = 1:5;
%!  obs = [1, 2, 4, 7, 14];
%!  ## model function:
%!  f = @ (p, x) p(1) * exp (p(2) * x);
%!  ## initial values:
%!  init = [.25; .25];
%!  ## linear constraints, A.' * parametervector + B >= 0
%!  A = [1; -1]; B = 0; # p(1) >= p(2);
%!  settings = optimset ("inequc", {A, B});
%!
%!  ## start optimization
%!  [p, model_values, cvg, outp] = nonlin_curvefit (f, init, indep, obs, settings)

%!test
%! t = optim_problems ().curve.schittkowski_327;
%! cp = nonlin_curvefit (@ (p, x) t.f (x, p), t.init_p, t.data.x, t.data.y, optimset ("lbound", t.non_strict_inequc.bounds(:, 1), "ubound", t.non_strict_inequc.bounds(:, 2), "inequc", {t.non_strict_inequc.general}, "dfdp", @ (p, x) t.dfdp (x, p)));
%! assert (cp, t.result.p, [.0001; .001]);
