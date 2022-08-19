## Copyright (C) 2015-2021 Pantxo Diribarne
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
## @deftypefn {Function File} {@var{node} =} xmlread (@var{fname})
##
## Parse an xml file @var{fname} using Xerces Java library and return
## a Java object representing an XML DOM document.
##
## Octave does not ship with a Xerces library so you should take care
## of adding the required .jar files to your java_path, e.g:
## 
## @example
## @code{javaaddpath ("/path/to/xerces-2_11_0/xercesImpl.jar");}
## @code{javaaddpath ("/path/to/xerces-2_11_0/xml-apis.jar");}
## @end example
##
## xmlread will check for Java support and proper xerces Java libraries
## in the javaclasspath until the check passes, or if it is called without
## arguments.  In the latter case it will return the found xerces entries
## in the javaclasspath and xerces version to standard output.
##
## @seealso{xmlwrite}
## @end deftypefn

function node = xmlread (fname)

  persistent java_ok = [];

  if (nargin < 1)
    ## Reset Java support check results
    java_ok = [];
  elseif (nargin != 1 || ! ischar (fname))
    print_usage ()
  endif

  ## This is a Java based function
  if (isempty (java_ok))
    if (! __have_feature__ ("JAVA"))
      error ("xmlread: Octave was built without Java support, exiting");
    elseif (! usejava ("jvm"))
      error ("xmlread: no Java JRE or JDK detected, exiting");
    endif
    ## Default verbosity for Java lib search
    vrbs = 0;
    if (nargin < 1)
      vrbs = 3;
    endif
    ## Check if required Java class libs are in the javaclasspath
    chk = __XMLrw_chk_sprt__ (javaclasspath ("-all"), vrbs);
    if (chk)
      java_ok = 1;
      ## If xmlread was called w/o args it means reset .jar search results
      if (nargin < 1)
        node = [];
        return
      endif
    else
      error (["xmlread: no xercesImpl.jar and/or xml-apis.jar > v2.11.0 ", ...
              "in javaclasspath"]);
    endif
  endif

  ## Checks OK, read XML file
  try
    parser = javaObject ("org.apache.xerces.parsers.DOMParser");
  catch
    disp (lasterr ());
    error ("xmlread: couldn't load Xerces parser object");
  end_try_catch

  try
    parser.parse (make_absolute_filename (fname));
    node = parser.getDocument ();
  catch
    disp (lasterr ());
    error ("xmlread: couldn't load and parse \"%s\"", fname);
  end_try_catch
  
endfunction


##%!demo
##%! ## Create an svg file, which is nothing but an xml tree
##%! tk = graphics_toolkit ();
##%! graphics_toolkit ("fltk");
##%! hf = figure ();
##%! sombrero ();
##%! fname = [tempname(), ".svg"];
##%! print (fname);
##%! close (hf)
##%! graphics_toolkit (tk);
##%! 
##%! ## Read the svg file and check the root node is named "svg"
##%! dom = xmlread (fname);
##%! if (dom.hasChildNodes ())
##%!   root_node = dom.getChildNodes ().item (0);
##%!   printf ("The name of the root node is \"%s\"\n", ...
##%!            char (root_node.getNodeName ()))
##%! endif
