## Copyright (C) 2022 Olaf Till <i7tiol@t-online.de>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} __maybe_limit_arg_count__ ()
## Undocumented internal function.
## @end deftypefn

function ret_fh = __maybe_limit_arg_count__ (fh, argc_limit, argc_max)

  ## Newer Octave versions throw an error if a user function which
  ## doesn't use 'varargin' is called with more arguments than it
  ## explicitly accepts. This function can be used to avoid this
  ## situation.

  if (__max_nargin_optim__ (fh) < argc_max)

    ret_fh = @(varargin) fh (varargin{1:argc_limit});

  else

    ret_fh = fh;

  endif

endfunction
