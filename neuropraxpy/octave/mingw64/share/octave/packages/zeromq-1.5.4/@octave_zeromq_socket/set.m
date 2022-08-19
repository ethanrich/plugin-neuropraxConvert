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
## @deftypefn {Function File} {} get (@var{s}, @var{prop}, @var{value} [, ...])
## set  property @var{prop} to @var{value} from a ZeroMQ socket represented by
## the object @var{s}.
##
## @var{s} is an ZeroMQ socket object returned by the @code{zmq_socket} 
## @var{prop} is a valid ZeroMQ socket property name.
## @var{value} is the value to set the property to.
##
## Multiple @var{prop} @var{value} pairs can be provided at a time.
## @end deftypefn

function output = set (s, varargin)

  if (nargin < 3)
    print_usage ();
  endif

  if ( rem (numel (varargin), 2) != 0)
    error ("@octave_zeromq_socket/set: expecting PROPERTY/VALUE pairs");
  endif

  output = s;

  while (numel (varargin) > 1)
    prop = varargin{1};
    val  = varargin{2};
    varargin(1:2) = [];

    __zmq_properties__ (s, prop, val);
  endwhile

endfunction

%!test
%! a = zmq_socket();
%! id = uint8([ 1, 2, 3 ]);
%! set(a, "identity", id);
%! assert(__zmq_properties__(a, "identity"), id);
%! zmq_close(a);

