%% Copyright (C) 2014, 2016, 2019, 2022 Colin B. Macdonald
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
%% @deftypemethod  @@sym {[@var{Q}, @var{R}] =} qr (@var{A})
%% @deftypemethodx @@sym {[@var{Q}, @var{R}] =} qr (@var{A}, 0)
%% @deftypemethodx @@sym {@var{R} =} qr (@var{A})
%% Symbolic QR factorization of a matrix.
%%
%% Example:
%% @example
%% @group
%% A = sym([1 1; 1 0]);
%%
%% [Q, R] = qr (A)
%%   @result{} Q = (sym 2×2 matrix)
%%
%%       ⎡√2   √2 ⎤
%%       ⎢──   ── ⎥
%%       ⎢2    2  ⎥
%%       ⎢        ⎥
%%       ⎢√2  -√2 ⎥
%%       ⎢──  ────⎥
%%       ⎣2    2  ⎦
%%
%%   @result{} R = (sym 2×2 matrix)
%%
%%       ⎡    √2⎤
%%       ⎢√2  ──⎥
%%       ⎢    2 ⎥
%%       ⎢      ⎥
%%       ⎢    √2⎥
%%       ⎢0   ──⎥
%%       ⎣    2 ⎦
%% @end group
%% @end example
%%
%% Passing an extra argument of @code{0} gives an ``economy-sized''
%% factorization.  This is currently the default behaviour even without
%% the extra argument.  In fact the result may even more minimal than
%% the double precision @ref{qr}; when the input has low rank, a
%% rectangular rank-revealing result is returned:
%% @example
%% @group
%% @c doctest: +SKIP_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.7.1")'))
%% [Q, R] = qr (sym ([6 2; 6 2]))
%%   @result{} Q = (sym 2×1 matrix)
%%       ⎡√2⎤
%%       ⎢──⎥
%%       ⎢2 ⎥
%%       ⎢  ⎥
%%       ⎢√2⎥
%%       ⎢──⎥
%%       ⎣2 ⎦
%%   @result{} R = (sym) [6⋅√2  2⋅√2]  (1×2 matrix)
%% @end group
%% @end example
%% We have one column in @code{Q} because the original matrix had
%% rank one:
%% @example
%% @group
%% @c doctest: +SKIP_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.7.1")'))
%% Q*R
%%   @result{} ans = (sym 2×2 matrix)
%%       ⎡6  2⎤
%%       ⎢    ⎥
%%       ⎣6  2⎦
%% @end group
%% @end example
%%
%% But what of the extreme case of a zero matrix?
%% @example
%% @group
%% @c doctest: +SKIP_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.7.1")'))
%% [Q, R] = qr (sym (zeros (2, 2)))
%%   @result{} Q = (sym) []  (empty 2×0 matrix)
%%   @result{} R = (sym) []  (empty 0×2 matrix)
%% @end group
%% @group
%% @c doctest: +SKIP_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.7.1")'))
%% Q*R
%%   @result{} ans = (sym 2×2 matrix)
%%       ⎡0  0⎤
%%       ⎢    ⎥
%%       ⎣0  0⎦
%% @end group
%% @end example
%% Magic?  Not really but don't let anyone tell you the dimensions
%% of empty matrices are unimportant!
%%
%% @seealso{qr, @@sym/lu}
%% @end deftypemethod


function [varargout] = qr(A, ord)

  if (nargin == 2)
    assert (ord == 0, 'OctSymPy:NotImplemented', 'Matrix "B" form not implemented')
  elseif (nargin ~= 1)
    print_usage ();
  end

  if (nargout == 3)
    error ('OctSymPy:NotImplemented', 'permutation output form not implemented')
  end

  %% TODO: sympy QR routine could be improved, as of 2019:
  % * does not give permutation matrix
  % * probably numerically unstable for Float matrices

  cmd = { 'A = _ins[0]' ...
          'if not A.is_Matrix:' ...
          '    A = sp.Matrix([A])' ...
          '(Q, R) = A.QRdecomposition()' ...
          'return (Q, R)' };

  [Q, R] = pycall_sympy__ (cmd, sym(A));

  if (nargout <= 1)
    varargout{1} = R;
  else
    varargout{1} = Q;
    varargout{2} = R;
  end
end


%!error qr (sym(1), 2, 3)

%!error <not implemented> [Q, R, P] = qr (sym(1))
%!error <not implemented> qr (sym(1), 1)

%!test
%! % scalar
%! [q, r] = qr(sym(6));
%! assert (isequal (q, sym(1)))
%! assert (isequal (r, sym(6)))

%!test
%! syms x positive
%! [q, r] = qr(x);
%! assert (isequal (q*r, x))
%! assert (isequal (q, sym(1)))
%! assert (isequal (r, x))

%!test
%! % trickier if x could be zero, fails on 1.8 <= SymPy <= 1.10.1
%! syms x
%! [q, r] = qr(x);
%! if (pycall_sympy__ ('return Version(spver) > Version("1.10.1")'))
%! assert (isequal (q*r, x))
%! end

%!test
%! A = [1 2; 3 4];
%! B = sym(A);
%! [Q, R] = qr(B);
%! assert (isequal (Q*R, B))
%! assert (isequal (R(2,1), sym(0)))
%! assert (isequal (Q(:,1)'*Q(:,2), sym(0)))
%! %[QA, RA] = qr(A)
%! %assert ( max(max(double(Q)-QA)) <= 10*eps)
%! %assert ( max(max(double(Q)-QA)) <= 10*eps)

%!test
%! % non square: tall skinny
%! A = sym([1 2; 3 4; 5 6]);
%! [Q, R] = qr (A, 0);
%! assert (size (Q), [3 2])
%! assert (size (R), [2 2])
%! assert (isequal (Q*R, A))

%!test
%! % non square: short fat
%! A = sym([1 2 3; 4 5 6]);
%! [Q, R] = qr (A);
%! assert (isequal (Q*R, A))

%!test
%! % non square: short fat, rank deficient
%! A = sym([1 2 3; 2 4 6]);
%! [Q, R] = qr (A);
%! assert (isequal (Q*R, A))
%! A = sym([1 2 3; 2 4 6; 0 0 0]);
%! [Q, R] = qr (A);
%! assert (isequal (Q*R, A))

%!test
%! % rank deficient
%! A = sym([1 2 3; 2 4 6; 0 0 0]);
%! [Q, R] = qr (A);
%! assert (isequal (Q*R, A))
%! A = sym([1 2 3; 2 5 6; 0 0 0]);
%! [Q, R] = qr (A);
%! assert (isequal (Q*R, A))

%!test
%! % single return value R not Q
%! assert (isequal (qr (sym(4)), sym(4)))
