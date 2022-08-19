function resu = df_mapper(func, df, varargin)
  %# resu = df_mapper(func, df)
  %# small interface to iterate some func over the elements of a dataframe.

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
  
  resu = df_allmeta(df);
  resu.x_data = cellfun(@(x) feval(func, x, varargin{:}), df.x_data, ...
                       'UniformOutput', false);
  resu.x_rep = df.x_rep; %# things didn't change
  resu.x_type = cellfun(@(x) class(x(1)), resu.x_data, 'UniformOutput', false);

  resu = df_thirddim(resu);

end
