## Copyright (C) 2010-2019 Olaf Till <i7tiol@t-online.de>
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

function f = __jacobian_constants__ (o, f, fnames, pstruct,
                                     scalar_names, assign_fixed)


  n_names = rows (scalar_names);
  ## fieldnames in argument 'o'
  names_o = scalar_names(:, 1);
  ## fieldnames passed to jacobian functions
  names_j = scalar_names(:, 2);

  ## prepare parameter-related configuration for jacobian functions
  if (any (pstruct))

    s_opts = cell (1, n_names);

    if(o.pnonscalar)

      for id = 1:n_names

        s_opts{id} = ...
        cell2struct ...
	  (cellfun (@ reshape, mat2cell (o.(names_o{id}), o.ppartidx),
		    o.param_dims, "UniformOutput", false),
           o.param_order, 1);

      endfor

      s_fixed = ...
      cell2struct ...
	(cellfun (@ reshape, mat2cell (o.jac_fixed, o.ppartidx),
		  o.param_dims, "UniformOutput", false),
         o.param_order, 1);

      s_plabels = cell2struct ...
	            (num2cell ...
	               (horzcat ...
                          (cellfun ...
		             (@ (x) cellfun ...
		                (@ reshape, mat2cell (cat (1, x{:}),
                                                      o.ppartidx),
		                 o.param_dims, "UniformOutput", false),
		              num2cell (o.plabels, 1),
                              "UniformOutput", false){:}), 2),
	             o.param_order, 1);

    else
      for id = 1:n_names
        s_opts{id} = ...
        cell2struct (num2cell (o.(names_o{id})), o.param_order, 1);
      endfor
      s_fixed = ...
      cell2struct (num2cell (o.jac_fixed), o.param_order, 1);
      s_plabels = cell2struct (num2cell (o.plabels, 2), o.param_order, 1);
    endif

  endif

  if (! all (pstruct))

    v_opts = fields2cell (o, names_o);

  endif

  for id = 1 : numel (fnames)

    fname = fnames{id};
    f_pstruct = pstruct(id);

    if (f_pstruct)

      if (assign_fixed)
        f.(fname) = ...
        @ (p, varargin) ...
          f.(fname) (p, varargin{1:end-1},
                     cell2fields ...
                       ({s_opts{:}, s_plabels, ...
                         cell2fields(num2cell(varargin{end}.fixed),
                                     o.param_order(o.nonfixed), 1,
                                     s_fixed), ...
                         o.cstep, o.parallel_local, ...
                         o.parallel_net, true},
                        {names_j{:}, "plabels", "fixed", ...
                         "h", "parallel_local", "parallel_net", ...
                         "__check_first_call__"},
                        2, varargin{end}));
      else
        f.(fname) = ...
        @ (p, varargin) ...
          f.(fname) (p, varargin{1:end-1},
                     cell2fields ...
                       ({s_opts{:}, s_plabels, ...
                         s_fixed, ...
                         o.cstep, o.parallel_local, ...
                         o.parallel_net, true},
                        {names_j{:}, "plabels", "fixed", ...
                         "h", "parallel_local", "parallel_net", ...
                         "__check_first_call__"},
                        2, varargin{end}));
      endif

    else

      if (assign_fixed)
        f.(fname) = ...
        @ (p, varargin) ...
          f.(fname) (p, varargin{1:end-1},
                     cell2fields ...
                       ({v_opts{:}, o.plabels, ...
                         assign(o.jac_fixed, o.nonfixed,
                                varargin{end}.fixed), ...
                         o.cstep, o.parallel_local, ...
                         o.parallel_net, true},
                        {names_j{:}, "plabels", "fixed", ...
                         "h", "parallel_local", "parallel_net", ...
                         "__check_first_call__"},
                        2, varargin{end}));
      else
        f.(fname) = ...
        @ (p, varargin) ...
          f.(fname) (p, varargin{1:end-1},
                     cell2fields ...
                       ({v_opts{:}, o.plabels, ...
                         o.jac_fixed, ...
                         o.cstep, o.parallel_local, ...
                         o.parallel_net, true},
                        {names_j{:}, "plabels", "fixed", ...
                         "h", "parallel_local", "parallel_net", ...
                         "__check_first_call__"},
                        2, varargin{end}));
      endif

    endif

  endfor

endfunction

function lval = assign (lval, lidx, rval)

  lval(lidx) = rval;

endfunction
