%% Copyright (C) 2014-2016, 2018-2019, 2022 Colin B. Macdonald
%% Copyright (C) 2014-2015 Andrés Prieto
%% Copyright (C) 2020 Jing-Chen Peng
%%
%% This file is part of OctSymPy.
%%
%% OctSymPy is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published
%% by the Free Software Foundation; either version 3 of the License,
%% or (at your option) any later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty
%% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
%% the GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.
%% If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @deftypemethod  @@sym {@var{sol} =} dsolve (@var{ode})
%% @deftypemethodx @@sym {@var{sol} =} dsolve (@var{ode}, @var{IC})
%% @deftypemethodx @@sym {@var{sol} =} dsolve (@var{ODEs}, @var{IC1}, @var{IC2}, @dots{})
%% @deftypemethodx @@sym {@var{sol} =} dsolve (@var{ODEs}, @var{ICs})
%% @deftypemethodx @@sym {[@var{sol}, @var{classify}] =} dsolve (@dots{})
%% Solve ordinary differential equations (ODEs) symbolically.
%%
%% Basic example:
%% @example
%% @group
%% syms y(x)
%% DE = diff(y, x) - 4*y == 0
%%   @result{} DE = (sym)
%%                 d
%%       -4⋅y(x) + ──(y(x)) = 0
%%                 dx
%% @end group
%%
%% @group
%% sol = dsolve (DE)
%%   @result{} sol = (sym)
%%           4⋅x
%%       C₁⋅ℯ
%% @end group
%% @end example
%%
%% You can specify initial conditions:
%% @example
%% @group
%% sol = dsolve (DE, y(0) == 1)
%%   @result{} sol = (sym)
%%        4⋅x
%%       ℯ
%% @end group
%% @end example
%%
%% In some cases, SymPy can return a classification of the
%% differential equation:
%% @example
%% @group
%% DE = diff(y) == y^2
%%   @result{} DE = (sym)
%%       d           2
%%       ──(y(x)) = y (x)
%%       dx
%%
%% [sol, classify] = dsolve (DE, y(0) == 1)
%%   @result{} sol = (sym)
%%        -1
%%       ─────
%%       x - 1
%%   @result{} classify = ... separable ...
%% @end group
%% @end example
%%
%% Many types of ODEs can be solved, including initial-value
%% problems and boundary-value problem:
%% @example
%% @group
%% DE = diff(y, 2) == -9*y
%%   @result{} DE = (sym)
%%          2
%%         d
%%        ───(y(x)) = -9⋅y(x)
%%          2
%%        dx
%%
%% dsolve (DE, y(0) == 1, diff(y)(0) == 12)
%%   @result{} (sym) 4⋅sin(3⋅x) + cos(3⋅x)
%%
%% dsolve (DE, y(0) == 1, y(sym(pi)/2) == 2)
%%   @result{} (sym) -2⋅sin(3⋅x) + cos(3⋅x)
%% @end group
%% @end example
%%
%% Some systems can be solved, including initial-value problems
%% involving linear systems of first order ODEs with constant
%% coefficients:
%% @example
%% @group
%% syms x(t) y(t)
%% ode_sys = [diff(x(t),t) == 2*y(t);  diff(y(t),t) == 2*x(t)]
%%   @result{} ode_sys = (sym 2×1 matrix)
%%       ⎡d                ⎤
%%       ⎢──(x(t)) = 2⋅y(t)⎥
%%       ⎢dt               ⎥
%%       ⎢                 ⎥
%%       ⎢d                ⎥
%%       ⎢──(y(t)) = 2⋅x(t)⎥
%%       ⎣dt               ⎦
%% @end group
%%
%% @group
%% soln = dsolve (ode_sys)
%%   @result{} soln = scalar structure containing ...
%%        x = ...
%%        y = ...
%%
%% @c doctest: +SKIP_IF(pycall_sympy__ ('return Version(spver) <= Version("1.5.1")'))
%% soln.x
%%   @result{} ans =
%%       (sym)
%%               -2⋅t       2⋅t
%%         - C₁⋅ℯ     + C₂⋅ℯ
%%
%% @c doctest: +SKIP_IF(pycall_sympy__ ('return Version(spver) <= Version("1.5.1")'))
%% soln.y
%%   @result{} ans =
%%       (sym)
%%             -2⋅t       2⋅t
%%         C₁⋅ℯ     + C₂⋅ℯ
%% @end group
%% @end example
%%
%% Note: The Symbolic Math Toolbox used to support strings like 'Dy + y = 0'; we
%% are unlikely to support this so you will need to assemble a symbolic
%% equation instead.
%%
%% @seealso{@@sym/diff, @@sym/int, @@sym/solve}
%% @end deftypemethod


