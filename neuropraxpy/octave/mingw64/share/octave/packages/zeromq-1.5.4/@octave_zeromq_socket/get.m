## Copyright (C) 2017-2018 John Donoghue
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
## @deftypefn {Function File} {} get (@var{s}, @var{prop})
## @deftypefnx {Function File} {} get (@var{s})
## get  property @var{prop} from a ZeroMQ socket represented by the object @var{s}.
##
## @var{s} is an ZeroMQ socket object returned by the @code{zmq_socket} 
## @var{prop} is a valid ZeroMQ socket property name. If prop is not provided, it 
## will get all properties of @var{s}
## @end deftypefn

function output = get (varargin)

  if (nargin < 1 || nargin > 2)
    print_usage ();
  endif

  output = __zmq_properties__ (varargin{:});

endfunction

%!test
%! server = zmq_socket(ZMQ_PUB);
%! props = get(server);
%! assert(props.type, "ZMQ_PUB")
%!
%! assert(get(server, "type"), "ZMQ_PUB")
%!
%! zmq_close (server);
