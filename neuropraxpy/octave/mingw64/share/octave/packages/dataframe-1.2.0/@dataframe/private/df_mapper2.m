function resu = df_mapper2(func, df, varargin)
  %# resu = df_mapper2(func, df)
  %# small interface to iterate some vector func over the elements of a
  %# dataframe. This one is specifically adapted to all functions where
  %# the first argument, if numeric, is 'dim'.

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
  
  dim = []; resu = []; vout = varargin;
  
  %# take care of constructs as min(x, [], dim);  sum(x, 2, 'native')
  for indi = (nargin-2:-1:1)
    if (isscalar (varargin{indi}))
      if (isnumeric (varargin{indi}))
        dim = varargin{indi}; 
        %# the 'third' dim is the second on stored data
        if (3 == dim) vout(indi-2) = 2; end
      end
    end
    break;
  end

  if (isempty (dim))
    %# iterates on the first non-singleton dim
    dim = find (df.x_cnt > 1)(1);
  end
    
  switch (dim)
    case {1}
      resu = df_colmeta (df); %# don't copy all the information
      for indi = (1:df.x_cnt(2))
        resu.x_data{indi} = feval (func, df.x_data{indi}(:, df.x_rep{indi}), ...
                                  vout{:});
        resu.x_rep{indi} = 1:size (resu.x_data{indi}, 2);
      end
      resu.x_cnt(1) = max (cellfun ('size', resu.x_data, 1));
      if (resu.x_cnt(1) == df.x_cnt(1))
        %# the func was not contracting
        resu.x_ridx = df.x_ridx;
        resu.x_name{1} = resu.x_name{1}; resu.x_over{1} = resu.x_over{1};
      else
        %# select the first value
        if (~isempty (resu.x_name{1}))
          resu.x_name{1} = resu.x_name{1}(1);
        end
        if (~isempty (resu.x_over{1}))
          resu.x_over{1} = resu.x_over{1}(1);
        end
      end
    case {2}
      switch func
        case @sum
          contract = true; func = @plus;
        case @cumsum
          contract = false; func = @plus;  
        case @prod
          contract = true; func = @times;
        case @cumprod
          contract = false; func = @times;
        case @any
          contract = true; func = @or;
        case @all
          contract = true; func = @and;    
        otherwise
          error ('Operation not implemented');
      end
      if (contract)
        resu = df_allmeta (df, [df.x_cnt(1) 1]);
      else
        resu = df_allmeta(df);
      end  
      resu.x_data{1} = df.x_data{1}(:, df.x_rep{1});
      resu.x_rep{1} = df.x_rep{1};
      if (contract) 
        for indi = (2:df.x_cnt(2))
          %# this call is 'unfolding'
          resu.x_data{1} =  feval (func, resu.x_data{1}(:, df.x_rep{1}), ...
                                                 df.x_data{indi}(:, df.x_rep{indi}));
          resu.x_rep{1} = 1:size (resu.x_data{1}, 2);
        end
      else
        for indi = (2:df.x_cnt(2))
          resu.x_data{indi} =  feval (func, resu.x_data{indi-1}(:, df.x_rep{indi-1}), ...
                                                    df.x_data{indi}(:, df.x_rep{indi}));
          resu.x_rep{indi} = 1:size (resu.x_data{indi}, 2);                             
        end
      end      
      %# type may have changed
      resu.x_type = cellfun(@(x) class(x(1)), resu.x_data, 'UniformOutput', false);
    case {3}
      resu = df_allmeta(df); 
      for indi = (1:df.x_cnt(2))
        resu.x_data{indi} = feval (func, df.x_data{indi}(:, df.x_rep{indi}), ...
                                  vout{:});
        resu.x_rep{indi} = 1:size (resu.x_data{indi}, 2);
      end
    otherwise
      error ('Invalid dimension %d', dim); 
  end

  resu = df_thirddim (resu);

end
