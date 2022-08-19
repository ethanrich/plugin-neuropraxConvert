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
## @deftypefn {Function File} {@var{retval} =} __OTK_chk_sprt__ (@var{varargin})
## Undocumented internal function
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2014-10-31

function [chk, missing5] = __OTK_chk_sprt__ (jcp, dbug=0)

  chk = 0;
  if (dbug > 1)
    printf ("\nODF Toolkit (.ods) <odfdom> <xercesImpl>:\n");
  endif
  entries5 = {"odfdom", "xerces", {"xml-apis", "xml-commons-apis"}}; 
  [jpchk, missing5] = chk_jar_entries (jcp, entries5, dbug);
  missing5 = entries5 (find (missing5));
  ## Check xerces (version 2.9.1 = stand-alone, 2.10.+ needs xml-apis.jar)
  try
    xvsn = javaMethod ("getVersion", "org.apache.xerces.impl.Version");
    if (index (xvsn, "2.9.1") && strncmp (missing5, "xml", 3))
      jpchk++;
    endif
    if (dbug > 2)
      printf ("  xerces version:          %s\n", xvsn);
    endif
  catch
  end_try_catch
  if (jpchk >= numel (entries5))    
    ## Apparently all required classes present. Only now we can check for proper
    ## odfdom version (only 0.7.5 & 0.8.6-0.8.8 work OK).
    ## The odfdom team deemed it necessary to change the version call so we need this:
    odfvsn = " ";
    try
      ## New in 0.8.6
      odfvsn = javaMethod ("getOdfdomVersion", "org.odftoolkit.odfdom.JarManifest");
    catch
      ## Worked in 0.7.5
      odfvsn = javaMethod ("getApplicationVersion", "org.odftoolkit.odfdom.Version");
    end_try_catch
    if (dbug > 2)
      printf ("  odfdom version:          %s\n", odfvsn);
    endif
    ## For odfdom-incubator (= 0.8.8+), strip extra info after version
    odfvsn = regexp (odfvsn, '[0123456789]+\.[0123456789]+\.[01234567890]+', "match"){1};
    if (! (strcmp (odfvsn, "0.7.5") || (compare_versions (odfvsn, "0.8.6", ">=") ...
           && compare_versions (odfvsn, "0.8.8", "<="))))
      chk = -1;
      if (dbug > 1)
        printf ("  *** odfdom version (%s) is not supported - use v. 0.8.6 - 0.8.8\n", ...
                odfvsn);
      endif
    else
      chk = 1;
      if (dbug > 1)
        printf ("  => ODFtoolkit (OTK) OK.\n");
      endif
    endif
  elseif (dbug > 1)
    printf ("  => Not all required classes (.jar) in classpath for OTK\n");
  endif

endfunction
