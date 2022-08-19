function resu = df_colmeta(df)

  %# function resu = df_colmeta(df)
  %# Returns a new dataframe, initalised with the meta-information
  %# about columns from the source, but with empty data

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
  
  resu = dataframe ();

  resu.x_cnt(2) = df.x_cnt(2);
  resu.x_name{2} = df.x_name{2};
  resu.x_over{2} = df.x_over{2};
  resu.x_type = df.x_type;

  if (~isempty (df.x_ridx))
    if (size (df.x_ridx, 2) >= resu.x_cnt(2)),
      resu.x_ridx = df.x_ridx(1, :, :);
    else
      resu.x_ridx = df.x_ridx(1, 1, :);
    end
  end
    
  %# init it with the right orientation
  resu.x_data = cell (size (df.x_data));
  resu.x_rep = cell (size (df.x_rep));
  resu.x_src  = df.x_src;
  resu.x_cmt  = df.x_cmt;

end
