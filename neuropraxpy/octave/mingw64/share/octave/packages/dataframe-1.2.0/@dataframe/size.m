function varargout = size(df, varargin)

  %# function resu = size(df, varargin)
  %# This is size operator for a dataframe object.

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
  
  switch nargin
    case 1
      switch nargout
        case {0, 1}
          varargout{1} = df.x_cnt;
        case {2}
          varargout{1} = df.x_cnt(1);
          if (1 == df.x_cnt(2) && length (df.x_cnt) > 2)
            varargout{2} = df.x_cnt(3);
          else
            varargout{2} = df.x_cnt(2);
          end
        case {3}
          varargout = {df.x_cnt(1) df.x_cnt(2)};
          if (2 == length (df.x_cnt))
            varargout{3} = 1;
          else
            varargout{3} = df.x_cnt(3);
          end
        otherwise
          error (print_usage ());
      end
    case 2
      switch nargout
        case {0 1}
          varargout{1} = df.x_cnt;
          try
            varargout{1} = varargout{1}(varargin{1});
          catch
            error (print_usage ());
          end
        otherwise
          error (print_usage ());
      end
    case 3
      switch nargout
        case {0 1}
          if (length (df.x_cnt) < 3),
            varargout{1} = 1;
          else
            varargout{1} = df.x_cnt;
          end
          try
            varargout{1} = varargout{1}(varargin{1});
          catch
            error (print_usage ());
          end
        otherwise
          error (print_usage ());
      end
    otherwise
      error (print_usage ());
  end

end

function usage = print_usage()
  usage = strcat ('Invalid call to size.  Correct usage is: ', ' ', ...
                  '-- Overloaded Function:  size (A, N)');
end
