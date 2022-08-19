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
## @deftypefn {Function File} {@var{retval} =} __OCT_merge_data__ (@var{input1}, @var{input2})
## Internal function meant for merging existing sheet data and new data
##
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users sf net>
## Created: 2014-01-29

function [rawarr, lims, onr, onc] = __OCT_merge_data__ (rawarr, lims, obj, obj_dims)

  ## C . If required, adapt current data array size to disjoint new data
  if (! isempty (rawarr))
    ## Merge new & current data. Assess where to augment/overwrite current data
    [onr, onc] = size (rawarr);
    if (obj_dims.tr < lims(2, 1))
      ## New data requested above current data. Add rows above current data
      rawarr = [ cell(lims(2, 1) - obj_dims.tr, onc) ; rawarr];
      lims(2, 1) = obj_dims.tr;
    endif
    if (obj_dims.br > lims(2, 2))
      ## New data requested below current data. Add rows below current data
      rawarr = [rawarr ; cell(obj_dims.br - lims(2, 2), onc)];
      lims (2, 2) = obj_dims.br;
    endif
    ## Update number of rawarr rows
    onr = size (rawarr, 1);
    if (obj_dims.lc < lims(1, 1))
      ## New data requested to left of curremnt data; prepend columns
      rawarr = [cell(onr, lims(1, 1) - obj_dims.lc), rawarr];
      lims(1, 1) = obj_dims.lc;
    endif
    if (obj_dims.rc > lims(1, 2))
      ## New data to right of current data; append columns
      rawarr = [rawarr, cell(onr, obj_dims.rc - lims(1, 2))];
      lims(1, 2) = obj_dims.rc;
    endif
    ## Update number of columns
    onc = size (rawarr, 2);

    ## Copy new data into place
    objtr = obj_dims.tr - lims(2, 1) + 1;
    objbr = obj_dims.br - lims(2, 1) + 1;
    objlc = obj_dims.lc - lims(1, 1) + 1;
    objrc = obj_dims.rc - lims(1, 1) + 1;
    rawarr(objtr:objbr, objlc:objrc) = obj; 

  else
    ## New sheet
    lims = [obj_dims.lc, obj_dims.rc; obj_dims.tr, obj_dims.br];
    onc = obj_dims.nc;
    onr = obj_dims.nr;
    rawarr = obj;
  endif


endfunction
