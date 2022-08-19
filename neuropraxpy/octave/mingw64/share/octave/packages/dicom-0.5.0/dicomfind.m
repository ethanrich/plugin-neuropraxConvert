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
## @deftypefn {} {@var{attrinfo}} = dicomfind(@var{filename}, @var{attribute})
## @deftypefnx {} {@var{attrinfo}} = dicomfind(@var{info}, @var{attribute})
## Find the location and value of an attribute in a dicom file or info structure.
##
## @subsubheading Inputs
## @var{filename} - filename to open.
##
## @var{info} - dicominfo struct.
##
## @var{attribute} - attribute name to find.
##
## @subsubheading Outputs
## @var{attrinfo} - a table with fields Location and Value fior each matched attribute.
##
## @subsubheading Examples
## @example
## filename = file_in_loadpath("imdata/rtstruct.dcm");
##
## info = dicomfind(filename, "ROINumber");
##
## @end example
## @end deftypefn

function data = dicomfind(filename, attributename)
  if ischar(filename) 
    info = dicominfo(filename);
  elseif isstruct(filename)
    info = filename;
  else
    error ("Expected first argument as a filename or dicominfo structure");
  endif

  if !ischar(attributename)
    error ("Expected attribute as a string");
  endif

  data = recurse_dicom_struct(info, "", attributename);
endfunction

function data = recurse_dicom_struct(info, base, name)
  data = struct('Location', [], 'Value', []);

  names = fieldnames(info);
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
      ndata = recurse_dicom_struct(fieldval, nbase, name);
      if !isempty(ndata) && !isempty(ndata.Location)
        #ndata
        if isempty(data.Location)
          data.Location = [ ndata.Location ];
          data.Value = [ ndata.Value ];
        else
          data.Location = [ data.Location; ndata.Location ];
          data.Value = [ data.Value; ndata.Value ];
        endif
      endif
    else
      if strcmp(fieldname, name)
        if isempty(data.Location)
          data.Location = [{nbase}];
          data.Value = [{fieldval}];
        else
          data.Location = [ data.Location; {nbase} ];
          data.Value = [ data.Value; {fieldval} ];
        endif
      endif
    endif
  endfor

endfunction	

%!test
%! filename = file_in_loadpath("imdata/rtstruct.dcm");
%! info = dicomfind(filename, "ROINumber");
%! assert(length(info.Location),4)
%! assert(length(info.Value),4)
%! assert(info.Location{1}, 'StructureSetROISequence.Item_1.ROINumber')

%!test
%! filename = file_in_loadpath("imdata/rtstruct.dcm");
%! dinfo = dicominfo(filename);
%! info = dicomfind(dinfo, "ROINumber");
%! assert(length(info.Location),4)
%! assert(length(info.Value),4)
%! assert(info.Location{1}, 'StructureSetROISequence.Item_1.ROINumber')

