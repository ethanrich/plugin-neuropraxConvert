## Copyright (C) 2022 John Donoghue <john.donoghue@ieee.org>
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
## @deftypefn {} {@var{info} =} dicomupdate(@var{fileinfo}, @var{attribute}, @var{value})
## @deftypefnx {} {@var{info} =} dicomupdate(@var{info}, @var{attrinfo})
## Update a dicom struct with new values
##
## @subsubheading Inputs
## @var{info} - dicominfo struct.
##
## @var{attribute} - attribute name to find and change value of.
##
## @var{value} - attribute value to set.
##
## @var{attrinfo} - a table with fields Location and Value for each matched attribute to change.
##
## @subsubheading Outputs
## @var{info} - dicominfo struct.
##
## @subsubheading Examples
## @example
## filename = file_in_loadpath("imdata/rtstruct.dcm");
## info = dicominfo(filename);
##
## % update specific values
## finfo = dicomfind(info, "ROINumber");
## finfo.Value@{1@} = 10;
## info = dicomupdate(info, finfo);
## 
## % update all matching
## info = dicomupdate(info, "ROINumber", 100);
##
## @end example
## @end deftypefn

function info = dicomupdate(info, attrname, value=0)

  # if attrname is a char, need find positions
  if ischar(attrname)
    if nargin != 3
      error ("Expected value");
    endif
    attribinfo = dicomfind(info, attrname);
  else
    attribinfo = attrname;
    if nargin != 2
      error ("Unexpected value");
    endif
    if !isfield(attribinfo, "Location") || !isfield(attribinfo, "Value")
      error ("Expected struct to contain Location and Value fields");
    endif
  endif
  for idx=1:size(attribinfo.Location, 1)
     if size(attribinfo.Location, 1) == 1
       loc  = attribinfo.Location;
       if nargin > 2
         val = value;
       else
         val = attribinfo.Value
       endif
     else
       loc = attribinfo.Location{idx};
       if nargin > 2
         val = value;
       else
         val = attribinfo.Value{idx};
       endif
     endif
     # set value in location
     info = recurse_set_dicom_struct(info, "", loc, val);
  endfor

endfunction

function info = recurse_set_dicom_struct(info, base, name, value)

  names = fieldnames(info);

  # TODO: rather than recurse till find, we could traverse down the struct
  for idx = 1:length(names)
    fieldname = names{idx};
    fieldval = info.(fieldname);
    fieldtype = class(fieldval);
    if length(base) == 0
      nbase = fieldname;
    else
      nbase = [base  "." fieldname];
    endif
 
    if strcmp(fieldtype, "struct")
     info.(fieldname) = recurse_set_dicom_struct(fieldval, nbase, name, value);
    else
      if strcmp(nbase, name)
        info.(fieldname) = value;
      endif
    endif
  endfor

endfunction	

%!test
%! filename = file_in_loadpath("imdata/rtstruct.dcm");
%! info = dicominfo(filename);
%! finfo = dicomfind(info, "ROINumber");
%! assert(length(finfo.Location),4);
%! assert(length(finfo.Value),4);
%! assert(finfo.Location{1}, 'StructureSetROISequence.Item_1.ROINumber');
%! assert(finfo.Value{1}, 2);
%! finfo.Value{1} = 10;
%! info = dicomupdate(info, finfo);
%! finfo = dicomfind(info, "ROINumber");
%! assert(finfo.Value{1}, 10);

%!test
%! filename = file_in_loadpath("imdata/rtstruct.dcm");
%! info = dicominfo(filename);
%! finfo = dicomfind(info, "ROINumber");
%! assert(length(finfo.Location),4);
%! assert(length(finfo.Value),4);
%! assert(finfo.Location{1}, 'StructureSetROISequence.Item_1.ROINumber');
%! assert(finfo.Value{1}, 2);
%! info = dicomupdate(info, "ROINumber", 100);
%! finfo = dicomfind(info, "ROINumber");
%! assert(finfo.Value{1}, 100);
%! assert(finfo.Value{2}, 100);
%! assert(finfo.Value{3}, 100);
%! assert(finfo.Value{4}, 100);