function [soln,classify] = dsolve(ode,varargin)

  % Usually we cast to sym in the _cmd call, but want to be
  % careful here b/c of symfuns
  if (~ iscell (ode) && ~ all (isa (ode, 'sym')))
    error('Inputs must be sym or symfun')
  end

  % FIXME: might be nice to expose SymPy's "sp.ode.classify_sysode" and
  %        "sp.ode.classify_ode" with their own commands
  if (isscalar(ode) && nargout==2)
    cmd = { 'from sympy.solvers import classify_ode'
            'return classify_ode(_ins[0]),' };
    classify = pycall_sympy__ (cmd, ode);
  elseif(~isscalar(ode) && nargout==2)
    warning('Classification of systems of ODEs is currently not supported')
    classify='';
  end

  cmd = { 'ode=_ins[0]; ics=_ins[1:]'
          'if len(ics) == 1:'
          '    ics = ics[0]'
          'try:'
          '    ics = {ic.lhs: ic.rhs for ic in ics}'
          'except TypeError:'  % not iterable
          '    ics = {ics.lhs: ics.rhs}'
          'sol = sp.dsolve(ode, ics=ics)'
          'def convert_helper(sympy_obj):'
          '    if isinstance(sympy_obj, Eq) and sympy_obj.lhs.is_Function:'
                   % y(t) = rhs to str "y", rhs expression
          '        return str(sympy_obj.lhs.func), sympy_obj.rhs'
          '    return None, None'
          % if just single equality with simple lhs, we return the rhs
          'if isinstance(sol, Eq):'
          '    if sol.lhs.is_Function:'
          '        return sol.rhs'
          % If the solution set is iterable (system or multiple solutions),
          % we will try to convert to structure of {"x": expr, "y": expr2, ...}
          'try:'
          '    return_data = dict()'
          '    for solution_part in sol:'
          '        key, rhs = convert_helper(solution_part)'
          '        if key is None:'
          '            raise ValueError("not of right form for extraction")'
          '        if key in return_data.keys():'
          '            raise KeyError(f"repeated key {key}")'
          '        return_data[key] = rhs'
          '    return return_data'
          'except (TypeError, ValueError, KeyError):'
          '    pass'
          % if nothing else worked, give back whatever form we have
          'return sol' };
  soln = pycall_sympy__ (cmd, ode, varargin{:});
end


%!error <sym> dsolve (1, sym('x'))

%!test
%! syms y(x)
%! de = diff(y, 2) - 4*y == 0;
%! f = dsolve(de);
%! syms C1 C2
%! g1 = C1*exp(-2*x) + C2*exp(2*x);
%! g2 = C2*exp(-2*x) + C1*exp(2*x);
%! assert (isequal (f, g1) || isequal (f, g2))

%!test
%! % Not enough initial conditions
%! syms y(x) C1
%! de = diff(y, 2) + 4*y == 0;
%! g = 3*cos(2*x) + C1*sin(2*x);
%! try
%!   f = dsolve(de, y(0) == 3);
%!   waserr = false;
%! catch
%!   waserr = true;
%!   expectederr = regexp (lasterr (), 'Perhaps.*under-specified');
%!   f = 42;
%! end
%! assert ((waserr && expectederr) || isequal (f, g))

%!test
%! % Solution in implicit form
%! syms y(x) C1
%! de = (2*x*y(x) - exp(-2*y(x)))*diff(y(x), x) + y(x) == 0;
%! sol = dsolve (de);
%! eqn = x*exp(2*y(x)) - log(y(x)) == C1;
%! % could differ by signs
%! sol = lhs (sol) - rhs (sol);
%! eqn = lhs (eqn) - rhs (eqn);
%! sol2 = subs (sol, C1, -C1);
%! assert (isequal (sol, eqn) || isequal (sol2, eqn))

