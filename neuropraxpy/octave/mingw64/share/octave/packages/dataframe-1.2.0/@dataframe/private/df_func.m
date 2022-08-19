function resu = df_func(func, A, B, itercol=true, whole=logical([0 0]));

  %# function resu = df_func(func, A, B, whole)
  %# Implements an iterator to apply some func when at
  %# least one argument is a dataframe. The output is a dataframe with
  %# the same metadata, types may be altered, like f.i. double=>logical.
  %# When itercol is 'true', the default, LHS is iterated by columns,
  %# otherwise by rows. 'Whole' is a two-elements logical vector with
  %# the meaning that LHS and or RHS must be iterated at once or not

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
  
  [A, B, resu] = df_basecomp (A, B, itercol, func);
  itercol = itercol(1); %# drop second value

  if (isa (B, 'dataframe'))
    if (~isa (A, 'dataframe')),
      if (isscalar (A)),
        for indi = (resu.x_cnt(2):-1:1)
          switch resu.x_type{indi}
            case 'char'
              resu.x_data{indi} = feval (func, A, char (B.x_data{indi}));
            otherwise
              resu.x_data{indi} = feval (func, A, B.x_data{indi});
          end
        end
        resu.x_rep = B.x_rep;
      else
        if (whole(1) && ~whole(2))
          for indi = (resu.x_cnt(2):-1:1)
            switch resu.x_type{indi}
              case 'char'
                resu.x_data{indi} = feval (func, A, ...
                                          char (B.x_data{indi}(:, B.x_rep{indi})));
              otherwise
                resu.x_data{indi} = feval (func, A, ...
                                          B.x_data{indi}(:, B.x_rep{indi}));
            end
            resu.x_rep{indi} = 1:size (resu.x_data{indi}, 2);
          end
        elseif (itercol && ~whole(2)),
          for indi = (resu.x_cnt(2):-1:1)
            switch resu.x_type{indi}
              case 'char'
                resu.x_data{indi} = feval (func, squeeze (A(:, indi, :)), ...
                                          char (B.x_data{indi}(:, B.x_rep{indi})));
              otherwise
                resu.x_data{indi} = feval (func, squeeze (A(:, indi, :)), ...
                                          B.x_data{indi}(:, B.x_rep{indi}));
            end
            resu.x_rep{indi} = 1:size (resu.x_data{indi}, 2);
          end
        elseif (~whole(2)),
          warning ('no 3D yet');
          for indi = (resu.x_cnt(2):-1:1)
            switch resu.x_type{indi}
              case 'char'
                resu.x_data{indi} = feval (func, A(indi, :), char (B.x_data{indi}));
              otherwise
                resu.x_data{indi} = feval (func, A(indi, :), B.x_data{indi});
            end
          end
        else
          dummy = feval (func, A, df_whole (B));
          for indi = (resu.x_cnt(2):-1:1) %# store column-wise
            resu.x_data{indi} = squeeze (dummy(:, indi, :));
            resu.x_rep{indi} = 1:size (resu.x_data{indi}, 2);
            resu.x_type{indi} = class (dummy);
          end
        end
      end
    else
      if (itercol)
        for indi = (resu.x_cnt(2):-1:1)
          switch resu.x_type{indi}
            case 'char'
              resu.x_data{indi} = feval ...
                  (func, char (A.x_data{indi}(:, A.x_rep{indi})), ...
                   char (B.x_data{indi}(B.x_rep{indi})));
            otherwise
              resu.x_data{indi} = feval ...
                  (func, A.x_data{indi}(:, A.x_rep{indi}), ...
                   B.x_data{indi}(:, B.x_rep{indi}));
          end
          resu.x_rep{indi} = 1:size (resu.x_data{indi}, 2);
        end
      else %# itercol is false
        dummy = df_whole(A);
        if (whole(1))
          for indi = (resu.x_cnt(2):-1:1)
            switch resu.x_type{indi}
              case 'char'
                resu.x_data{indi} = feval (func, dummy, ...
                                          char (B.x_data{indi}(:, B.x_rep{indi})));
              otherwise
                resu.x_data{indi} = feval (func, dummy, ...
                                          B.x_data{indi}(:, B.x_rep{indi}));
            end
            resu.x_rep{indi} = 1:size (resu.x_data{indi}, 2);
          end
        elseif (~whole(2))
          for indi = (resu.x_cnt(2):-1:1)
            switch resu.x_type{indi}
              case 'char'
                resu.x_data{indi} = squeeze ...
                    (feval (func, dummy(indi, :, :),...
                            char (B.x_data{indi}(:, B.x_rep{indi}))));
              otherwise
                resu.x_data{indi} = squeeze ...
                    (feval (func, dummy(indi, :, :), ...
                            B.x_data{indi}(:, B.x_rep{indi})));
            end
            resu.x_rep{indi} = 1:size (resu.x_data{indi}, 2);
          end
        else
          dummy = feval (func, dummy, df_whole(B));
          for indi = (resu.x_cnt(2):-1:1) %# store column-wise
            resu.x_data{indi} = squeeze (dummy(:, indi, :));
            resu.x_rep{indi} = 1:size (resu.x_data{indi}, 2);
            resu.x_type{indi} = class (dummy);
          end
        end
      end
    end  
  else %# B is not a dataframe
    if (isscalar (B))
      for indi = (resu.x_cnt(2):-1:1)
        switch resu.x_type{indi}
          case 'char'
            resu.x_data{indi} = feval (func, char (A.x_data{indi}), B);
          otherwise
            resu.x_data{indi} = feval (func, A.x_data{indi}, B);
        end
      end
      resu.x_rep = A.x_rep;
    else
      if (itercol)
        if (whole(2))
          for indi = (resu.x_cnt(2):-1:1)
            switch resu.x_type{indi}
              case 'char'
                unfolded = char (A.x_data{indi}(:, A.x_rep{indi}));
              otherwise
                unfolded = A.x_data{indi}(:, A.x_rep{indi});
            end
            resu.x_data{indi} = squeeze (feval (func, unfolded, B));
            resu.x_rep{indi} = 1:size (resu.x_data{indi}, 2);
          end
        else
          for indi = (resu.x_cnt(2):-1:1)
            switch resu.x_type{indi}
              case 'char'
                unfolded = char (A.x_data{indi}(:, A.x_rep{indi}));
              otherwise
                unfolded = A.x_data{indi}(:, A.x_rep{indi});
            end
            resu.x_data{indi} = feval (func, unfolded, ...
                                      squeeze (B(:, indi, :)));
            resu.x_rep{indi} = 1:size (resu.x_data{indi}, 2);
          end
        end 
      else
        dummy = df_whole(A);
        if (whole(1))
          for indi = (columns (B):-1:1)
            resu.x_data{indi} = squeeze (feval(func, dummy, B(:, indi, :)));
            resu.x_rep{indi} = 1:size (resu.x_data{indi}, 2);
          end
        else
          if (~whole(2))
            for indi = (resu.x_cnt(1):-1:1)
              resu.x_data{indi} = squeeze (feval (func, dummy(indi, :, :), ...
                                                 B(:, indi, :)));
              resu.x_rep{indi} = 1:size (resu.x_data{indi}, 2);
            end
          else
            for indi = (resu.x_cnt(1):-1:1) %# in place computation
              dummy(indi, :, :) = feval (func, dummy(indi, :, :), B);
            end
            for indi = (resu.x_cnt(2):-1:1) %# store column-wise
              resu.x_data{indi} = squeeze (dummy(:, indi, :));
              resu.x_rep{indi} = 1:size (resu.x_data{indi}, 2);
            end
          end
        end
        %# verify that sizes match, this is required for '\'
        resu.x_cnt(2) = length (resu.x_data);
        resu.x_cnt(1) = max (cellfun ('size', resu.x_data, 1));
        if (length (resu.x_ridx) < resu.x_cnt(1)),
          if (1 == length (resu.x_ridx))
            resu.x_ridx(end+1:resu.x_cnt(1), 1) = resu.x_ridx(1);
          else
            resu.x_ridx(end+1:resu.x_cnt(1), 1) = NA;
          end
        end
        if (length (resu.x_name{2}) < resu.x_cnt(2)),
          if (1 == length (resu.x_name{2})),
            resu.x_name{2}(end+1:resu.x_cnt(2), 1) = resu.x_name{2};
            resu.x_over{2}(end+1:resu.x_cnt(2), 1) = resu.x_over{2};
          else
            resu.x_name{2}(end+1:resu.x_cnt(2), 1) = '_';
            resu.x_over{2}(end+1:resu.x_cnt(2), 1) = true;
          end
        end
      end
    end
  end

  resu.x_type = cellfun (@class, resu.x_data, 'UniformOutput', false); 

  resu = df_thirddim (resu);

end
