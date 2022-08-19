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

function o = __apply_param_config_structure__ (o, param_list, predefs)

  ## use reshape with explicit dimensions (instead of x(:)) so that
  ## errors are thrown if a configuration item has incorrect number of
  ## elements

  for id = 1 : rows (param_list)

    param = param_list{id, 1};

    label_default = param_list{id, 2};
    ## so that the default vectors need to be constructed only once
    default = predefs.(label_default);

    o.(param) = default;
    if (isfield (o.param_config, param))
      idx = ! fieldempty (o.param_config, param);
      if (o.pnonscalar)
        o.(param)(idx(o.prepidx), 1) = ...
        vertcat (cellfun (@ (x, n) reshape (x, n, 1),
                          {o.param_config(idx).(param)}.',
                          o.cpnel(idx), "UniformOutput", false){:});
      else
        o.(param)(idx, 1) = vertcat (o.param_config.(param));
      endif
      o.(param)(isna (o.(param))) = default(1);
      if (strcmp (label_default, "false") ...
          || strcmp (label_default, "true"))
        o.(param) = logical (o.(param));
      endif
    endif

  endfor

endfunction
