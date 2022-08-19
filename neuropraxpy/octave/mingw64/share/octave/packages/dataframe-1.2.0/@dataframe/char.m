function resu = char(df, varargin) 

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

  [count1, count2, count3] = size (df);
  resu = '';
  for indk = (1:count3)
    %# iterate on a column by column basis
    for indj = (1:count2)
      if (length (df.x_rep{indj}) >= indk)
        dummy = char (df.x_data{indj}(:, df.x_rep{indj}(indk)));
        if (isempty (dummy))
          dummy = repmat (' ', [count1 1]);
        end
        resu = strvcat (resu, dummy);
      else
        resu = strvcat (resu, repmat ('NA', [count1 1]));
      end
    end
  end
  
  if (nargin > 1)
    resu = vertcat (resu, varargin{:});
  end
    
end
