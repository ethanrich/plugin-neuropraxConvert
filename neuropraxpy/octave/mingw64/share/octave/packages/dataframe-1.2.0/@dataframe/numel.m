function resu = numel(df, varargin)
  %# function resu = numel(df, varargin)
  %# This is numel operator for a dataframe object.

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
  
  resu = prod (df.x_cnt);
  
  if (nargin > 1)
    if (1 == length (varargin))
      %# vector-like access
      if (':' == varargin{1})
        return;
      end
      if (islogical (varargin{1}))
        dummy = numel (varargin{1})
        if (dummy > resu)
          dummy = sprintf ('%d out of bound %d', dummy, resu); 
          error (['A(I): index out of bounds;' dummy]);
        end
        resu  = sum (varargin{1}(:));
        return;
      end
      iw = varargin{1}(:) > resu;
      if (any (iw))
        iw = find (iw); iw = iw(1);
        dummy = sprintf ('%d out of bound %d', varargin{1}(iw), resu); 
        error (['A(I): index out of bounds;' dummy]);
      end
      resu  = numel (varargin{1});
      return;
    end

                         %# multi-argument access -- iterate over args
    resu = 1;
    for indi = (1: length (varargin))
      if (':' == varargin{indi})
        resu = resu * df.x_cnt(indi);
        continue;
      end
      if (indi > length (df.x_cnt))
        dummy = 1;
      else
        dummy = df.x_cnt(indi);
      end
      if (islogical (varargin{indi}))
        iw = find (varargin{indi});
        if (any (iw) > df.x_cnt(indi))
          switch (indi)
            case 1
              dummy = ...
              sprintf ('row index out of bounds; value %d out of bound %d', iw, dummy);
            case 2
              dummy = ...
              sprintf ('column index out of bounds; value %d out of bound %d', iw, dummy);
            case 3
              dummy = ...
              sprintf ('page index out of bounds; value %d out of bound %d', iw, dummy);
          end
          if (length (varargin) <= 2)
            dummy = ['A(I, J): ', dummy];
          else
            dummy = ['A(I, J, ...): ', dummy];
          end
          error (dummy);
        end
        resu = resu * length (iw);
      else
        switch class (varargin{indi})
          case {'char'}
            [indc, ncol] = df_name2idx (df.x_name{indi}, varargin{indi}, df.x_cnt(indi), indi);
            resu = resu * ncol;
          otherwise
            iw = varargin{indi} > dummy;
            if (any (iw))
              iw = find (iw); iw = iw(1);
              switch (indi)
                case 1
                  dummy = ...
                  sprintf ('row index out of bounds; value %d out of bound %d', varargin{indi}(iw), dummy);
                case 2
                  dummy = ...
                  sprintf ('column index out of bounds; value %d out of bound %d', varargin{indi}(iw), dummy);
                case 3
                  dummy = ...
                  sprintf ('page index out of bounds; value %d out of bound %d', varargin{indi}(iw), dummy);
              end
              if (length (varargin) <= 2)
                dummy = ['A(I, J): ', dummy];
              else
                dummy = ['A(I, J, ...): ', dummy];
              end
              error (dummy);
            end
            resu = resu * length (varargin{indi});
        end
      end
    end
  else
     %# This is just plain silly: numel is called by generic subsasgn,
     %# returning anything > 1 means troubles
    resu = 1;
  end
 
end
