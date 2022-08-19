## Copyright (C) 2018-2019 Olaf Till <i7tiol@t-online.de>
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
## along with this program; If not, see <http://www.gnu.org/licenses/>.

function o = __apply_param_config_vectors__ (o, param_list, predefs)

  ## 4th column (expansion of vectors which are to small, ugh) is only
  ## used by fmincon
  if (columns (param_list) == 3)

    param_list = horzcat (param_list,
                          num2cell (false (rows (param_list), 1)));

  endif

  for id = 1 : rows (param_list)

    param = param_list{id, 1};

    label_default = param_list{id, 2};
    ## so that the default vectors need to be constructed only once
    default = predefs.(label_default);

    expand_scalar = param_list{id, 3};

    expand_vector = param_list{id, 4};

    if (isempty (o.(param)))
      o.(param) = default;
    else
      if (any ((psize = size (o.(param))) != predefs.sizevec))
        if (expand_scalar && isscalar (o.(param)))
          tp = predefs.zero;
          tp(:) = o.(param);
          o.(param) = tp;
        elseif (expand_vector
                && psize(2) == 1
                && predefs.sizevec(2) == 1
                && psize(1) < predefs.sizevec(1))
          o.(param)(psize(1) + 1 : predefs.sizevec(1), 1) = default(1);
        else
          error ("%s: wrong dimensions", param);
        endif
      endif
      o.(param)(isna (o.(param))) = default(1);
      if (strcmp (label_default, "false") ...
          || strcmp (label_default, "true"))
        o.(param) = logical (o.(param));
      endif
    endif

  endfor

endfunction
