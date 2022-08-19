## Copyright (C) 2013-2021 Philip Nienhuis <prnienhuis at users.sf.net>
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
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} @var{filename} = rsearchfile (@var{dname}, @var{fname})
## @deftypefnx {Function File} @var{filename} = rsearchfile (@var{dname}, @var{fname}, @var{maxdepth})
## Recursively search for file or filename pattern FNAME starting in directory
## DNAME and return the first match.
##
## @var{dname} and @var{fname} must be character strings and should conform
## to the directory name and filename requirements of your operating system.
## Optional argument @var{maxdepth} can be specified to limit the maximum search
## depth; the default value is 1 (search only in @var{dname} and subdirs of
## @var{dname}). Setting maxdepth to 0 limits the search to @var{dname}.
## Be careful with setting @var{maxdepth} to values > 3 or 4 as this can
## provoke excessive search times in densely populated directory trees.
## Keep in mind that rfsearch is a recursive function itself.
##
## Output argument @var{filename} returns the relative file path of the
## first match, relative to @var{DNAME}, or an empty character string if
## no match was found.
##
## Examples:
##
## @example
## filename = rfsearch ("/home/guest/octave", "test.fil")
## Look for file test.fil and start the search in /home/guest/octave
## @end example
##
## @example
## filename = rfsearch ("/home", "test.fil", 2)
## Look for file test.fil, start the search in /home, and if needed
## search subdirs of subdirs of /home
## @end example
##
## @seealso {dir, glob}
##
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2013-08-20

function [ fpath ] = rfsearch (dname, fname, mxdpth=1, depth=0)

  ## Input validation
  if (nargin < 2)
    print_usage ()
  elseif ((! ischar (dname)) || (! ischar (fname)))
    error ("rfsearch: character arguments expected for DNAME and FNAME\n");
  elseif (! isnumeric (mxdpth))
    error ("rfsearch: numeric value >= 0 expected for MAXDEPTH\n");
  elseif (mxdpth < 0)
    warning ("rfsearch: negative value for MAXDEPTH (%d) set to 0\n", mxdpth);
    mxdpth = 0;
  elseif (! isnumeric (depth))
    print_usage ("too many or illegal arguments");
  endif

  ## If present strip trailing filesep of dname (doesn't hurt though).
  ## Preserve root /
  if (length (dname) > 1 && strcmp (dname(min(2, end)), filesep))
    dname(end:end) = '';
  endif

  sbdir = '';

  fpath = dir ([dname filesep fname '*']);
  if (isempty (fpath) && depth < mxdpth)
    ## Bump search depth
    ++depth;

    ## Get list of subdirs in current level
    dirlist = dir (dname);
    if (! isempty (dirlist))
      dirlist = dirlist(find ([dirlist.isdir]));
      ii = 0;
      if (strcmp (dirlist(1).name, '.'))
        ## Not a root dir; discard entries '.' & '..'
        ii = 2;
      endif
      fpath = '';

      ## Search all subdirs in current level
      while (++ii <= numel (dirlist) && isempty (fpath))
        sbdir = [filesep dirlist(ii).name];
        fpath = dir ([dname sbdir filesep fname '*']);
        if (isempty (fpath) && depth < mxdpth)
          ## Try a level deeper, if allowed. Be sure to convey current depth
          ## as 'find_in_subdir' is called recursively here
          fpath = rfsearch ([dname sbdir], fname, mxdpth, depth);
        endif
      endwhile
    endif
  endif

  ## Final parts
  if (isempty (fpath))
    fpath = '';
  else
    if (isstruct (fpath))
      fpath = fpath.name;
    endif
    ## Combine and strip leading filesep
    fpath = [sbdir filesep fpath](2:end);
  endif

endfunction ## rfsearch
