## Copyright (C) 2019-2021 Ketan M. Patel
##
## This program is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see
## <https://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {} {@var{str} =} toJSON (@var{obj})
## @deftypefnx {} {@var{str} =} toJSON (@var{obj}, @var{prec})
## @deftypefnx {} {@var{str} =} toJSON (@var{obj}, @var{compact})
## @deftypefnx {} {@var{str} =} toJSON (@var{obj}, @var{prec}, @var{compact})
## Convert any Octave @var{obj} into a compact JSON string.
##
## toJSON strives to convert Octave vectors, matrices and/or ND arrays to
## equivalent JSON arrays.  Special provisions are made to handle +/-Inf and
## complex numbers, which are conventionally not permitted is JSON string.
##
## Input arguments:
##
## @itemize
## @item
## @var{obj}, any Octave object: double, float, int, logical, complex, char, etc.
## There are no limitations on the class accepted,  but classes not
## permitted in JSON are merely referenced by classname, along the lines of
## @code{"[octave_com_object]"}, and the contents are lost.
## @end item
##
## @item
## @var{prec}, a numeric value, specifies number of significant digits for
## number-to-string conversion.  The default value of @var{prec} is 15.
## @end item
##
## @item
## @var{compact} (logical; default value is FALSE) specifies whether to return
## Octave struct arrays as arrays of JSON objects or JSON objects of arrays.
## Consider an Octave struct array with fields 'x' and 'y':
##
## @itemize
## @item
## Leaving as FALSE returns a JSON array of objects, i.e.:
##
## @w{   '[@{"x": ..., "y": ...@}, @{"x": ..., "y": ...@}]'   }
## @end item
##
## @item
## Changing to TRUE returns a JSON object of arrays, i.e.:
#
## @w{  '@{"x": [...], "y": [...]@}'         }
## @end item
## @end itemize
##
## @end item
## @end itemize
##
## Special cases:
##
## The specification for JSON does not allow +/-Inf or complex numbers;
## nevertheless, provisions are made here to enable these important numbers:
##
## @itemize
## @item
## Octave numbers +/-Inf return as numeric string '+/-1e999' which
## should automatically revert to +/-Inf when parsed.
## @end item
##
## @item
## Complex numbers return as JSON object @code{@{"re":..., "im":...@}}
## @end item
## @end itemize
##
## Apparent JSON strings are left unquoted.  This allows recursive use of toJSON.
## To prevent this, append a whitespace to the string.
##
## The bodies of Octave inline functions are stored as string; however, reference to
## values external to inline function will be lost. e.g.
##
## @w{           @@(x) a*x   =>   "@@@@(x) a*x"   }
##
##
## @seealso{fromJSON}
## @end deftypefn

## Author: Ketan M. Patel <kmpatel@roc-photonics.com>
## Created: 2019-06-01

function str = toJSON ( obj='', PREC=[], COMPACT=[] );

  if( isbool(PREC) );
    [PREC,COMPACT] = {[],PREC}{:};
  elseif ~(isempty(PREC) || isnumeric(PREC));
    warning ("toJSON.m: invalid PREC\n");
    PREC = [];
  elseif ~(isempty(COMPACT) || isbool(COMPACT));
    warning ("toJSSON.m: invalid COMPACT\n");
    COMPACT = [];
  endif

  # set defaults
  isempty(PREC)    && (PREC=15);
  isempty(COMPACT) && (COMPACT=false);

  fmt = sprintf('%%.%dg,',fix(abs(PREC)));
  opt = struct('fmt',fmt,'prec',PREC,'compact',COMPACT);

  if( nargin == 0 );
    str = '';
  else
    str = _tojson_(obj,opt);
  endif

endfunction

