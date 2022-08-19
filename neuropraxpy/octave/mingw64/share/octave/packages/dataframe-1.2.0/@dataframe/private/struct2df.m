function df = struct2df(x, varargin)

  %# function df = struct2df(x, varargin)
  %# This function converts an ordinary structure into a dataframe.
  %# Fieldnames are taken as columns names

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
  
  names = fieldnames (x);
  if (isscalar (x))
    
    rowcount = structfun (@(x) size(x, 1), x);
    df = cell(1+max (rowcount), length (names));
    df(1, :) = names;

    for indi = (length (names) : -1 : 1)
      if (isa (x.(names{indi}), 'cell'))
        df(1+(1:rowcount(indi)), indi) = x.(names{indi});
      else
        dummy = mat2cell (x.(names{indi}), repmat (1, [rowcount(indi) 1], 1));
        df(1+(1:rowcount(indi)), indi) = dummy;
      endif
    endfor

  else

    rowcount = size (x, 1);
    df = cell (1 + rowcount, length (names));
    df(1, :) = names;

    for indi = (length (names) : -1 : 1)
      for indj = (1:rowcount)
        df(1+indj, indi) = x(indj).(names{indi});
      endfor
    endfor
  endif

  df = dataframe (df);

end
