function resu = summary(df)
  %# function resu = summary(df)
  %# This function prints a nice summary of a dataframe, on a
  %# colum-by-column basis. For continuous varaibles, returns basic
  %# statistics; for discrete one (char, factors, ...), returns the
  %# occurence count for each element.

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
  
  dummy = df.x_type; resu = [];
  
  for indi = (1:length (dummy))
    switch dummy{indi}
      case {'char' 'factor'}
        [sval, sidxi, sidxj] = unique (df.x_data{:, indi});
        %# compute their occurences
        sidxj = hist (sidxj, min(sidxj):max(sidxj));
        
        %# generate a column with unique values. The regexp is used to
        %# call disp and re-format the output over many lines.
        resuR = strjust (char (regexp (disp (char (sval)), '.*', 'match', ...
                                       'dotexceptnewline')), 'right');
        resuR = horzcat (resuR, repmat (':', size(resuR, 1), 1));
        %# put the name above all       
        resuR = strjust (char ([deblank(df.x_name{1, 2}(indi, :)); resuR]), ...
                         'right');
              
        %# generate a column with a blank line and the values
        resuR = horzcat (resuR, repmat (' ', size(resuR, 1), 1),
                         strjust (char (' ', regexp (disp (sidxj.'), '.*', ...
                                                     'match', ...
                                                     'dotexceptnewline')), ...
                                  'right'),...
                         repmat (' ', size(resuR, 1), 1));
      otherwise
        s = df.x_data{:, indi};
        if (ismatrix (s))
          %# matrix => collate every observation together
          s = statistics (s(:));
        else
          s = statistics (s);
        end
        s = s([1:3 6 4:5]);
        %# generate a column with name and fields name
        resuR = strjust ([deblank(df.x_name{1, 2}{indi, :}); 
                          'Min.   :'; '1st Qu.:';
                          'Median :'; 'Mean   :';
                          '3rd Qu.:'; 'Max.   :'], 'right');
        %# generate a column with a blank line and the values
        resuR = horzcat (resuR, repmat (' ', size(resuR, 1), 1),
                         strjust (char (' ', regexp (disp (s), '.*', ...
                                                     'match', ...
                                                     'dotexceptnewline')), ...
                                 'right'),...
                        repmat (' ', size(resuR, 1), 1));
    end
    resu = horzcat_pad (resu, resuR);
  end
  
end


function resu = horzcat_pad(A, B)
  %# small auxiliary function to cat horizontally tables of different height
  dx = size (A, 1) - size (B, 1);
  
  if (dx < 0)
    %# pad A
    A = strvcat (A, repmat (' ', -dx, size(A, 2)));
  elseif (dx > 0)
    B = strvcat (B, repmat (' ', dx, size(B, 2)));
  end

  resu =  horzcat (A, B);

end
