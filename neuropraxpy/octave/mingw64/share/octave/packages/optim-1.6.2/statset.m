## Copyright (C) 2007-2015 John W. Eaton
## Copyright (C) 2009 VZLU Prague
##
## This function is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This function is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this function; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {} statset ()
## @deftypefnx {Function File} {@var{options} =} statset ()
## @deftypefnx {Function File} {@var{options} =} statset (@var{par}, @var{val}, @dots{})
## @deftypefnx {Function File} {@var{options} =} statset (@var{old}, @var{par}, @var{val}, @dots{})
## @deftypefnx {Function File} {@var{options} =} statset (@var{old}, @var{new})
## Create options structure for statistics functions.
##
## When called without any input or output arguments, @code{statset} prints
## a list of all valid statistics parameters.
##
## When called with one output and no inputs, return an options structure with
## all valid option parameters initialized to @code{[]}.
##
## When called with a list of parameter/value pairs, return an options
## structure with only the named parameters initialized.
##
## When the first input is an existing options structure @var{old}, the values
## are updated from either the @var{par}/@var{val} list or from the options
## structure @var{new}.
##
## Please see individual statistics functions for valid settings.
##
## @seealso{statget}
## @end deftypefn

## Copied from Octave (was 'optimset') (Asma Afzal <asmaafzal5@gmail.com>).

function retval = statset (varargin)

  nargs = nargin ();

  opts = __all_stat_opts__ ();

  if (nargs == 0)
    if (nargout == 0)
      ## Display possibilities.
      puts ("\nAll possible statistics options:\n\n");
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
      error ("statset: no defaults for function '%s'", fcn);
    end_try_catch
  elseif (nargs == 2 && isstruct (varargin{1}) && isstruct (varargin{2}))
    ## Set slots in old from non-empties in new.
    ## Should we be checking to ensure that the field names are expected?
    old = varargin{1};
    new = varargin{2};
    fnames = fieldnames (old);
    ## skip validation if we're in the internal query
    validation = ! isempty (opts);
    for [val, key] = new
      if (validation)
        ## Case insensitive lookup in all options.
        i = strncmpi (opts, key, length (key));
        nmatch = sum (i);
        ## Validate option.
        if (nmatch == 1)
          key = opts{find (i)};
        elseif (nmatch == 0)
          warning ("statset: unrecognized option: %s", key);
        else
          fmt = sprintf ("statset: ambiguous option: %%s (%s%%s)",
                         repmat ("%s, ", 1, nmatch-1));
          warning (fmt, key, opts{i});
        endif
      endif
      old.(key) = val;
    endfor
    retval = old;
  elseif (rem (nargs, 2) && isstruct (varargin{1}))
    ## Set values in old from name/value pairs.
    pairs = reshape (varargin(2:end), 2, []);
    retval = statset (varargin{1}, cell2struct (pairs(2, :), pairs(1, :), 2));
  elseif (rem (nargs, 2) == 0)
    ## Create struct.
    ## Default values are replaced by those specified by name/value pairs.
    pairs = reshape (varargin, 2, []);
    retval = statset (struct (), cell2struct (pairs(2, :), pairs(1, :), 2));
  else
    print_usage ();
  endif

endfunction

%!assert (isfield (statset (), "TolFun"))
%!assert (isfield (statset ("tolFun", 1e-3), "TolFun"))

## Test input validation
%!error statset ("1_Parameter")
%!error <no defaults for function> statset ("%NOT_A_REAL_FUNCTION_NAME%")
%!warning <statset: unrecognized option: foobar> statset ("foobar", 13);

