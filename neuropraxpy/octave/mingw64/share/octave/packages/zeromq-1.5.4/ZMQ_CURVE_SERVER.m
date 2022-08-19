## Copyright (C) 2019 John Donoghue
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
## @deftypefn  {Command} {} ZMQ_CURVE_SERVER
##
## Constant for getsockopt and setsockopt CURVE_SERVER value option
##
## @seealso{zmq_getsockopt, zmq_setsockopt}
## @end deftypefn

function v = ZMQ_CURVE_SERVER ()
  v = __ZMQ_OPT_CURVE_SERVER;
endfunction

%!assert (ZMQ_CURVE_SERVER, __ZMQ_OPT_CURVE_SERVER)


