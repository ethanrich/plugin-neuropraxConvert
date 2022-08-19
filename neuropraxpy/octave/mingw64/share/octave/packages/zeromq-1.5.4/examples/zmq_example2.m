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
## Example code for a REP socket server which waits for client commands and sends
## back a response.

% zeromq package must be installed and loaded to work

% don't buffer output
more off

printf ("Connecting to hello world server...\n");

% create reply socket, and bind it to port 5555
responder = zmq_socket (ZMQ_REP);

zmq_bind (responder, "tcp://*:5555");
  
printf ("Waiting for clients ...\n");
  
% loop forever, waiting for client requests and responding back  
while (true)
  recievedata = zmq_recv (responder, 10, 0);
  printf ("Received Hello\n");
  zmq_send (responder, "World", 5, 0);
endwhile

%!test 
% % interactive script - nothing to do

