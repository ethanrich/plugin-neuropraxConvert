%% Copyright (C) 2014, 2016-2017, 2019, 2022 Colin B. Macdonald
%% Copyright (C) 2020 Mike Miller
%% Copyright (C) 2020 Fernando Alvarruiz
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
%% @defun mat_rclist_asgn (@var{A}, @var{r}, @var{c}, @var{B})
%% Private helper routine for sym array assigment using lists.
%%
%% @code{(R(i),C(i))} specify entries of the matrix @var{A}.
%% We execute @code{A(R(i),C(i)) = B(i)}.
%%
%% Notes:
%% @itemize
%% @item  @var{B} is accessed with linear indexing.
%% @item  @var{B} might be a scalar, used many times.
%% @item  @var{A} might need to get bigger, if so it will be padded
%%        with zeros.
%% @end itemize
%%
%% @end defun


function z = mat_rclist_asgn(A, r, c, B)

  if (isempty (r) && isempty (c) && (isempty (B) || isscalar (B)))
    z = A;
    return
  end

  if ~( isvector(r) && isvector(c) && (length(r) == length(c)) )
    error('this routine is for a list of rows and cols');
  end

  if ((numel(B) == 1) && (numel(r) > 1))
    B = repmat(B, size(r));
  end
  if (length(r) ~= numel(B))
    error('not enough/too much in B')
  end

  % Easy trick to copy A into larger matrix AA:
  %    AA = sp.Matrix.zeros(n, m)
  %    AA[0, 0] = A
  % Also usefil: .copyin_matrix

  cmd = { '(A, r, c, B) = _ins'
          '# B linear access fix, transpose for sympy row-based'
          'if B is None or not B.is_Matrix:'
          '    B = sp.Matrix([[B]])'
          'BT = B.T'
          '# make a resized copy of A, and copy existing stuff in'
          'if isinstance(A, list):'
          '    assert len(A) == 0, "unexpectedly non-empty list: report bug!"'
          '    n = max(max(r) + 1, 1)'
          '    m = max(max(c) + 1, 1)'
          '    AA = [[0]*m for i in range(n)]'
          'elif A is None or not isinstance(A, MatrixBase):'
          '    # we have non-matrix, put in top-left'
          '    n = max(max(r) + 1, 1)'
          '    m = max(max(c) + 1, 1)'
          '    AA = [[0]*m for i in range(n)]'
          '    AA[0][0] = A'
          'else:'
          '    # build bigger matrix'
          '    n = max(max(r) + 1, A.rows)'
          '    m = max(max(c) + 1, A.cols)'
          '    AA = [[0]*m for i in range(n)]'
          '    # copy current matrix in'
          '    for i in range(A.rows):'
          '        for j in range(A.cols):'
          '            AA[i][j] = A[i, j]'
          '# now insert the new bits from B'
          'for i, (r, c) in enumerate(zip(r, c)):'
          '    AA[r][c] = BT[i]'
          'return sp.Matrix(AA),' };

  rr = num2cell(int32(r-1));
  cc = num2cell(int32(c-1));
  z = pycall_sympy__ (cmd, A, rr, cc, B);

  % a simpler earlier version, but only for scalar r,c
  %cmd = { '(A, r, c, b) = _ins'
  %        'if not A.is_Matrix:'
  %        '    A = sp.Matrix([[A]])'
  %        'AA = sp.Matrix.zeros(max(r+1, A.rows), max(c+1, A.cols))'
  %        'AA[0, 0] = A'
  %        'AA[r, c] = b'
  %        'return AA,' };
end
