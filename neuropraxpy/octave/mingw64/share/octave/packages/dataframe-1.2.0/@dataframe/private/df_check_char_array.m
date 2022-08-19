function resu = df_check_char_array(x, nelem, required)

  %# auxiliary function: pad a char array to some width

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
  
  if (2 == nargin) required = [nelem 1]; end

  if (nelem < required(1))
    error ('Too many elements to assign');
  end

  %# a zero-length element is still considered as a space by char
  if (isempty (x)) x = ' '; end 

  if (size (x, 1) < max (required(1), nelem))
    %# pad vertically
    dummy = repmat (' ', nelem-size (x, 1), 1);
    resu = char (x, dummy);
  else
    resu = x;
  end
      
  if (size (resu, 2) < required(2))
    %# pad horizontally
    dummy = repmat (' ', nelem, required(2)-size (resu, 2));
    resu = horzcat (resu, dummy);
  end

end
