function resu = ischar(df)
  %# function resu = ischar(df)
  %# This is ischar() operator for a dataframe object.

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
  
  resu = false & true;
  return
  ## %# explicitelly applies the func over the rows                
  ## for indj = (1:df.x_cnt(2))
  ##   resu = resu & ischar (df.x_data(indj));
  ## end
           
end
