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
## @deftypefn {Function File} {} xmlwrite (@var{fname}, @var{dom})
## @deftypefnx {Function File} {@var{str} =} xmlwrite (@var{dom})
##
## Write an XML DOM document to file @var{fname} or to output string
## @var{str}.
## 
## The @var{dom} argument must be a DOM document object as returned by
## @code{xmlread} function.
##
## Octave does not ship with the necessary Xerces library so you
## should take care of adding the required .jar files to your
## javaclasspath, e.g:
## 
## @example
## @code{javaaddpath ("/path/to/xerces-2_11_0/xercesImpl.jar");}
## @code{javaaddpath ("/path/to/xerces-2_11_0/xml-apis.jar");}
## @end example
##
## xmlwrite will check for Java support and proper xerces Java libraries
## in the javaclasspath until the check passes, or if it is called without
## arguments.  In the latter case it will also return the found xerces
## javaclasspath entries and xerces version to standard output.
## 
## @seealso{xmlread}
## @end deftypefn

function str = xmlwrite (varargin)

  persistent java_ok = [];

  if (nargin < 1)
    ## Reset Java support check results
    java_ok = [];
  endif

  ## Check Java support and support files
  if (isempty (java_ok))
    if (! __have_feature__ ("JAVA"))
      error ("xmlwrite: Octave was built without Java support, exiting");
    elseif (! usejava ("jvm"))
      error ("xmlwrite: no Java JRE or JDK detected, exiting");
    endif
    ## Default verbosity level for Java libs check
    vrbs = 0;
    if (nargin < 1)
      vrbs = 3;
    endif
    ## Check if required Java class libs are in the javaclasspath
    chk = __XMLrw_chk_sprt__ (javaclasspath ("-all"), vrbs);
    if (chk)
      java_ok = 1;
      ## If xmlwrite was called w/o args, return
      if (nargin < 1)
        str = [];
        return
      endif
    else
      java_ok = 0;
      error (["xmlwrite: no xercesImpl.jar and/or xml-apis.jar > v2.11.0 ", ...
              "in javaclasspath"]);
    endif
  endif

  ## Java checks OK; process arguments
  if (nargin == 1)
    dom = varargin{1};
    jos = javaObject ("java.io.StringWriter");
  elseif (nargin == 2)
    dom = varargin{2};
    fname = varargin{1};
    if (! ischar (fname))
      print_usage ();
    endif
    jfile = javaObject ("java.io.File", fname);
    jos = javaObject ("java.io.FileOutputStream", jfile);
  else
    print_usage ();
  endif
  
  ## Check the validity of the DOM document
  unwind_protect
    doc_classes = {"org.apache.xerces.dom.DeferredDocumentImpl", ...
                   "org.apache.xerces.dom.DocumentImpl"};
    if (! any (strcmp (class (dom), doc_classes)))
      error ("xmlwrite: DOM must be a java DOM document object")
    endif

    try
      jfmt = javaObject ("org.apache.xml.serialize.OutputFormat", dom);
      jfmt.setIndenting (1);
      serializer = javaObject ("org.apache.xml.serialize.XMLSerializer", ...
                               jos, jfmt);
    catch
      disp (lasterr ());
      error ("xmlwrite: couldn't load Xerces serializer object")
    end_try_catch

    try
      serializer.serialize (dom);
    catch
      disp (lasterr ());
      error ("xmlwrite: couldn't serialize document")
    end_try_catch
    
    if (nargout > 0 && strcmp (class (jos), "java.io.StringWriter"))
      str = char (jos.toString ());
    else
      str = 1;
    endif
  unwind_protect_cleanup
    jos.close ();
  end_unwind_protect
endfunction


%!demo
%! ## Create a java representation of a DOM document. The document
%! ## object features all the necessary methods to create subelements.
%! doc = javaObject ("org.apache.xerces.dom.DocumentImpl");
%! 
%! ## Create a root node and add it to the document
%! root = doc.createElement ("RootNode");
%! root.setAttribute ("created", datestr (date ()));
%! doc.appendChild (root);
%! 
%! ## Create a child node, append it text data and add it to the
%! ## root children
%! child = doc.createElement ("TextChild");
%! child.setAttribute ("verbose", "yes");
%! child.setAttribute ("useful", "no");
%! txt = doc.createTextNode ("These are text data");
%! child.appendChild (txt);
%! root.appendChild (child);
%! 
%! ## Serialize DOM document to string
%! str = xmlwrite (doc)
