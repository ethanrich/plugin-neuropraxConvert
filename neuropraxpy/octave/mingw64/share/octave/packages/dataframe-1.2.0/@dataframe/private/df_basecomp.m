function [A, B, C] = df_basecomp(A, B, itercol=true, func=@plus);

  %# function [A, B, C] = df_basecomp(A, B, itercol)
  %# Basic size and metadata compatibility verifications for
  %# two-arguments operations on dataframe. Returns a scalar, a matrix,
  %# or a dataframe. Cell arrays are converted to df. Third output
  %# contains a merge of the metadata.

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
  
  if (1 == length (itercol)) 
    strict = false;
  else
    strict = itercol(2); itercol = itercol(1);
  end

  if (~isa (A, 'dataframe'))
    if (iscell (A)) A = dataframe (A); end
  end
  if (~isa (B, 'dataframe'))
    if (iscell (B)) B = dataframe (B); end
  end

  switch (func2str (func))
    case 'bsxfun'
      %# bsxfun compatibility rule: if there is at least one singleton
      %# dim, the smallest is repeated to reach the size of the
      %# greatest. Otherwise, all dims must be equal.
      if (any (size (A)(1:2) ~= size (B)(1:2)))
        if (~any (1 == [size(A) size(B)]))
          error ('bsxfun: both arguments must have the same dim, of one of them must have at least one singleton dim');
        else
          Csize = max ([size(A)(1:2); size(B)(1:2)]);
        end
      else
        Csize = size (A)(1:2);
      end
    case 'mldivide'
      if (isscalar (A)) 
        Csize = size (B)(1:2);
      else
        if (size (A, 1) ~= size (B, 1))
          error ('Non compatible row sizes (op1 is %dx%d, op2 is %dx%d)',...
                 size (A), size (B)(1:2));
        end
        Csize = [size(A, 2) size(B, 2)];
      end
    otherwise
      %# if strict is set, B may not be non-scalar vs scalar
      if (strict && isscalar (A))
        if (itercol) %# requires full compatibility
          Csize = size (A)(1:2);
          if (any (Csize - size (B)(1:2)))
            %# disp([size(A) size(B)])
            error ('Non compatible row and columns sizes (op1 is %dx%d, op2 is %dx%d)',...
                   Csize, size (B));
          end
        else %# compatibility with matrix product
          if (size (A, 2) - size (B, 1))
            error ('Non compatible columns vs. rows size (op1 is %dx%d, op2 is %dx%d)',...
                  size (A)(1:2), size (B)(1:2));
          end
          Csize = [size(A, 1) size(B, 2)];
        end
      end
      if (~(isscalar (A) || isscalar (B)))
      %# can it be broadcasted ?
        if (any (size (A)(1:2) ~= size (B)(1:2)))
          if (~any (1 == [size(A) size(B)]))
            error ('bsxfun: both arguments must have the same dim, of one of them must have at least one singleton dim');
          else
            Csize = max ([size(A)(1:2); size(B)(1:2)]);
          end
        else
          Csize = size (A)(1:2);
        end
      end
  end

  if (~(isscalar (A) || isscalar (B)))
    C = [];
    if (isa (A, 'dataframe'))
      if (nargout > 2 && all (Csize == size (A)(1:2)))
        C = df_allmeta (A, Csize);
      end         
      if (isa (B, 'dataframe'))
        if (nargout > 2 && isempty (C) && all (Csize == size (B)(1:2)))
          C = df_allmeta (B, Csize);
        end
        if (strict)
          %# compare indexes if both exist
          if (~isempty (A.x_ridx))
            if (~isempty(B.x_ridx) && itercol)
              if (any (A.x_ridx-B.x_ridx))
                error ('Non compatible indexes');
              end
            end
          else
            if (nargout > 2 && itercol) C.x_ridx = B.x_ridx; end
          end
          
          if (itercol)
            idxB = 1; %# row-row comparison
          else
            idxB = 2; %# row-col comparsion
          end
          
          if (~isempty (A.x_name{1})) 
            if (~isempty (B.x_name{idxB}))
              dummy = ~(strcmp (cellstr (A.x_name{1}), cellstr (B.x_name{idxB}))...
                        | (A.x_over{1}(:)) | (B.x_over{idxB}(:)));
              if (any (dummy))
                if (itercol)
                  error ('Incompatible row names');
                else
                  error ('Incompatible row vs. column names');
                end
              end
              dummy = A.x_over{1} > B.x_over{idxB};
              if (any (dummy))
                C.x_name{1}(dummy) = B.x_name{idxB}(dummy);
                C.x_over{1}(dummy) = B.x_over{idxB}(dummy);
              end
            end
          else
            if (nargout > 2)
              C.x_name{1} = B.x_name{idxB}; C.x_over{1} = B.x_over{idxB};
            end
          end
          
          idxB = 3-idxB;
          
          if (~isempty(A.x_name{2}))
            if (~isempty(B.x_name{idxB}))
              dummy = ~(strcmp (cellstr (A.x_name{2}), cellstr (B.x_name{2}))...
                        | (A.x_over{2}(:)) | (B.x_over{2}(:)));
              if (any (dummy))
                if (itercol)
                  error ('Incompatible column vs row names');
                else
                  error ('Incompatible column names');
                end
              end
              dummy = A.x_over{2} > B.x_over{idxB};
              if (any (dummy))
                C.x_name{2}(dummy) = B.x_name{idxB}(dummy);
                C.x_over{2}(dummy) = B.x_over{idxB}(dummy);
              end
            end
          else
            if (nargout > 2 && ~isempty (B.x_name{idxB}))
              C.x_name{2} = B.x_name{idxB}; C.x_over{2} = B.x_over{idxB}; 
            end
          end
        end

        if (isempty (A.x_src) && nargout > 2 && ~isempty (B.x_src))
          C.x_src = B.x_src;
        end
        if (isempty (A.x_cmt) && nargout > 2 && ~isempty (B.x_cmt))
          C.x_cmt = B.x_cmt;
        end
      else %# B is not a df
        B = dataframe (B, 'colnames', '');
        if (nargout > 2 && isempty (C))
          C = df_allmeta (A, Csize);
        end
      end
    else %# A is not a df
      A = dataframe (A, 'colnames', '');
      if (nargout > 2)
        if (all (Csize == size (B)(1:2)))
          C = df_allmeta (B, Csize);
        else
          C = df_allmeta (B, Csize);
        end         
      end
    end
  else %# both arg are  scalar
    if (nargout > 2)
      if (isa (A, 'dataframe')) 
        C = df_allmeta (A);     
      else
        C = df_allmeta (B); 
      end
    end
  end
  
end
