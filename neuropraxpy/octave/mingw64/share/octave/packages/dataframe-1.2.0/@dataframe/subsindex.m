function resu = subsindex(df, base)
  %# function resu = subsindex(df)
  %# This function convert a dataframe to an index. Do not expect a
  %# meaningfull result when mixing numeric and logical columns.

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
  
  if nargin < 2, 
    base = 1.0; 
  else
    base = base - 1.0;
  end
  
  %# extract all values at once
  dummy = df_whole(df); 
  if isa(dummy, 'logical'),
    resu = sort(find(dummy)-base);
    %# resu = dummy - base;
  else
    resu = dummy - base;
  end

end
