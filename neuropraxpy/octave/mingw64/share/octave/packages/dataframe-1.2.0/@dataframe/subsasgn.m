function df = subsasgn(df, S, RHS)
  %# function df = subsasgn(df, S, RHS)
  %# This is the assignement operator for a dataframe object, taking
  %# care of all the housekeeping of meta-info.

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
  
  if (isnull (df))
    error ('dataframe subsasgn: first argument may not be empty');
  end

  switch (S(1).type)
    case '{}'
      error ('Invalid dataframe as cell assignement');
    case '.'
      %# translate the external to internal name
      switch (S(1).subs)
        case 'rownames'
          if (~isnull (RHS) && isempty (df.x_name{1}))
            df.x_name{1}(1:df.x_cnt(1), 1) = {''};
            df.x_over{1}(1, 1:df.x_cnt(1)) = true;
          end
          [df.x_name{1}, df.x_over{1}] = df_strset ...
              (df.x_name{1}, df.x_over{1}, S(2:end), RHS);
          return

        case 'rowidx'
          if (1 == length (S))
            df.x_ridx = RHS;
          else
            df.x_ridx = feval (@subsasgn, df.x_ridx, S(2:end), RHS);
          end
          return
          
        case 'colnames'
          if (isnull (RHS)) error ('Colnames can''t be nulled'); end
          [df.x_name{2}, df.x_over{2}] = df_strset ...
              (df.x_name{2}, df.x_over{2}, S(2:end), RHS, '_');
          df.x_name{2} = genvarname (df.x_name{2});
          return
          
        case 'types'
          if (isnull (RHS)) error ('Types can''t be nulled'); end
          if (1 == length (S))
            %# perform explicit cast on each column
            switch (RHS)
              case {'char'}
                for indj = (1:df.x_cnt(2))
                  if (isnumeric (df.x_data{indj}) || islogical (df.x_data{indj}))
                    df.x_data(indj) = cellfun (@(x) cellstr (num2str(x, '%f')), ...
                                              df.x_data(indj), 
                                              'UniformOutput', false); 
                  end
                end
              otherwise
                df.x_data = cellfun (@(x) cast (x, RHS), df.x_data, 
                                    'UniformOutput', false);
            end
            df.x_data = cellfun (@(x) cast (x, RHS), df.x_data, 
                                'UniformOutput', false);
            df.x_type(1:end) = RHS;
          else
            if (~strcmp (S(2).type, '()'))
              error ('Invalid internal type sub-access, use () instead');
            end 
            if (length (S) > 2 || length (S(2).subs) > 1)
              error('Types can only be changed as a whole');
            end
            if (~isnumeric(S(2).subs{1}))
              [indj, ncol, S(2).subs{1}] = df_name2idx ...
                  (df.x_name{2}, S(2).subs{1}, df.x_cnt(2), 'column');
            else
              indj = S(2).subs{1}; ncol = length (indj);
            end
            switch (RHS)
              case {'char'}
                if (isnumeric (df.x_data{indj}) || islogical (df.x_data{indj}))
                  df.x_data(indj) = cellfun (@(x) cellstr (num2str(x, '%f')), ...
                                            df.x_data(indj), 
                                            'UniformOutput', false); 
                end
              otherwise
                df.x_data(indj) = cellfun (@(x) cast (x, RHS), df.x_data(indj), 
                                          'UniformOutput', false);
            end
            df.x_type(indj) = {RHS};
          end
          return
          
        case 'source'
          if (length (S) > 1)
            df.x_src = feval (@subsasgn, df.x_src, S(2:end), RHS);
          else
            df.x_src = RHS;
          end
          return

        case 'header'
          if (length (S) > 1)
            df.x_header = feval (@subsasgn, df.x_header, S(2:end), RHS);
          else
            df.x_header = RHS;
          end
          return
          
        case 'comment'
          if (length (S) > 1)
            df.x_cmt = feval (@subsasgn, df.x_cmt, S(2:end), RHS);
          else
            df.x_cmt = RHS;
          end
          return
          
        otherwise
          if (~ischar (S(1).subs))
            error ('Congratulations. I didn''t see how to produce this error');
          end
          %# translate the name to column
          [indc, ncol] = df_name2idx (df.x_name{2}, S(1).subs, ...
                                      df.x_cnt(2), 'column', true);
          if (isempty (indc))
            %# dynamic allocation
            df = df_pad (df, 2, 1, class (RHS));
            indc = df.x_cnt(2); ncol = 1;
            df.x_name{2}(end) = S(1).subs;
            df.x_name{2} = genvarname(df.x_name{2});
            df.x_over{2}(end) = false;
          end
          
          if (length (S) > 1)
            if (1 == length (S(2).subs)), %# add column reference
              S(2).subs{2} = indc;
            else
              S(2).subs(2:3) = {indc, S(2).subs{2}};
            end
          else
            %# full assignement
            S(2).type = '()'; S(2).subs = { '', indc, ':' };
            if (ndims (RHS) < 3)
              if (isnull (RHS))
                S(2).subs = {':', indc};
              elseif (1 == size (RHS, 2))
                S(2).subs = { '', indc };
              elseif (1 == ncol && 1 == size (df.x_data{indc}, 2))
                %# force the padding of the vector to a matrix 
                S(2).subs = {'', indc, [1:size(RHS, 2)]};
              end
            end
          end
          %# do we need to 'rotate' RHS ?
          if (1 == ncol && ndims (RHS) < 3 ...
                && size (RHS, 2) > 1)
            RHS = reshape (RHS, [size(RHS, 1), 1, size(RHS, 2)]);
          end
          df = df_matassign (df, S(2), indc, ncol, RHS);
      end
      
    case '()'
      [indr, nrow, S(1).subs{1}] = df_name2idx (df.x_name{1}, S(1).subs{1}, ...
                                                df.x_cnt(1), 'row');
      if (isempty (indr) && df.x_cnt(1) > 0)
        %# this is not an initial assignment
        df = df; return;
      end
      if (any (indr < 1))
        %# assigning line '0' -> this is a no-op
        df = df; return;
      end
      
      if (length (S(1).subs) > 1)
        if (~isempty (S(1).subs{2}))
          [indc, ncol, S(1).subs{2}] = ...
              df_name2idx (df.x_name{2}, S(1).subs{2}, df.x_cnt(2), 'column');
          %# if (isempty (indc) && df.x_cnt(2) > 0)
          %# this is not an initial assignment
          %# df = df; return;
        else
          [indc, ncol] = deal ([]);
        end
      else
        mz = max (cellfun (@length, df.x_rep));
        [fullindr, fullindc, fullinds] = ind2sub ([df.x_cnt(1:2) mz], indr);
        indr = unique( fullindr); indc = unique (fullindc); 
        inds = unique (fullinds);
        ncol = length (indc);
        if (any (inds > 1))
          S(1).subs{3} = inds;
        end
      end
      
      %# avoid passing ':' as selector on the two first dims
      if (~isnull (RHS))
        S(1).subs{1} = indr; S(1).subs{2} = indc;
      end
      df = df_matassign (df, S, indc, ncol, RHS);
  end
  
  %# disp ('end of subsasgn'); keyboard
  
end
