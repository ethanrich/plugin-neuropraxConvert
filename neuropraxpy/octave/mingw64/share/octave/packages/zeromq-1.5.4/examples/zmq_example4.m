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
## Example code for a SUB socket client which subscribes to a 'weather' server 
## for weather updates for zipcode 10001.

% don't buffer output
more off

subscriber = zmq_socket (ZMQ_SUB);
rc = zmq_connect (subscriber, "tcp://localhost:5556");
assert (rc);

%  Subscribe to zipcode, default is NYC, 10001
zipfilter = "10001 ";
rc = zmq_setsockopt (subscriber, ZMQ_SUBSCRIBE, zipfilter);
assert (rc);

%  Process 100 updates
update_nbr = 0;
total_temp = 0;

for update_nbr = 1:100
  string = char( zmq_recv(subscriber, 128) );

  [zipcode, temperature, relhumidity, count, errmsg] = sscanf (string, "%d %d %d", "C");
  
  fprintf ("received a temp for zipcode '%s' of %dF\n", ...
     zipfilter, temperature);

  total_temp += temperature;
endfor

fprintf ("Average temperature for zipcode '%s' was %dF\n", ...
  zipfilter, (total_temp / update_nbr));

zmq_close (subscriber);

%!test 
% % interactive script - nothing to do

