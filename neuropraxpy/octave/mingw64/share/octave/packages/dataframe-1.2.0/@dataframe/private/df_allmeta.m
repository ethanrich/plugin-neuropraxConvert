function resu = df_allmeta(df, dim = [])

  %# function resu = df_allmeta(df, dim = [])
  %# Returns a new dataframe, initalised with the all the
  %# meta-information but with empty data

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

  if (isempty (dim))
    dim = df.x_cnt(1:2); 
  else
    dim = dim(1:2); %# ignore third dim, if any
  end

  %# this is unnecessary: if passed a dim, just use it.
  %# resu.x_cnt(1:2) = min (dim, df.x_cnt(1:2));
  resu.x_cnt(1:2) = dim;
  
  if (~isempty (df.x_name{1}))
    if (df.x_cnt(1) >= resu.x_cnt(1))
      resu.x_name{1} = df.x_name{1}(1:resu.x_cnt(1));
      resu.x_over{1} = df.x_over{1}(1:resu.x_cnt(1));
    else
      dummy = floor (resu.x_cnt(1) / df.x_cnt(1));
      resu.x_name{1} = repmat (df.x_name{1}(1:df.x_cnt(1)), 1, dummy);
      resu.x_over{1} = repmat (df.x_over{1}(1:df.x_cnt(1)), 1, dummy);
      if (length (resu.x_name{1}) != dim(1))
        if (~isempty (other))
          if (isa (other, 'dataframe'))
            if (length (other.x_name{1}) >= dim(1))
              resu.x_name{1} = other.x_name{1}(1:resu.x_cnt(1));
              resu.x_over{1} = other.x_over{1}(1:resu.x_cnt(1));
            end
          end
        end
      end
    end
  end

  if (~isempty (df.x_name{2}))
    if (df.x_cnt(2) >= resu.x_cnt(2))
      resu.x_name{2} = df.x_name{2}(1:resu.x_cnt(2));
      resu.x_over{2} = df.x_over{2}(1:resu.x_cnt(2));
    else
      dummy = floor (resu.x_cnt(2) / df.x_cnt(2));
      resu.x_name{2} = repmat (df.x_name{2}(1:df.x_cnt(2)), 1, dummy);
      resu.x_over{2} = repmat (df.x_over{2}(1:df.x_cnt(2)), 1, dummy);
      if (length (resu.x_name{2}) != dim(2))
        dummy = repmat ('X', resu.x_cnt(2), 1);
        dummy = cstrcat (dummy, strjust (num2str ((1:resu.x_cnt(2))(:)), 'left'));
        resu.x_name{2} = cellstr (dummy);
        resu.x_over{2} = true (ones (resu.x_cnt(2), 1));
      end
    end
  end

  if (~isempty (df.x_ridx))
    if (size (df.x_ridx, 2) >= resu.x_cnt(2)),
      resu.x_ridx = df.x_ridx(1:resu.x_cnt(1), :, :);
    else
      resu.x_ridx = df.x_ridx(1:resu.x_cnt(1), 1, :);
    end
  end
  
  %# init it with the right orientation
  resu.x_data = cell (size (df.x_data, 1), min (dim(2), size (df.x_data, 2)));
  resu.x_rep = cell (size (resu.x_data));
  
  %# type 'char' must get through
  resu.x_type = cellstr (repmat ('unknown', resu.x_cnt(2), 1)).';
  if (df.x_cnt(2) >= resu.x_cnt(2))
    for indi = (1:resu.x_cnt(2))
      switch df.x_type{indi}
        case 'char'
          resu.x_type{indi} = 'char';
      end
    end
  else
    for indi = (1:df.x_cnt(2))
      switch df.x_type{indi}
        case 'char'
          resu.x_type = cellstr (repmat ('char', resu.x_cnt(2), 1)).';
      end 
    end  
  end
    
  resu.x_src  = df.x_src;
  resu.x_cmt  = df.x_cmt;
  
end
