%% Copyright (C) 2018-2019 Mike Miller
%% Copyright (C) 2018, 2020-2021 Colin B. Macdonald
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
%% @defun defaultpython ()
%% A string to execute to call a Python interpreter.
%%
%% Distributors/vendors may find this a convenient place to change
%% the default python executable, e.g., to specify "python3.8" or to
%% hardcode a path to a particular executable.
%%
%% End-users can always override this by setting the environment
%% variable @code{PYTHON} as documented in @pxref{sympref}.
%%
%% @end defun

function python = defaultpython ()

  % PEP394 says Python 3 installs should all provide this command
  python = 'python3';

  if (ispc () && (~isunix ()))
    % 2020-03: Python.org installer/Anaconda do not provide python3
    python = 'python';
  end

end
