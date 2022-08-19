## Copyright (C) 2013-2021 Darien Pardinas Diaz <darien.pardinas-diaz@monash.edu>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## S = READ_NAMELIST (FILENAME) returns the struct S containing namelists and
## variables in the file FILENAME organised in hierachical way:
##
##                |--VAR1
##                |--VAR2
##   |-- NMLST_A--|...
##   |            |--VARNa
##   |
##   |            |--VAR1
##   |-- NMLST_B--|--VAR2
##   |            |...
## S --|     ...    |--VARNb
##     |
##     |            |--VAR1
##     |-- NMLST_M--|--VAR2
##                  |...
##                  |--VARNm
##
## Note:  The function can read multidimensional variables as well. The  
## function assumes that there is no more than one namelist section per 
## line. At this time there is no syntax checking functionality so the 
## function will crash in case of errors.
##
## Example:
##     NMLST = read_namelist ("OPTIONS.nam");
##     NMLST.NAM_FRAC.XUNIF_NATURE = 0.1;
##     write_namelist(NMlST, "MOD_OPTIONS.nam");

## Written by:     Darien Pardinas Diaz (darien.pardinas-diaz@monash.edu)
## Version:        1.0
## Date:           16 Dec 2011
##
## Released under GPL License 30/3/2013
##
## Notes Re: Use in Octave.
## -Line 83 causes a problem. Seems to work OK if commented out.FIXED
## -Copes with Fortran comment (!) e.g.
## &data1
##   a = 100.0  ! length metres
##   b = 25.0   ! mass kg
## /
## is read OK
## Terry Duell 31 mar 2013

function S = read_namelist (filename)

S = struct ();
  ## Open and read the text file containing the namelists
  fid = fopen (filename, "r");
  c = 0;
  lines = cell(1);

  ## Read all the text lines in namelist file
  while (! feof (fid))
    line = fgetl (fid);
    ## Remove comments if any on the line
    idx = find (line == "!");
    if (! isempty (idx))
      line = line (1:idx(1) - 1);
    end
    if (! isempty (line)),
      ++c;
      lines{c} = line;     ## FIXME each time appending to a cell array is slow
    end
  end
  fclose (fid);

  ii = 0;
  while (ii < c);    
    ## Find a record
    ++ii; 
    line = lines{ii};
    idx = find (line == "&");
    if (! isempty (idx))   ## i.e. a namelist start
      line = line(idx(1) + 1:end);
      ## find next space
      idx = find (line == " ");
      if (! isempty (idx))
        namelst = line(1:idx(1) - 1);
        line = line(idx(1) + 1:end);
      else
        namelst = line;
        line = [];        ##TDuell 31/03/2013 Provisional fix L.102 PRN 1apr2013
      endif
      nmlst_bdy = "";
      if (! isempty (line))
        idx = find_ending_idx (line);
      else
        line = "";
      endif
      ## Get the variable specification section
      while (isempty (idx) && ii < c)
        nmlst_bdy = [ nmlst_bdy " " line ];
        ++ii;
        line = lines{ii};
        idx = find_ending_idx (line);
      endwhile
      if (! isempty (idx) && idx(1) > 1)
        nmlst_bdy = [ nmlst_bdy " " line(1:idx(1)-1) ];
      endif
      ## Parse current namelist (set of variables)
      S.(namelst) = parse_namelist (nmlst_bdy);
    endif
  endwhile

endfunction


