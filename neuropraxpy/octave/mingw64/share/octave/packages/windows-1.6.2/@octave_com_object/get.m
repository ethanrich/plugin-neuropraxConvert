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
## @deftypefn  {} {@var{S} =} get (@var{obj})
## @deftypefnx  {} {@var{S} =} get (@var{obj}, @var{propertynames})
## A get override for octave_com_object objects.
##
## When specifying just @var{obj}, the function will return a list of property names in @var{S}.
## When also providing @var{propertynames}, the function return the values of the properties.
##
## @seealso{com_get, get}
## @end deftypefn

function output = get (varargin)

  output = com_get (varargin{:});

endfunction

%!testif HAVE_WINDOWS_H
%! wshell = actxserver ("WScript.Shell");
%! assert(wshell.CurrentDirectory, get(wshell, "CurrentDirectory"));
%! delete (wshell)


