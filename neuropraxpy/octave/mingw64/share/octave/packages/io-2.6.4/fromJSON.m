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
## @deftypefn {} {@var{obj} =} fromJSON (@var{str})
## @deftypefnx {} {@var{obj} =} fromJSON (@var{str}, @var{sarray})
## Convert a JSON string into a native Octave object.
##
## fromJSON especially strives to convert numerical JSON arrays into Octave
## vector, matrix or ND array.  Special provisions are made to recognize
## +/-Inf, NaN and complex numbers, which are conventionally not permited in
## JSON strings.
##
## Input arguments:
##
## @itemize
## @item
## @var{str} is a JSON string.
## @end item
##
## @item
## @var{sarray}, (default TRUE) logical value that determines how JSON member
## arrays are parsed.  Setting it to FALSE is recommended for safer parsing of
## non-numerical, mixed-class or mixed-size arrays JSON payloads.
##
## Leave @var{sarray} set to TRUE for fast parsing of numerical JSON arrays and
## objects.  Octave vectors, matrices, ND arrays and struct arrays are returned
## as much as possible, otherwise returned as a combination of vectors/matrices
## and cell arrays.
##
## Set @var{sarray} to FALSE if, with fast parsing, output does not match
## expections, particularly if @var{str} mainly comprises JSON objects/arrays
## with strings.   All JSON member arrays are returned as (nested) Octave cell
## arrays.
## @end item
## @end itemize
##
## Output:
##
## @itemize
## @item
## @var{obj} is a native Octave object.  JSON number, logical, array, and
## object strings are converted to Octave numbers, logicals, vectors and
## structs, respectively.  Quoted or unrecognizable JSON fragments are returned
## as NaN values.
## @end itemize
##
## Special numbers:
##
## The specification for JSON does not allow +/-Inf, NaN or complex numbers;
## nevertheless, provisions are made here to enable these important numbers:
##
## @itemize
## @item
## JSON number strings '+/-1e308' are rounded to +/-Inf.
## @end item
##
## @item
## Unquoted JSON string 'null' is converted to NaN.
## @end item
##
## @item
## JSON objects, or arrays thereof, with exclusive members "real" and "imag"
## (or "re" and "im") will be converted to Octave complex numbers, vectors or
## matrices, respectively.
##
## @example
## @w{e.g. '@{"re":3,"im":1@}'     => 3 + 1i               }
## @w{     '[1,@{"re":3,"im":1@}]' => [ 1 + 0i, 3 + 1i ]   }
## @end example
## @end item
## @end itemize
##
## @seealso{toJSON}
## @end deftypefn

## Author: Ketan M. Patel <kmpatel@roc-photonics.com>
## Created: 2019-06-01

function [obj] = fromJSON ( str=' ', SARRAY=[] );

  if ~( isnumeric(SARRAY) || isbool(SARRAY) );
    _warn_("invalid SARRAY");
    SARRAY = [];
  endif

  ## set defaults
  ischar(str) && str || (str=' ');
  ~isempty(SARRAY)   || (SARRAY=true);

  str(1) > 126 && (str = str( find(str<127,1) : end ));   # drop leading encoding chars

  wstate = warning('off',"Octave:num-to-str");
  obj    = _fromjson_(str,SARRAY);
  warning(wstate);

endfunction

function [obj, remain] = _fromjson_ ( str, SARRAY );

    [btag, block, remain] = _get_block_(str);

    switch( btag );
      case '[';  obj = _to_array_  (block, SARRAY);
      case '{';  obj = _to_struct_ (block, SARRAY);
      case '"';  obj = _to_string_ (block, SARRAY);
      otherwise; obj = _to_number_ (block, SARRAY);
    endswitch

    remain = regexprep(remain,'^[\s,]*',''); #!!! keep this HERE, not in _get_block_

endfunction

