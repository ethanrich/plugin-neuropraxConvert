## Copyright (C) 2016 John Donoghue
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {@var{tf} = } iscom (@var{h})
##
## Determine whether @var{h} is a COM object.
##
## if @var{h} is a COM object, returns true, otherwise returns false.
##
## @seealso{actxserver}
## @end deftypefn


function tf = iscom (h)
  if (nargin == 0)
    print_usage ();
  endif

  tf = strcmp(typeinfo(h), "octave_com_object");
endfunction

%!test assert(iscom(1), false)

%!testif HAVE_WINDOWS_H
%! a = actxserver ("WScript.Shell");
%! assert (iscom (a));
%! delete(a);

