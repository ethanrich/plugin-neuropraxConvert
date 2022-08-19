function resu = nth_element(df, n, dim)
  %# function resu = nth_element(x, n, dim)
  %# This is a wrapper for the real nth_element

  %% Copyright (C) 2009-2017 Pascal Dupuis <cdemills@gmail.com>
  %%
  %% This file is part of the dataframe package for Octave.
  %%
  %% This package is free software; you can redistribute it and/or
  %% modify it under the terms of the GNU General Public
  %% License as published by the Free Software Foundation;
  %% either version 3, or (at your option) any later version.
  %%
  %% This package is distributed in the hope that it will be useful,
  %% but WITHOUT ANY WARRANTY; without even the implied
  %% warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
  %% PURPOSE.  See the GNU General Public License for more
  %% details.
  %%
  %% You should have received a copy of the GNU General Public
  %% License along with this package; see the file COPYING.  If not,
  %% see <http://www.gnu.org/licenses/>.
  
  if (~isa (df, 'dataframe'))
    resu = []; return;
  end

  if (nargin < 3)
     %# default: operates on the first non-singleton dimensio
     resu = df.x_cnt;
     dim = find (resu > 1); 
     dim = dim(1);
  end

   switch dim
    case {1}
      resu = df_colmeta (df);
      for indi = (1:df.x_cnt(2))
        resu.x_data{indi} = feval (@nth_element, df.x_data{indi}(:, df.x_rep{indi}), n, dim);
        resu.x_rep{indi} = 1:size (resu.x_data{indi}, 2);
      end
      resu.x_cnt(1) = max (cellfun ('size', resu.x_data, 1));
      if (resu.x_cnt(1) == df.x_cnt(1))
        %# the func was not contracting
        resu.x_ridx = df.x_ridx;
        resu.x_name{1} = resu.x_name{1}; resu.x_over{1} = resu.x_over{1};
      end
    case {2}
      error ('Operation not implemented');
    case {3}
      resu = df_allmeta(df);
      for indi = (1:df.x_cnt(2))
        resu.x_data{indi} = feval (@nth_element, df.x_data{indi}(:, df.x_rep{indi}), n, dim-1);
        resu.x_rep{indi} = 1:size (resu.x_data{indi}, 2);
      end
    otherwise
      error ('Invalid dimension %d', dim); 
  end
  
  resu = df_thirddim (resu);
  
end
