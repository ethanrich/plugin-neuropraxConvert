function resu = cat(dim, A, varargin)
  %# function resu = cat(dim, A, varargin)
  %# This is the concatenation operator for a dataframe object. 'Dim'
  %# has the same meaning as ordinary cat. Next arguments may be
  %# dataframe, vector/matrix, or two elements cells. First one is taken
  %# as row/column name, second as data.

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
    NA = NA;
  catch
    NA = NaN;
  end
  
  if (~isa (A, 'dataframe')),
    A = dataframe (A);
  end

  switch dim
    case 1
      resu = A;
          
      for indi = (1:length (varargin))
        B = varargin{indi};
        if (~isa (B, 'dataframe'))
          if (iscell (B) && 2 == length (B))
            B = dataframe (B{2}, 'rownames', B{1});
          else
            B = dataframe (B, 'colnames', inputname(2+indi));
          end
        end
        if (resu.x_cnt(2) ~= B.x_cnt(2))
          error ('Different number of columns in dataframes');
        end
        %# do not duplicate empty names
        if (~isempty (resu.x_name{1}) || ~isempty (B.x_name{1}))
          if (length (resu.x_name{1}) < resu.x_cnt(1))
            resu.x_name{1}(end+1:resu.x_cnt(1), 1) = {''};
          end
          if (length (B.x_name{1}) < B.x_cnt(1))
            B.x_name{1}(end+1:B.x_cnt(1), 1) = {''};
          end
          resu.x_name{1} = vertcat (resu.x_name{1}(:),  B.x_name{1}(:));
          resu.x_over{1} = [resu.x_over{1} B.x_over{1}];
        end
        resu.x_cnt(1) = resu.x_cnt(1) + B.x_cnt(1);
        if (size (resu.x_ridx, 2) < size (B.x_ridx, 2))
          resu.x_ridx(:, end+1:size(B.x_ridx, 2)) = NA;
        elseif (size (resu.x_ridx, 2) > size (B.x_ridx, 2))
          B.x_ridx(:, end+1:size(resu.x_ridx, 2)) = NA;
        end
        resu.x_ridx = [resu.x_ridx; B.x_ridx];
        %# find data with same column names
        dummy = A.x_over{2} & B.x_over{2}; 
        indA = true (1, resu.x_cnt(2));
        indB = true (1, resu.x_cnt(2));
        for indj = (1:resu.x_cnt(2))
          if (dummy(indj))
            indk = strmatch (resu.x_name{2}(indj), B.x_name{2}, 'exact');
            if (~isempty (indk))
              indk = indk(1);
              if (~strcmp (resu.x_type{indj}, B.x_type{indk}))
                error ('Trying to mix columns of different types');
              end
            end
          else
            indk = indj;
          end
          resu.x_data{indj} = [resu.x_data{indj}; B.x_data{indk}];
          indA(indj) = false; indB(indk) = false;
        end
        if (any (indA) || any (indB))
          error ('Different number/names of columns in dataframe');
        end
        
      end
      
    case 2
      resu = A;

      for indi = (1:length (varargin))
        B = varargin{indi};
        if (~isa (B, 'dataframe'))
          if (iscell (B) && 2 == length (B))
            B = dataframe (B{2}, 'colnames', B{1});
          else
            B = dataframe (B, 'colnames', inputname(2+indi));
          end
          B.x_ridx = resu.x_ridx; %# make them compatibles
        end
        if (resu.x_cnt(1) ~= B.x_cnt(1))
          error ('Different number of rows in dataframes');
        end
        if (any(resu.x_ridx(:) - B.x_ridx(:)))
          error ('dataframes row indexes not matched');
        end
        resu.x_name{2} = vertcat (resu.x_name{2}, B.x_name{2});
        resu.x_over{2} = [resu.x_over{2} B.x_over{2}];
        resu.x_data(resu.x_cnt(2)+(1:B.x_cnt(2))) = B.x_data;
        resu.x_type(resu.x_cnt(2)+(1:B.x_cnt(2))) = B.x_type;
        resu.x_cnt(2) = resu.x_cnt(2) + B.x_cnt(2);        
      end
      
    case 3
      resu = A;
      
      for indi = (1:length (varargin))
        B = varargin{indi};
        if (~isa (B, 'dataframe'))
          if (iscell (B) && 2 == length (B)),
            B = dataframe (B{2}, 'rownames', B{1});
          else
            B = dataframe (B, 'colnames', inputname(indi+2)); 
          end
        end
        if (resu.x_cnt(1) ~= B.x_cnt(1))
          error ('Different number of rows in dataframes');
        end
        if (resu.x_cnt(2) ~= B.x_cnt(2)),
          error ('Different number of columns in dataframes');
        end
        %# to be merged against 3rd dim, rownames must be equals, if
        %# non-empty. Columns are merged based upon their name; columns
        %# with identic content are kept.

        if (size(resu.x_ridx, 2) < size(B.x_ridx, 2))
          resu.x_ridx(:, end+1:size(B.x_ridx, 2)) = NA;
        elseif (size(resu.x_ridx, 2) > size(B.x_ridx, 2))
          B.x_ridx(:, end+1:size(resu.x_ridx, 2)) = NA;
        end
        resu.x_ridx = cat (3, resu.x_ridx, B.x_ridx);
        %# find data with same column names
        indA = true (1, resu.x_cnt(2));
        indB = true (1, resu.x_cnt(2));
        dummy = A.x_over{2} & B.x_over{2}; 
        for indj = (1:resu.x_cnt(2))
          if (dummy(indj))
            indk = strmatch (resu.x_name{2}(indj), B.x_name{2}, 'exact');
            if (~isempty (indk)),
              indk = indk(1);
              if (~strcmp (resu.x_type{indj}, B.x_type{indk})),
                error('Trying to mix columns of different types');
              end
            end
          else
            indk = indj;
          end
          if (all ([isnumeric(resu.x_data{indj}) isnumeric(B.x_data{indk})])),
            %# iterate over the columns of resu and B
            op1 = resu.x_data{indj}; op2 = B.x_data{indk};
            for ind2 = (1:columns (op2))
              indr = false;
              for ind1 = (1:columns (op1))
                if (all (abs (op1(:, ind1) - op2(:, ind2)) <= eps)),
                  resu.x_rep{indj} = [resu.x_rep{indj} ind1];
                  indr = true;
                  break;
                end
              end
              if (~indr),
                %# pad in the second dim
                resu.x_data{indj} = [resu.x_data{indj}, B.x_data{indk}];
                resu.x_rep{indj} = [resu.x_rep{indj} 1+length(resu.x_rep{indj})];
              end
            end
          else
            resu.x_data{indj} = [resu.x_data{indj} B.x_data{indk}];
            resu.x_rep{indj} = [resu.x_rep{indj} 1+length(resu.x_rep({indj}))];
          end
          indA(indj) = false; indB(indk) = false;
        end
        if (any (indA) || any (indB))
          error ('Different number/names of columns in dataframe');
        end
      end
     
      resu = df_thirddim (resu);
      
    otherwise
      error ('Incorrect call to cat');
  end
  
  %#  disp ('End of cat'); keyboard
end
