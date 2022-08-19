function [idx, nelem, subs, mask] = df_name2idx(names, subs, count, dimname, missingOK);

  %# This is a helper routine to translate rownames or columnames into
  %# real index. Input: names, a char array, and subs, a cell array as
  %# produced by subsref and similar. This routine can also detect
  %# ranges, two values separated by ':'. On output, subs is
  %# 'sanitised' from names, and is either a vector, either a single ':'

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
  
  if (nargin < 5) missingOK = false; end
  
  %# regexp idea of 'word boundary' changed between 3.6 and 3.7
  persistent wbs wbe;
  
  if (isempty (wbs))
    if (isempty ( regexp ('This is a test', '\<is\>')))
       [wbs, wbe] = deal ('\b');
    else
      wbs = '\<'; wbe = '\>';
    end
  end

  if (isempty (subs))
    %# not caring about rownames ? Avoid generating an error.
    idx = []; nelem = 0; return
  end

  if (~isa (dimname, 'char'))
    switch dimname
      case 1
        dimname = 'row';
      case 2
        dimname = 'column';
      case 3
        dimname = 'page';
      otherwise
        error ('Unknown dimension %d', dimname);
    end
  end

  if (isa (subs, 'char')),
    orig_name = subs;
    if (1 == size (subs, 1))
      if (strcmp(subs, ':')) %# range operator
        idx = 1:count; nelem = count;
        return
      end
    end
    subs = cellstr (subs);
  else
    if (~isvector(subs))
      %# yes/no ?
      %# error('Trying to access column as a matrix');
    end
    switch (class (subs))
      case {'cell'}
        orig_name = char (subs);
      case {'dataframe'}
        orig_name = 'elements indexed by a dataframe';
      otherwise
        orig_name = num2str (subs);
    end
  end

  if (isa (subs, 'cell'))
    subs = subs(:); idx = []; mask = logical (zeros (size (subs, 1), 1));
    %# translate list of variables to list of indices
    for indi = (1:size (subs, 1))
      %# regexp doesn't like empty patterns
      if (isempty (subs{indi})) continue; end
      %# convert  from standard pattern to regexp pattern
      subs{indi} = regexprep (subs{indi}, '([^\.\\])(\*|\?)', '$1.$2');
      %# quote repetition ops at begining of line, otherwise the regexp
      %# will stall forever/fail
      subs{indi} = regexprep (subs{indi}, ...
                              '^([\*\+\?\{\}\|])', '\\$1');
      %# detect | followed by EOL 
      subs{indi} = regexprep (subs{indi}, '([^\\])\|$', '$1\\|');
      if (0 == index (subs{indi}, ':'))
         %# if there's no special operator, make match strict
        if (isempty (regexp (subs{indi}, '[\.\*\+\?\{\}\(\)\[\]\^\$\\]')))
          subs{indi}  = [wbs subs{indi} wbe];
        end
        for indj = (1:min (length (names), count)) %# sanity check
          if (~isempty (regexp (names{indj}, subs{indi})))
            idx = [idx indj]; mask(indi) = true; dummy = true;
          end
        end
      else
        dummy = strsplit (subs{indi}, ':');
        ind_start = 1;
        if (~isempty (dummy{1}))
          ind_start = sscanf (dummy{1}, '%d');
          if (isempty (ind_start))
            ind_start = 1;
            for indj = (1:min(length (names), count)) %# sanity check
              if (~isempty (regexp (names{indj}, subs{indi}))),
                ind_start = indj; break; %# stop at the first match
              end
            end
          end
        end
        
        if (isempty (dummy{2}) || strcmp (dummy{2}, 'end'))
          ind_stop = count;
        else
          ind_stop = sscanf(dummy{2}, '%d');
          if (isempty (ind_stop))
            ind_stop = 1;
            for indj = (min (length (names), count):-1:1) %# sanity check
              if (~isempty (regexp (names{indj}, subs{indi})))
                ind_stop = indj; break; %# stop at the last match
              end
            end
          end
        end
        idx = [idx ind_start:ind_stop];
      end
    end
    if (isempty (idx) && ~missingOK)
      dummy = sprintf ('Unknown %s name while searching for %s', ...
                       dimname, orig_name);
      error (dummy);
    end
  elseif (isa (subs, 'logical'))
    idx = 1:length (subs(:)); idx = reshape (idx, size (subs));
    idx(~subs) = []; mask = subs;
  elseif (isa (subs, 'dataframe'))
    idx = subsindex (subs, 1);
  else
    idx = subs;
  end

  subs = idx;
  nelem = length (idx);
  
end
