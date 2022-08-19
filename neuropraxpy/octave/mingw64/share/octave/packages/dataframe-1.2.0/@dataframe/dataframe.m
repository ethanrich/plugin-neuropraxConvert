function df = dataframe(x, varargin)
  
  %# -*- texinfo -*-
  %#  @deftypefn {Function File} @var{df} = dataframe(@var{x = []}, ...)
  %# This is the default constructor for a dataframe object, which is
  %# similar to R 'data.frame'. It's a way to group tabular data, then
  %# accessing them either as matrix or by column name.
  %# Input argument x may be: @itemize
  %# @item a dataframe => use @var{varargin} to pad it with suplemental
  %# columns
  %# @item a matrix => create column names from input name; each column
  %# is used as an entry
  %# @item a cell matrix => try to infer column names from the first row,
  %#   and row indexes and names from the two first columns;
  %# @item a file name => import data into a dataframe;
  %# @item a matrix of char => initialise colnames from them.
  %# @item a two-element cell: use the first as column as column to
  %# append to,  and the second as initialiser for the column(s)
  %# @end itemize
  %# If called with an empty value, or with the default argument, it
  %# returns an empty dataframe which can be further populated by
  %# assignement, cat, ... If called without any argument, it should
  %# return a dataframe from the whole workspace. 
  %# @*Variable input arguments are first parsed as pairs (options, values).
  %# Recognised options are: @itemize
  %# @item rownames : take the values as initialiser for row names
  %# @item colnames : take the values as initialiser for column names
  %# @item seeked : a (kept) field value which triggers start of processing.
  %# @item trigger : a (unkept) field value which triggers start of processing.
  %# @item datefmt: date format, see datestr help 
  %# Each preceeding line is silently skipped. Default: none
  %# @item unquot: a logical switch telling wheter or not strings should
  %# be unquoted before storage, default = true;
  %# @item sep: the elements separator, default {'\t', ','}
  %# @item conv: some regexp to convert each field. This must be a
  %# two-elements cell array containing regexprep() second (@var{PAT})
  %# and third (@var{REPSTR}) arguments. In order to replace ',' by '.',
  %# use '@{',', '.'@}'. In this case, the default separator is adjusted to '\t;'
  %# @end itemize
  %# The remaining data are concatenated (right-appended) to the existing ones.
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

if (0 == nargin)
  %# default constructor: create a scalar struct and initialise the
  %# fields in the right order
  df = struct ('x_cnt',  [0 0]);
  %# do not call 'struct' with the two next args: it would create an array
  df.x_name = {cell(0, 1), cell(1, 0)}; %# rows - cols 
  df.x_over = cell (1, 2);
  df.x_ridx = [];  
  df.x_data = cell (0, 0);
  df.x_rep = cell (0, 0);   %# a repetition index
  df.x_type = cell (0, 0);  %# the type of each column
  df.x_src = cell (0, 0);
  df.x_header = cell (0, 0);
  df.x_cmt = cell (0, 0);   %# to put comments
  df = class (df, 'dataframe');
  return
end

if (isempty (x) && 1 == nargin)
  disp ('FIXME -- should create a dataframe from the whole workspace')
  df = dataframe ();  %# just call the default constructor
  return
end

if (isa (x, 'dataframe'))
  %# Try to append whatever data or metadata given through varargin
  %# into this dataframe 
  df = x;
else
  df = dataframe (); %# get the right fields   
  if (isa (x, 'struct'))
    %# only accept a struct if it has the same fieldnames as a dataframe
    %# convert a struct to a dataframe using fieldnames as column names
    dummy = fieldnames (x);     
    indi = fieldnames (df);
    if (size (dummy, 1) ~= size (indi, 1))
      df = struct2df (x);
%#      error ('First argument of dataframe is a struct with the wrong number of fields');
    else
      if (~all (cellfun (@strcmp, dummy, indi)))
        df = struct2df (x);
%# error ('First argument of dataframe is a struct with wrong field names');
      else
             %# looks like a real dataframe
             %# easy way to transform a struct into a dataframe object
        df = class (x, 'dataframe');
      end
    end
    if (1 == nargin) return; end  
  end
end

%# default values
seeked = ''; trigger = ''; unquot = true; sep = '';
default_sep = {char(9),  ','}; %# ascii tab and comma
cmt_lines = []; conv_regexp = {}; datefmt = ''; verbose = false;

