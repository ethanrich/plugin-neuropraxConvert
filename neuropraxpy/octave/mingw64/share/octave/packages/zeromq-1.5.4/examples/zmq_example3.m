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
## Example code for a PUB socket server which sends 'weather' updates from random
## zipcodes.

% zeromq package must be installed and loaded to work


% don't buffer output
more off

publisher = zmq_socket (ZMQ_PUB);

rc = zmq_bind (publisher, "tcp://*:5556");
assert (rc);

while (true) 
  % make up some random values 
  zipcode     = 10000 + randi (20);
  temperature = randi (215) - 80;
  relhumidity = randi (50) + 10;

  %  Send message to all subscribers
  update = sprintf ("%05d %d %d", zipcode, temperature, relhumidity);
  fprintf("%s\n", update);
  
  zmq_send (publisher, update);
endwhile

zmq_close (publisher);


%!test 
% % interactive script - nothing to do

