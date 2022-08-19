## Copyright (C) 2020 John Donoghue
## Based heavily of the on the octave function of same name,
## Copyright (C) 2012-2019 Rik Wehbring
##
## This file is part of Octave.
##
## Octave is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <https://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {} {} methods (@var{obj})
## @deftypefnx {} {@var{mtds} =} methods (@var{obj})
## List the names of the public methods for the object octave_com_object 
## @var{obj}.
##
## When called with no output arguments, @code{methods} prints the list of
## method names to the screen.  Otherwise, the output argument @var{mtds}
## contains the list in a cell array of strings.
##
## @seealso{methods}
## @end deftypefn

function mtds = methods (obj)

  if isa(obj, 'octave_com_object')
    mtds_list = com_invoke (obj);
    # add the class methods
    class_mtds_list = __methods__ ("octave_com_object");
    mtds_list = [mtds_list; class_mtds_list]; 
  else
    mtds_list = __methods__ (obj);
  endif

  if (nargout == 0)
    classname = ifelse (ischar (obj), obj, class (obj));
    printf ("Methods for class %s:\n", classname);
    disp (list_in_columns (mtds_list));
  else
    mtds = mtds_list;
  endif

endfunction

%!testif HAVE_WINDOWS_H
%! wshell = actxserver ("WScript.Shell");
%! mtds = methods(wshell);
%! class_mtds = methods("octave_com_object");
%! assert([com_invoke(wshell); class_mtds], mtds);
%! delete (wshell);

%!testif HAVE_WINDOWS_H
%! mtds = methods ("octave_com_object");
%! assert (mtds{1}, "delete");
