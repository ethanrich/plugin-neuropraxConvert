## Copyright (C) 2013-2020 Michael Goffioul <michael.goffioul@swing.be>
##
## This file is part of Octave.
##
## Octave is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <https://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {} {} invoke (@var{obj})
## @deftypefnx  {} {@var{S} =} invoke (@var{obj}, @var{methodname})
## @deftypefnx  {} {@var{S} =} invoke (@var{obj}, @var{methodname}, @var{arg1}, @dots{}, @var{argN})
## Invoke a method on a COM object.
##
## When called with just the single @var{obj}, invoke displays the methods available to the object.
## When called with @var{methodname}, invoke will invoke the method with optional args and return
## the result in @var{S}.
##
## @seealso{com_invoke, methods}
## @end deftypefn

function output = invoke (varargin)

  output = com_invoke (varargin{:});

endfunction

%!testif HAVE_WINDOWS_H
%! wshell = actxserver ("WScript.Shell");
%! assert(invoke(wshell, "CurrentDirectory"), pwd ());
%! % get all methods available for the object
%! assert(!isempty(invoke(wshell)));
%! delete (wshell)

