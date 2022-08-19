## Copyright (C) 2016 Parsiad Azimzadeh <parsiad.azimzadeh@gmail.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU Lesser General Public License as published by the Free
## Software Foundation; either version 3 of the License, or (at your option) any
## later version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
## for more details.
##
## You should have received a copy of the GNU Lesser General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {[@var{NVARS}] =}  (@dots{})
## Attempts to infer and return the number of state variables from optional SDE
## arguments.
##
## @end deftypefn

function NVARS = sdenvars (varargin)

  if (mod (nargin, 2) == 1)
    error ("sde: optional arguments must be specified in key-value pairs");
  endif

  NVARS = 0;
  for i = 1:length(varargin)/2
    key = varargin{2*i-1};
    value = varargin{2*i};
    if (! (ischar (key) && isvector (key)))
      continue;
    endif
    switch (key)
      case "StartState"
        if (isreal (value))
          NVARS = size (value, 1);
        endif
    endswitch
  endfor

  if (NVARS <= 0)
    error ("sde: unable to infer NVARS; you must specify the StartState option as a nonempty vector or matrix");
  endif

endfunction

