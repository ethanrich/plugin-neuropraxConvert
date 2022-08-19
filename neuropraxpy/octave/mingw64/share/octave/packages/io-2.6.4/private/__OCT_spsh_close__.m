## Copyright (C) 2013-2021 Philip Nienhuis
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
## @deftypefn {Function File} {@var{xls} =} __OCT_spsh_close__ (@var{xls})
## Internal function! do not call directly; close spreadsheet pointer
## struct xls; for native OCT interface just set it to empty.
##
## @end deftypefn

## Author: Philip Nenhuis <prnienhuis at users.sf.net>
## Created: 2013-09-09

function [xls] = __OCT_spsh_close__ (xls, fcn)

  if (isfield (xls, "nfilename"))
    xls.filename = xls.nfilename;
  endif

  ## Check extension and full path to file
  [pth, fname, ext] = fileparts (xls.filename);
  opwd = pwd;
  if (isempty (pth))
    filename = [ opwd filesep xls.filename ];
  else
    filename = make_absolute_filename (xls.filename);
  endif

  ## .ods and.xlsx are both zipped
  if (strcmpi (ext, ".ods") || strcmpi (ext, ".xlsx"))
    if (xls.changed && xls.changed < 3)
      ## Go to temp dir where .ods or .xlsx file has been unzipped
      cd (xls.workbook);
            pause (0.05);
      ## Zip tmp directory into .ods or .xlsx and copy it over original file
      try
        if exist (fullfile (xls.workbook, [fname ".zip"]), "file")
          delete (fullfile (xls.workbook, [fname ".zip"]));
        endif
        [stts, op] = system (sprintf ('zip -q -r "%s" *', [fname ".zip"]));

        if (stts == 0)
          ## Move file from temp folder and rename
          ## This doesn't seem to work well since v. 6.2.0 ...:
          [mvst, msg] = movefile (["." filesep fname ".zip"], filename, "f");
          if (! mvst)
            ## ... but removing ".\" (or ("./") seems to work:
            [mvst, msg] = movefile ([fname ".zip"], filename, "f");
          endif
          if (! mvst)
            ## Still no luck
            error ('%s: Moving file "%s" to "%s" failed with message: "%s"', ...
                   fcn, fullfile (xls.workbook, [fname ".zip"]), filename, msg);
          endif
          xls.changed = 0;
        else
          error ("%s: Zipping xlsx-file failed with error %d\nOutput:\n%s\n", ...
                 fcn, stts, op);
        endif
      catch err
        printf ("%s: could not zip files in %s to %s\n", ...
                fcn, xls.workbook, filename);
        warning (err.message)
        warning (err.stack)
      end_try_catch;
    endif

  elseif (strcmpi (xls.filename(end-8:end), ".gnumeric"))
    ## gnumeric files are gzipped
    try
      status = system (sprintf ('gzip -c -S=gnumeric %s > "%s"', ...
               xls.workbook, filename));
      if (! status)
        ## Delete temporary file
        unlink (xls.workbook);
        xls.changed = 0;
      endif
    catch
      status = 1;
    end_try_catch
    if (status)
      printf ("%s: could not gzip gnumeric contents in %s to %s\n", ...
              fcn, xls.workbook, filename);
    endif
    ## If we get here, all is done for .gnumeric
    cd (opwd);
    return
  endif

  ## Delete tmp file and return to work dir
  cd (opwd);
  if (! xls.changed)
    ## Below is needed for a silent delete of our tmpdir
    confirm_recursive_rmdir (0, "local");
    rmdir (xls.workbook, "s");
  endif

endfunction