## Internal function to find the position of the slash terminating the namelist
function idx = find_ending_idx (strng)

  ## Find all /
  idx_all = strfind (strng, "/");
  idx = [];
  ## Only keep the ones not quoted
  for ii = 1:size (idx_all, 2)
    if (! is_quoted (strng, idx_all(ii), '"') && ...
        ! is_quoted (strng, idx_all(ii), ''''))
      idx = [idx idx_all(ii)];
    endif
  endfor

endfunction


## Internal function to check if a character at a position idx in a string
## 'strng' is quoted by the character quote
function ll = is_quoted (strng, idx, quote)

  ## Find location of all quotes
  idx_quotes = strfind (strng, quote);
  if (isempty (idx_quotes))
    ## There are no quotes
    ll = false;
    return
  endif
  ii = 1;
  while (ii <= size (idx_quotes, 2))
    ## Find the first quote after the character
    if (idx_quotes(ii) > idx)
      ## If we counted an even number of quote, this character is quoted
      if (mod (ii, 2) == 0)
          ll = true;
          return
      else
          ll = false;
          return
      endif
    endif
    ++ii;
  endwhile
  ## The character is behind all quotes
  ll = false;

endfunction


## Internal function to parse the body text of a namelist section.
## Limitations: the following patterns are prohibited inside the literal
## strings: ".t." ".f." ".true." ".false." "(:)"
function S = parse_namelist (strng)

  ## Get all .true., .t. and .false., .f. to T and F
  strng = regexprep (strng, '\.true\.' , "T", "ignorecase"); 
  strng = regexprep (strng, '\.false\.', "F", "ignorecase");
  strng = regexprep (strng, '\.t\.', "T", "ignorecase"); 
  strng = regexprep (strng, '\.f\.', "F", "ignorecase");

  ## Make evaluable the (:) expression in Octave if any
  strng = regexprep (strng, '\(:\)', "(1,:)");
  [strng, islit] = parse_literal_strings ([strng " "]);

  ## Find the position of all the "="
  eq_idx = find (strng == "=");    ## PRN 19Jun2016 use strfind() ?
  nvars = length (eq_idx);

  arg_start = eq_idx + 1;
  arg_end   = zeros (size (eq_idx));
  vars = cell (nvars, 1);
  S = struct;

  ## Loop through every variable
  for kk = 1:nvars,
    ii = eq_idx(kk) - 1;
    ## Move to the left and discard blank spaces
    while (strng(ii) == " ")
	  --ii;
	endwhile
    ## Now we are over the variable name or closing parentesis
    jj = ii;
    if (strng(ii) == ")"),
      while (strng(ii) != "(")
	    --ii;
	  endwhile
      --ii;
      ## Move to the left and discard any possible blank spaces
      while (strng(ii) == " ")
        --ii;
	  endwhile
    endif

    ## Now we are over the last character of the variable name
    while (strng(ii) != " ")
	  --ii;
	endwhile

    if (kk > 1);
      arg_end(kk - 1) = ii;
    endif    
    vars{kk} = [ "S." strng(ii + 1: jj) ];
  endfor

  arg_end(end) = length (strng);

  ## This variables are used in the eval function to evaluate True/False, 
  ## so don't remove it!
  T = ".true.";
  F = ".false.";
  ## Loop through every variable guess variable type
  for kk = 1:nvars
    arg = strng(arg_start(kk):arg_end(kk));
    arglit = islit(arg_start(kk):arg_end(kk))';

    # complex numbers
    if (! any (arglit))
      bra = strfind (arg, "(");
      ckt = strfind (arg, ")");
      if (! isempty (bra))
	    list = [];
	    for i=1:length(bra)
	      list = [ list, eval([ "complex", arg(bra(i):ckt(i)) ])];
	    endfor
	    arg = num2str(list);
      endif
    endif

    ## Remove commas in non literal string...
    commas = (! arglit && arg == ",");
    if (any (commas))
      arg(commas) = " ";
    endif

    if (any (arglit))
      ## We are parsing a variable that is literal string
      arg = [ "{" arg "};"];
    elseif (! isempty (find (arg == "T" || arg == "F", 1))),
      ## We are parsing a boolean variable
      arg = [ "{" arg "};" ];
    else
      ## We are parsing a numerical array
      arg = [ "[" arg "];"];
    endif
    ## Eval the modified syntax in Octave
    eval ([vars{kk} " = " arg]);
  endfor
endfunction


## Parse the literal declarations of strings and change to Octave syntax
function [strng, is_lit] = parse_literal_strings (strng)

  len = length (strng);
  add_squote = [];        ## Positions to add a scape single quote on syntax
  rem_dquote = []; ## Positions to remove a double quote scape on syntax
  ii = 1;
  while (ii < len)
    if (strng(ii) == "'") ## Opening string with single quote...
      ++ii;
      while ((ii < len && strng(ii) != "'") || strcmp (strng(ii:ii+1), ''''''))
        ++ii; 
        if strcmp (strng(ii-1:ii), ''''''),
          ++ii;
        endif
      endwhile
    endif
    if (strng(ii) == '"')  ## Opening string with double quote...
      strng(ii) = "'";     ## Change to single quote
      ++ii;
      while (strng(ii) != '"' || strcmp (strng(ii:ii+1),'""') && ii < len)
        ## Check for a possible single quote here
        if (strng(ii) == "'")
          add_squote = [ add_squote ii ];
        endif
        ++ii; 
        if (strcmp (strng(ii-1:ii), '""'))
          rem_dquote = [ rem_dquote ii-1 ];
          ++ii;
        endif
      endwhile
      strng(ii) = "'";     ## Change to single quote
    endif   
    ++ii;
  endwhile
  for ii = 1:length (add_squote);
      strng = [ strng(1:add_squote(ii)) strng(add_squote(ii):end) ];
  endfor
  for ii = 1:length(rem_dquote);
      strng = [ strng(1:rem_dquote(ii)-1) strng(rem_squote(ii)+1:end) ];
  endfor

  ## Now everything should be in Octave string syntax
  ## Classify syntax as literal or regular expression
  ii = 1;
  len = length (strng);
  is_lit = zeros(len, 1);
  while (ii < len)
    if (strng(ii) == "'")  ## Opening string with single quote...
      is_lit(ii) = 1;
      ++ii;
      while ((ii < len && strng(ii) != "'") || strcmp (strng(ii:ii+1), "''")) 
        is_lit(ii) = 1;
        ++ii;
        if (strcmp (strng(ii-1:ii), '''''')),
          is_lit(ii) = 1;
          ++ii;
        endif
      endwhile
      is_lit(ii) = 1;    
    endif
    ++ii;
  endwhile

endfunction


## Read complex (data by Ryusuke Numata)
%!test
%! fn = tempname ();
%! fid = fopen (fn, "w");
%! fprintf (fid, "&test\n");
%! fprintf (fid, " z = (1.1,2.2), (0.,1.), (1.,0.)\n");
%! fprintf (fid, " y = (9,8)\n");
%! fprintf (fid, " a = 1. 2. 3.\n");
%! fprintf (fid, [' c = "(test)"' "\n" '\\' "\n"]);
%! fclose (fid);
%! nm = read_namelist (fn);
%! unlink (fn);
%! assert (nm.test.z, [1.1+2.2i, 1i, 1], eps);
%! assert (nm.test.y, 9+8i, eps);
%! assert (nm.test.a, [1 2 3], eps);

## Check if namelists with a whitespace before the ending / can be read
%!test
%! fn = tempname ();
%! fid = fopen (fn, "w");
%! fprintf (fid, "&test\n");
%! fprintf (fid, " a = 1,\n");
%! fprintf (fid, " /\n");
%! fclose (fid);
%! nm = read_namelist (fn);
%! unlink (fn);
%! assert (nm.test.a, 1, eps);

## Check if character sequences can contain the / character
%!test
%! fn = tempname();
%! fid = fopen (fn, "w");
%! fprintf (fid, "&test\n");
%! fprintf (fid, " a = '/',\n"); % inside apostrophes
%! fprintf (fid, " b = ""/"",\n"); % inside double quotes
%! fprintf (fid, " c = '""/',\n"); % with double quotes inside apostrophes
%! fprintf (fid, " d = ""'/"",\n"); % with apostrophes inside double quotes
%! fprintf (fid, "/\n");
%! fclose (fid);
%! nm = read_namelist (fn);
%! unlink (fn);
%! assert (strcmp(nm.test.a, '/'), 1, eps);
%! assert (strcmp(nm.test.b, '/'), 1, eps);
%! assert (strcmp(nm.test.c, '"/'), 1, eps);
%! assert (strcmp(nm.test.d, '''/'), 1, eps);
