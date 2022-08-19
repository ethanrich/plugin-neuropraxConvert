function [x, over] = df_strset(x, over, S, RHS, pad = ' ')
  %# x = df_strset(x, over, S, RHS, pad = ' ')
  %# replaces the strings in cellstr x at indr by strings at y. Adapt
  %# the width of x if required. Use x 'over' attribute to display a
  %# message in case strings are overwritten.

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
  
  %# adjust x size, if required
  if (isnull (RHS))
    %# clearing
    if (isempty (S))
      x = cell (0, 1); over = zeros (1, 0);
      return
    end
    dummy = S; dummy(1).subs(2:end) = [];
    over = builtin ('subsasgn', over, dummy, true);
  else
    if (isempty (S)) %# complete overwrite
      if (ischar (RHS)) RHS = cellstr (RHS); end
      nrow = length (RHS);
      if (any(~over(nrow)))
        warning ('going to overwrite names');
      end
      x(1:nrow) = RHS;
      over(1:nrow) = false;
      if (nrow < length (x))
        x(nrow+1:end) = {pad};
      end
      return
    else
      dummy = S(1); dummy.subs(2:end) = []; % keep first dim only
      if (any (~builtin ('subsref', over, dummy)))
        warning ('going to overwrite names');
      end
      over = builtin ('subsasgn', over, dummy, false);
    end
  end

  %# common part
  if (ischar (RHS) && length (S(1).subs) > 1) 
    %# partial accesses to a char array
    dummy = char (x);
    dummy = builtin ('subsasgn', dummy, S, RHS);
    if (isempty(dummy))
      x = cell (0, 1); over = zeros (1, 0);
      return
    end
    if (size (dummy, 1) == length (x))
      x = cellstr (dummy);
      return
    end
    %# partial clearing gone wrong ? retry
    RHS = { RHS }; 
  end
  x = builtin ('subsasgn', x, S, RHS);
    
end
