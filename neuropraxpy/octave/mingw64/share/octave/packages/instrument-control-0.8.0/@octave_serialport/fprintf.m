## Copyright (C) 2019-2021 John Donoghue <john.donoghue@ieee.org>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{numbytes} =} fprintf (@var{obj}, @var{template} ...)
## Writes formatted string @var{template} using optional parameters to 
## serialport instrument
##
## @subsubheading Inputs
## @var{obj} is a serialport object.@*
## @var{template} Format template string 
##
## @subsubheading Outputs
## @var{numbytes} - number of bytes written to the serial device.
##
## @end deftypefn

function numbytes = fprintf (varargin)

  defaultformat = '%s\n';

  if (nargin < 2)
    print_usage ();
  elseif (nargin < 3)
    formargs = varargin(2);
    format = defaultformat;
  else
    formargs = varargin(3:nargin);
    format = varargin{2};
  endif

  if (! ( ischar (format)))
    print_usage ();
  endif

  numbytes = __srlp_write__ (varargin{1}, sprintf (format, formargs{:}));

endfunction
