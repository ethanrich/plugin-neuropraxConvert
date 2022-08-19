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
## @deftypefn {Function File} {@var{retval} =} __COM_chk_sprt__ (@var{dbug})
## Undocumented internal function
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2014-10-31

function [retval] = __COM_chk_sprt__ (dbug)

  retval = false;
  if (dbug >= 1)
    printf ("Checking Excel/ActiveX/COM... ");
  endif
  try
    app = actxserver ("Excel.application");
    ## If we get here, the call succeeded & COM works.
    xlsinterfaces.COM = 1;
    ## Close Excel to avoid zombie Excel invocation
    app.Quit();
    delete(app);
    if (dbug >= 1)
      printf ("OK.\n\n");
    endif
    retval = true;
  catch
    ## COM not supported
    if (dbug >= 1)
      printf ("not working.\n");
    endif
    ## Check if Windows package is installed and loaded
    pkglist = pkg ("list");
    winpkgind = find (cellfun (@(x) strcmp(x.name, "windows"), pkglist), 1, "first");
    if (! isempty (winpkgind))
      winpkg = pkglist{winpkgind};
      if (winpkg.loaded && dbug)
        printf ("MS-Excel couldn't be started although OF windows is loaded...\n");
      endif
    elseif (dbug >= 1)
      printf ("(OF windows package is required for COM/ActiveX support)\n");
    endif
  end_try_catch

endfunction
