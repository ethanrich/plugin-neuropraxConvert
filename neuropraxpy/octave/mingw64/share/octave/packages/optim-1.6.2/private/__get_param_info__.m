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

function [o, f, p] = __get_param_info__ (o, f, p, need_param_order,
                                         param_order_unclear)

  ## some settings require a parameter order
  if (need_param_order)
    if (isempty (o.param_order))
      if (o.p_struct)
	if (param_order_unclear)
	  error ("no parameter order specified and constructing a parameter order from the structure of initial parameters can not be done since not all configuration or given functions are structure based");
	else
	  o.param_order = fieldnames (p);
	endif
      else
	error ("given settings require specification of parameter order or initial parameters in the form of a structure");
      endif
    endif
    o.param_order = o.param_order(:);
    if (o.p_struct && ! all (isfield (p, o.param_order)))
      error ("some initial parameters lacking");
    endif
    if ((nnames = rows (unique (o.param_order))) < rows (o.param_order))
      error ("duplicate parameter names in 'param_order'");
    endif
    if (isempty (o.param_dims))
      if (o.p_struct)
	o.param_dims = cellfun ...
	    (@ size, fields2cell (p, o.param_order), "UniformOutput", false);
      else
	o.param_dims = num2cell (ones (nnames, 2), 2);
      endif
    else
      o.param_dims = o.param_dims(:);
      if (o.p_struct &&
	  ! all (cellfun (@ (x, y) prod (size (x)) == prod (y),
			  struct2cell (p), o.param_dims)))
	error ("given param_dims and dimensions of initial parameters do not match");
      endif
    endif
    if (nnames != rows (o.param_dims))
      error ("lengths of 'param_order' and 'param_dims' not equal");
    endif
    pnel = cellfun (@ prod, o.param_dims);
    o.ppartidx = pnel;
    if (any (pnel > 1))
      o.pnonscalar = true;
      o.cpnel = num2cell (pnel);
      o.prepidx = cat (1, cellfun ...
		     (@ (x, n) x(ones (1, n), 1),
		      num2cell ((1:nnames).'), o.cpnel,
		      "UniformOutput", false){:});
      epord = o.param_order(o.prepidx, 1);
      psubidx = cat (1, cellfun ...
		     (@ (n) (1:n).', o.cpnel,
		      "UniformOutput", false){:});
    else
      o.pnonscalar = false; # some less expensive interfaces later
      o.prepidx = (1:nnames).';
      epord = o.param_order;
      psubidx = ones (nnames, 1);
    endif
  else
    o.param_order = []; # spares checks for given but not needed
  endif

  if (o.p_struct)
    o.np = sum (pnel);
  else
    o.np = length (p);
    if (! isempty (o.param_order) && o.np != sum (pnel))
      error ("number of initial parameters not correct");
    endif
    o.parclass = class (p);
  endif
  ## next is only for the statistics frontend
  if (isnumeric (f.dfdp) && ! isempty (f.dfdp) && o.np == 0)
    o.np = columns (f.dfdp);
  endif

  ## if necessary, convert parameters to vector
  if (o.p_struct)
    if (o.pnonscalar)
      p = cat (1, cellfun (@ (x, n) reshape (x, n, 1),
			     fields2cell (p, o.param_order), o.cpnel,
			     "UniformOutput", false){:});
    else
      p = cat (1, fields2cell (p, o.param_order){:});
    endif
  endif

  ## note class of parameter vector
  o.parclass = class (p);

  o.plabels = num2cell (num2cell ((1:o.np).'));
  if (! isempty (o.param_order))
    o.plabels = cat (2, o.plabels, num2cell (epord),
		   num2cell (num2cell (psubidx)));
  endif

endfunction
