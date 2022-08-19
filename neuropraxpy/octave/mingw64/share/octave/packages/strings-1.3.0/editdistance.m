## Copyright (C) 2006 Muthiah Annamalai <muthiah.annamalai@uta.edu>
## Copyright (C) 2014 Max Görner <max.goerner@tu-dresden.de>
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

## -*- texinfo -*-
## @deftypefn  {Function File} {[@var{dist}, @var{L}] =} editdistance (@var{str1}, @var{str2})
## @deftypefnx {Function File} {[@var{dist}, @var{L}] =} editdistance (@var{str1}, @var{str2}, @var{weights})
## @deftypefnx {Function File} {[@var{dist}, @var{L}] =} editdistance (@var{str1}, @var{str2}, @var{weights}, @var{modus})
## Compute the Levenshtein edit distance between the two strings.
##
## The optional argument @var{weights} specifies weights for the deletion,
## matched, and insertion operations; by default it is set to +1, 0, +1
## respectively, so that a least editdistance means a closer match between the
## two strings. This function implements the Levenshtein edit distance as
## presented in Wikipedia article, accessed Nov 2006. Also the levenshtein edit
## distance of a string with the empty string is defined to be its length.
##
## For the special case that there are no weights given and the array L is not
## requested, an algorithm of Berghel and Roach, which improves an algorithm 
## introduced by Ukkonen in 1985, will be applied. This algorithm is
## significantly faster most of the times. Its main strength lies in cases with
## small edit distances, where huge speedups and memory savings are suspectible.
## The time (and space) complexity is O(((dist^2 - (n - m)^2)/2) + dist), where
## n and m denote the length of both strings.
## 
## The optional argument @var{modus} specifies the algorithm to be used. For
## @var{modus} = 0, Berghel and Roach's algorithm will be used whenever
## possible. For @var{modus} = 1, the classic algorithm by Fisher and Wagner
## will be used. If @var{L} is omitted, and @var{modus} = 1, a variant of Fisher
## and Wagner's algorithm using only a linear amount of memory with respect to
## the input length, but O(m*n) runtime, will be used. Again, n and m denote the
## length of both strings.
##
## The default return value @var{dist} is the edit distance, and
## the other return value @var{L} is the distance matrix.
##
## @example
## @group
## editdistance ('marry', 'marie') 
##   @result{}  2
## @end group
## @end example
##
## @end deftypefn

function [dist, L] = editdistance (str1, str2, weights = [1 0 1], modus = 0)
  #Checking correct call of the function.
  if (nargin < 2 || nargin > 4)
    print_usage ();
  endif
  if (nargin >= 3 && numel (weights) != 3)
    error ("editdistance: WEIGTHS must be a 3 element vector.")
  endif 
  if (!isvector(str1) || !isvector(str2))
    error ("editdistance: Both strings must be a vector.")
  endif

  #Using the approach of Berghel and Roach, if possible.
  if (modus == 0 &&
      nargout < 2 && 
      (weights(1) == weights(3) && weights(2) == 0)
     )
    dist = weights(1)*editdistance_berghel_roach (str1,str2);
    return;
  endif

  saveMemory = nargout < 2;

  L1 = numel (str1) + 1;
  L2 = numel (str2) + 1;

  #Checking whether str1 or str2 are empty strings. If so, the determination of the minimal edit distance is trivial.
  if (L1 == 1)
    dist = L2-1;
    return;
  elseif (L2 == 1)
    dist = L1-1;
    return;
  endif

  if (saveMemory)
    L = zeros (2,L2);
  else
    L  = zeros (L1,L2);
  endif
  
  %Setting weights
  g = weights(1); %insertion
  m = weights(2); %match
  d = weights(3); %deletion

  if (not (saveMemory))
    L(:,1) = [0:L1-1]'*g;
  endif
  L(1,:) = [0:L2-1]*g;

  for idx = 2:L1;
    if (saveMemory)
      L(2, 1) = idx-1;
    endif
    for idy = 2:L2
      if (str1(idx-1) == str2(idy-1))
        score = m;
      else
        score = d;
      endif
      if (saveMemory)
        x = 2;
      else
        x = idx;
      endif
      m1 = L(x-1,idy-1) + score;
      m2 = L(x-1,idy) + g;
      m3 = L(x,idy-1) + g;
      L(x,idy) = min ([m1, m2, m3]);
    endfor
    if (saveMemory)
      L(1, :) = L(2, :);
    endif
  endfor

  if (saveMemory)
    x = 2;
  else
    x = L1;
  endif

  dist = L(x,L2);
