function [a, b] = df_strjust(a, b)
  
  %# small auxiliary function: make two char arrays the same width

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
  
  indi = size (a, 2) - size (b, 2);
  if (indi < 0)
    a = horzcat (repmat (' ', size (a, 1), -indi), a);
  elseif indi > 0,
    b = horzcat (repmat (' ', size (b, 1), indi), b);
  end

end