if (length (varargin) > 0)      %# extract known arguments
  indi = 1;
  %# loop over possible arguments
  while (indi <= size (varargin, 2))
    if (isa (varargin{indi}, 'char'))
      switch(varargin{indi})
        case 'rownames'
          switch class (varargin{indi+1})
            case {'cell'}
              df.x_name{1} = varargin{indi+1};
            case {'char'}
              df.x_name{1} = cellstr (varargin{indi+1});
            otherwise
              df.x_name{1} = cellstr (num2str (varargin{indi+1}));
          end
          df.x_name{1} = genvarname (df.x_name{1});
          df.x_over{1}(1, 1:length (df.x_name{1})) = false;
          df.x_cnt(1) = size (df.x_name{1}, 1);
          df.x_ridx = (1:df.x_cnt(1))';
          varargin(indi:indi+1) = [];
        case 'colnames'
          switch class(varargin{indi+1})
            case {'cell'}
              df.x_name{2} = varargin{indi+1};
            case {'char'}
              df.x_name{2} = cellstr (varargin{indi+1});
            otherwise
              df.x_name{2} = cellstr (num2str (varargin{indi+1}));
          end
          %# detect assignment - functions calls - ranges
          dummy = cellfun ('size', cellfun (@(x) strsplit (x, ':=('), df.x_name{2}, ...
                                           'UniformOutput', false), 2);
          if (any (dummy > 1))
            warning ('dataframe colnames taken literally and not interpreted');
          end
          df.x_name{2} = genvarname (df.x_name{2});
          df.x_over{2}(1, 1:length (df.x_name{2})) = false;
          varargin(indi:indi+1) = [];
        case 'seeked'
          seeked = varargin{indi + 1};
          varargin(indi:indi+1) = [];
        case 'trigger'
          trigger = varargin{indi + 1};
          varargin(indi:indi+1) = [];
        case 'unquot'
          unquot = varargin{indi + 1};
          varargin(indi:indi+1) = [];
        case 'sep'
          sep = varargin{indi + 1};
          varargin(indi:indi+1) = [];
        case 'conv'
          conv_regexp = varargin{indi + 1};
          varargin(indi:indi+1) = [];
        case 'datefmt'
          datefmt = varargin{indi + 1};
          varargin(indi:indi+1) = [];
        case 'verbose'
          verbose = varargin{indi + 1};
          varargin(indi:indi+1) = [];
        case '--'
          %# stop processing args -- take the rest as filenames
          varargin(indi) = [];
          break;
        otherwise %# FIXME: just skip it for now
          disp (sprintf ('Ignoring unkown argument %s', varargin{indi}));
          indi = indi + 1;    
      end
    else
      indi = indi + 1;    %# skip it
    end         
  end
end

if (isempty (sep))
  sep = default_sep;
  if (~isempty (conv_regexp))
    if (any (~cellfun (@isempty, (strfind (conv_regexp, ',')))))
      sep = [char(9) ';' ]; %# locales where ',' is used as decimal separator
    end
  end
end

if (~isempty (datefmt))
  %# replace consecutive spaces by one
  datefmt =  regexprep (datefmt, '[ ]+', ' ');
  %# is 'space' used as separator ? Then we may take more than one field. 
  if (~isempty (regexp (sep, ' ')))
    datefields = 1 + length (regexp (datefmt, ' '));
  else
    datefields = 1; 
  end
else
  datefields = 1;
end

if (~isempty (seeked) && ~isempty (trigger))
  error ('seeked and trigger are mutuallly incompatible arguments');
end

