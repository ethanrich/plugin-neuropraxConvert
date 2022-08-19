## Copyright (C) 2016-2018 john donoghue
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## Example code for a REQ socket connected to a server and sending and
## receiving responses.
##
## The example contains comments on the differences between the C API, and the 
## Octave bindings.

% zeromq package must be installed and loaded to work

% don't buffer output
more off

printf ("Connecting to hello world server...\n");

% don't need to create context in octave binding
% % ZeroMQ API: context = zmq_ctx_new ();

% Create socket and connect to server

% since context in internal, a function that requires a context is used
% without specifying the context.
% ZeroMQ API: requester = zmq_socket (context, ZMQ_REQ);
requester = zmq_socket (ZMQ_REQ);
zmq_connect (requester, "tcp://localhost:5555");

for request_nbr = [1:10]
  printf ("Sending Hello %d...\n", request_nbr);

  zmq_send (requester, uint8("Hello"), 5, 0);
  
  % try to read up to 10 bytes of reply data.
  printf ("Waiting for server response %d... (Ctrl-C to exit)\n", request_nbr); 
  % The ZeroMQ API fills a buffer and returns a count of bytes
  % Octave binding returns a buffer of the size received.
  % ZeroMQ API: zmq_recv (requester, buffer, 10, 0);
  received = zmq_recv (requester, 10, 0);
  printf ("Received World %d\n", request_nbr);
endfor
    
zmq_close (requester);
    
% Binding handles context, so don't need to destroy it   
% ZeroMQ API: zmq_ctx_destroy (context);

%!test 
% % interactive script - nothing to do
