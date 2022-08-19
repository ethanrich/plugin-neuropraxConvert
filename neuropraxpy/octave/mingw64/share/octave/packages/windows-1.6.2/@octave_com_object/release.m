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
## @deftypefn  {} {} release (@var{obj})
## Release the COM object @var{obj} and all of its resources.
##
## @seealso{com_release, delete}
## @end deftypefn

function release (varargin)

  com_release (varargin{:});

endfunction

%!testif HAVE_WINDOWS_H
%! wshell = actxserver ("WScript.Shell");
%! release (wshell);
%! delete (wshell)