%%!xtest
%%! % system with solution in implicit form
%%! % TODO: not implemented upstream?
%%! syms y(x) z(x) C1
%%! de1 = (2*x*y(x) - exp(-2*y(x)))*diff(y(x), x) + y(x) == 0;
%%! de2 = diff(z, x) == 0;
%%! sol = dsolve ([de1; de2]);

%!test
%! % Compute solution and classification
%! syms y(x) C1
%! de = (2*x*y(x) - exp(-2*y(x)))*diff(y(x), x) + y(x) == 0;
%! [sol, classy] = dsolve (de);
%! assert (any (strcmp (classy, '1st_exact')))

%!test
%! % initial conditions (first order ode)
%! syms y(x)
%! de = diff(y, x) + 4*y == 0;
%! f = dsolve(de, y(0) == 3);
%! g = 3*exp(-4*x);
%! assert (isequal (f, g))

%!test
%! % initial conditions (second order ode)
%! syms y(x)
%! de = diff(y, 2) + 4*y == 0;
%! f = dsolve(de, y(0) == 3, subs(diff(y,x),x,0)==0);
%! g = 3*cos(2*x);
%! assert (isequal (f, g))

%!test
%! % Dirichlet boundary conditions (second order ode)
%! syms y(x)
%! de = diff(y, 2) + 4*y == 0;
%! f = dsolve(de, y(0) == 2, y(1) == 0);
%! g = -2*sin(2*x)/tan(sym('2'))+2*cos(2*x);
%! assert (isequal (simplify (f - g), 0))

%!test
%! % Neumann boundary conditions (second order ode)
%! syms y(x)
%! de = diff(y, 2) + 4*y == 0;
%! f = dsolve(de, subs(diff(y,x),x,0)==1, subs(diff(y,x),x,1)==0);
%! g = sin(2*x)/2+cos(2*x)/(2*tan(sym('2')));
%! assert (isequal (simplify (f - g), 0))

%!test
%! % Dirichlet-Neumann boundary conditions (second order ode)
%! syms y(x)
%! de = diff(y, 2) + 4*y == 0;
%! f = dsolve(de, y(0) == 3, subs(diff(y,x),x,1)==0);
%! g = 3*sin(2*x)*tan(sym('2'))+3*cos(2*x);
%! assert (isequal (simplify (f - g), 0))

%!test
%! % System of ODEs gives struct, Issue #1003.
%! syms x(t) y(t)
%! ode1 = diff(x(t),t) == 2*y(t);
%! ode2 = diff(y(t),t) == 2*x(t);
%! soln = dsolve([ode1, ode2]);
%! assert (isstruct (soln))
%! assert (numfields (soln) == 2)
%! assert (isequal (sort (fieldnames (soln)), {'x'; 'y'}))

%!test
%! % System of ODEs
%! syms x(t) y(t) C1 C2
%! ode1 = diff(x(t),t) == 2*y(t);
%! ode2 = diff(y(t),t) == 2*x(t);
%! soln = dsolve([ode1, ode2]);
%! soln = [soln.x, soln.y];
%! g1 = [C1*exp(-2*t) + C2*exp(2*t), -C1*exp(-2*t) + C2*exp(2*t)];
%! g2 = [C1*exp(2*t) + C2*exp(-2*t), C1*exp(2*t) - C2*exp(-2*t)];
%! g3 = [-C1*exp(-2*t) + C2*exp(2*t), C1*exp(-2*t) + C2*exp(2*t)];
%! g4 = [C1*exp(2*t) - C2*exp(-2*t), C1*exp(2*t) + C2*exp(-2*t)];
%! % old SymPy <= 1.5.1 had some extra twos
%! g5 = [2*C1*exp(-2*t) + 2*C2*exp(2*t), -2*C1*exp(-2*t) + 2*C2*exp(2*t)];
%! g6 = [2*C1*exp(2*t) + 2*C2*exp(-2*t), 2*C1*exp(2*t) - 2*C2*exp(-2*t)];
%! assert (isequal (soln, g1) || isequal (soln, g2) || ...
%!         isequal (soln, g3) || isequal (soln, g4) || ...
%!         isequal (soln, g5) || isequal (soln, g6))

