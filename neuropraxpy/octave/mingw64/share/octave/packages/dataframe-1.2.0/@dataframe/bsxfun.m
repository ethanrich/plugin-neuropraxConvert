function resu = bsxfun(func, A, B)

  %# function resu = bsxfun(func, A, B)
  %# Implements a wrapper around internal bsxfun

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

    [A, B, resu] = df_basecomp (A, B, true, @bsxfun);

    for indi = (1:max (A.x_cnt(2), B.x_cnt(2)))
      indA = min (indi, A.x_cnt(2));
      indB = min (indi, B.x_cnt(2));
      Au = A.x_data{indA}(:, A.x_rep{indA});
      Bu = B.x_data{indB}(:, B.x_rep{indB});
      resu.x_data{indi} = bsxfun(func, Au, Bu);
      resu.x_rep{indi} = 1:size(resu.x_data{indi}, 2);
    end

    resu = df_thirddim (resu);

  catch
    disp (lasterr ());
    error ('bsxfun: non-compatible dimensions')
  end
  
end
