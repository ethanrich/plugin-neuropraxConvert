## Copyright (C) 2021 John Donoghue <john.donoghue@ieee.org>
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
## @deftypefn {Function File} {@var{numbytes} = } write (@var{obj}, @var{data})
## @deftypefnx {Function File} {@var{numbytes} =} write (@var{obj}, @var{data}, @var{datatype})
## Writes @var{data} to TCP instrument
##
## @subsubheading Inputs
## @var{obj} is a TCPclient  object.@*
## @var{data} data to write.@*
## @var{datatype} datatype of data. If not specified, it defaults to "uint8".@*
##
## @subsubheading Outputs
## returns number of bytes written.
## @end deftypefn

function numbytes = write(obj, data, datatype)

  if (nargin < 2)
    print_usage ();
  elseif (nargin < 3)
    datatype = "uint8";
  endif

  switch (datatype)
    case {"string"}
      data = int8 (data);
    case {"char" "schar" "int8"}
      data = int8 (data);
    case {"uchar" "uint8"}
      data = uint8 (data);
    case {"int16" "short"}
      data = int16 (data);
    case {"uint16" "ushort"}
      data = uint16 (data);
    case {"int32" "int"}
      data = int32 (data);
    case {"uint32" "uint"}
      data = uint32 (data);
    case {"long" "int64"}
      data = int64 (data);
    case {"ulong" "uint64"}
      data = uint64 (data);
    case {"single" "float" "float32"}
      data = single (data);
    case {"double" "float64"}
      data = double (data);
    otherwise
      error ("precision not supported");
  endswitch

  numbytes = __tcpclient_write__ (obj, typecast(data,'uint8'));

endfunction