indi = 0;
while (indi <= size (varargin, 2))
  indi = indi + 1;
  if (~isa (x, 'dataframe'))
    if (isa (x, 'char') && size (x, 1) < 2)
      %# dummy = tilde_expand (x);
      dummy = x;
      try
        %# read the data frame from a file
        df.x_src{end+1, 1} = dummy;
        x = load (dummy);
      catch
        %# try our own method
        if (~exist('OCTAVE_VERSION', 'builtin'))
          UTF8_BOM = unicode2native (char ([hex2dec('EF') hex2dec('BB') hex2dec('BF')]));
        else
          UTF8_BOM = char ([hex2dec('EF') hex2dec('BB') hex2dec('BF')]);
        end
        %# Is it compressed ?
        cmd = []; count = regexpi (dummy, '\.gz');
        if (length (dummy) - count == 2)
          cmd = ['gzip -dc '];
        else
          count = regexpi (dummy, '\.bz2');
          if (length (dummy) - count == 3)
            cmd = ['bzip2 -dc '];
          else
            count = regexpi (dummy, '\.xz');
            if (length (dummy) - count == 2)
              cmd = ['xz -dc '];
            else
              count = regexpi (dummy, '\.zip');
              if (length (dummy) - count == 3)
                cmd = ['unzip -p '];
              else
                count = regexpi (dummy, '\.lzo');
                if (length (dummy) - count == 3)
                  cmd = ['lzop -dc '];
                end
              end
            end
          end
        end
        
        if (isempty (cmd)) %# direct read
          [fid, msg] = fopen (dummy, 'rt');
        else
          %# The file we read from external process must be seekable !!!
          tmpfile = tmpnam (); 
          %# quote to protect from spaces in the name
          dummy = strcat ('''', dummy, '''');
          cmd = [cmd, dummy,  ' > ',  tmpfile];
          if (exist ('OCTAVE_VERSION', 'builtin'))
            [output, status] = system (cmd);
          else
            [status, output] = system (cmd);
          end 
          if (not (0 == status))
            disp (sprintf ('%s exited with status %d', cmd, status));
          end
          fid = fopen (tmpfile, 'rt');
          if (exist ('OCTAVE_VERSION', 'builtin'))
            [cmd, status] = unlink (tmpfile);
          else
            delete (tmpfile)
          end
        end
        
        unwind_protect
          in = [];
          if (fid ~= -1)
            dummy = fgetl (fid);
            if (-1 == dummy)
              x = []; %# file is valid but empty
            else  
              if (~strcmp (dummy, UTF8_BOM))
                frewind (fid);
              end
              %# slurp everything and convert doubles to char, avoiding
              %# problems with char > 127
              in = char (fread (fid).');
            end 
          end
        unwind_protect_cleanup
          if (fid ~= -1) fclose (fid); end
        end_unwind_protect
        
        if (~isempty (in))
          %# explicit list taken from 'man pcrepattern' -- we enclose all
          %# vertical separators in case the underlying regexp engine
          %# doesn't have them all.
          eol = '(\r\n|\n|\v|\f|\r|\x85)';
          eol = strcat('(', char (13), char (10), '|',  char (10), '|',  char(11) , '|' ,char(12) ,'|', char(13), ')');
          %# "\x85" is unicode continuation dot
          %# cut into lines -- include the EOL to have a one-to-one
            %# matching between line numbers. Use a non-greedy match.
          lines = regexp (in, ['.*?' eol], 'match');
          %# spare memory
          clear in;
          try
            dummy =  cellfun (@(x) regexp (x, eol), lines); 
          catch  
            disp ('line 245 -- binary garbage in the input file ? '); keyboard
          end
          %# remove the EOL character(s)
          lines(1 == dummy) = {''};
          %# use a positive lookahead -- eol is not part of the match
          lines(dummy > 1) = cellfun (@(x) regexp (x, ['.*?(?=' eol ')'], ...
                                                   'match'), lines(dummy > 1));
          %# a field either starts at a word boundary, either by + - . for
          %# a numeric data, either by ' for a string. 
          
          %# content = cellfun(@(x) regexp(x, '(\b|[-+\.''])[^,]*(''|\b)', 'match'),\
          %# lines, 'UniformOutput', false); 
          
          %# extract fields
          if (all (cellfun (@isspace, sep)))
            content = cellfun (@(x) strsplit (x), lines, ...
                               'UniformOutput', false); %# extract fields  
          else
            content = cellfun (@(x) strsplit (x, sep), lines, ...
                               'UniformOutput', false); %# extract fields 
          end
          %# spare memory
          clear lines;

          indl = 1; indj = 1; dummy = []; 
          
          if (~isempty (seeked))
            while (indl <= length (content))
              dummy = content{indl};
              if (all (cellfun ('size', dummy, 2) == 0))
                indl = indl + 1; 
                continue;
              end
              if (all (cellfun (@isempty, regexp (dummy, seeked, 'match')))) 
                if (isempty (df.x_header))
                  df.x_header =  dummy;
                else
                  df.x_header(end+1, 1:length (dummy)) = dummy;
                end
                indl = indl + 1;
                continue;
              end
              break;
            end
          elseif (~isempty (trigger))
            while (indl <= length (content))
              dummy = content{indl};
              indl = indl + 1;
              if (all (cellfun ('size', dummy, 2) == 0))
                continue;
              end
              if (isempty (df.x_header))
                 df.x_header =  dummy;
              else
                df.x_header(end+1, 1:length (dummy)) = dummy;
              end
              if (all (cellfun (@isempty, regexp (dummy, trigger, 'match'))))
                continue;       
              end
              break;
            end
          else
            dummy = content{1}; %# rough guess
          end

          if (indl > length (content))
             x = []; 
          else
            x = cell (1+length (content)-indl, size (dummy, 2)); 
            empty_lines = []; cmt_lines = [];
            while (indl <= length (content))
              dummy = content{indl};
              if (all (cellfun ('size', dummy, 2) == 0))
                empty_lines = [empty_lines indj];
                indl = indl + 1; indj = indj + 1;
                continue;
              end
              %# does it looks like a comment line ?
              if (regexp (dummy{1}, ['^\s*' char(35)]))
                empty_lines = [empty_lines indj];
                cmt_lines = strvcat (cmt_lines, horzcat (dummy{:}));
                indl = indl + 1; indj = indj + 1;
                continue;
              end
              
              if (all (cellfun (@isempty, regexp (dummy, trigger, 'match'))))
                %# it does not look like the trigger. Good.
                %# try to convert to float
                if (~ isempty(conv_regexp))
                  dummy = regexprep (dummy, conv_regexp{:});
                end
                [the_line, counts] = cellfun (@(x) sscanf (x, '%f'), dummy, ...
                                              'UniformOutput', false);
                
                indk = 1; indm = 1;
                while (indk <= size (the_line, 2))
                  if (isempty (the_line{indk}) || any (size (the_line{indk}) > 1)) 
                    %#if indi > 1 && indk > 1, disp ('line 117 '); keyboard; %#end
                    if (isempty (dummy {indk}))
                      %# empty field, just don't care
                      indk = indk + 1; indm = indm + 1;
                      continue;
                    end
                    if (2 == counts{indk})
                      %# the number was complex
                      x(indj, indm) = ...
                      complex(the_line{indk}(1), the_line{indk}(2));
                    elseif (unquot)
                      try
                        %# remove quotes and leading space(s)
                        regexp (dummy{indk}, '[^''" ].*[^''"]', 'match');
                        x(indj, indm) = ans{1};
                      catch
                        %# if the previous test fails, try a simpler one
                        in = regexp (dummy{indk}, '[^'' ]+', 'match');
                        if (~isempty (in))
                          x(indj, indm) = in{1};
                        %# else
                        %#    x(indj, indk) = [];
                        end
                      end
                    else
                      %# no conversion possible, store and remove leading space(s)
                      x(indj, indm) = regexp (dummy{indk}, '[^ ].*', 'match');
                    end
                  elseif (~isempty (regexp (dummy{indk}, '[/:-]')) && ...
                          ~isempty (datefmt))
                    %# does it look like a date ?
                    datetime = dummy{indk}; 
                    
                    if (datefields > 1)             
                      %# concatenate the required number of fields 
                      indc = 1;
                      for indc = (2:datefields)
                        datetime = horzcat (datetime, ' ', dummy{indk+indc-1});
                      end
                    else
                      %# ensure spaces are unique
                      datetime =  regexprep (datetime, '[ ]+', ' ');
                    end
                    
                    try
                      datetime = datevec (datetime, datefmt);
                      timeval = struct ('usec', 0, 'sec', floor (datetime (6)), ...
                                        'min', datetime(5), 'hour', datetime(4), ...
                                        'mday', datetime(3), 'mon', datetime(2)-1, ...
                                        'year', datetime(1)-1900);
                      timeval.usec = 1e6*(datetime(6) - timeval.sec);
                      x(indj, indm) =  str2num (strftime ([char(37) 's'], timeval)) + ...
                                       timeval.usec * 1e-6;
                      if (datefields > 1)
                        %# skip fields successfully converted
                        indk = indk + (datefields - 1);
                      end
                    catch
                      %# store it as is
                      x(indj, indm) = the_line{indk}; 
                    end
                  else
                    x(indj, indm) = the_line{indk}; 
                  end
                  indk = indk + 1; indm = indm + 1;
                end
                if (verbose)
                   if (0 == mod (indl, 256))
                     disp (sprintf ('Processed line %d', indl)); fflush (1);
                     if (verbose > 1)
                       keyboard
                     end
                   end
                end
                indl = indl + 1; indj = indj + 1;
              else
                %# trigger seen again. Throw last value and abort processing.
                x(end, :) = [];
                fprintf (2, 'Trigger seen a second time, stopping processing\n');
                break
              end
            end
            
            if (~isempty (empty_lines))
              x(empty_lines, :) = [];
            end
            
            %# detect empty columns
            empty_lines = find (0 == sum (cellfun ('size', x, 2)));
            if (~isempty (empty_lines))
              x(:, empty_lines) = [];
            end
          end
          
          clear UTF8_BOM fid indl the_line content empty_lines 
          clear datetime timeval idx count tmpfile cmd output status

        end
      end
    end

    %# fallback, avoiding a recursive call
    idx.type = '()'; indj = [];
    if (~isa (x, 'char')) %# x may be a cell array, a simple matrix, ...
      indj = df.x_cnt(2)+(1:size (x, 2));
    else
      %# at this point, reading some filename failed
      error ('dataframe: can''t open "%s" for reading data', x);
    end;

    if (iscell (x) && ~isa (x, 'dataframe'))
      %# x was filled with fields read from the CSV
      if (and (isvector (x), 2 == length (x)))
        %# use the intermediate value as destination column
        [indc, ncol] = df_name2idx (df.x_name{2}, x{1}, df.x_cnt(2), 'column');
        if (ncol ~= 1)
          error (['With two-elements cell, the first should resolve ' ...
                  'to a single column']);
        end
        try
          dummy = cellfun (@class, x{2}(2, :), 'UniformOutput', false);
        catch
          dummy = cellfun (@class, x{2}(1, :), 'UniformOutput', false);
        end
        df = df_pad (df, 2, [length(dummy) indc], dummy);
        x = x{2}; 
        indj =  indc + (1:size (x, 2));  %# redefine target range
      elseif (isa (x{1}, 'cell'))
        x = x{1}; %# remove one cell level
      end
      
      if (length (df.x_name{2}) < indj(1) || isempty (df.x_name{2}(indj)))
        [df.x_name{2}(indj, 1),  df.x_over{2}(1, indj)] ...
            = df_colnames (inputname(indi), indj);
        df.x_name{2} = genvarname (df.x_name{2});
      end
      %# allow overwriting of column names
      df.x_over{2}(1, indj) = true;
  
    elseif (~isempty (indj))        
      %# x is an array, generates fieldnames from names given as args
      if (1 == length (df.x_name{2}) && length (df.x_name{2}) < ...
          length (indj))
        [df.x_name{2}(indj, 1),  df.x_over{2}(1, indj)] ...
            = df_colnames (char (df.x_name{2}), indj);
      elseif (length (df.x_name{2}) < indj(1) || isempty (df.x_name{2}(indj)))
        [df.x_name{2}(indj, 1),  df.x_over{2}(1, indj)] ...
            = df_colnames (inputname(indi), indj);
      end
      df.x_name{2} = genvarname (df.x_name{2});
    end
    
    if (~isempty (indj))
      %# the exact row size will be determined latter
      idx.subs = {'', indj};
      %# use direct assignement
      if (ndims (x) > 2), idx.subs{3} = 1:size (x, 3); end
      %#      df = subsasgn(df, idx, x);        <= call directly lower level
      try
        if (verbose)
           printf ('Calling df_matassign, orig size: %s\n', disp (size (df)));
           printf ('size(x): %s\n', disp (size (x)));
        end
        dtemp = struct (df);
        df = df_matassign (dtemp, idx, indj, length (indj), x, trigger);
        df = class (df, 'dataframe');
      catch
        disp ('line 443: df_matassign failure ??? '); keyboard
      end
      if (~isempty (cmt_lines))
        df.x_cmt = vertcat (df.x_cmt, cellstr (cmt_lines));
        cmt_lines = [];
      end
    else
      df.x_cnt(2) = length (df.x_name{2});
    end
  elseif (indi > 1)
    error ('Concatenating dataframes: use cat instead');
  end

  try
    %# loop over next variable argument
    x = varargin{1, indi};   
  catch
    %#   disp ('line 197 ???');
  end

end

end

function [x, y] = df_colnames(base, num)
  %# small auxiliary function to generate column names. This is required
  %# here, as only the constructor can use inputname()
  if (~isempty( find (base == '=')))
    %# takes the left part as base
    x = strsplit (base, '=');
    x = deblank (x{1});
    if (isvarname (x))
      y = false;
    else
      x = 'X'; y = true; 
    end
  else
    %# is base most probably a filename ?
    x =  regexp (base, '''[^''].*[^'']''', 'match');
    if (isempty (x))
      if (isvarname (base))
        x = base; y = false;
      else
        x = 'X'; y = true; %# this is a default value, may be changed
      end
    else
      x = x{1}; y = true;
    end
  end

  if (numel (num) > 1)
    x = repmat (x, numel (num), 1);
    x = horzcat (x, strjust (num2str (num(:)), 'left'));
    y = repmat (y, 1, numel (num));
  end
  
  x = cellstr (x);
    
end
