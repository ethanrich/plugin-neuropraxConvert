function [resu, idx] = isfield(df, name, strict)
  
  %# -*- texinfo -*-
  %# @deftypefn {Function File} [@var{resu}, @var{idx}] = isfield
  %# (@var{df}, @var{name}, @var{strict})
  %# Return true if the expression @var{df} is a dataframe and it
  %# includes an element matching @var{name}.  If @var{name} is a cell
  %# array, a logical array of equal dimension is returned. @var{idx}
  %# contains the column indexes of number of fields matching
  %# @var{name}. To enforce strict matching instead of regexp matching,
  %# set the third argument to 'true'.
  %# @end deftypefn 

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

  if (~isa (df, 'dataframe'))
    resu = false; return;
  end

  if (nargin < 2 || nargin > 3)
    print_usage ();
    resu = false; return;
  end

  if (2 == nargin) strict = false; end

  if (isa (name, 'char'))
    if (strict) %# use strmatch to get indexes
      for indi = (size (name, 1):-1:1)
        dummy = strmatch (name(indi, :), df.x_name{2}, 'exact');
        resu(indi, 1) = ~isempty (dummy);
        for indj = (1:length (dummy))
          idx(indi, indj) = dummy(indj);
        end
      end
    else
      for indi = (size (name, 1):-1:1)
        try
          dummy = df_name2idx (df.x_name{2}, name(indi, :), ...
                               df.x_cnt(2), 'column');
          resu(indi, 1) = ~isempty (dummy);
          for indj = (1:length (dummy))
            idx(indi, indj) = dummy(indj);
          end
        catch
          resu(indi, 1) = false; idx(indi, 1) = 0;
        end
      end
    end
  elseif (isa (name, 'cell'))
    if (strict) %# use strmatch to get indexes
      for indi = (size (name, 1):-1:1)
        dummy = strmatch (name{indi}, df.x_name{2}, 'exact');
        resu{indi, 1} = ~isempty (dummy);
        idx{indi, 1} = dummy;
      end
    else
      for indi = (length (name):-1:1)
        try
          dummy = df_name2idx (df.x_name{2}, name{indi}, ...
                               df.x_cnt(2), 'column');
          keyboard
          resu{indi, 1} = ~isempty (dummy); idx{indi, 1} = dummy;
        catch
          resu{indi, 1} = false; cnt{indi, 1} = 0;
        end
      end
    end
  end
end
