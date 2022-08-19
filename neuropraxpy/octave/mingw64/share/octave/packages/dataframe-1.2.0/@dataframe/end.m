function resu = end(df, k, n)
  %# function resu = end(df, k, n)
  %# This is the end operator for a dataframe object, returning the
  %# maximum number of rows or columns

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
  
  try
    if k < 3,
      resu = df.x_cnt(k);
    else
      resu =  max(cellfun(@length, df.x_rep));
    end
  catch
    error('incorrect call to end, index greater than number of dimensions');
  end

end
