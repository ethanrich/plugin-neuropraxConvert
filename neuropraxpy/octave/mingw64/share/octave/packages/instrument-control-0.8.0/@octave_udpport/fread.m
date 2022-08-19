## Copyright (C) 2021 John Donoghue  <john.donoghue@ieee.org>
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
## @deftypefn {Function File} {@var{data} =} fread (@var{obj})
## @deftypefnx {Function File} {@var{data} =} fread (@var{obj}, @var{size})
## @deftypefnx {Function File} {@var{data} =} fread (@var{obj}, @var{size}, @var{precision})
## @deftypefnx {Function File} {[@var{data},@var{count}] =} fread (@var{obj}, ...)
## @deftypefnx {Function File} {[@var{data},@var{count},@var{errmsg}] =} fread (@var{obj}, ...)
## Reads @var{data} from UDP instrument
##
## @subsubheading Inputs
## @var{obj} is a UDP port object.@*
## @var{size} Number of values to read. (Default: 100).@*
## @var{precision} precision of data.@*
##
## @subsubheading Outputs
## @var{data} data values.@*
## @var{count} number of values read.@*
## @var{errmsg} read operation error message.@*
##
## @end deftypefn

function [data, count, errmsg] = fread (obj, size, precision)

  if (nargin < 2)
    ## TODO: InputBufferSize property not implemented yet
    warning("fread: InputBufferSize property not implemented yet, using 100 as default");
    size = 100;
  endif

  if (nargin < 3)
    precision = 'uchar';
  endif

  if ((rows(size) == 1) && (columns(size) == 2))
    toread = size(1) * size(2);
  elseif (numel(size) == 1)
    toread = size;
  else
    print_usage();
  endif

  switch (precision)
    case {"char" "schar" "int8"}
      toclass = "int8";
    case {"uchar" "uint8"}
      toclass = "uint8";
    case {"int16" "short"}
      toclass = "int16";
      toread = toread * 2;
    case {"uint16" "ushort"}
      toclass = "uint16";
      toread = toread * 2;
    case {"int32" "int"}
      toclass = "int32";
      toread = toread * 4;
    case {"uint32" "uint"}
      toclass = "uint32";
      toread = toread * 4;
    case {"long" "int64"}
      toclass = "int64";
      toread = toread * 8;
    case {"ulong" "uint64"}
      toclass = "uint64";
      toread = toread * 8;
    case {"single" "float" "float32"}
      toclass = "single";
      toread = toread * 4;
    case {"double" "float64"}
      toclass = "double";
      toread = toread * 8;
    otherwise
      error ("precision not supported");
  endswitch

  eoi=0; tmp=[]; count=0;
  while ((!eoi) && (toread > 0))
    tmp1 = __udpport_read__ (obj, toread, get(obj, 'Timeout')*1000);
    if !isempty(tmp1)
      wasread = numel(tmp1);
      count = count + wasread;
      toread = toread - wasread;
    else
      break;
    endif
  tmp = [tmp tmp1];
  endwhile

  errmsg = '';

  data = typecast(tmp,toclass);
  if (numel(size) > 1)
    data = reshape(data,size);
  endif

endfunction
