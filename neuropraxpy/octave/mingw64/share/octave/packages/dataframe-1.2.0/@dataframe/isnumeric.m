function resu = isnumeric(df)
  %# function resu = isnumeric(df)
  %# returns true if the dataframe contains only numeric columns

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

  df_is_num  = isnumeric(df.x_data{1});
  df_is_char = ischar(df.x_data{1});
  for indi = df.x_cnt(2):-1:2,
    df_is_num  = df_is_num & isnumeric(df.x_data{indi});
    df_is_char = df_is_char & ischar(df.x_data{indi});
  end
  
  resu = isnumeric(zeros(0, class(sum(cellfun(@(x) zeros(1, class(x(1))),...
                                              df.x_data)))));

end
