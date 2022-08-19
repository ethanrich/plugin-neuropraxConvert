function [resu, rcond] = inv(df);

  %# function [x, rcond] = inv(df)
  %# Overloaded function computing the inverse of a dataframe. To
  %# succeed, the dataframe must be convertible to an square array. Row
  %# and column meta-information are exchanged.  

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
  
  if (length (df.x_cnt) > 2 || (df.x_cnt(1) ~= df.x_cnt(2)))
    error ('Dataframe is not square');
  end

  %# quick and dirty conversion
  [dummy, rcond] = inv (horzcat (df.x_data{:}));

  resu = df_allmeta(df);
  
  [resu.x_name{2}, resu.x_name{1}] = deal (resu.x_name{1}, resu.x_name{2});
  [resu.x_over{2}, resu.x_over{1}] = deal (resu.x_over{1}, resu.x_over{2});
  if (isempty (resu.x_name{2})),
    resu.x_name{2} = cellstr (repmat('_', resu.x_cnt(2), 1));
    resu.x_over{2} = ones (1, resu.x_cnt(2));
  end
  for indi = (resu.x_cnt(1):-1:1)
    resu.x_data{indi} = dummy(:, indi);
  end
  resu.x_type(:) = class (dummy);
  
end
