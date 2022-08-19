## Copyright (C) 2018-2022 Philip Nienhuis
## 
## This program is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see
## <https://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {} {@var{retval} =} kmzread (@var{fname}, @dots{})
## Read a compressed Google kmz file and return its contents in a struct.
##
## See 'help kmlread' for more information.
##
## @seealso{kmlread}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2018-05-13

function out = kmzread (fzname, varargin)

  ## Check filename etc.
  [~, fn, ext] = fileparts (fzname);
  if (isempty (ext))
    ext = ".kmz";
    fzname = [fzname ext];
  elseif (! strcmp (lower (ext), ".kmz"))
    error ("kmzread: filename extension should be '.kmz'");
  endif

  ## Unpack into temp directory
  tmpd = tempdir;
  fl = unzip (fzname, tempdir);
  if (isempty (fl{1}))
    ## Unzip failed. Check if a previous unzipped doc.kml file exists and wipe it
    if (unlink ([tempdir filesep "doc.kml"]) == 0)
      ## Yep existed, now try again
      fl = unzip (fzname, tempdir);
    else
      error ("kmzread: couldn't unzip %s", fzname);
    endif
  endif
  flname = [tempdir fl{1}];

  unwind_protect
    ## Read file
    out = kmlread (flname, varargin{:});
  unwind_protect_cleanup
    ## Delete unpacked file
    unlink (flname);
  end_unwind_protect

endfunction