## gets block quoted-string/array/object block from string
##   this will work with single-quoted strings, but only double-quoted strings are safe
function [btag, block, remain] = _get_block_ (str);

    [open, btag] = regexp(str,'[^\s,]','once','start','match');

    switch( btag );     # find ALL bracket tag (open/close) positions

      case '[';  idx = [strfind(str,'[') -strfind(str,']')];    # strfind is 100x faster than regexp
      case '{';  idx = [strfind(str,'{') -strfind(str,'}')];

      case {'"',"'"}; idx   = -strfind(str,btag); idx(1) *= -1; # all but first are closers
                      btag  = '"';      # regard single-quote as double-quote (lazy JSON)

      otherwise;  [block,remain] = strtok(str(open:end),',');
                  return;
    endswitch

    idx( '\' == str([1 abs(idx(2:end))-1]) ) = [];      # exclude escaped-tags (e.g.'\[', '\{', '\"', etc)

    ## filter out double-quoted (exclusively) block tags
    ( btag ~= '"' && (q = strfind(str,'"')  )           # find all double-quote marks
                  && (q = q(str(q-1) ~= '\')) > 1       # discard \", stop if only single " remains
                  && (idx = _bfilter_(idx, q))    );    # filter out quoted btags

    if ~( numel(idx) > 1 && ( close=-idx(2) ) > 0 );    # unless simple (non-nested) block...

        idx   = idx([~,i] = sort(abs(idx)));  # sort idx by abs(idx)

        if( ( ci=find(0 == cumsum(sign(idx)), 1) )  );
          close = -idx(ci);
        else
          close = numel(str)+1;
          _warn_(btag,str);
        endif
    end

    block  = str(  open+1 : close-1 );
    remain = str( close+1 : end     );

endfunction

function [arr] = _to_array_ ( str, SARRAY );

    ok = SARRAY && ~(    regexp(str,'\[\s*\[','once')    # no ND array
                      || regexp(str,':\s*[''"]','once')  # no struct array with strings
                      || strfind(str,'=') );             # no apparent assignment op
    if( ok );
      arr = regexprep( _rep_(str, Inf), ',(?=\s*\[)',';');  # JSON to Octave array syntax

      if( strfind(str,'{') );   # JSON object
          arr = [ _lazyJSON_ "; arr=_deep_complex_([" _rep_(arr, struct) "])" ];
      else                      # JSON numerical? array
          arr = [ "arr=[" arr "]" ];
      endif

      eval([ arr "; ok = isnumeric(arr) || isstruct(arr);" ], "ok=false;");

    endif

    if( ~ok );   # this can be slow, avoid getting here if possible

      arr = {};

      while( str );  # grind thru string, one array element at a time
          [arr{end+1} str] = _fromjson_(str,SARRAY);
      endwhile;

      if( SARRAY );
          switch numel(arr);
            case 0;     arr = [];
            case 1;     arr = arr{1};
            otherwise;  arr = _ndarray_(arr);
          endswitch
      endif

    endif

endfunction

function [obj] = _to_struct_ ( str, SARRAY );

    obj = struct();

    ## we're making this harder than needed in order to permit lazy JSON
    ## i.e. unquoted and single quote keys (but! start/end quote chars must match)

    while( ( q=regexp(str, '[^\s,:]', 'once','match') )       # detect key quote-char or empty str
       &&  ( m=regexp(str, _qrgx_(q), 'once','names') ).k );  # get key,val or fail

      [obj.(m.k) str] = _fromjson_(m.v, SARRAY);

    endwhile

    regexp(str,'[^\s]','once') && _warn_('}', str);
    obj = _complex_( obj );    # _deep_complex_ not necessary here

endfunction

function [str] = _to_string_ ( str, SARRAY );

    if( SARRAY && (numel(str) > 2 && str(1:2) == '@') );
        try    str = str2func(str(2:end));
        catch  _warn_('@', str);
        end_try_catch;
    endif

endfunction

function [num] = _to_number_( str, SARRAY );

    if( strfind(str,'=') );   # guard against assignment expr
        num = 'error()';
    else
        num = ['num=[' _rep_(str,Inf) '];'];
    endif

    eval(num, ['_warn_("invalid frag",str); num=NaN;']);

endfunction

##========================= helpers =======================

## filter out quoted block tags
function [idx] = _bfilter_(idx,q);

  qo = q(1:2:end-1)'; # open quote (ignore unclosed quote)
  qc = q(2:2:end)';   # close quote

  ai = abs(idx);
  idx( any(qo < ai & ai < qc,1) ) = [];  # purge quoted block tags

endfunction

## replace string frags according to set pattern
function [str] = _rep_ ( str, pat );

  if isstruct(pat);
      pat = {'{','struct(',':',',','}',')'};
  else
      pat = {'null','NaN ','e308','e999','Infinity','Inf     ',"\n",' '};  # keep empty spaces
  endif

  do
    str = strrep(str,pat{1:2},'overlaps',false);
    pat(1:2) = [];
  until isempty(pat);

endfunction

## try to make ND array (either mat or cell)
function [c] = _ndarray_ ( c );

  sz = size(e = c{1}); t = class(e);

  if ~( ~ischar(e) && sz && cellfun(@(v)isa(v,t)&&size(v)==sz, c) );
      return;
  elseif( isscalar(e) );     # try matrix conversion, ok to fail if not uniform class
      try c = [c{:}]; end;
  elseif( isvector(e) );     # cell array of mat or cell array
      c = reshape([c{:}], numel(e), numel(c)).';
  else                       # make ND array
      index.type = "()";
      index.subs = repmat({':'},1,ndims(e)+1);
      i = numel(c);

      do
        index.subs{end} = i;
        e = subsasgn(e,index,c{i});
      until (--i) == 1;
      c = e;
  endif

endfunction

## convert complex number struct DEEP WITHIN structure to complex number
function [s] = _deep_complex_(s);

  if( isstruct(s) && isstruct( s=_complex_(s) ) );
     vals = cellfun(@_deep_complex_, struct2cell(s), 'uniformoutput', false);
     s    = cell2struct(vals, __fieldnames__(s));
  endif

endfunction

## convert complex number struct to complex number
function [s] = _complex_ ( s );

  if( numel( keys=__fieldnames__(s) ) == 2
  &&  ( ismember( k={'real','imag'}, keys) || ismember( k={'re','im'}, keys) )
  &&  isnumeric( re=[s.(k{1})] )
  &&  isnumeric( im=[s.(k{2})] )
  &&  size_equal(re,im) );

        s = reshape( complex(re,im), ifelse(isscalar(s), size(re), size(s)) );

  endif

endfunction

## for max conversion speeed, gaurd against common lazy JSON (unquoted keys)
function [str] = _lazyJSON_ ( );

  str = 'x="x";y="y";z="z";real=re="re";imag=im="im";r="r";rho="rho";theta="theta";phi="phi";';

endfunction

## compute regexp pattern for JSON object key (quoted or unquoted)
function [rgx] = _qrgx_(q);

  sum(q=="\"'") || (q='');
  rgx = ['[\s,]*' q '(?<k>.+?)' q '\s*:\s*(?<v>[^\s].*)' ];

endfunction


function [out] = _warn_ ( msg, frag='' );

  if( numel(msg) == 1 );
    switch(msg);
       case '{'; msg = "unclosed object";
       case '['; msg = "unclosed array";
       case '"'; msg = "unclosed quote";
       case '}'; msg = "malformed structure";
                 regexp(lastwarn,'unclosed') || ( frag=[frag '}'] );
       case '@'; msg = "invalid inline func string";
     endswitch
  endif

  frag && ( frag=["`" frag "`"] );
  numel(frag)>40 && (frag = [frag(1:27) ' ... ' frag(end-27:end)]);
  out = warning("fromJSON: %s %s\n",msg,frag);

endfunction


################################################################################
###############################   BIST   #######################################
################################################################################

%!test	##	input validation
%! assert( fromJSON(),[]); % ok, reference
%!warning <invalid SARRAY> fromJSON('',struct);
%!

%!test	##	invalid input validation
%! bad = {4,{},@sin,struct(),'',false,0,[1,2,3]};
%! assert(fromJSON(4),      []);
%! assert(fromJSON({}),     []);
%! assert(fromJSON(@sin),   []);
%! assert(fromJSON(struct), []);
%! assert(fromJSON(false),  []);
%! assert(fromJSON([1,2,3]),[]);

############### JSON number BIST #####################

%!test	##	number
%! assert( fromJSON('4'),4)

%!test	##	number string
%! assert( fromJSON('"string"'),"string")

%!test	##	bool
%! assert( fromJSON('true'),true)

%!test	##	round up to Inf
%! assert( fromJSON('1e308'),      Inf)
%! assert( fromJSON('-1e308'),    -Inf)

%!test  ## do NOT round up to Inf
%! assert( fromJSON('1e307'),    1e307)
%! assert( fromJSON('-1e307'),  -1e307)

%!test  ## automatically parse as Inf
%! assert( fromJSON('1e309'),      Inf)
%! assert( fromJSON('-1e309')     -Inf)
%! assert( fromJSON('1e999'),      Inf)
%! assert( fromJSON('-1e999'),    -Inf)

%!test	##	null
%! assert( fromJSON( 'null' ),NaN)

%!test  ## in case JSON spec commitee gets head out of ass
%! assert( fromJSON('Inf'),        Inf)
%! assert( fromJSON('-Inf'),      -Inf)
%! assert( fromJSON('Infinity'),   Inf)
%! assert( fromJSON('-Infinity'), -Inf)
%! assert( fromJSON('NaN'),        NaN)
%! assert( fromJSON('nan'),        NaN)

%!test	##	quoted null,Inf,etc (guard against false-positive, leave alone)
%! assert( fromJSON('"null"'),"null")
%! assert( fromJSON('"Inf"'),"Inf")
%! assert( fromJSON('"1e308"'),"1e308")

%!test  ## all of the above in array form
%! assert( fromJSON('[1,1e308,Inf,-Infinity,NaN,nan,null]'),
%!         [1 Inf Inf -Inf NaN NaN,NaN])

%!test	##	garbage (non-quoted, meaningless string)
%!warning <invalid> assert( fromJSON('garbage'),   NaN)

############### JSON aray BIST #####################

%!test	##	empty array
%! assert( fromJSON('[]',true),[]);

%!test	##	empty cell array
%! assert( fromJSON('[]',false),{});

%!test	##	single element array
%! assert( fromJSON('[1]',true),1);
%! assert( fromJSON('[1]',false),{1});

%!test	##	JSON array to Octave vector
%! assert( fromJSON('[1,2,3,4]', true),
%!         [1 2 3 4])

%!test	##	JSON array to Octave vector
%! assert( fromJSON('[[1],[2],[3],[4]]', true),
%!         [1;2;3;4])

%!test	##	JSON array to Octave cell array
%! assert( fromJSON('[1,2,3,4]', false),
%!         {1 2 3 4})

%!test	##	JSON array to Octave vector
%! assert( fromJSON('[[1],[2],[3],[4]]', false),
%!         {{1},{2},{3},{4}})

%!test	##	JSON nested array to Octave matrix
%! assert( fromJSON('[[1,2],[3,4]]', true),
%!         [1 2;3 4])

%!test	##	JSON nested array to nested Octave cell array
%! assert( fromJSON('[[1,2],[3,4]]', false),
%!         {{1 2},{3 4}})

%!test	##	JSON nested array to Octave ND array
%! assert( fromJSON('[[[1,3,5],[2,4,6]],[[7,9,11],[8,10,12]]]', true),
%!         reshape(1:12,2,3,2));

%!test	##	numerical ND cell array
%! assert( fromJSON('[[[1,3,5],[2,4,6]],[[7,9,11],[8,10,12]]]', false),
%!         {{{1,3,5},{2,4,6}},{{7,9,11},{8,10,12}}});

%!test	##	test default SARRAY
%! assert( fromJSON('[[1,2],[3,4]]'),
%!         fromJSON('[[1,2],[3,4]]',true))

%!test	##	bool array
%! assert( fromJSON('[true,false,false,true]'),
%!         !![1 0 0 1])

%!test	##	mixed bool and number array
%! assert( fromJSON("[[true,3],[false,1]]"),
%!         [1 3;0 1])

%!test	##	more N numerical ND array
%! json = "[[[[[1,3],[2,4]],[[5,7],[6,8]]],[[[11,13],[12,14]],[[15,17],[16,18]]]],[[[[21,23],[22,24]],[[25,27],[26,28]]],[[[31,33],[32,34]],[[35,37],[36,38]]]]]";
%! assert( fromJSON(json),
%!         reshape([1:8 11:18 21:28 31:38],2,2,2,2,2));

%!test	##	mismatch nested array (mix of scalar and cell array)
%! assert( fromJSON('[[1,2,3,4,5],[1,2]]', true),
%!         {[1 2 3 4 5] [1 2]})

%!test	##	more mismatched nested array
%! assert( fromJSON('[1,2,3,[2,3]]'),
%!         {1,2,3,[2,3]})

%!test	##	array of numerical array and mixed-class array
%! assert( fromJSON('[[1,2,3,"a"],[2,3,4,4]]', true),
%!         {{1 2 3 "a"},[2 3 4 4]})

%!test	##	mixed-class array
%! assert( fromJSON('[["a",2,3],[4,"b",5]]', true),
%!         {'a' 2 3; 4 'b' 5});

%!test	##	mismatch nested array, safe parsing to cell array
%! assert( fromJSON('[[1,2,3,4,5],[1,2]]', false),
%!         {{1 2 3 4 5},{1 2}})

%!test	##	mixed-class array, safe parsing to cell array
%! assert( fromJSON('[["a",2,3],[4,"b",5]]', false),
%!         {{'a' 2 3},{4 'b' 5}} );

%!test	##	more N numerical ND array
%! json = "[[[[[1,3],[2,4]],[[5,7],[6,8]]],[[[11,13],[12,14]],[[15,17],[16,18]]]],[[[[21,23],[22,24]],[[25,27],[26,28]]],[[[31,33],[32,34]],[[35,37],[36,38]]]]]";
%! json = regexprep(json,'(\d+)','"$1"'); % turn it input JSON array of strings
%! c    = cellfun(@num2str,num2cell(reshape([1:8 11:18 21:28 31:38],2,2,2,2,2)), 'uniformoutput', false);
%! assert( fromJSON(json),c);

%!test	##	JSON-like: with non-JSON, Octave, numerical notation (bonus feature)
%! assert( fromJSON('[Inf,-Inf,NaN,2i,pi,e]'),
%!         [Inf,-Inf,NaN,2*i,pi,e],1e-15);


%!test	##	beautified JSON vector
%! assert( fromJSON("\n[1,\n2\n]\n",true),
%!         [1,2])

%! assert( fromJSON("\n[1,\n2\n]\n",false),
%!         {1,2})

%!test	##	beautified JSON array
%! assert( fromJSON("[\n  [\n    1,\n    2\n  ],\n  [\n    3,\n    4\n  ]\n]",true),
%!         [[1 2];[3 4]])

%!test	##	beautified JSON array
%! assert( fromJSON("[\n  [\n    1,\n    2\n  ],\n  [\n    3,\n    4\n  ]\n]",false),
%!         {{1,2},{3,4}})

%!test	##	incomplete array
%! warning('off','all');
%! assert( fromJSON("[1,2,3  "),
%!         [1,2,3]);

%!test	##	more incomplete array
%! warning('off','all');
%! assert( fromJSON("[[1,2,3],[3"),
%!         {[1,2,3],[3]});

%!test	##	string with whitespaces
%! assert( fromJSON("\"te\nss      df\t t\""),
%!         "te\nss      df\t t")

%!test	##	char array
%! assert( fromJSON('["a","b","c"]'),
%!         {'a','b','c'})

%!test	##	array of string
%! assert( fromJSON('["test","list","more"]'),
%!         {'test',"list","more"})

%!test	##	escaped quote
%! assert( fromJSON ('"tes\"t"'),
%!         'tes\"t');

%!test	##	escaped quote in array
%! assert( fromJSON('["te\"t","list","more"]'),
%!         {'te\"t' 'list' 'more'})

%!test	##	garbage in array
%! warning('off','all');
%! assert( fromJSON('[1,garbage]'),     [1,NaN])

############### JSON object BIST #####################

%!test	##	empty object to empty struct
%! assert( fromJSON('{}',true), struct())
%! assert( fromJSON('{}',false),struct())
%! assert( fromJSON('{ }',false),struct())

%!test	##	struct to object
%! assert( fromJSON('{"a":3,"b":5}',true),
%!         struct("a",3,"b",5))

%!test	##	unclosed object
%!warning <unclosed>    assert(fromJSON('{a:3,b:4'),struct("a",3,"b",4));

%!test	##	string with colons (guards against JSON object false postive)
%! assert( fromJSON('["2012-11-12T10:35:32Z","2012-11-13T08:35:12Z"]'),
%!        {"2012-11-12T10:35:32Z", "2012-11-13T08:35:12Z"});

%!test	##	string with {} (guards against JSON object false postive)
%! assert( fromJSON('["some text {hello:3}","more text \"{hello:3}\""]'),
%!        {'some text {hello:3}', 'more text \"{hello:3}\"'});

%!test	##	lazy JSON object (unquoted and single-quote keys)
%! assert( fromJSON("{a:3,'b':5}",true),
%!         struct("a",3,"b",5))

%!test	##	bad (but passable) lazy JSON object, unquoted-key with quote char at end
%! assert( fromJSON("{a':3,b\":5}",true),
%!         struct("a'",3,'b"',5))

%!test	## bad (failing) JSON object (mismatched or unclosed quoted-keys)
%!warning <malformed> assert( fromJSON("{'a  :3}"), struct());
%!warning <malformed> assert( fromJSON("{'a\":3}"), struct());
%!warning <malformed> assert( fromJSON("{\"a :3}"), struct());
%!warning <malformed> assert( fromJSON("{\"a':3}"), struct());

%!test	##	keys (quoted and unquoted) with whitespace
%! assert( fromJSON('{"a":3,"   key with space  ": 4,  more white space  : 40}'),
%!         struct("a",3,"   key with space  ",4,"more white space",40))

%!test	##	object with duplicate key
%! assert( fromJSON('{"a":3,"a":5}'),
%!         struct("a",5))

%!test	##	empty object key-val
%! assert( fromJSON('{a:3,,,    ,     b   :5}'),
%!         struct("a",3,"b",5))

%!test	##	object with object
%! assert( fromJSON('{a:{b:2}}', true),
%!         struct('a',struct('b',2)));

%!test	##	object with object with object
%! assert( fromJSON('{a:{b:{c:3,d:4},e:5}}', true),
%!         struct('a',struct('b',struct('c',3,'d',4),'e',5)));

%!test	##	object with array to struct with array
%! assert( fromJSON('{a:[1,2,3,4]}', true),
%!         struct('a',[1 2 3 4]));

%!test	##	object with array to struct with cell array
%! assert( fromJSON('{a:[1,2,3,4]}', false),
%!         struct('a',{{1 2 3 4}}));

%!test	##	array of objects to struct array
%! assert( fromJSON('[{a:1},{a:2},{a:3},{a:4}]',true),
%!         struct('a',{1 2 3 4}));

%!test	##	array of objects to cell array
%! assert( fromJSON('[{a:1},{a:2},{a:3},{a:4}]',false),
%!         num2cell(struct('a',{1 2 3 4})));

%!test	##	object with 2x2 array to struct with 2x2 array
%! assert( fromJSON('{a:[[1,3],[2,4]]}', true),
%!         struct('a',[1 3;2 4]));

%!test	##	object with 2x2 array to struct with cell array
%! assert( fromJSON('{a:[[1,3],[2,4]]}', false),
%!         struct('a',{{{1,3},{2,4}}}));

%!test	##	2x2 array of object to struct array
%! assert( fromJSON('[[{a:1},{a:2}],[{a:3},{a:4}]]',true),
%!         struct('a',{1 2;3 4}));

%!test	##	2x2 array of object to cell array
%! assert( fromJSON('[[{a:1},{a:2}],[{a:3},{a:4}]]',false),
%!         { num2cell(struct('a',{1 2})), num2cell(struct('a',{3 4}))} );

%!test	##	**nested** object with array to struct array
%! assert( fromJSON('{"a":{"b":[1,2,3]}}',true ),
%!         struct("a",num2cell(struct("b",[1,2,3]))))  % <== struct array

%!test	##	**nested** object with array to cell array
%! assert( fromJSON('{"a":{"b":[1,2,3]}}',false),
%!         struct("a",struct("b",{{1,2,3}})))          % <== struct with array b

%!test	##	object with mixed-size arrays (will not honor SARRAY=true)
%! assert( fromJSON('{"a":[1,2],"b":[3,4,5]}',true),
%!         struct("a",[1,2],"b",[3,4,5]))

%!test	##	object with number and string (guard against turing string into char array)
%! assert( fromJSON('{"a":1,"b":"hello"}',true),
%!         struct("a",1,"b","hello"))

%!test	##	object with empty array  (gaurd against returning empty struct array)
%! assert( fromJSON('{"a":3,"b":[]}',true),
%!         struct("a",3,"b",[]))

%!test	##	object with colon value
%! assert( fromJSON('{"time": "10:35:00"}'),
%!         struct("time", "10:35:00"));

%!test	##	object with colon key
%! assert( fromJSON('{"ti:me": "10:35:00", ":tricky:" : 4}'),
%!         struct("ti:me", "10:35:00",":tricky:",4));

%!test	##	array of structure with value with colons
%! assert( fromJSON('[{"time": "10:35"},{"time": "10:54"}]', true),
%!         struct("time", {"10:35","10:54"}));

%!test	##	array of structure with value with  keys
%! assert( fromJSON('[{"ti:me": "10:35"},{"ti:me": "10:54"}]', true),
%!         struct("ti:me", {"10:35","10:54"}));

%!test	##	incomplete struct
%!warning <malformed> assert( fromJSON('{a:3,b   }', true),
%!                            struct('a',3));

%!test	##	incomplete struct
%!warning <malformed> assert( fromJSON('{a:3,b:   }', true),
%!                            struct('a',3));


%!test	##	struct with mixed class array SARRAY=true
%! assert( fromJSON('{"b":[1,2,{c:4}]}',true),
%!         struct('b',{{1,2,struct('c',4)}}));

%!test	##	struct with mixed class array SARRAY=false
%! assert( fromJSON('{"b":[1,2,{c:4}]}',false),
%!         struct('b',{{1,2,struct('c',4)}}));

%!test	##	2x2 array of struct
%! assert( fromJSON('[[{a:1},{a:3}],[{a:2},{a:4}]]'),
%!         struct('a',{1 3;2 4}));

%!test	##	ND array of struct to ND struct array
%! assert( fromJSON('[[[{a:1},{a:3}],[{a:2},{a:4}]],[[{a:11},{a:13}],[{a:12},{a:14}]]]'),
%!         struct('a',num2cell(reshape([1:4 11:14],2,2,2))));

%!test	##	mixed array with struct
%! assert( fromJSON('[2,{a:3,"b":5}]'),
%!         {2,struct("a",3,"b",5)})

%!test	##	more mixed array with struct
%! assert( fromJSON('[{a:3,"b":5},{a:3}]'),
%!         {struct("a",3,"b",5),struct("a",3)})

%!test	##	garbage in struct
%! warning('off','all');
%! assert( fromJSON('{a:garbage}'),  struct('a', NaN));

######### complex number JSON object BIST ################

%!test	##	complex number object
%! assert( fromJSON('{"re":3,"im":5}'),     3+5i);
%! assert( fromJSON('{"real":3,"imag":5}'), 3+5i);

%!test	##	complex number lazy notation object
%! assert( fromJSON('{re:3,im:5}'), 3+5i);
%! assert( fromJSON('{real:3,imag:5}'), 3+5i);

%!test	##	fake complex number object
%! assert( fromJSON('{"re": "hello","im":5}'),
%!         struct('re',"hello",'im',5));

%!test	##	complex number in reverse order
%! assert( fromJSON('{im:3,re:5}'), 5+3i);

%!test	##	complex with excess members
%! assert( fromJSON('{im:3,re:5,re:7,im:10}'),7+10i);

%!test	##	complex number object with mismatch re/im and real/imag
%! assert( fromJSON('{real:3,im:5}'),
%!         struct('real',3,'im',5));

%!test	##	apparent complex number object with extra member
%! assert( fromJSON('{re:3,im:5,t:3}'),
%!         struct('re',3,'im',5,'t',3));

%!test	##	array of complex number object  to scalar array of complex number
%! assert( fromJSON('[{re:4,im:6},{re:5,im:7}]}',true),
%!         [4+6i,5+7i] );

%!test	##	array of complex number object  to cell array of complex number
%! assert( fromJSON('[{re:4,im:6},{re:5,im:7}]}',false),
%!         {4+6i,5+7i} );

%!test	##	complex number object with array to scalar array of complex number
%! assert( fromJSON('{re:[4,5],im:[6,7]}',true),
%!         [4+6i,5+7i] );

%!test	##	complex number object with array to struct with cell array
%! assert( fromJSON('{re:[4,5],im:[6,7]}',false),
%!         struct("re",{{4,5}},"im",{{6,7}}));

%!test	##	complex number object with mismatch array sizes
%! assert( fromJSON('{re:[4,5],im:[6]}',true),
%!         struct('re',[4,5],'im',6));

%!test	##	complex number object with mismatch array sizes
%! assert( fromJSON('{re:[4,5],im:[6]}',true),
%!         struct('re',[4,5],'im',6));

%!test	##	bogus complex number object with mixed classed array
%! assert( fromJSON('{re:[4,5],im:[6,"a"]}',true),
%!         struct('re',[4,5],'im',{{6,'a'}}));

%!test	##	array of bogus complex number object
%! assert( fromJSON('[{re:4,im:6},{re:5,im:"a"}]',true),
%!         {4+6i,struct('re',5,'im','a')});

%!test	##	complex number object with matrix
%! assert( fromJSON('[{re:[4,5;0 2],im:[6,7;3 0]}]'),
%!         [4+6i,5+7i;3i 2]);

%!test	##	array of complex number object
%! assert( fromJSON('[[{re:4,im:6},{re:1,im:0}],[{re:0,im:2}, {re:2,im:4}]]'),
%!         [4+6i 1;2i 2+4i]);

%!test	##	complex number object with ND array
%! assert( fromJSON('{re:[[[1,1],[2,2]],[[3,3],[4,4]]],im:[[[1,1],[2,2]],[[3,3],[4,4]]]}', true),
%!        reshape( (1+i)*[1 2 1 2 3 4 3 4], 2,2,2));

%!test  ##  ND array of complex number objects
%! assert( fromJSON('[[[{"re":1,"im":1},{"re":1,"im":1}],[{"re":2,"im":2},{"re":2,"im":2}]],[[{"re":3,"im":3},{"re":3,"im":3}],[{"re":4,"im":4},{"re":4,"im":4}]]]'),
%!        reshape( (1+i)*[1 2 1 2 3 4 3 4], 2,2,2));

%!test	##	array of objects with complex number member
%! assert( fromJSON('[{"a": {re:4, im:6}},{"a": {re:5,im:7}}]'),
%!         struct('a',{4+6i,5+7i}) );

%!test	##	ND array objects with complex number members
%! obj = struct('a',{4+6i,5+7i;4+6i,5+7i});
%! obj(:,:,2) = obj;
%! assert( fromJSON('[[[{"a": {re:4, im:6}},{"a": {re:5,im:7}}],[{"a": {re:4, im:6}},{"a": {re:5,im:7}}]],[[{"a": {re:4, im:6}},{"a": {re:5,im:7}}],[{"a": {re:4, im:6}},{"a": {re:5,im:7}}]]]'),
%!         obj );

%!test	##	array of objects with DEEP complex number member
%! assert( fromJSON('[{"a": {"b": {re:4, im:6}}},{"a": {re:5,im:7}}]'),
%!         [struct('a',struct('b',4+6i)),struct('a',5+7i)] );

%!test	##	mismatch array (to cell array) of objects with DEEP complex number member
%! assert( fromJSON('[{"a":{"b":{re:4, im:6}}}, {"c":{"d":{"e":{re:5,im:7}}}}]'),
%!         {struct('a',struct('b',4+6i)),struct('c',struct('d',struct('e',5+7i)))} );

%!test  # array of complex number in algebraic format (extracircular parsing)
%! assert( fromJSON('[[4+6i, 1+0i], [2i, 4i + 2]]'),
%!         [4+6i 1;2i 2+4i]);

%!test	##	complex number object mixed with number within array (test array parsing)
%! assert( fromJSON('[[4,{re:1,im:0}],[{re:0,im:2}, {re:4,im:6}]]'),
%!         [4 1;2i 4+6i]);

%!test	##	complex number object within a structure (nested)
%! assert( fromJSON('{"a": {re:1,im:5}}'),
%!         struct('a',1+5i));

%!test	##	complex number object with structure array (nested)
%! assert( fromJSON('[{"a":{re:1,im:5}},{"a":{re:2,im:5}}]'),
%!         struct('a',{1+5i,2+5i}));

%!test	##	complex number object deeply nested in object
%! assert( fromJSON('{a:1,b:{c:2,d:{e:3,f:{re:3,im:5}}}}'),
%!         struct('a',1,'b',struct('c',2,'d',struct('e',3,'f',3+5i))));

############## file encoding error ######################
###### simulate parsing with non-ASCII character#########

%!test  ##  leading file-encoding bytes (simulated with emoji)
%! assert( fromJSON('😊4'), 4);    %  just ignore it, likely some file encoding taken in by fread

%!test  ##  inside arrray
%!warning <invalid> assert( fromJSON('[😊,4]'), [NaN, 4]); % convert to NaN

%!test  ##  inside struct
%!warning <invalid> assert( fromJSON('{"a":😊4}'), struct('a',NaN));  % convert to NaN

%!test  ##  inside quotes
%! assert( fromJSON('"😊"'), '😊');     % SMILE! not invalid

############### exotic JSON BIST #####################

%!test  ## test octave inline fn  (convert to inline)
%! assert(fromJSON('"@@sin"'),@sin);
%! assert(func2str(fromJSON('"@@(x)3*x"')),func2str(@(x)3*x));

%!test  ## test apparent octave inline fn  (do NOT convert to inline)
%! assert(fromJSON('"@sin"'), '@sin');
%! assert(fromJSON('"@(x)3*x"'),'@(x)3*x');

%!test  ## test octave inline fn with SARRAY=false (do NOT convert otherwise valid inline)
%! assert(fromJSON('"@@sin"', false), '@@sin');
%! assert(fromJSON('"@@(x)3*x"', false),'@@(x)3*x');

%# exotic object in structure
%!testif HAVE_JAVA
%! if (usejava ("jvm"))
%!  assert(fromJSON('{"a":"[java.math.BigDecimal]"}'),struct('a','[java.math.BigDecimal]'));
%! endif

%# exotic object (placeholder of class name)
%!testif HAVE_JAVA
%! if (usejava ("jvm"))
%!  assert(fromJSON('"[java.math.BigDecimal]"'),'[java.math.BigDecimal]');
%! endif

############### beautified or confusing JSON BIST #####################

%!test	##	JSON with confusing '[]{},' AND missing quotes (hard string parse test)
%! warning('off','all');
%! obj=fromJSON('[{a:"tes, {}: [ ] t"},"lkj{} sdf",im mi{}ing quotes]');
%! assert(obj,{struct('a',"tes, {}: [ ] t"), 'lkj{} sdf',NaN})

%!test	##	beautified JSON object (extraneous whitespace/newline)
%! assert( fromJSON("\n  {  \n\t\"a\"\t\n\n\n  :\t\n\n\n  3\n\t} \n \n"),
%!         struct("a",3))

%!test	##	beautified JSON string with array (test parse with extraneous whitespace)
%! pretty_json ="{\n  \"data\": [\n    {\n      \"vendor\": \"0x10de\",\n      \"details\": {\n        \"created\": \"2012-11-12T10:35:32Z\"\n      },\n      \"_status\": \"synced\"\n    }\n  ]\n}";
%!
%! obj = struct('data', ...
%!          struct('vendor','0x10de', ...
%!                 'details', struct('created','2012-11-12T10:35:32Z'), ...
%!                 '_status', 'synced'
%!           )
%!       );
%!
%! assert( fromJSON(pretty_json),obj,true);

%!test	##	garbage string with whitespace
%!warning <invalid> assert( fromJSON("[1, gar bage]"),[1,NaN])

%!test	##	garbage string with newline
%!warning <invalid> assert( fromJSON("[1, \n gar \n bage]"),[1,NaN])

%!test	##	garbage string with quotes
%!warning <invalid> assert( fromJSON('[1,gar""bage]'),[1,NaN])

%!test	##	garbage string with array brackets
%!warning <invalid> assert( fromJSON('[1,gar[]bage]'),[1,NaN])

%!test	##	garbage string with object brackets
%!warning <invalid> assert( fromJSON('[1,{"a":gar{}bage}]'),{1,struct('a',NaN)})

%!test  ## looks like fn, but is UNQUOTED string
%!warning <invalid>   assert(fromJSON('@@nofunc'),NaN);

########## complex (non-numerical) JSON BIST ################

%!test  ## a JSON string stored inside JSON string object
%! json = "[         \n  {                \n  \"plot\": [      \n      {            \n      \"line1\": { \n         \"x\": [  \n             1,     \n            3      \n          ],       \n         \"y\": [  \n            12,    \n            32     \n          ]        \n        }          \n      }            \n    ]              \n  }                \n]";
%! assert( fromJSON(json,true),
%!         struct('plot',struct('line1',struct('x',[1,3],'y',[12,32]))));

%!test  ## jsondecode's Arrays with the same field names in the same order.
%! json = '[{"x_id":"5ee28980fc9ab3","index":0,"guid":"b229d1de-f94a","latitude":-17.124067,"longitude":-61.161831,"friends":[{"id":0,"name":"Collins"},{"id":1,"name":"Hays"},{"id":2,"name":"Griffin"}]},{"x_id":"5ee28980dd7250","index":1,"guid":"39cee338-01fb","latitude":13.205994,"longitude":-37.276231,"friends":[{"id":0,"name":"Osborn"},{"id":1,"name":"Mcdowell"},{"id":2,"name":"Jewel"}]},{"x_id":"5ee289802422ac","index":2,"guid":"3db8d55a-663e","latitude":-35.453456,"longitude":14.080287,"friends":[{"id":0,"name":"Socorro"},{"id":1,"name":"Darla"},{"id":2,"name":"Leanne"}]}]';
%!
%! f1 = num2cell(struct ('id', {0 1 2}, 'name', {'Collins' 'Hays' 'Griffin'}));
%! f2 = num2cell(struct ('id', {0 1 2}, 'name', {'Osborn' 'Mcdowell' 'Jewel'}));
%! f3 = num2cell(struct ('id', {0 1 2}, 'name', {'Socorro' 'Darla' 'Leanne'}));
%!
%! keys = {'x_id','index','guid','latitude','longitude','friends'};
%! val1 = {'5ee28980fc9ab3', 0, 'b229d1de-f94a', -17.124067, -61.161831, f1};
%! val2 = {'5ee28980dd7250', 1, '39cee338-01fb', 13.205994,  -37.276231, f2};
%! val3 = {'5ee289802422ac', 2, '3db8d55a-663e', -35.453456,  14.080287, f3};
%!
%! exp = cell2struct({val1{:};val2{:};val3{:}}',keys)';
%! fromJSON(json);     # this may be confusing mix of array and non-cell array, but NO fail allowed
%! assert (fromJSON(json, false), num2cell(exp));


%!test  ## from firefox active-stream.discovery_stream.json (UGH!  url link as object key)
%!
%! json = '[{"feeds":{"https://getpocket.cdn.mozilla.net/v3/firefox/global-recs?version=3&consumer_key=$apiKey&locale_lang=$locale&region=$region&count=30":{"lastUpdated":1640020188467,"data":{"settings":{"domainAffinityParameterSets":{"default":{"recencyFactor":0.5,"frequencyFactor":0.5,"combinedDomainFactor":0.5,"perfectFrequencyVisits":10,"perfectCombinedDomainScore":2,"multiDomainBoost":0,"itemScoreFactor":1}}}}}}}]';
%! exp  = struct("feeds",
%!          struct('https://getpocket.cdn.mozilla.net/v3/firefox/global-recs?version=3&consumer_key=$apiKey&locale_lang=$locale&region=$region&count=30',
%!             struct("lastUpdated",1640020188467,
%!                    "data",
%!                     struct("settings",
%!                             struct("domainAffinityParameterSets",
%!                                struct("default",
%!                                  struct("recencyFactor",0.5,
%!                                      "frequencyFactor",0.5,
%!                                      "combinedDomainFactor",0.5,
%!                                      "perfectFrequencyVisits",10,
%!                                      "perfectCombinedDomainScore",2,
%!                                      "multiDomainBoost",0,
%!                                      "itemScoreFactor",1
%!                                  )
%!                            )
%!                    )
%!              )
%!            )
%!          )
%!        );
%! assert (fromJSON(json, true),   exp );
%! assert (fromJSON(json, false), {exp});

