function resu = permute(df, perm) 
  
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

  resu = dataframe ();

  if (length (df.x_cnt) >= length (perm))
    resu.x_cnt = df.x_cnt(perm);
  else
    resu.x_cnt = [df.x_cnt 1](perm);
  end
  
  if (ndims (df.x_ridx) < 3)
    resu.x_ridx = permute (df.x_ridx, [min(perm(1), 2) min(perm(2:end))]);
  else
    resu.x_ridx = permute (df.x_ridx, perm);
  end

  if (size (resu.x_ridx, 1) < resu.x_cnt(1))
    %# adjust index size, if required
    resu.x_ridx(end+1:resu.x_cnt(1), :, :) = NA;
  end

  if (2 == perm(1)),
    resu.x_name{1} = df.x_name{2};
    resu.x_over{1} = df.x_over{2};
    indc = length (resu.x_name{1});
    indi = resu.x_cnt(1) - indc;
    if (indi > 0)
      %# generate a name for the new row(s)
      dummy = cstrcat (repmat ('_', indi, 1), ...
                       strjust (num2str (indc + (1:indi).'), 'left'));
      resu.x_name{1}(indc + (1:indi)) = cellstr (dummy);
      resu.x_over{1}(1, indc + (1:indi)) = true;
    end 
  else
    resu.x_name{1} = df.x_name{1};
    resu.x_over{1} = df.x_over{1};
  end

  
  if (2 == perm(2))
    resu.x_name{2} = df.x_name{2};
    resu.x_over{2} = df.x_over{2};
  else
    resu.x_name{2} = df.x_name{1};
    resu.x_over{2} = df.x_over{1};
  end
  
  if (isempty (resu.x_name{2})),
    indc = 0;
  else
    indc = length (resu.x_name{2});
  end
  indi = resu.x_cnt(2) - indc;
  if (indi > 0)
    %# generate a name for the new column(s)
    dummy = cstrcat (repmat ('_', indi, 1), ...
                     strjust (num2str (indc + (1:indi).'), 'left'));
    resu.x_name{2}(indc + (1:indi)) = cellstr (dummy);
    resu.x_over{2}(1, indc + (1:indi)) = true;    
  end 
  
  if (2 ~= perm(2)),
    %# recompute the new type
    dummy = zeros (0, class (sum (cellfun (@(x) zeros (1, class(x(1))),...
                                           df.x_data))));
    resu.x_type(1:resu.x_cnt(2)) = class (dummy);
    dummy = permute (df_whole(df), perm);
    for indi = (1:resu.x_cnt(2))
      resu.x_data{indi} = squeeze (dummy(:, indi, :));
      resu.x_rep{indi} = 1:size (resu.x_data{indi}, 2);
    end 
  else %# 2 == perm(2)
    if (1 == perm(1)) %# blank operation
      resu.x_type = df.x_type;
      resu.x_data = df.x_data;
      resu.x_rep = df.x_rep;
    else
      for indi = (1:resu.x_cnt(2))
        unfolded = df.x_data{indi}(:, df.x_rep{indi});
        resu.x_data{indi} = permute (unfolded, [2 1]);
        resu.x_rep{indi} = 1:size (resu.x_data{indi}, 2);
        resu.x_type{indi} = df.x_type{indi};
      end    
    end
  end

  resu.x_src = df.x_src;
  resu.x_header = df.x_header;
  resu.x_cmt = df.x_cmt;

end
