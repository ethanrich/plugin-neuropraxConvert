function df = df_pad(df, dim, n, coltype)
  %# function resu = df_pad(df, dim, n, coltype = [])
  %# given a dataframe, insert n rows or columns, and adjust everything
  %# accordingly. Coltype is a supplemental argument:
  %# dim = 1 => not used
  %# dim = 2 => type of the added column(s)
  %# dim = 3 => index of columns receiving a new sheet (default: all)

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
  
  if (nargin < 4), coltype = []; end
  try
    NA = NA;
  catch
    NA = NaN;
  end
  
  switch dim
    case 1
      if (~isempty (df.x_name{1})),
        if (length (df.x_name{1}) < df.x_cnt(1)+n)
          %# generate a name for the new row(s)
          df.x_name{1}(df.x_cnt(1)+(1:n), 1) = {'_'};
          df.x_over{1}(1, df.x_cnt(1)+(1:n), 1) = true;
        end
      end
      %# complete row indexes: by default, row number.
      if (isempty (df.x_ridx))
        (1:n);
        dummy = ans(:);
      else
        dummy = vertcat (df.x_ridx, repmat (size (df.x_ridx, 1)+(1:n).', ...
                                           1, size (df.x_ridx, 2))); 
      end
      df.x_ridx = dummy; 
      %# pad every line
      for indi = (1:min (size (df.x_data, 2), df.x_cnt(2)))
        neff = n + df.x_cnt(1) - size (df.x_data{indi}, 1);
        if (neff > 0)
          m = max(1, size (df.x_data{indi}, 2));
          switch df.x_type{indi}
            case {'char'}
              %# there is no 'string NA'
              dummy = {}; dummy(1:neff, 1:m) = 'NA';
              dummy = vertcat (df.x_data{indi}, dummy);
            case { 'double'}
              dummy = vertcat (df.x_data{indi}, repmat (NA, neff, m));
            %# there is no 'NA' with logical values, avoid casting error
            case {'logical'}
              dummy = vertcat (df.x_data{indi}, repmat (false, neff, m));
            otherwise
              dummy = cast (vertcat (df.x_data{indi}, repmat (NA, neff, m)), ...
                            df.x_type{indi});
          end
          df.x_data{indi} = dummy;
          if (isempty (df.x_rep{indi}))
            df.x_rep{indi} = 1;
          end
        end
      end
      df.x_cnt(1) = df.x_cnt(1) + n;

    case 2
      %# create new columns
      if (isempty (coltype))
        error ('df_pad: dim equals 2, and coltype undefined');
      end
      if (length (n) > 1) %#second value is an offset
        indc =  n(2); n = n(1);
        if (indc < df.x_cnt(2)),
          %# shift to the right
          df.x_name{2}(n + (indc+1:end)) =  df.x_name{2}(indc+1:end);
          df.x_over{2}(n + (indc+1:end)) =  df.x_over{2}(indc+1:end);
          dummy = cstrcat (repmat ('_', n, 1), ...
                           strjust (num2str(indc + (1:n).'), 'left'));
          df.x_name{2}(indc + (1:n)) = cellstr (dummy);   
          df.x_over{2}(indc + (1:n)) = true;
          df.x_type(n+(indc+1:end)) = df.x_type(indc+1:end);
          df.x_type(indc + (1:n)) = NA;
          df.x_data(n + (indc+1:end)) = df.x_data(indc+1:end);
          df.x_rep(n + (indc+1:end)) = df.x_rep(indc+1:end);
          df.x_data(indc + (1:n)) = NA;
          df.x_rep(indc + (1:n)) = 1;
        end
      else
        %# add new values after the last column
        indc = min (size (df.x_data, 2), df.x_cnt(2)); 
      end
      if (~isa (coltype, 'cell')) coltype = {coltype}; end
      if (isscalar (coltype) && n > 1)
        coltype = repmat (coltype, 1, n);
      end
      for indi = (1:n)
        switch coltype{indi}
          case {'char'}
            dummy = {repmat(NA, df.x_cnt(1), 1) }; 
            dummy(:, 1) = '_';
          case { 'double'}
            dummy = repmat (NA, df.x_cnt(1), 1);
          case {'logical'} %# there is no NA in logical type
            dummy = repmat (false, df.x_cnt(1), 1);
          otherwise
            try
              dummy = cast (repmat (NA, df.x_cnt(1), 1), coltype{indi});
            catch
              %# There was an issue -- transfer coltype to data
              if (indc+indi > df.x_cnt(2))
                dummy = {coltype{indi}}; coltype{indi} = 'char';
                if (df.x_cnt(1) < 1)
                  %# nothing defined yet -- pad with one line
                  df.x_type{indc+indi} = coltype{indi};
                  df = df_pad (df, 1, 1);
                end
              else
                dummy = sprintf ('Trying to change type of column %d, which was %s, to %s', ...
                                 indc+indi, df.x_type{indi}, coltype{indi});
                error (dummy);
              end
            end  
        end
        df.x_data{indc+indi} = dummy;
        df.x_rep{indc+indi} = 1;
        df.x_type{indc+indi} = coltype{indi};
      end
   
      if (size (df.x_data, 2) > df.x_cnt(2)),
        df.x_cnt(2) =  size (df.x_data, 2);
      end
      if (length (df.x_name{2}) < df.x_cnt(2)),
        %# generate a name for the new column(s)
        dummy = cstrcat (repmat ('_', n, 1), ...
                         strjust (num2str (indc + (1:n).'), 'left'));
        df.x_name{2}(indc + (1:n)) = cellstr (dummy);
        df.x_over{2}(1, indc + (1:n)) = true;
      end   
      
    case 3
      if (n <= 0) return; end
      if (isempty (coltype)),
        coltype = 1:df.x_cnt(2);
      end
      dummy = max (n+cellfun (@length, df.x_rep(coltype)));
      if (size (df.x_ridx, 2) < dummy),
        df.x_ridx(:, end+1:dummy) = NA;
      end
      for indi = (coltype)
        switch df.x_type{indi}
          case {'char'}
            if (isa (df.x_data{indi}, 'char')) %# pure char
              dummy = horzcat (df.x_data{indi}(:, df.x_rep{indi}), ...
                               repmat({NA}, df.x_cnt(1), 1));
              keyboard
            else
              dummy =  horzcat (df.x_data{indi}(:, df.x_rep{indi}), ...
                                repmat({NA}, df.x_cnt(1), 1));
            end
          case {'double'}
            dummy = horzcat (df.x_data{indi}(:, df.x_rep{indi}), ...
                             repmat (NA, df.x_cnt(1), 1));
          case {'logical'}
            %# there is no logical 'NA' -- fill empty elems with false
            dummy = horzcat (df.x_data{indi}(:, df.x_rep{indi}), ...
                             repmat (false, df.x_cnt(1), 1));
          otherwise
            dummy = cast (horzcat (df.x_data{indi}(:, df.x_rep{indi}), ...
                                   repmat (NA, df.x_cnt(1), 1)), ...
                          df.x_type{indi});
        end
        df.x_data{indi} = dummy;
        df.x_rep{indi} = [df.x_rep{indi} length(df.x_rep{indi})+ones(1, n)];
        try
          assert (size(df.x_data{indi}, 2), max(df.x_rep{indi}))
        catch
          keyboard
        end
      end
      df =  df_thirddim (df);
    otherwise
      error ('Invalid dimension in df_pad');
  end

end             
