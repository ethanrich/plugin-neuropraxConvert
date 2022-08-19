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

## -*- texinfo -*-
## @deftypefn {Built-in Function} {[@var{v1}, @dots{}] =} getfields (@var{s}, 'k1', @dots{})
##
## It is equivalent to [@var{s}.k1, @dots{}]
## Return selected values from a scalar struct. Provides some
## compatibility and some flexibility.
## @seealso{setfields,rmfield,isfield,isstruct,struct}
## @end deftypefn

function [varargout] = getfields (s, varargin)

  if (! all (isfield (s, varargin)))
    error ("getfields: some fields not present");
  endif

  if (all (size (s) <= 1))
    varargout = fields2cell (s, varargin);
  else
    error ("getfields: structure must be scalar or empty");
  endif

endfunction

%!assert (getfields (struct ("key", "value"), "key"), "value");

%!shared s, x, y, z, oo
%! s = struct ("hello", 1, "world", 2);
%!assert (getfields (s, "hello"), s.hello);
%!assert (getfields (s, "world"), s.world);
%!
%! x = 2;
%! y = 3;
%! z = "foo";
%! s = tars (x, y, z);
%!assert (nthargout (1:3, @getfields, s, "x" , "y" ,"z"), {x y z});
%!assert (nthargout (1:3, @getfields, s, "x" , "z" ,"z"), {x z z});
%!
%!fail ('getfields (s, "foo")')
