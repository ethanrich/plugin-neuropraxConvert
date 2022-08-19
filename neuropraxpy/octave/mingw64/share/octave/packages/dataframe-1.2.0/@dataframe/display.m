function resu = display(df)

  %# function resu = display(df)
  %# Tries to produce a nicely formatted output of a dataframe.

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
  
  if (exist ('OCTAVE_VERSION', 'builtin'))
    mydisp = @(x) disp(x);
  else
    format short eng;
    mydisp = @(x) evalc ('disp (x)');
    isna = @(x) isnan (x);
  end
  
  %# generate header name
  dummy = inputname (1);
  if (isempty (dummy))
    dummy = 'ans';
  end

  if (2 == length (df.x_cnt))
    head = sprintf ('%s = dataframe with %d rows and %d columns', ...
                    dummy, df.x_cnt);
  else
    head = sprintf ('%s = dataframe with %d rows and %d columns on %d pages', ...
                    dummy, df.x_cnt);
  end

  if (~isempty (df.x_src))
    for indi = (1:size (df.x_src, 1))
      head = strvcat...
          (head, [repmat('Src: ', size (df.x_src{indi, 1}, 1), 1)...
                  df.x_src{indi, 1}]);
    end
  end

  if (~isempty (df.x_cmt))
    for indi = (1:size(df.x_cmt, 1))
      head = strvcat...
          (head, [repmat('Comment: ', size (df.x_cmt{indi, 1}, 1), 1)...
                  df.x_cmt{indi, 1}]);
    end
  end
 
  if (any (df.x_cnt > 0))  %# stop for empty df
    dummy = []; vspace = repmat (' ', max (1, df.x_cnt(1)), 1);
    indi = 1; %# the real, unfolded index
    %# loop over columns where the corresponding _data really exists
    for indc = (1:min (df.x_cnt(2), size (df.x_data, 2))) 
      %# emit column names and type
      if (1 == length (df.x_rep{indc}))
        dummy{1, 2+indi} = deblank (df.x_name{2}{indc});
        dummy{2, 2+indi} = deblank (df.x_type{indc});
      else
        %# append a dot and the third-dimension index to column name
        tmp_str = [deblank(mydisp (df.x_name{2}{indc})) '.'];
        tmp_str = arrayfun (@(x) horzcat (tmp_str, num2str(x)), ...
                            (1:length (df.x_rep{indc})), 'UniformOutput', false); 
        dummy{1, 2+indi} = tmp_str{1};
        dummy{2, 2+indi} = deblank (df.x_type{indc});
        for indk = (2:length (tmp_str))
          dummy{1, 1+indi+indk} = tmp_str{indk};
          dummy{2, 1+indi+indk} = dummy{2, 2+indi};
        end
      end
      %# 'print' each column
      switch df.x_type{indc}
        case {'char'}
          indk = 1; while (indk <= size (df.x_data{indc}, 2))
            tmp_str = df.x_data{indc}(:, indk); %#get the whole column
            indj = cellfun ('isprint', tmp_str, 'UniformOutput', false); 
            indj = ~cellfun ('all', indj);
            for indr = (1:length (indj))
              if (indj(indr)),
                if (isna (tmp_str{indr})),
                  tmp_str{indr} = 'NA';
                else
                  if (~ischar (tmp_str{indr}))
                    tmp_str{indr} = char (tmp_str{indr});
                  end
                  tmp_str{indr} = undo_string_escapes (tmp_str{indr});
                end
              end
            end
            %# keep the whole thing, and add a vertical space
            dummy{3, 2+indi} = mydisp (char (tmp_str));
            dummy{3, 2+indi} = horzcat...
                (vspace, char (regexp (dummy{3, 2+indi}, '.*', ...
                                       'match', 'dotexceptnewline')));
            indi = indi + 1; indk = indk + 1;
          end
        otherwise
          %# keep only one horizontal space per line
          unfolded = df.x_data{indc}(:, df.x_rep{indc});
          indk = 1; while (indk <= size (unfolded, 2))
            dummy{3, 2+indi} = mydisp (unfolded(:, indk));
            tmp_str = char (regexp (dummy{3, 2+indi}, ...
                                    '[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?(\s??[-+]\s??[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?i)?', ...
                                    'match', 'dotexceptnewline'));
            tmp_str = horzcat...
                (vspace, char (regexp (dummy{3, 2+indi}, '\S.*', ...
                                       'match', 'dotexceptnewline')));
            dummy{3, 2+indi} = tmp_str;
            indi = indi + 1; indk = indk + 1;
          end
      end
    end

    %# put everything together
    vspace = [' '; ' '; vspace];
    %# second line content
    resu = []; 
    
    for (ind1 = 1:size (df.x_ridx, 2))
      %# simple case: no column-compressed data
      if ((1 == size(df.x_ridx, 3)) && ...
          (any (~isna (df.x_ridx(1:df.x_cnt(1), ind1)))) || ...
          (any (isempty (df.x_ridx(1:df.x_cnt(1), ind1)))))
        dummy{2, 1} = [sprintf('_%d', ind1) ; 'Nr'];
        %# save the actual format; display in short form, and restore.
        try
          %# Octave 3.8 (CentOS 7). MatLab still uses this in R2017
          myform = get(0, 'format');
          myformfunc = @(x) format(x);
        catch
          %# Octave 4.0 and 4.2 specific
          try
            myform = __formatstring__(); myformfunc = @(x) __formatstring__(x);
          catch
           %# Octave 4.4 ?
            try
              myform = format(); myformfunc = @(x) format(x); 
            catch
              myform = "short"; myformfunc = [];
            end
          end
        end
        format short;
        dummy{3, 1} = mydisp (df.x_ridx(1:df.x_cnt(1), ind1)); 
        if (~isempty (myformfunc))
          myformfunc (myform);
        end
        %# re-format disp output over many lines, trimming extra spaces
        indi = regexp (dummy{3, 1}, '\S.*', 'match', 'dotexceptnewline');
        %# was
        %# indi = regexp (dummy{3, 1}, '\b.*\b', 'match', 'dotexceptnewline');
        if (isempty (resu))
          resu = strjust (char (dummy{2, 1}, indi), 'right');
        else
          resu = horzcat(resu, vspace, strjust (char (dummy{2, 1}, indi), ...
                                                'right'), vspace);
        end
      else 
        %# column-compressed data 
        for ind2 = (1:size (df.x_ridx, 3))
          if ((any (~isna (df.x_ridx(1:df.x_cnt(1), ind1, ind2)))) || ...
              (any (isempty (df.x_ridx(1:df.x_cnt(1), ind1, ind2)))))
            dummy{2, 1} = [sprintf('_%d.%d', ind1, ind2) ; 'Nr'];
            dummy{3, 1} = mydisp (df.x_ridx(1:df.x_cnt(1), ind1, ind2)); 
            indi = regexp (dummy{3, 1}, '\S.*', 'match', ...
                           'dotexceptnewline');
            if (isempty (resu)) 
              resu = strjust (char (dummy{2, 1}, indi), 'right');
            else
              resu = horzcat (resu, vspace, strjust (char(dummy{2, 1}, indi), ...
                                                     'right'), vspace);
            end
          end
        end
      end
    end
   
    %# emit row names
    if (isempty (df.x_name{1})),
      dummy{2, 2} = []; dummy{3, 2} = [];
    else
      dummy{2, 2} = [' ';' '];
      dummy{3, 2} = df.x_name{1};
    end
    
    %# insert a vertical space
    if (~isempty (dummy{3, 2}))
      indi = ~cellfun ('isempty', dummy{3, 2});
      if (any (indi))
        try
          resu = horzcat (resu, vspace, strjust (char(dummy{2, 2}, dummy{3, 2}),...
                                                 'right'));
        catch
          disp ('line 172 '); keyboard
        end
      end
    end
    
    %# emit each colum
    for indi = (1:size (dummy, 2) - 2)
      %# was max(df.x_cnt(2:end)),
      try
        %# avoid this column touching the previous one
        if (any (cellfun ('size', dummy(1:2, 2+indi), 2) >= ...
                 size (dummy{3, 2+indi}, 2)))
          resu = horzcat (resu, vspace);
        end
        resu = horzcat (resu, strjust (char (dummy{:, 2+indi}), 'right'));
      catch
        tmp_str = sprintf ('Emitting %d lines, expecting %d', ...
                           size (dummy{3, 2+indi}, 1), df.x_cnt(1));
        keyboard
        error (tmp_str);
      end
    end
  else
    resu = '';
  end
  
  resu = char (head, resu); mydisp (resu)

end
