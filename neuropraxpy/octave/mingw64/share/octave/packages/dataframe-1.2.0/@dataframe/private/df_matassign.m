function df = df_matassign(df, S, indc, ncol, RHS, trigger)
  %# auxiliary function: assign the dataframe as if it was a matrix

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
  
  try
    NA = NA;
  catch
    NA = NaN;
  end
  
  if (isempty (RHS))
    if (1 == ncol)
      if (sum (~strcmp (S.subs, ':')) > 2)
        error('A null assignment can only have one non-colon index.');
      end
    elseif (sum (~strcmp (S.subs, ':')) > 1)
      error('A null assignment can only have one non-colon index.');
    end
    
    if (strcmp (S.subs(1), ':'))  %# removing column/matrix
      RHS = S; RHS.subs(2) = [];
      for indi = (indc)
        unfolded  = df.x_data{indi}(:, df.x_rep{indi});
        unfolded  = feval (@subsasgn, unfolded, RHS, []);
        df.x_data{indi} = unfolded;
        if (~isempty (unfolded))
          df.x_rep(indi) = 1:size (unfolded, 2);
        end
      end
      %# remove empty elements
      indi = cellfun ('isempty', df.x_data);
      if (any (indi)) %# nothing left, remove this column
        df.x_cnt(2) = df.x_cnt(2) - sum (indi);
        indi = ~indi; %# vector of kept data
        df.x_name{2} = df.x_name{2}(indi);
        df.x_over{2} = df.x_over{2}(indi);
        df.x_type = df.x_type(indi);
        df.x_data = df.x_data(indi);
        df.x_rep = df.x_rep(indi);
      end
      if (size (df.x_ridx, 3) > 1)
        df.x_ridx(:, indc, :) = [];
      end
    elseif (strcmp (S.subs(2), ':'))  %# removing rows
      indr = S.subs{1}; 
      if (~isempty (df.x_name{1}))
        df.x_name{1}(indr, :) = []; 
        df.x_over{1}(indr) = []; 
      end     
      df.x_ridx(indr, :, :) = [];
      %# to remove a line, iterate on each column
      df.x_data = cellfun (@(x) feval(@subsasgn, x, S, []), ...
                          df.x_data, 'UniformOutPut', false);
      if (isa (indr, 'char'))
        df.x_cnt(1) = 0;
      else
        df.x_cnt(1) = df.x_cnt(1) - length (indr);
      end
    end
    df = df_thirddim (df);
    
    return;
  end

  %# char array are problematic, convert to cellstr
  if (ischar (RHS) && ismatrix (RHS))
    RHS = cellstr (RHS);
  end
   
  indc_was_set = ~isempty (indc);
  if (~indc_was_set) %# initial dataframe was empty
    ncol = size (RHS, 2); indc = 1:ncol;
  end

  %# iscell(dataframe) returns true. Beware.
  ispurecell = iscell (RHS) & ~isa (RHS, 'dataframe');
  
  indr = S.subs{1, 1}; 
  indr_was_set = ~isempty (indr); 
  %# initial dataframe was empty ?
  if (~indr_was_set || strcmp (indr, ':'))
    if (ispurecell)
      nrow = max (sum (cellfun ('size', RHS, 1), 1));
    else
      if (isvector (RHS))
        if (0 == df.x_cnt(1))
          nrow = size (RHS, 1); 
        else
          nrow = df.x_cnt(1);  %# limit to df numbner of rows
        end 
      else
        %# deduce limit from RHS 
        nrow = size (RHS, 1);
      end
    end
    indr = 1:nrow;
  elseif (~isempty (indr)) 
    if (~isnumeric (indr))
      %# translate row names to row index
      [indr, nrow] = df_name2idx (df.x_name{1}, indr, df.x_cnt(1), 'row');
      S.subs{1, 1} = indr;
    else
      nrow = length (indr);
    end
  end
  if (length (S.subs) > 2)
    inds = S.subs{1, 3};
  else
    inds = [];
  end
  
  rname = cell(0, 0); rname_width = max (1, size (df.x_name{2}, 2)); 
  ridx = []; cname = rname; ctype = rname;
  
  if (ispurecell)
    if ((length (indc) == df.x_cnt(2) && size (RHS, 2) >=  df.x_cnt(2)) ...
        || 0 == df.x_cnt(2) || isempty (S.subs{1}) || isempty (S.subs{2}))
      %# providing too much information -- remove extra content
      if (size (RHS, 1) > 1)
        %# at this stage, verify that the first line doesn't contain
        %# chars only; use them for column names
        dummy = cellfun ('class', ...
                         RHS(1, ~cellfun ('isempty', RHS(1, :))), ...
                         'UniformOutput', false);
        dummy = strcmp (dummy, 'char');
        if (all (dummy))
          if (length (df.x_over{2}) >= max (indc) ...
              && ~all (df.x_over{2}(indc)) && ~isempty (S.subs{2}))
            warning('Trying to overwrite colum names');
          end
          
          cname = RHS(1, :).'; RHS = RHS(2:end, :);            
          if (~indr_was_set) 
            nrow = nrow - 1; indr = 1:nrow;
          else
            %# we know indr, there is no reason that RHS(:, 1) contains
            %# row names.
            if (isempty (S.subs{2}))
              %# extract columns position from columns names 
              [indc, ncol,  S.subs{2}, dummy] = ...
                  df_name2idx (df.x_name{2}, cname, df.x_cnt(2), 'column');
              if (length (dummy) ~= sum (dummy))
                warning ('Not all RHS column names used');
                cname = cname(dummy); RHS = RHS(:, dummy);
              end
            end
          end
        end
        %# at this stage, verify that the first line doesn't contain
        %# chars only; use them for column types
        dummy = cellfun ('class', ...
                         RHS(1, ~cellfun ('isempty', RHS(1, :))), ...
                         'UniformOutput', false);
        dummy = strcmp (dummy, 'char');
        if (all (dummy))
          if (length (df.x_over{2}) >= max (indc) ...
              && ~all (df.x_over{2}(indc)))
            warning ('Trying to overwrite colum names');
          end
          
          if (sum (~cellfun ('isempty', RHS(1, indc))) == ncol)
            ctype = RHS(1, :); 
          end
          
          RHS = RHS(2:end, :);
          if (~indr_was_set)
            nrow = nrow - 1; indr = 1:nrow;
          end
        end
      end
      
      %# more elements than df width -- try to use the first two as
      %# row index and/or row name
      if (size (RHS, 1) > 1)
        dummy = all (cellfun ('isnumeric', ...
                              RHS(~cellfun ('isempty', RHS(:, 1)), 1)));
      else
         if  (0 == size (RHS, 1))
           dummy = false;
         else
           dummy =  isnumeric (RHS{1, 1});
         end
      end
      dummy = dummy && (~isempty (cname) && size (cname{1}, 2) < 1);
      if (dummy)
        ridx = cell2mat (RHS(:, 1)); 
        %# can it be converted to a list of unique numbers ?
        if (length (unique (ridx)) == length (ridx))
          ridx = RHS(:, 1); RHS = RHS(:, 2:end);
          if (length (df.x_name{2}) == df.x_cnt(2) + ncol)
            %# columns name were pre-filled with too much values
            df.x_name{2}(end) = [];
            df.x_over{2}(end) = [];
            if (size (RHS, 2) < ncol) 
              ncol = size (RHS, 2); indc = 1:ncol;
            end
          elseif (~indc_was_set) 
            ncol = ncol - 1;  indc = 1:ncol; 
          end 
          if (~isempty (cname)) cname = cname(2:end); end
          if (~isempty (ctype)) ctype = ctype(2:end); end
        else
          ridx = [];
        end
      end
      
      if (size (RHS, 2) >  df.x_cnt(2))
        %# verify the the first row doesn't contain chars only, use them
        %# for row names
        dummy = cellfun ('class', ...
                         RHS(~cellfun ('isempty', RHS(:, 1)), 1), ...
                         'UniformOutput', false);
        dummy = strcmp (dummy, 'char') ...
            && (~isempty (cname) && size (cname{1}, 2) < 1);
        if (all (dummy)) 
          if (length (df.x_over{1}) >= max (indr) ...
              && ~all (df.x_over{1}(indr)))
            warning('Trying to overwrite row names');
          else
            rname = RHS(:, 1); 
          end
          rname_width = max ([1; cellfun('size', rname, 2)]); 
          RHS = RHS(:, 2:end); 
          if (length (df.x_name{2}) == df.x_cnt(2) + ncol)
            %# columns name were pre-filled with too much values
            df.x_name{2}(end) = [];
            df.x_over{2}(end) = [];
            if (size (RHS, 2) < ncol) 
              ncol = size (RHS, 2); indc = 1:ncol;
            end
          elseif (~indc_was_set) 
            ncol = ncol - 1;  indc = 1:ncol; 
          end
          if (~isempty (cname)) cname = cname(2:end); end
          if (~isempty (ctype)) ctype = ctype(2:end); end
        end
      end
    end
  end
  
  %# perform row resizing if columns are already filled
  if (~isempty (indr) && isnumeric(indr))
    if (max (indr) > df.x_cnt(1) && size (df.x_data, 2) == df.x_cnt(2))
      df = df_pad (df, 1, max (indr)-df.x_cnt(1), rname_width);
    end
  end
  
  if (ispurecell) %# we must pad on a column-by-column basis
    %# verify that each cell contains a non-empty vector, and that sizes
    %# are compatible
    %# dummy = cellfun ('size', RHS(:), 2);
    %# if any (dummy < 1),
    %#   error('cells content may not be empty');
    %# end
    
    %# dummy = cellfun ('size', RHS, 1);
    %# if any (dummy < 1),
    %#   error('cells content may not be empty');
    %# end
    %# if any (diff(dummy) > 0),
    %#   error('cells content with unequal length');
    %# end
    %# if 1 < size (RHS, 1) && any (dummy > 1),
    %#   error('cells may only contain scalar');
    %# end
    
    if (size (RHS, 2) > indc)
      if (size (cname, 1) > indc)
        ncol = size (RHS, 2); indc = 1:ncol;      
      else
        if (debug_on_error ()) keyboard; end
      end
    end
    
    %# try to detect and remove bottom garbage
    eff_len = zeros (nrow, 1);
    if (size (RHS, 1) > 1)
      for indi = (indr)
        eff_len(indi, 1) = sum (~cellfun ('isempty', RHS(indi, :)));
      end
      indi = nrow;
      while (indi > 0)
        if (eff_len(indi) < 1)
          nrow = nrow - 1;
          indr(end) = [];
          RHS(end, :) = [];
          indi = indi - 1;
          if (~indr_was_set && isempty (df.x_name{1, 1}))
            df.x_cnt(1) = nrow;
            df.x_ridx(end) = [];
          end
        else
          break;
        end
      end
      clear eff_len;
    end
    
    %# the real assignement
    if (1 == size (RHS, 1)) %# each cell contains one vector
      extractfunc = @(x) RHS{x};
      idxOK = logical(indr);
    else %# use cell2mat to pad on a column-by-column basis
      extractfunc = @(x) cell2mat (RHS(:, x));
    end

    indj = 1; S.subs(2) = [];
    if (length (S.subs) < 2) 
      S.subs{2} = 1; 
    end 
    for indi = (1:ncol)
      if (indc(indi) > df.x_cnt(2))
        %# perform dynamic resizing one-by-one, to get type right
        if (isempty (ctype) || length (ctype) < indc(indi))
          df = df_pad (df, 2, indc(indi)-df.x_cnt(2), class (RHS{1, indj}));
        else
          df = df_pad (df, 2, indc(indi)-df.x_cnt(2), ctype{indj});
        end
      end
      if (max (inds) > length (df.x_rep{indc(indi)}))
        df = df_pad (df, 3, max (inds)-length (df.x_rep{indc(indi)}), ...
                     indc(indi));
      end
      if (nrow == df.x_cnt(1))
        %# whole assignement
        try 
          if (size (RHS, 1) <= 1)
            switch df.x_type{indc(indi)}
              case {'char'} %# use a cell array to hold strings
                dummy = cellfun (@num2str, RHS(:, indj), ...
                                 'UniformOutput', false);
              case {'double'}
                dummy = extractfunc (indj);
              otherwise
                dummy = cast (extractfunc (indj), df.x_type{indc(indi)});
            end
          else
            %# keeps indexes in sync as cell elements may be empty
            idxOK = ~cellfun ('isempty', RHS(:, indj));
            %# intialise dummy so that it can receive 'anything'
            dummy = [];
            switch (df.x_type{indc(indi)})
              case {'char'} %# use a cell array to hold strings
                dummy = cellfun (@num2str, RHS(:, indj, :), ...
                                 'UniformOutput', false);
              case {'double'}
                dummy(idxOK, :) = extractfunc (indj); dummy(~idxOK, :) = NA;
              otherwise
                dummy(idxOK, :) = extractfunc (indj); dummy(~idxOK, :) = NA;
                dummy = cast(dummy, df.x_type{indc(indi)});
            end
          end
        catch
          fprintf (2, 'Something went wrong while converting colum %d\n', indj);
          fprintf (2, 'Error was: %s\n', lasterr ());
          keyboard;
          dummy =  unique (cellfun (@class, RHS(:, indj), ...
                                    'UniformOutput', false));
          if (any (strmatch ('char', dummy, 'exact')))
            fprintf (2, 'Downclassing to char\n');
            %# replace the actual column, of type numeric, by a char 
            df.x_type{indc(indi)} = 'char';
            dummy = RHS(:, indj);
            for indk =  (size (dummy, 1):-1:1)
              if (~isa ('char', dummy{indk}))
                if (isinteger (dummy{indk}))
                  dummy(indk) = mat2str (dummy{indk});
                elseif (isa ('logical', dummy{indk}))
                  if  (dummy{indk})
                    dummy(indk) = 'true';
                  else
                    dummy{indk} = 'false';
                  end
                elseif (isnumeric (dummy{indk}))
                  dummy(indk) = mat2str (dummy{indk}, 6);
                end
              end
            end
          else
            dummy = ...
                sprintf ('Assignement failed for colum %d, of type %s and length %d,\nwith new content\n%s', ...
                         indj, df.x_type{indc(indi)}, length (indr), disp (RHS(:, indj)));
            keyboard
            error (dummy);
          end
          if (debug_on_error ()) keyboard; end
        end
        if (size (dummy, 1) < df.x_cnt(1))
          dummy(end+1:df.x_cnt(1), :) = NA;
        end
      else
        %# partial assignement -- extract actual data and update
        dummy = df.x_data{indc(indi)}; 
        if (size (RHS, 1) > 0)
           %# pad content
          try     
            switch (df.x_type{indc(indi)})
              case {'char'} %# use a cell array to hold strings
                dummy(indr, 1) = cellfun(@num2str, RHS(:, indj), ...
                                         'UniformOutput', false);
              case {'double'}
                dummy(indr, :) = extractfunc (indj);
              otherwise
                dummy(indr, :) = cast(extractfunc (indj), df.x_type{indc(indi)});
            end
          catch
            dummy = ...
            sprintf ('Assignement failed for colum %d, of type %s and length %d,\nwith new content\n%s', ...
                     indj, df.x_type{indc(indi)}, length (indr), disp (RHS(:, indj)));
            error (dummy);
          end
        end
      end
      [df, S] = df_cow (df, S, indc(indi));
      if (isempty (inds))
        df.x_data{indc(indi)} = dummy;
        df.x_rep{indc(indi)} = 1:size (dummy, 2);
      else
        fillfunc = @(x, S, y) feval (@subsasgn, x, S, dummy);
        try
          df.x_data{indc(indi)} = fillfunc (df.x_data{indc(indi)}, S, indi);  
        catch
          disp (lasterr ()); disp ('line 439'); keyboard
        end
      end
      
      %# df.x_rep{indc(indi)} = 1:size (dummy, 2); 
      indj = indj + 1;
    end

  else 
    %# RHS is either a numeric, either a df
    if (any (indc > min (size (df.x_data, 2), df.x_cnt(2))))
      df = df_pad (df, 2, max (indc-min (size (df.x_data, 2), df.x_cnt(2))), ...
                   class(RHS));
    end
    if (~isempty (inds) && isnumeric(inds) && any (inds > 1))
      for indi = (1:ncol)
        if (max (inds) > length (df.x_rep{indc(indi)}))
          df = df_pad (df, 3, max (inds)-length (df.x_rep{indc(indi)}), ...
                       indc(indi));
        end
      end
    end

    if (isa (RHS, 'dataframe'))
      %# block-copy index
      S.subs(2) = 1;
      if (any (~isna(RHS.x_ridx)))
        df.x_ridx = feval (@subsasgn,  df.x_ridx, S,  RHS.x_ridx);
      end
      %# skip second dim and copy data
      S.subs(2) = []; Sorig = S; 
      for indi = (1:ncol)
        [df, S] = df_cow (df, S, indc(indi));
        if (strcmp (df.x_type(indc(indi)), RHS.x_type(indi)))
          try
            df.x_data{indc(indi)} = feval (@subsasgn, df.x_data{indc(indi)}, S, ...
                                          RHS.x_data{indi}(:, RHS.x_rep{indi}));
          catch
            disp (lasterr ()); disp('line 445 ???'); keyboard
          end
        else
          df.x_data{indc(indi)} = feval (@subsasgn, df.x_data{indc(indi)}, S, ...
                                        cast (RHS.x_data{indi}(:, RHS.x_rep{indi}),...
                                            df.x_type(indc(indi))));
        end
        S = Sorig;
      end
      if (~isempty (RHS.x_name{1}))
        df.x_name{1}(indr) = genvarname(RHS.x_name{1}(indr));
        df.x_over{1}(indr) = RHS.x_over{1}(indr);
      end
      if (~isempty (RHS.x_src))
        if (~any (strcmp (cellstr(df.x_src), cellstr(RHS.x_src))))
          df.x_src = vertcat(df.x_src, RHS.x_src);
        end
      end
      if (~isempty (RHS.x_cmt))
        if (~any (strcmp (cellstr(df.x_cmt), cellstr(RHS.x_cmt))))
          df.x_cmt = vertcat(df.x_cmt, RHS.x_cmt);
        end
      end

    else
      %# RHS is homogenous, pad at once
      if (isvector (RHS)) %# scalar - vector
        if (isempty (S.subs))
          fillfunc = @(x, y) RHS;
        else 
          %# ignore 'column' dimension -- force colum vectors -- use a
          %# third dim just in case
          if (isempty (S.subs{1})) S.subs{1} = ':'; end 
          S.subs(2) = [];
          if (length (S.subs) < 2) 
            S.subs{2} = 1; 
          end 
          if (ncol > 1 && length (RHS) > 1)
            %# set a row from a vector
            fillfunc = @(x, S, y) feval (@subsasgn, x, S, RHS(y));
          else   
            fillfunc = @(x, S, y) feval (@subsasgn, x, S, RHS);
          end
        end
        Sorig = S; 
        for indi = (1:ncol)
          try
            lasterr('');
            dummy= 'df_cow';
            [df, S] = df_cow (df, S, indc(indi));
            dummy = 'fillfunc';
            df.x_data{indc(indi)} = fillfunc (df.x_data{indc(indi)}, S, indi);
            S = Sorig;
          catch
            disp (lasterr  ()); disp ('line 499 '); keyboard
          end
          %# catch
          %#   if ndims(df.x_data{indc(indi)}) > 2,
          %#     %# upstream forgot to give the third dim
          %#     dummy = S; dummy.subs(3) = 1;
          %#     df.x_data{indc(indi)} = fillfunc(df.x_data{indc(indi)}, \
          %#                                   dummy, indi);
          %#   else
          %#     rethrow(lasterr());
          %#   end
          %# end
        end
      else %# 2D - 3D matrix
        S.subs(2) = []; %# ignore 'column' dimension
        if (isempty (S.subs{1}))
          S.subs{1} = indr;
        end
        %# rotate slices in dim 1-3 to slices in dim 1-2
        fillfunc = @(x, S, y) feval (@subsasgn, x, S, squeeze(RHS(:, y, :)));
        Sorig = S; 
        for indi = (1:ncol)
          [df, S] = df_cow (df, S, indc(indi));
          df.x_data{indc(indi)} = fillfunc (df.x_data{indc(indi)}, S, indi);
          S = Sorig;
        end
      end
      if (indi < size (RHS, 2) && ~isa (RHS, 'char'))
        warning (' not all columns of RHS used');
      end
    end
  end

  %# delayed row padding -- column padding occured before
  if (~isempty (indr) && isnumeric (indr))
    if (max (indr) > df.x_cnt(1) && size (df.x_data, 2) < df.x_cnt(2))
      df = df_pad (df, 1, max (indr)-df.x_cnt(1), rname_width);
    end
  end

  %# adjust ridx and rnames, if required
  if (~isempty (ridx))
    dummy = df.x_ridx;
    if (1 == size (RHS, 1))
      dummy(indr) = ridx{1};
    else
      dummy(indr) = vertcat(ridx{indr});
    end
    if (length (unique (dummy)) ~= length (dummy)) %# || ...
          %# any (diff(dummy) <= 0),
      error('row indexes are not unique or not ordered');
    end
    df.x_ridx = dummy;
  end
  
  if (~isempty (rname) && (length (df.x_over{1}) < max (indr) || ...
        all (df.x_over{1}(indr))))
    df.x_name{1}(indr, 1) = genvarname(rname);
    df.x_over{1}(1, indr) = false;
  end
  if (~isempty (cname) && (length (df.x_over{2}) < max (indc) || ...
        all (df.x_over{2}(indc))))
    if (length (cname) < ncol)
      cname(end+1:ncol) = {'_'};
    end
    cname(cellfun (@isempty, cname)) = 'unnamed';
    try
      df.x_name{2}(indc, 1) = genvarname (cname);
    catch
      %# there was a problem with genvarname. 
      dummy = sum (~cellfun ('isempty', cname));
      if (1 == dummy)
        dummy =  strsplit(cname{1}, ' ', true);
        if (length (dummy) == ncol)
          df.x_name{2}(indc, 1) = dummy;
        else
          disp ('line 575 '); keyboard
        end
      else
        disp ('line 578 '); keyboard
      end
    end
    df.x_over{2}(1, indc) = false;
  end
  
  df = df_thirddim (df);

  end
