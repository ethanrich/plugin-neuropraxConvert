## Copyright (C) 2018 john donoghue
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
## Example code for a STREAM socket connecting to a HTTP server
## and making a HTTP request

% zeromq package must be installed and loaded to work

% don't buffer output
more off

printf ("Connecting to octave.org ...\n");

% Create socket
sock = zmq_socket (ZMQ_STREAM);

% connect to gnu.org
zmq_connect (sock, "tcp://octave.org:80");

% get socket identity
% NOTE: we MUST get it as zmq uses the identity for the
% first frame to know where to route to
% ZeroMQ API: zmq_socket (sock, ZMQ_IDENTITY, id, idsize);
id = zmq_getsockopt (sock, ZMQ_IDENTITY);

% send request for getting the home page info
% in HTTP would be HEAD / HTTP/1.1\r\n\r\n
printf ("Requesting HEAD / ...\n");

% send id frame first
zmq_send (sock, id, ZMQ_SNDMORE);
% now the content
zmq_send(sock, "HEAD / HTTP/1.1\r\n\r\n");

printf ("Waiting for server response...\n"); 

% zmq will add an identity as the 1st frame back
identity = zmq_recv (sock, 255, 0);
% http request blank line
received = zmq_recv (sock, 255, 0);

% the actual content
identity = zmq_recv (sock, 255, 0);
readmore = zmq_getsockopt (sock, ZMQ_RCVMORE);
while (readmore)
  received = zmq_recv (sock, 1024, 0);
  readmore = zmq_getsockopt (sock, ZMQ_RCVMORE);
  printf ("%s", char(received))
endwhile
printf ("\n");

printf("Closing socket ...\n");
% if was a server, send id frame following by an empty zero frame to
% close the socket
    
zmq_close (sock);

%!test
% % interactive script - nothing to do
