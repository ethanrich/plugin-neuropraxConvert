function [df, S] = df_cow(df, S, col)

  %# function [resu, S] = df_cow(df, S, col)
  %# Implements Copy-On-Write on dataframe. If one or more columns
  %# specified in inds is aliased to another one, duplicate it and
  %# adjust the repetition index to remove the aliasing

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
  
  if (length (col) > 1)
    error ('df_cow must work on a column-by-column basis');
  end
  
  if (1 == length (S.subs)),
    inds = 1; 
  else
    inds = S.subs{2};
  end

  if (~isnumeric(inds)) 
    if (~strcmp (inds, ':'))
      error ('Unknown sheet selector %s', inds);
    end
    inds = 1:length (df.x_rep(col));
  end

  for indi = (inds(:).')
    dummy = df.x_rep{col}; dummy(indi) = 0;
    df.x_rep{col}(indi);
    [t1, t2] = ismember (ans(:), dummy);
    for indj = (t2(find (t2))) %# Copy-On-Write
      %# determines the index for the next column
      t1 = 1 + max (df.x_rep{col}); 
      %# duplicate the touched column
      df.x_data{col} = horzcat (df.x_data{col}, ...
                               df.x_data{col}(:, df.x_rep{col}(indj)));  
      if (indi > 1)
        %# a new column has been created
        df.x_rep{col}(indi) = t1;
      else
        %# update repetition index aliasing this one
        df.x_rep{col}(find (dummy == indi)) = t1;
      end
    end
  end

  %# reorder S
  if (length (S.subs) > 1)
    if (S.subs{2} ~= 1 || length (S.subs{2}) > 1), 
      %# adapt sheet index according to df_rep
      S.subs{2} = df.x_rep{col}(S.subs{2});
    end
  end

  df = df_thirddim (df);

end
