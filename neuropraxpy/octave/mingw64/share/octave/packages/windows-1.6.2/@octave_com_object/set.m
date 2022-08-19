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
## @deftypefn  {} {@var{S} =} set (@var{obj}, @var{propname}, @var{value})
## A set override for octave_com_object objects.
##
## Call set function on COM object @var{obj} to set property @var{propname} to value @var{value}. Returns any result in @var{S}.
##
## @seealso{com_set}
## @end deftypefn

function output = set (varargin)

  output = com_set (varargin{:});

endfunction

%!testif HAVE_WINDOWS_H
%! wshell = actxserver ("WScript.Shell");
%! currdir = pwd ();
%! set(wshell, "CurrentDirectory", getenv("SYSTEMROOT"));
%! assert(pwd(), getenv("SYSTEMROOT"));
%! cd(currdir);
%! delete (wshell)