## convert any object into some kind of JSON string
function [str] = _tojson_ ( obj, opt );

  ND = ndims(obj);

  if( iscomplex(obj) );

      obj = {real(obj) imag(obj)};

      if( ~opt.compact );
        obj = _map_(@num2cell,obj);
      endif

      str = _tojson_(struct('re',obj{1},'im',obj{2}),opt);
  ## end iscomplex

  elseif( isstruct(obj) && (ND == 2 || opt.compact) );

      keys = __fieldnames__(obj);
      vals = struct2cell(obj);

      if( isempty(vals) );
        str = '{}';

      elseif( isscalar(obj) || opt.compact );

        if( ~isscalar(obj) );
           vals = _nestdim_(vals,1);
        endif

        str  = _map_(@(k,v)['"',k,'":',_tojson_(v,opt)], keys(:),vals(:));
        str  = _csv_('{',str,'}');

      elseif( ~isvector(obj) );   # 2D or ND struct array
        str = _tojson_(_nestdim_(obj,1),opt);

      else   # 1D struct array
      ##  NOTE:  str = _tojson_(num2cell(obj,opt))  is a simpler but very slow alternative

        for i = 1:rows(vals);               # join key value pairs
          kv(i,:) = _map_(@(k,v)['"',k,'":',_tojson_(v,opt)], keys(i), vals(i,:));
        endfor

        for i = 1:columns(kv);              # assemble key-value into struct
          str{i} = _csv_('{',kv(:,i),'}');
        endfor

        str = _csv_('[',str,']');
      endif
  ## end isstruct

  elseif( ND > 2 );   # nest ND array, c-style
      str = _tojson_(_nestdim_(obj,ND),opt);

  elseif( iscell(obj) );

      try   # try as matrix first
        ~cellfun(@ischar,obj) || error('no');
        str = _tojson_(reshape([obj{:}],size(obj)),opt);
      catch; if( isempty(obj) );
        str = '[]';
      elseif( ~isvector(obj) );
        str = _tojson_(_nestdim_(obj,1),opt);
      else
        str = _csv_('[', _map_(@(o) _tojson_(o,opt),obj), ']');
      endif; end_try_catch;
  ## end iscell

  elseif( isnumeric(obj) || isbool(obj) );

      ## stringify
      if( isbool(obj) );
        str = _csv_('',{'false','true'}(obj.'+1),'');

      else
        obj( nans=isnan(obj) ) = NaN;   # standardize NaN,nan,NA
        str = sprintf(opt.fmt,obj.')(1:end-1);

        ## GRRR! JSON is not IEEE754 complain;  hacks to transmit Inf and NaN
        any(isinf(obj)) && (str = _rep_(str,'Inf','1e999'));
        any(nans)       && (str = _rep_(str,'NaN','null' ));

      endif

      ## bracket string
      if( size(obj) > 1 );
        idx = strfind(str,',');
        c   = columns(obj);
        str(idx(c:c:end)) = ';';     # replace end of row ','  with ';'
        str = ['[['  _rep_(str,';','],[')   ']]'];
      elseif( numel(obj) ~= 1 );    # NOTE:  either empty or vector
        str = ['[' str ']'];
      endif
  ## end isnumeric || isbool


  elseif( ischar(obj) );

      ## 2D array of chars, make it a column vector of strings
      if( rows(obj)>1 );
        str = _tojson_(mat2cell(obj,ones(1,rows(obj)),columns(obj)),opt);
      ## else quote it, if not already JSON string (i.e. object/struct/quoted string)
      elseif( ~(numel(str=obj) && strfind('{}[]""',obj([1,end])))  );
        str = ['"' _rep_(obj,'"','\"') '"'];
      end
  ## end ischar

  elseif( is_function_handle(obj) );

      str = func2str(obj);
      str(1) == "@" || (str = ['@(x) ' str '(x)']);
      str = ['"@' str '"'];

  else
      str =  ['"[' class(obj) ']"'];
  endif

endfunction   ## _tojson()


##========================= helpers =======================

function str1 = _rep_ ( str, pat, rep );
  str1 = strrep(str,pat,rep,'overlaps',false);

endfunction


function obj = _map_ ( fn, varargin );
  obj = cellfun(fn,varargin{:},'UniformOutput',false);
endfunction


function C = _nestdim_ ( obj, D );
  index.type = '()';
  index.subs(1:ndims(obj)) = {':'};

  for i = 1:size(obj,D);
    index.subs(D) = i;
    C{i} = squeeze(subsref(obj,index)); # allow rows => columns
  endfor
endfunction


function str = _csv_ ( a, c, b );
  c      = c(:).';
  c(2,:) = ',';
  str = [a c{1:end-1} b];
endfunction


%!test ## invalid args
%!warning <invalid PREC>   toJSON(0,struct);
%!warning <invalid COMPACT> toJSON(0,:,struct);

%!test  ## no args
%!  assert(toJSON(),'');

%!test  ## empty string
%!  assert(toJSON(''),'""');

%!test  ## empty array
%!  assert(toJSON([]),'[]');

%!test  ## zero
%!  assert(toJSON(0),"0")

%!test  ## false
%!  assert(toJSON(false),'false')

%!test  ## float
%!  assert(toJSON(pi),'3.14159265358979')

%!test  ##  PREC input arg test
%!  assert(toJSON(pi,  0),'3')
%!  assert(toJSON(pi,  5),'3.1416')
%!  assert(toJSON(pi, -5),'3.1416')
%!  assert(toJSON(pi, 25),'3.141592653589793115997963')
%!  assert(toJSON(pi,  :),'3.14159265358979')
%!  assert(toJSON(pi, []),'3.14159265358979')
%!  assert(toJSON(pi, false),'3.14159265358979');
%!  assert(toJSON(pi, {}),'3.14159265358979');

%!test  ## number single
%!  assert(toJSON(single(pi)),'3.14159274101257')

%!test  ## number int8
%!  assert(toJSON(int8(pi)),'3')

%!test  ## number int32
%!  assert(toJSON(int32(pi)),'3')

%!test  ## number string
%!  assert(toJSON("3"),'"3"')

%!test  ## string
%! assert(toJSON("abcdefg"), '"abcdefg"');

%# unknown class
%!testif HAVE_JAVA
%! if (usejava ("jvm"))
%!  obj = javaObject ("java.math.BigDecimal", 1.0);
%!  assert(toJSON(obj), '"[java.math.BigDecimal]"');
%! endif


%!test  ## apparent JSON string, do not quote
%!  assert(toJSON('[]'),'[]');
%!  assert(toJSON('[1,2,     3]'),'[1,2,     3]');
%!  assert(toJSON('{}'),'{}');
%!  assert(toJSON('{"a":4}'),'{"a":4}');
%!  assert(toJSON('""'),'""');

%!test  ## apparent JSON string blocked, quote it
%!  assert(toJSON('"abc def" '),'"\"abc def\" "');

%!test  ## vectors
%!  assert(toJSON([1,2,3]),'[1,2,3]')
%!  assert(toJSON([1;2;3]),'[1,2,3]')

%!test  ## vector with PREC
%!  assert(toJSON(pi*(1:4),3),'[3.14,6.28,9.42,12.6]')

%!test  ## matrix
%!  assert(toJSON([1,2,3;13,14,15]),'[[1,2,3],[13,14,15]]')

%!test  ## boolean 2D array
%!  assert(toJSON(![1 1;0 1]),'[[false,false],[true,false]]')

%!test  ## ND array
%!  assert(toJSON(reshape(1:8,2,2,2)),'[[[1,3],[2,4]],[[5,7],[6,8]]]')

%!test  ## more N ND array
%!  ndmat = ones(2,2,2,3);
%!  ndmat([4,9,21]) = [4,9,21];
%!  json = toJSON(ndmat);
%!  assert(json,'[[[[1,1],[1,4]],[[1,1],[1,1]]],[[[9,1],[1,1]],[[1,1],[1,1]]],[[[1,1],[1,1]],[[21,1],[1,1]]]]')

%!test ## string array
%! assert(toJSON(["a";"bc";"defg"]), '["a   ","bc  ","defg"]');

%!test   ## string array
%! assert(toJSON(["a";"bc";"defg"]'), '["abd"," ce","  f","  g"]');

%!test   ## cell vector
%!  assert(toJSON({1,2,3}),'[1,2,3]')
%!  assert(toJSON({1;2;3}),'[1,2,3]')

%!test   ## mixed cell vector
%!  assert(toJSON({1,2,3,"a"}),'[1,2,3,"a"]')

%!test   ## cell array of numerical vectors
%!  assert(toJSON({[1,2,3];[3,4,5]}),'[[1,2,3],[3,4,5]]')

%!test   ## numerical ND cell array (look just like ND numerical array)
%!  json = toJSON(num2cell(reshape(1:8,2,2,2)));
%!  assert(json,'[[[1,3],[2,4]],[[5,7],[6,8]]]')

%!test   ## numerical ND cell array, with PREC
%! c = num2cell(reshape(1:8,2,2,2)); c{5} = pi;
%!  assert(toJSON(c,5),'[[[1,3],[2,4]],[[3.1416,7],[6,8]]]')

%!test   ## mixed ND cell array
%! c = num2cell(reshape(1:8,2,2,2)); c{5} = "a";
%!  assert(toJSON(c),'[[[1,3],[2,4]],[["a",7],[6,8]]]')

%!test   ## structure numbers
%!  assert(toJSON(struct(), true),'{}')

%!test   ## structure numbers
%!  assert(toJSON(struct("a",3,"b",5), true),'{"a":3,"b":5}')

%!test   ## structure string
%!  s = struct("a","hello","b",4);
%!  assert(toJSON(s, true),'{"a":"hello","b":4}')

%!test   ## structure string array
%!  s = struct("a","","b",4); s.a = {"hello","bye"};
%!  assert(toJSON(s, true),'{"a":["hello","bye"],"b":4}')

%!test   ## structure array COMPACT=false
%!  assert(toJSON(struct("a",{3.125;3.125}), false),'[{"a":3.125},{"a":3.125}]')

%!test   ## structure array  COMPACT=true
%!  assert(toJSON(struct("a",{3.125;3.125}), true),'{"a":[3.125,3.125]}')
%!  assert(toJSON(struct("a",{pi;pi}), 5,    true),'{"a":[3.1416,3.1416]}')

%!test   ## structure array 2D
%!  s = struct("a",{1 3;2 4},"b",{11 13;12 14});
%!  assert(toJSON(s, true),'{"a":[[1,3],[2,4]],"b":[[11,13],[12,14]]}')

%!test   ## structure array 2D COMPACT=false
%!  s = struct("a",{1 3;2 4},"b",{11 13;12 14});
%!  assert(toJSON(s, false),'[[{"a":1,"b":11},{"a":3,"b":13}],[{"a":2,"b":12},{"a":4,"b":14}]]')

%!test   ## mixed cell array
%!  assert(toJSON({1,2,3,"a",struct("a",3)}, true),'[1,2,3,"a",{"a":3}]')

%!test  ## complex number
%!  assert(toJSON(i, true),'{"re":0,"im":1}');

%!test    ## complex number 1D array
%!  assert(toJSON([i,1], true),'{"re":[0,1],"im":[1,0]}');

%!test  ## complex number COMPACT=false,
%!  assert(toJSON([i,1], false),'[{"re":0,"im":1},{"re":1,"im":0}]');

%!test  ## test complex number 2D array
%!  assert(toJSON([i 1;2 i*3],true),'{"re":[[0,1],[2,0]],"im":[[1,0],[0,3]]}');

%!test  ## struct with complex number
%!  assert(toJSON(struct('a',1+i,'b',3),true), '{"a":{"re":1,"im":1},"b":3}');

%!test ## struct ARRAY with complex number
%!  json = toJSON(struct('a',{1;i},'b',{5;2}),true);
%!  assert(json, '{"a":{"re":[1,0],"im":[0,1]},"b":[5,2]}');

%!test ## struct ARRAY with complex number COMPACT=false,
%!  json = toJSON(struct('a',{1;i},'b',{5;2}),false);
%!  assert(json, '[{"a":1,"b":5},{"a":{"re":0,"im":1},"b":2}]');

%!test ## struct ARRAY with complex number COMPACT=false,
%!  json = toJSON(struct('a',{[1 2i];[3 i]},'b',{5;2}),false);
%!  assert(json, '[{"a":[{"re":1,"im":0},{"re":0,"im":2}],"b":5},{"a":[{"re":3,"im":0},{"re":0,"im":1}],"b":2}]');

%!test ## ND struct array
%!  json=toJSON(struct('a',num2cell(reshape(1:8,2,2,2))),true);
%!  assert(json, '{"a":[[[1,3],[2,4]],[[5,7],[6,8]]]}');

%!test ## ND struct array  COMPACT=false,
%!  json=toJSON(struct('a',num2cell(reshape(1:8,2,2,2))),false);
%!  assert(json, '[[[{"a":1},{"a":3}],[{"a":2},{"a":4}]],[[{"a":5},{"a":7}],[{"a":6},{"a":8}]]]');

%!test ## inline function
%!  assert(toJSON(@sin),'"@@(x) sin(x)"')
%!  assert(toJSON(@(a,b)a+b+c),'"@@(a, b) a + b + c"')

%# struct with java object
%!testif HAVE_JAVA
%! if (usejava ("jvm"))
%!  obj = javaObject ("java.math.BigDecimal", 1.0);
%!  assert(toJSON(struct('a',obj)), '{"a":"[java.math.BigDecimal]"}');
%! endif


%!test   ## structure array   DEFAULT COMPACT
%!  s = struct("a",{3.125;3.125});
%!  assert(toJSON(s),'[{"a":3.125},{"a":3.125}]')

%!test  %% jsondecode's a big test
%! var1 = struct ('para', ['A meta-markup language, used to create ' ...
%!                         'markup languages such as DocBook.'], ...
%!                'GlossSeeAlso', {{'GML'; 'XML'}});
%! var2 = struct ('ID', 'SGML', 'SortAs', 'SGML', ...
%!                'GlossTerm', 'Standard Generalized Markup Language', ...
%!                'Acronym', 'SGML', 'Abbrev', 'ISO 8879:1986', ...
%!                'GlossDef', var1, 'GlossSee', 'markup');
%! data  = struct ('glossary', ...
%!                struct ('title', 'example glossary', ...
%!                        'GlossDiv', struct ('title', 'S', ...
%!                                            'GlossList', ...
%!                                            struct ('GlossEntry', var2))));
%! exp = ['{' , ...
%!     '"glossary":{', ...
%!         '"title":"example glossary",', ...
%! 		'"GlossDiv":{', ...
%!             '"title":"S",', ...
%! 			'"GlossList":{', ...
%!                 '"GlossEntry":{', ...
%!                     '"ID":"SGML",', ...
%! 					'"SortAs":"SGML",', ...
%! 					'"GlossTerm":"Standard Generalized Markup Language",', ...
%! 					'"Acronym":"SGML",', ...
%! 					'"Abbrev":"ISO 8879:1986",', ...
%! 					'"GlossDef":{', ...
%!                         '"para":"A meta-markup language, ', ...
%!                         'used to create markup languages such as DocBook.",', ...
%! 						'"GlossSeeAlso":["GML","XML"]', ...
%!                     '},', ...
%! 					'"GlossSee":"markup"', ...
%!                 '}', ...
%!             '}', ...
%!         '}', ...
%!     '}', ...
%! '}'];
%! assert (toJSON (data), exp);

%!test  %% jsondecode's another big Test
%! var1 = struct ('id', {0; 1; 2}, 'name', {'Collins'; 'Hays'; 'Griffin'});
%! var2 = struct ('id', {0; 1; 2}, 'name', {'Osborn'; 'Mcdowell'; 'Jewel'});
%! var3 = struct ('id', {0; 1; 2}, 'name', {'Socorro'; 'Darla'; 'Leanne'});
%! data = struct (...
%!   'x_id', {'5ee28980fc9ab3'; '5ee28980dd7250'; '5ee289802422ac'}, ...
%!   'index', {0; 1; 2}, ...
%!   'guid', {'b229d1de-f94a'; '39cee338-01fb'; '3db8d55a-663e'}, ...
%!   'latitude', {-17.124067; 13.205994; -35.453456}, ...
%!   'longitude', {-61.161831; -37.276231; 14.080287}, ...
%!   'friends', {var1; var2; var3});
%! exp  = ['[', ...
%!   '{', ...
%!     '"x_id":"5ee28980fc9ab3",', ...
%!     '"index":0,', ...
%!     '"guid":"b229d1de-f94a",', ...
%!     '"latitude":-17.124067,', ...
%!     '"longitude":-61.161831,', ...
%!     '"friends":[', ...
%!       '{', ...
%!         '"id":0,', ...
%!         '"name":"Collins"', ...
%!       '},', ...
%!       '{', ...
%!         '"id":1,', ...
%!         '"name":"Hays"', ...
%!       '},', ...
%!       '{', ...
%!         '"id":2,', ...
%!         '"name":"Griffin"', ...
%!       '}', ...
%!     ']', ...
%!   '},', ...
%!   '{', ...
%!     '"x_id":"5ee28980dd7250",', ...
%!     '"index":1,', ...
%!     '"guid":"39cee338-01fb",', ...
%!     '"latitude":13.205994,', ...
%!     '"longitude":-37.276231,', ...
%!     '"friends":[', ...
%!       '{', ...
%!         '"id":0,', ...
%!         '"name":"Osborn"', ...
%!       '},', ...
%!       '{', ...
%!         '"id":1,', ...
%!         '"name":"Mcdowell"', ...
%!       '},', ...
%!       '{', ...
%!         '"id":2,', ...
%!         '"name":"Jewel"', ...
%!       '}', ...
%!     ']', ...
%!   '},', ...
%!   '{', ...
%!     '"x_id":"5ee289802422ac",', ...
%!     '"index":2,', ...
%!     '"guid":"3db8d55a-663e",', ...
%!     '"latitude":-35.453456,', ...
%!     '"longitude":14.080287,', ...
%!     '"friends":[', ...
%!       '{', ...
%!         '"id":0,', ...
%!         '"name":"Socorro"', ...
%!       '},', ...
%!       '{', ...
%!         '"id":1,', ...
%!         '"name":"Darla"', ...
%!       '},', ...
%!       '{', ...
%!         '"id":2,', ...
%!         '"name":"Leanne"', ...
%!       '}', ...
%!     ']', ...
%!   '}', ...
%! ']'];
%! assert (toJSON (data), exp);

