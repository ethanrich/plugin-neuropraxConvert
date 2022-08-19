function resu = fold(df, dim, indr, indc)

  %# function resu = fold(df, S, RHS)
  %# The purpose is to fold a dataframe. Part from (1:indr-1) doesn't
  %# move, then content starting at indr is moved into the second,
  %# third, ... sheet. To be moved, there must be equality of rownames,
  %# if any, and of fields contained in indc.


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
  
switch dim
  case 1
    [indr, nrow] = df_name2idx (df.x_name{1}, indr, df.x_cnt(1), 'row');
    [indc, ncol] = df_name2idx (df.x_name{2}, indc, df.x_cnt(2), 'column');
    
    if (indr(1) > 1)
      slice_size = indr(1) - 1;
      %# we can't use directly resu = df(1:slice_size, :, :)
      S.type = '()';
      S.subs = { 1:slice_size, ':', ':', 'dataframe'};
      resu = subsref (df, S);
      
      %# how many columns for each slice
      targets = cellfun (@length, df.x_rep);
      %# a test function to determine if the location is free
      for indj = (1:df.x_cnt(2))
        if (any (indj == indc))
          continue;
        end
        switch (df.x_type{indj})
          case { 'char' }
            testfunc{indj} = @(x, indr, indc) ...
                ~isna (x{indr, indc});
          otherwise
            testfunc{indj} = @(x, indr, indc) ...
                ~isna (x(indr, indc));
        end
      end

      for indi = (indr)
        %# where does this line go ?
        where = find (df.x_data{indc}(1:slice_size, 1) ...
                      == df.x_data{indc}(indi, 1));
        if (~isempty (where))
          %# transfering one line -- loop over columns
          for indj = (1:df.x_cnt(2))
            if (any (indj == indc))
              continue;
            end
           
            if (testfunc{indj}(resu.x_data{indj}, where, targets(indj)))
              %# add one more sheet
              resu = df_pad(resu, 3, 1, indj);
              targets(indj) = targets(indj) + 1;
            end
            %# transfer field
            stop
            resu.x_data{indj}(where, targets(indj)) = ...
                df.x_data{indj}(indi, 1);
          end
          %# update row index
          resu.x_ridx(where, max(targets)) = df.x_ridx(indi);
        else
          disp ('line 65: FIXME'); keyboard;
        end
      end

    else
      disp ('line 70: FIXME '); keyboard
    end

end
