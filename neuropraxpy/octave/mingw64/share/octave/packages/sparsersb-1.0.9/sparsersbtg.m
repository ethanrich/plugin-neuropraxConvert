#!/usr/bin/octave -q
# 
#  Copyright (C) 2011-2020   Michele Martone   <michelemartone _AT_ users.sourceforge.net>
# 
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
# 
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
# 
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {} {} sparsersbtg ()
## @deftypefnx {} {} sparsersbtg (@var{k})
## @deftypefnx {} {} sparsersbtg (@var{k}, @var{m})
## Invoked with no arguments, print a script with tests of sparse vs sparsersb.
## Invoked with "r" as @var{k}, will use a random seeding scheme.
##
## If @var{k} is "p" and @var{m} a matrix, it will print it out in a
## manner readable by Octave.
##
## @seealso{sparsersb}
## @end deftypefn

## Author: Michele Martone

function ret = sparsersbtg (varargin)
	ret="";
	if nargin == 2 && varargin{1} == ['p']
		ret = printmat(varargin{2});
		return
	elseif nargin == 1 && varargin{1} == ['r']
		rs = sprintf ( "%d;", full (rand ("state") ));
		rs = sprintf ("%% Generated with rand state [%s].\n", rs);
	elseif nargin == 1
		rs = "%% Generated with rand state 42 .\n";
		rand ("state", 42); # seed
		parms = varargin{1};
		if length (parms) == 3
			nrl=parms(1);
			nri=parms(2);
			nru=parms(3);
			ncl=parms(1);
			nci=parms(2);
			ncu=parms(3);
		elseif length (parms) == 6
			nrl=parms(1);
			nri=parms(2);
			nru=parms(3);
			ncl=parms(4);
			nci=parms(5);
			ncu=parms(6);
		else
			# Well, error actually.
			return;
		end
	elseif nargin == 0
		rs = "%% Generated with rand state 42 .\n";
		rand ("state", 42); # seed
		#printf ("%s","rand(\"state\",42);\n"); # seed
		#nrl=1;nri=9;nru=10;
		#ncl=1;nci=9;ncu=10;
		nrl=1;nri=2;nru=3;
		ncl=1;nci=2;ncu=3;
	end
	for dp = [10,20,50,100]
	for nr = nrl:nri:nru
	for nc = ncl:nci:ncu
	for wc = 0:  1
		tt = "";
		lp = "";
		lp = "%!";
		ti = [lp, "test\n"];
		if wc
			A = round (sprand (nr, nc, dp/200)*100)      ;
			A = round (sprand (nr, nc, dp/200)*100)*i + A;
		else
			A = round (sprand (nr, nc, dp/100)*100);
		end
		if 0
			# repeat twice
			tl = printmat (A);
		else
			# define once in A
			tl = printmat (A);
			lp = [lp," A = ",tl,"; "];
			tl = "A";
		end
		for f = {"","istril","istriu","isreal","iscomplex","issymmetric","ishermitian","nnz","rows","columns"}
			exp = [f{:}," (sparsersb (",tl,")) == ",f{:}," (sparse (",tl,"))"];
			tt = [tt,ti,lp,"assert (",exp,");\n"];
		end
		nrs = sprintf("%d",nr);
		ncs = sprintf("%d",nc);
		nrc = sprintf("%d",nr*nc);
		for f = unique ({"( )","(:)",sprintf("(%s)",nrc),"(1)","(1,1)","(:,:)",sprintf("(%s,:)",nrs),sprintf("(:,%s)",ncs),sprintf("(%s,%s)",nrs,ncs),"*(1*ones(size(A,2)))","*(i*ones(size(A,2)))","'*(1*ones(size(A,1)))","'*(i*ones(size(A,1)))",".'*(1*ones(size(A,1)))",".'*(i*ones(size(A,1)))","*1","*i"})
			exp = [ "sparsersb (",tl,")",f{:}," == sparse (",tl,")",f{:}];
			tt = [tt,ti,lp,"assert (",exp,");\n"];
		end
		for inr = unique ([1,nr,nr*nc])
			inc = (nr * nc) / inr;
			ra = sprintf (" %d, %d", inr, inc);
			exp = [ "reshape (sparsersb (",tl,"),",ra,")"," == reshape (sparse (",tl,"),",ra,")"];
			tt = [tt,ti,lp,"assert (",exp,");\n"];
		end
		ret = [ret, sprintf("\n%%%% tests for a %g x %g matrix,  density %g%%",nr,nc,dp) ];
		if wc ; ret = [ret, sprintf(", complex\n") ]; else; ret = [ret , sprintf(", real\n") ] ; end
		#printf ("%s",tt);
		ret = [ret, tt];
	end
	end
	end
	end
	ret = [ ret, rs ];
end 

function s = printrow (v)
	assert (   rows (v) >= 1);
	assert (columns (v) >= 1);
	s = "";
	for i = 1 : columns (v)
		e = v(1,i);
		if iscomplex (v(1,i))
			s = sprintf ("%s%g+%g*i,", s, real (e), imag (e));
		else
			s = sprintf ("%s%g,", s, e);
		end
	end
	s = sprintf ("%s;", s);
	#s = sprintf("%s;", sprintf ("%g,", full(v(1,:)))); # only real
end

function s = printmat(v)
	assert (   rows (v) >= 1);
	assert (columns (v) >= 1);
	s = "";
	v = full (v);
	for i = 1:rows (v)
		s = sprintf ("%s%s", s, printrow(v(i,:)));
	end
	s = sprintf ("[%s]", s);
end

%!test
%!                 sparsersbtg ('p', [1]);
%! assert ( strcmp (sparsersbtg ('p', [1])      , ["[1,;]"]))
%!test
%!                  sparsersbtg ('p', [1,1,2,2]);
%! assert ( strcmp (sparsersbtg ('p', [1,1,2,2]), ["[1,1,2,2,;]"]))
%!test
%!                  sparsersbtg ('p', [1,1;2,2]);
%! assert ( strcmp (sparsersbtg ('p', [1,1;2,2]), ["[1,1,;2,2,;]"]))

%!test
%!                  sparsersbtg ('p', [1+i]);
%! assert ( strcmp (sparsersbtg ('p', [1+i])      , ["[1+1*i,;]"]))
%!test
%!                  sparsersbtg ('p', [1+i,1,2+i,2]);
%! assert ( strcmp (sparsersbtg ('p', [1+i,1,2+i,2]), ["[1+1*i,1,2+1*i,2,;]"]))
%!test
%!                  sparsersbtg ('p', [1+i,1;2+i,2]);
%! assert ( strcmp (sparsersbtg ('p', [1+i,1;2+i,2]), ["[1+1*i,1,;2+1*i,2,;]"]))

%!test
%! assert( length( sparsersbtg () ) >= 57846 )
%! assert( length( sparsersbtg ([1,1,1,1,1,1]) ) >= 11218 )
%! assert( length( sparsersbtg ([1,1,1]) ) >= 11218 )
%! assert( length( sparsersbtg ([1]) ) == 0 )
