## Copyright (C) 2017-2019 John Donoghue <john.donoghue@ieee.org>
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
## @deftypefn {Function File} {@var{tf} =} iszmq (@var{h})
##
## Determine whether @var{h} is a zeromq socket object.
##
## if @var{h} is a zeromq socket object, returns true, otherwise returns false.
##
## @seealso{zmq_socket}
## @end deftypefn

function tf = iszmq (h)
  if (nargin == 0)
    print_usage ();
  endif

  tf = strcmp(typeinfo(h), "octave_zeromq_socket");
endfunction

%!test assert(iszmq(1), false)

%!test
%! a = zmq_socket (ZMQ_SUB);
%! assert (iszmq (a));
%! zmq_close(a);
