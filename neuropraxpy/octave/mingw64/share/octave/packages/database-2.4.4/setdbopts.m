## Copyright (C) 2012 John W. Eaton
##
## Copyright (C) 2012 VZLU Prague
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {} setdbopts ()
## @deftypefnx {Function File} {} setdbopts (@var{par}, @var{val}, @dots{})
## @deftypefnx {Function File} {} setdbopts (@var{old}, @var{par}, @var{val}, @dots{})
## @deftypefnx {Function File} {} setdbopts (@var{old}, @var{new})
## Create settings structure for database functions.
##
## When called without any input or output arguments, 'setdbopts'
## prints a list of all valid optimization parameters.
##
## When called with one output and no inputs, return an options
## structure with all valid option parameters initialized to '[]'.
##
## When called with a list of parameter/value pairs, return an options
## structure with only the named parameters initialized.
##
## When the first input is an existing options structure OLD, the
## values are updated from either the PAR/VAL list or from the options
## structure NEW.
##
## Please see individual database functions for valid settings.
##
## (Most of this documentation and this functions code are copied from
## Octaves 'optimset' function.)
## @end deftypefn

## Copied from Octave (was 'optimset') (Olaf Till <i7tiol@t-online.de>).

function retval = setdbopts (varargin)

  nargs = nargin ();

  ## Add more as needed.
  opts = __all_db_opts__ ();

  if (nargs == 0)
    if (nargout == 0)
      ## Display possibilities.
      puts ("\nAll possible optimization options:\n\n");
      printf ("  %s\n", opts{:});
      puts ("\n");
    else
      ## Return struct with all options initialized to []
      retval = cell2struct (repmat ({[]}, size (opts)), opts, 2);
    endif
  elseif (nargs == 1 && ischar (varargin{1}))
    ## Return defaults for named function.
    fcn = varargin{1};
    try
      retval = feval (fcn, "defaults");
    catch
      error ("no defaults for function `%s'", fcn);
    end_try_catch
  elseif (nargs == 2 && isstruct (varargin{1}) && isstruct (varargin{2}))
    ## Set slots in old from nonempties in new.  Should we be checking
    ## to ensure that the field names are expected?
    old = varargin{1};
    new = varargin{2};
    fnames = fieldnames (old);
    ## skip validation if we're in the internal query
    validation = ! isempty (opts);
    lopts = tolower (opts);
    for [val, key] = new
      if (validation)
        ## Case insensitive lookup in all options.
        i = lookup (lopts, tolower (key));
        ## Validate option.
        if (i > 0 && strcmpi (opts{i}, key))
          ## Use correct case.
          key = opts{i};
        else
          warning ("unrecognized option: %s", key);
        endif
      endif
      old.(key) = val;
    endfor
    retval = old;
  elseif (rem (nargs, 2) && isstruct (varargin{1}))
    ## Set values in old from name/value pairs.
    pairs = reshape (varargin(2:end), 2, []);
    retval = setdbopts (varargin{1}, cell2struct (pairs(2, :), pairs(1, :), 2));
  elseif (rem (nargs, 2) == 0)
    ## Create struct.  Default values are replaced by those specified by
    ## name/value pairs.
    pairs = reshape (varargin, 2, []);
    retval = setdbopts (struct (), cell2struct (pairs(2, :), pairs(1, :), 2));
  else
    print_usage ();
  endif

endfunction
