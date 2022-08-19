function resu = repmat(df, varargin) 

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

  resu = df; idx = horzcat (varargin{:});
  %# for the second dim, use either 1 either the 3rd one
  dummy = idx;
  if (length (dummy) > 2) 
    dummy(2) = []; 
  else
    dummy(2) = 1;
  end
  %# operate on first  dim 
  if (idx(1) > 1)
    resu = df_mapper (@repmat, df, [idx(1) 1]);
    if (~isempty (df.x_name{1})),
      resu.x_name{1} = feval (@repmat, df.x_name{1}, [idx(1) 1]);
      resu.x_over{1} = feval (@repmat, df.x_over{1}, [idx(1) 1]);
    end
    resu.x_cnt(1) = resu.x_cnt(1) * idx(1);
  end

  if (dummy(2) > 1)
    for indi = (1:resu.x_cnt(2))
      resu.x_rep{indi} = feval (@repmat, resu.x_rep{indi}, [1 dummy(2)]);
    end
  end

  %# operate on ridx 
  resu.x_ridx = feval (@repmat, resu.x_ridx, idx);
  
  %# operate on second dim
  if (length (idx) > 1 && idx(2) > 1)
    resu.x_data    = feval (@repmat, resu.x_data, [1 idx(2)]); 
    resu.x_name{2} = feval (@repmat, df.x_name{2}, [idx(2) 1]);
    resu.x_over{2} = feval (@repmat, df.x_over{2}, [1 idx(2)]);
    resu.x_type    = feval (@repmat, df.x_type, [1 idx(2)]);
    resu.x_cnt(2)  = resu.x_cnt(2) * idx(2);
  end

  resu = df_thirddim (resu);

end
