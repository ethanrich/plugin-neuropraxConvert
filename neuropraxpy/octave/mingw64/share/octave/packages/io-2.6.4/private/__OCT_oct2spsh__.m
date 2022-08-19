## Copyright (C) 2014-2021 Philip Nienhuis
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
## @deftypefn {Function File} {@var{retval} =} __OCT_oct2spsh__ (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users dot sf dot net>
## Created: 2014-01-24

function [ ods, rstatus ] = __OCT_oct2spsh__ (obj, ods, wsh, crange, spsh_opts)

  ## Analyze data and requested range. Get size of data to write
  [nnr, nnc ] = size (obj);

  if (isempty (crange))
    ## Infer range from data size
    nr = nnr;
    nc = nnc;
    ## Top left corner of range = cell A1
    tr = lc = 1;
  else
    ## Parse requested cell range
    [~, nr, nc, tr, lc] = parse_sp_range (crange);
  endif

  ## First check row size
  if (nnr > nr)
    ## Truncate obj
    obj = obj(1:nr, :);
  elseif (nnr < nr)
    ## Truncate requested range
    nr = nnr;
  endif
  ## Next, column size
  if (nnc > nc)
    ## Truncate obj
    obj = obj(:, 1:nc);
  elseif (nnc < nc)
    ## Truncate requested range
    nc = nnc;
  endif

  obj_dims.tr = tr;
  obj_dims.br = tr + nr - 1;
  obj_dims.nr = nr;
  obj_dims.lc = lc;
  obj_dims.rc = lc + nc - 1;
  obj_dims.nc = nc;

  ## Invoke file type-dependent functions
  if (strcmpi (ods.app, "ods"))
    ## Write to .ods
    [ ods, rstatus ] = __OCT_oct2ods__  (obj, ods, wsh, crange, spsh_opts, obj_dims);

  elseif (strcmpi (ods.app, "xlsx"))
    ## Write to .xlsx
    [ ods, rstatus ] = __OCT_oct2xlsx__ (obj, ods, wsh, crange, spsh_opts, obj_dims);

  elseif (strcmpi (ods.app, "gnumeric"))
    ## Write to .gnumeric
    [ ods, rstatus ] = __OCT_oct2gnm__  (obj, ods, wsh, crange, spsh_opts, obj_dims);

  else
    error ("oct2xls: writing to file type %s not supported by OCT", xls.app);

  endif

endfunction
