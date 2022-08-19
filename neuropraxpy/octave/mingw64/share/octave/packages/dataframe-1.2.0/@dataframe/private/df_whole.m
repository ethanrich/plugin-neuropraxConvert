function resu = df_whole(df);

  %# function resu = df_whole(df)
  %# Generate a full matrix from a column-compressed version of a dataframe.

  %% Copyright (C) 2009-2017 Pascal Dupuis <cdemills@gmail.com>
  %%
  %% This file is part of the dataframe package for Octave.
  %%
  %% This package is free software; you can redistribute it and/or
  %% modify it under the terms of the GNU General Public
  %% License as published by the Free Software Foundation;
  %% either version 2, or (at your option) any later version.
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
  
  inds = max (cellfun (@length, df.x_rep));

  resu = df.x_data{1}(:, df.x_rep{1});
  if (inds > 1)
    resu = reshape (resu, df.x_cnt(1), 1, []);
    if (1 == size (resu, 3))
      resu = repmat (resu, [1 1 inds]);
    end
  end

  if (df.x_cnt(2) > 1)
    resu = repmat (resu, [1 df.x_cnt(2)]);
    for indi = (2:df.x_cnt(2))
      dummy = df.x_data{indi}(:, df.x_rep{indi});
      if (inds > 1)
        dummy = reshape (dummy, df.x_cnt(1), 1, []);
        if (1 == size (dummy, 3)),
          dummy = repmat (dummy, [1 1 inds]);
        end
      end
      resu(:, indi, :) = dummy;
    end
  end

end
