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
## @deftypefn {Function File} [ @var{node}, @var{s}, @var{e} ] = getxmlnode (@var{xml}, @var{tag})
## @deftypefnx {Function File} [ @var{node}, @var{s}, @var{e} ] = getxmlnode (@var{xml}, @var{tag}, @var{is})
## @deftypefnx {Function File} [ @var{node}, @var{s}, @var{e} ] = getxmlnode (@var{xml}, @var{tag}, @var{is}, @var{contnt})
## Get a string representing the first xml @var{tag} node starting at position
## @var{is} in xml text string @var{xml}, and return start and end indices. If
## @var{is} is omitted it defaults to 1 (start of @var{xml}). If @var{contnt}
## is TRUE, return the portion of the node between the outer tags.
##
## @seealso{getxmlattv}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2013-09-08

function [ node, spos, epos ] = getxmlnode (xml, tag, is=1, contnt=0)

  if (nargin < 2)
    print_usage;
  endif
  if (nargin >= 3 && isempty (is))
    is = 1;
  endif

  ## Input validation
  if (! ischar (xml) || ! ischar (tag))
    error ("getxmlnode: text strings expected for first two args\n");
  elseif (nargin==3 && (! islogical (is) && ! isnumeric (is)))
    error ("getxmlnode: logical or numerical value expected for arg #3\n");
  elseif (nargin==4 && (! islogical (contnt) && ! isnumeric (contnt)))
    error ("getxmlnode: logical or numerical value expected for arg #3\n");
  endif

  is = max (is, 1);

  node = '';
  ## Start tag must end with either />, a space preceding an attribute, or >
  ## Search order is vital as /> (single node) is otherwise easily missed
  spos = regexp (xml(is:end), sprintf ("<%s(/>| |>)", tag), "once");
  if (! isempty (spos))
    ## Apparently a node exists. Get its end. Maybe it is a single node
    ## ending in "/>"
    spos = spos(1);
    [~, epos] = regexp (xml(is+spos:end), sprintf ("(</%s>|%s[^><]*/>)", tag, tag), "once");
    if (! isempty (epos))
      epos = epos(1);
      node = xml(is+spos-1 : is+spos+epos(1)-1);
      if (contnt)
        if (strcmp (node(end-1:end), "/>"))
          ## Single node tag. Return empty string
          node = '';
        else
          ## Get contents between end of opening tag en start of end tag
          node = node(index (node, ">", "first")+1 : index (node, "<", "last")-1);
        endif
      endif
    else
      error ("getxmlnode: couldn't find matching end tag for %s", tag);
    endif
    ## Update position pointers relative to input string
    epos += is + spos - 1;
    spos += is - 1;
  else
    ## No node found; reset pointers
    spos = 0;
    epos = 0;
  endif

endfunction
