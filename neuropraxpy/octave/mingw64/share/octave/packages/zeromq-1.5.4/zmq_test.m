## Copyright (C) 2016-2018 John Donoghue
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
## @deftypefn  {Command} {} zmq_test
##
## Perform zeromq Octave tests to exercise the oct file functionality.
##
## @end deftypefn

function zmq_test ()
  test ( "zmq_test", "verbose" );
endfunction

%!assert(!isempty(ZMQ_SUB))
%!assert(!isempty(ZMQ_PUB))
%!assert(!isempty(ZMQ_PULL))
%!assert(!isempty(ZMQ_PUSH))
%!assert(!isempty(ZMQ_REQ))
%!assert(!isempty(ZMQ_REP))

%!test
%! server = zmq_socket(ZMQ_PUB);
%! assert (!isempty(server));
%! zmq_close (server);

%!xtest
%! server = zmq_socket(ZMQ_PUB);
%! assert (!isempty(server));
%! assert(zmq_bind( server, "tcp://*:8071"))
%! client = zmq_socket(ZMQ_SUB);
%! assert (!isempty(client));
%! assert(zmq_connect( client, "tcp://127.0.0.1:8071"))
%! zmq_setsockopt(client, ZMQ_SUBSCRIBE, "");
%! pause (2)
%! assert(zmq_send (server, uint8([104 101 108 108 111])), 5);
%! assert(zmq_recv (client, 10), uint8([104 101 108 108 111]))
%! zmq_close (client);
%! zmq_close (server);

%!test
%! server = zmq_socket(ZMQ_PUB);
%! assert (!isempty(server));
%! zmq_setsockopt(server, ZMQ_IDENTITY, uint8([104 101 108 108 111]));
%! assert(zmq_getsockopt (server, ZMQ_IDENTITY), uint8([104 101 108 108 111]))
%! zmq_close (server);

