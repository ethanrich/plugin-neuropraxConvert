## Copyright (C) 2000 Etienne Grossmann <etienne@egdn.net>
## Copyright (C) 2012-2019 Olaf Till <i7tiol@t-online.de>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## s = tars (foo,bar, ... ) == struct ("foo",foo,"bar",bar,...)
##
## Groups foo, bar, ... into a struct whose fields are "foo", "bar" ...
## and such that s.foo == foo, s.bar == bar ...  
##
## See also : untar

function s = tars (varargin)

  ## cell2struct() probably couldn't be used here without preparations
  ## that use a loop, too, or which are unsafe

  for id = 1:nargin

    s.(deblank (inputname (id))) = varargin{id};

  endfor

endfunction

%!shared s, x, y, z
%! x = 2;
%! y = 3;
%! z = "foo";
%! s = tars (x, y, z);
%!assert ({s.x s.y s.z}, {x y z});
