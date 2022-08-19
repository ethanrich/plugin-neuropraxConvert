## Copyright (C) 2010-2021 Philip Nienhuis
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
## @deftypefn {Function File} [ @var{type-array} ] = spsh_prstype ( @var{iarray}, @var{rowsize}, @var{colsize}, @var{celltypes}, @var{options})
## (Internal function) Return rectangular array with codes for cell types in rectangular input cell array @var{iarray}.
## Codes are contained in input vector in order of Numeric, Boolean, Text, Formula and Empty, resp.
##
## spsh_prstype should not be invoked directly but rather through oct2xls or oct2ods.
##
## Example:
##
## @example
##   typarr = spsh_chkrange (cellarray, nr, nc, ctypes, options);
## @end example
##
## @end deftypefn

## Author: Philip Nienhuis, <prnienhuis@users.sf.net>
## Created: 2010-08-02

function [ typearr ] = spsh_prstype (obj, nrows, ncols, ctype, spsh_opts)

  ## ctype index:
  ## 1 = numeric
  ## 2 = boolean
  ## 3 = text
  ## 4 = formula
  ## 5 = error / NaN / empty

  typearr = ctype(5) * ones (nrows, ncols);   ## type "EMPTY", provisionally
  obj2 = cell (size (obj));                   ## Temporary storage for strings

  txtptr = cellfun ("isclass", obj, "char");  ## type "STRING" replaced by "NUMERIC"
  obj2(txtptr) = obj(txtptr);
  obj(txtptr) = 3;      ;                     ## Save strings in a safe place

  emptr = cellfun ("isempty", obj);
  obj(emptr) = 5;                             ## Set empty cells to EMPTY

  lptr = cellfun ("islogical" , obj);         ## Find logicals...
  obj2(lptr) = obj(lptr);                     ## .. and set them to BOOLEAN

  ptr = ! cellfun ("isfinite", obj);          ## Find NaNs,Infs & set to BLANK
  typearr(ptr) = 5;                           ## FIXME: do we need isfinite ()?
  typearr(! ptr) = 1;                         ## All other cells are now numeric

  obj(txtptr) = obj2(txtptr);                 ## Copy strings back into place
  obj(lptr) = obj2(lptr);                     ## Same for logicals
  obj(emptr) = -1;                            ## Add in a filler value for empty cells

  typearr(txtptr) = 3;                        ## ...and clean up
  typearr(emptr) = 5;                         ## EMPTY
  typearr(lptr) = 2;                          ## BOOLEAN

  if (! spsh_opts.formulas_as_text)
    ## Find formulas (designated by a string starting with "=")
    fptr = cellfun (@(x) ischar (x) && strncmp (x, "=", 1), obj);
    typearr(fptr) = 4;                         ## FORMULA
  endif

endfunction

## FIXME -- reinstate these tests one there if a way is found to test private
##          functions directly
##%!test
##%! tstobj = {1.5, true, []; 'Text1', '=A1+B1', '=SQRT(A1)'; NaN, {}, 0};
##%! typarr = spsh_prstype (tstobj, 3, 3, [1 2 3 4 5], struct ("formulas_as_text", 0));
##%! assert (typarr, [1 2 5; 3 4 4; 5 5 1]);

##%!test
##%! tstobj = {1.5, true, []; 'Text1', '=A1+B1', '=SQRT(A1)'; NaN, {}, 0};
##%! typarr = spsh_prstype (tstobj, 3, 3, [1 2 3 4 5], struct ("formulas_as_text", 1));
##%! assert (typarr, [1 2 5; 3 3 3; 5 5 1]);
