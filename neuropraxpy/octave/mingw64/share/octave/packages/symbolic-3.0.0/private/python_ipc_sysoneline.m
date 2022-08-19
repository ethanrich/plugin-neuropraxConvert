%% Copyright (C) 2014-2018, 2022 Colin B. Macdonald
%% Copyright (C) 2018-2019 Osella Giancarlo
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
%% @deftypefun {[@var{A}, @var{info}] =} python_ipc_sysoneline (@dots{})
%% Private helper function for Python IPC.
%%
%% @var{A} is the resulting object, which might be an error code.
%%
%% @var{info} usually contains diagnostics to help with debugging
%% or error reporting.
%%
%% @code{@var{info}.prelines}: the number of lines of header code
%% before the command starts.
%%
%% @code{@var{info}.raw}: the raw output, for debugging.
%% @end deftypefun

function [A, info] = python_ipc_sysoneline(what, cmd, varargin)

  persistent first_time

  info = [];

  if (strcmp(what, 'reset'))
    show_msg = [];
    A = true;
    return
  end

  if ~(strcmp(what, 'run'))
    error('unsupported command')
  end

  verbose = ~sympref('quiet');

  if (isempty(first_time))
    first_time = true;
  end

  if (verbose && first_time)
    fprintf ('Symbolic pkg v%s: using one-line system() communication with SymPy.\n', ...
             sympref ('version'))
    disp('Warning: this will be *SLOW*.  Every round-trip involves executing a')
    disp('new Python process and many operations involve several round-trips.')
    disp('Warning: "sysoneline" will fail when using very long expressions.')
  end

  newl = sprintf('\n');

  %% Headers
  % embedding the headers in the -c command is too long for
  % Windows.  We have a 8000 char budget, and the header uses all
  % of it.
  mydir = fileparts (mfilename ('fullpath'));
  mydir = strrep ([mydir filesep()], '\', '\\');
  % execfile() only works on python 2
  headers = ['exec(open(\"' mydir 'python_header.py\").read()); '];
  %s = python_header_embed2();
  %headers = ['exec(\"' s '\"); '];


  %% load all the inputs into python as pickles
  s = python_copy_vars_to('_ins', true, varargin{:});
  % extra escaping
  s = myesc(s);
  % join all the cell arrays with escaped newline
  s = strjoin(s, '\\n');
  s1 = ['exec(\"' s '\"); '];

  % The number of lines of code before the command itself (IIRC, all
  % newlines must be escaped so this should always be zero).
  assert(numel(strfind(s1, newl)) == 0);
  info.prelines = 0;

  %% The actual command
  % cmd is a snippet of python code defining a function '_fcn'.
  cmd = [cmd '_outs = _fcn(_ins)'];
  % now we have a snippet of python code that does something
  % with _ins and produces _outs.
  s = myesc(cmd);
  s = strjoin(s, '\\n');
  s2 = ['exec(\"' s '\"); '];


  %% output, or perhaps a thrown error
  s = python_copy_vars_from('_outs');
  s = myesc(s);
  s = strjoin(s, '\\n');
  s3 = ['exec(\"' s '\");'];

  pyexec = sympref('python');
  if (first_time)
    assert_have_python_and_sympy (pyexec)
  end

  bigs = [headers s1 s2 s3];

  %% paste all the commands into the system() command line
  % python -c
  [status,out] = system([pyexec ' -c "' bigs '"']);

  info.raw = out;

  % two blocks if everything worked, one on variable import fail
  ind = strfind(out, '<output_block>');

  if (status ~= 0) && isempty(ind)
    status
    out
    ind
    error('sysoneline ipc: system() call failed!');
  end

  info.raw = out;

  A = extractblock(out(ind(1):end));
  if (ischar(A) && strcmp(A, 'PYTHON: successful variable import'))
    % pass
  elseif (iscell(A) && strcmp(A{1}, 'INTERNAL_PYTHON_ERROR'))
    return
  else
    A
    out
    error('sysoneline ipc: something unexpected happened sending variables to python')
  end

  assert(length(ind) == 2)
  A = extractblock(out(ind(2):end));

  if (first_time)
    first_time = false;
  end
end


function s = myesc(s)

  for i = 1:length(s)
    % order is important here

    % escape quotes twice
    s{i} = strrep(s{i}, '\', '\\\\');

    % dbl-quote is rather special here
    % /" -> ///////" -> ///" -> /" -> "
    s{i} = strrep(s{i}, '"', '\\\"');
    
  if (ispc () && (~isunix ()))
    %Escape sequence for WIN (Octave & Matlab)
    s{i} = strrep(s{i}, '>', '^>');
    s{i} = strrep(s{i}, '<', '^<');
  end



  end
end