endfunction

function dist = editdistance_berghel_roach (a,b)
  #Variables named according to Berghel and Roach 1996 (except s, which is called dist here)
  
  if (!isvector(a) || !isvector(b))
    print_usage();
  endif

  if (numel (a) > numel (b))
    ans = a;
    a = b;
    b = ans;
  endif
  m = numel (a); n = numel (b);
  if (m == 0)
    dist = n;
    return;
  endif

  MIN_K = -m-1; #The diagonal with the lowest number is -m
  MIN_P = -1; #minimum p that has to be cached is 0
  FKP = sparse (m+n+2,n+1);
  FKP_cached = sparse (m+n+2,n+1);

  p = n-m;
  do
    inc = p;
    for temp_p = 0:p-1
      if (abs (n-m - inc) <= temp_p)
        get_f ((n-m) - inc, temp_p);
      endif
      if (abs(n-m + inc) <= temp_p)
        get_f(n-m+inc,temp_p);
      endif
      inc--;
    endfor
    get_f (n-m,p);
    p++;
  until (get_f (n-m,p-1) == m);

  dist = p-1;

  function f = get_f (k,p)
    if (p == abs (k)-1)
      if (k < 0)
        f = abs (k) - 1;
      else
        f = -1;
      endif
      return;
    endif
    if (p < abs (k)-1)
      f = -inf;
      return;
    endif
    
    if (FKP_cached(k-MIN_K,p-MIN_P) == 1)
      f = FKP(k-MIN_K,p-MIN_P);
      return;
    endif

    c1 = get_f (k,p-1) + 1;
    c2 = get_f (k-1,p-1);
    c3 = get_f (k+1,p-1) + 1;
    t = max ([c1 c2 c3]);
    #if (a([t, t+1]) == b([k+t+1, k+t]) t2 = t+1; endif #taking adjacent transpositions into account
    while (t < m && t+k < n && a(t+1) == b(t+1+k))
      t += 1;
    endwhile
    if (t > m || t+k > n)
      f = FKP(k-MIN_K,p-MIN_P) = NaN;
    else
      f = FKP(k-MIN_K,p-MIN_P) = t;
    endif
    FKP_cached(k-MIN_K,p-MIN_P) = 1;
  endfunction
endfunction

%!test
%! l = 50;
%! n = 20;
%! rand('state',31513);
%! abc = 'A':'Z';
%!
%! for it = 1:n
%!   #Generate two Strings
%!   #This kind of generation produces worst case examples for the new algorithm,
%!   #so runtime comparisons won't be informative.
%!   str1 = str2 = abc(randi([1 length(abc)],1,l));
%!   m = randi(l/2);
%!   str1(randi([1 l],1,m)) = abc(randi([1 length(abc)],1,m));
%!   m = randi(l/2);
%!   str2(randi([1 l],1,m)) = abc(randi([1 length(abc)],1,m));
%!
%!   d1 = editdistance(str1,str2); #Berghel and Roach
%!   tempDist = editdistance(str2,str1);
%!   assert(d1 == tempDist, "editdistance: Berghel and Roach algorithm is not symmetric.");
%!   [d2 ~] = editdistance(str1,str2); #Fisher and Wagner
%!   [tempDist ~] = editdistance(str2,str1);
%!   assert(d2 == tempDist, "editdistance: Fisher and Wagner algorithm is not symmetric.");
%!   d3 = editdistance(str1,str2,[1 0 1],1); #Fisher and Wagner with linear memory usage
%!   tempDist = editdistance(str2,str1,[1 0 1],1);
%!   assert(d3 == tempDist, "editdistance: Fisher and Wagner algorithm with linear memory usage is not symmetric.");
%!   assert(d1 == d2, "editdistance: The result of the algorithm by Berghel and Roach and that of the algorithm by Fisher and Wagners differ.");
%!   assert(d2 == d3, "editdistance: The results of the algorithm by Fisher and Wagner with and without linear memory usage differ.");
%! endfor
