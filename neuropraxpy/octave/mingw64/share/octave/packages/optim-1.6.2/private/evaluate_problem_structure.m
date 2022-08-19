## Copyright (C) 2018-2019 Olaf Till <i7tiol@t-online.de>
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

function ret = evaluate_problem_structure (problem, fields)

  ## 'fields' is a cell with 'problem' field names for corresponding
  ## positional arguments. An entry of 'fields' is itself cell, with
  ## the first entry saing if this argument is obligatory and the next
  ## entries being strings of synonymous fields.

  for id = 1 : numel (fields)

    arg = fields{id};

    obligatory = arg{1};

    arg = arg(2:end);

    applied = [];
    
    for aid = 1 : numel (arg)

      if (isfield (problem, arg{aid}))

        if (! isempty (applied)
            && ! isequal (val, problem.(arg{aid})))
          error ("In the given problem structure, fields %s and %s have the same meaning but a different value.",
                 applied, arg{aid});
        endif

        applied = arg{aid};

        val = problem.(applied);

      endif

    endfor

    if (isempty (applied))

      if (obligatory)
        error ("problem structure must have the field(s) %s",
               get_fields_string (arg));
      endif

    else

      ret{id} = val;

    endif

  endfor

endfunction

function s = get_fields_string (c)

  s = c{1};

  if (numel (c) > 1)
    s = cstrcat (s, sprintf (" or %s", c{2:end}));
  endif

endfunction
