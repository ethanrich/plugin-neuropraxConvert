function varargout = find(df, varargin) 

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

  switch nargout
    case {0, 1}
      resu = []; mz = max (cellfun (@length, df.x_rep));
      for indc = (1:df.x_cnt(2))
        [indr, inds] = feval (@find, df.x_data{indc}(:, df.x_rep{indc}));
        %# create a vector the same size as indr
        dummy = indr; dummy(:) = indc;
        resu = [resu; sub2ind([df.x_cnt(1:2) mz], indr, dummy, inds)];
      end
      varargout{1} = sort (resu);
    case 2
      nz = 0; idx_i = []; idx_j = [];
      for indc = (1:df.x_cnt(2))
        [dum1, dum2] = feval (@find, df.x_data{indc}(:, df.x_rep{indc}));
        idx_i = [idx_i; dum1];
        idx_j = [idx_j; nz + dum2];
        nz = nz + df.x_cnt(1)*length (df.x_rep{indc});
      end
      varargout{1} = idx_i; varargout{2} = idx_j;
    case 3
      nz = 0; idx_i = []; idx_j = []; val = [];
      for indc = (1:df.x_cnt(2))
        [dum1, dum2, dum3] = feval (@find, df.x_data{indc}(:, df.x_rep{indc}));
        idx_i = [idx_i; dum1];
        idx_j = [idx_j; nz + dum2];
        val = [val; dum3];
        nz = nz + df.x_cnt(1)*length (df.x_rep{indc});
      end
      varargout{1} = idx_i; varargout{2} = idx_j; varargout{3} = val;
    otherwise
      print_usage ('find');
  end

end