%!test
%! % System of ODEs (initial-value problem)
%! syms x(t) y(t)
%! ode_1=diff(x(t),t) == 2*y(t);
%! ode_2=diff(y(t),t) == 2*x(t);
%! sol_ivp=dsolve([ode_1,ode_2],x(0)==1,y(0)==0);
%! g_ivp=[exp(-2*t)/2+exp(2*t)/2,-exp(-2*t)/2+exp(2*t)/2];
%! assert (isequal ([sol_ivp.x, sol_ivp.y], g_ivp))

%!test
%! syms y(x)
%! de = diff(y, 2) + 4*y == 0;
%! f = dsolve(de, y(0) == 0, y(sym(pi)/4) == 1);
%! g = sin(2*x);
%! assert (isequal (f, g))

%!test
%! % Nonlinear example
%! syms y(x) C1
%! e = diff(y, x) == y^2;
%! g = -1 / (C1 + x);
%! soln = dsolve(e);
%! assert (isequal (soln, g))

%!test
%! % Nonlinear example with initial condition
%! syms y(x)
%! e = diff(y, x) == y^2;
%! g = -1 / (x - 1);
%! soln = dsolve(e, y(0) == 1);
%! assert (isequal (soln, g))

%!test
%! % forcing, Issue #183, broken in older sympy
%! if (pycall_sympy__ ('return Version(spver) >= Version("1.7.1")'))
%! syms x(t) y(t)
%! ode1 = diff(x) == x + sin(t) + 2;
%! ode2 = diff(y) == y - t - 3;
%! soln = dsolve([ode1 ode2], x(0) == 1, y(0) == 2);
%! X = soln.x;
%! Y = soln.y;
%! assert (isequal (diff(X) - (X + sin(t) + 2), 0))
%! assert (isequal (diff(Y) - (Y - t - 3), 0))
%! end

%!test
%! syms f(x) a b
%! de = diff(f, x) == 4*f;
%! s = dsolve(de, f(a) == b);
%! assert (isequal (subs(s, x, a), b))

%!test
%! % array of ICs
%! syms x(t) y(t)
%! ode_1 = diff (x(t), t) == 2*y(t);
%! ode_2 = diff (y(t), t) == 2*x(t);
%! sol = dsolve([ode_1, ode_2], [x(0)==1 y(0)==0]);
%! g = [exp(-2*t)/2+exp(2*t)/2, -exp(-2*t)/2+exp(2*t)/2];
%! assert (isequal ([sol.x, sol.y], g))

%!test
%! % cell-array of ICs or ODEs, but not both
%! % Note: to support both we'd need a wrapper outside of @sym
%! syms x(t) y(t)
%! ode_1 = diff (x(t), t) == 2*y(t);
%! ode_2 = diff (y(t), t) == 2*x(t);
%! sol = dsolve([ode_1, ode_2], {x(0)==1 y(0)==0});
%! g = [exp(-2*t)/2+exp(2*t)/2, -exp(-2*t)/2+exp(2*t)/2];
%! assert (isequal ([sol.x, sol.y], g))
%! sol = dsolve({ode_1, ode_2}, [x(0)==1 y(0)==0]);
%! g = [exp(-2*t)/2+exp(2*t)/2, -exp(-2*t)/2+exp(2*t)/2];
%! assert (isequal ([sol.x, sol.y], g))

%!test
%! % array of ICs, Issue #1040.
%! if (pycall_sympy__ ('return Version(spver) >= Version("1.7.1")'))
%! syms x(t) y(t) z(t)
%! syms x_0 y_0 z_0
%! diffEqns = [diff(x, t) == -x + 1, diff(y, t) == -y, diff(z, t) == -z];
%! initCond = [x(0) == x_0, y(0) == y_0, z(0) == z_0];
%! soln = dsolve (diffEqns, initCond);
%! soln = [soln.x, soln.y, soln.z];
%! exact_soln = [(x_0 - 1)*exp(-t) + 1  y_0*exp(-t)  z_0*exp(-t)];
%! assert (isequal (soln, exact_soln))
%! end
