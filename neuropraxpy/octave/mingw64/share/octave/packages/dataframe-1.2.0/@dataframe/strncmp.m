function resu = strncmp(A, B, n);

%# function resu = strncmp(A, B, n)
  %# Implements the strncmp func when at least one argument is a dataframe.

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
  
  if (isa (A, 'dataframe'))
    resu = logical (zeros (size (A)));
    for indc = (1:A.x_cnt(2))
      indr = feval (@strncmp, A.x_data{indc}(:, A.x_rep{indc}), B, n);
      resu(:, indc, A.x_rep{indc}) = indr;
    end
  else
    resu = logical (zeros (size (B)));
    for indc = (1:B.x_cnt(2))
      indr = feval (@strncmp, A, B.x_data{indc}(:, B.x_rep{indc}), n);
      resu(:, indc, B.x_rep{indc}) = indr;
    end
  end

end
