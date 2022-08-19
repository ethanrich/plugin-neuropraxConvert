%# -*- mode: Octave -*-

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

%# this file is mostly identical to 'dataframe', except that fragments
%# can be easily extracted and run in interactive mode.

x = dataframe(randn(3, 3), 'rownames', (7:-1:5).');
x(1:3, 1) = 3;
x(1:3, 1) = (4:6).';
assert(x.array(2, 1), 5)
x(1, 1:3) = 3;         
x(1, 1:3) = (4:6).';
assert(x.array(1, 2), 5)
assert(isempty(x.rowidx), false)
x.types(2) ='single';
assert(class(x.array(1, 2)), 'single')
x=dataframe('data_test.csv');
assert(isna(x.array(9, 4)))
# remove rownames
x.rownames = [];
assert(size(x.rownames), [0 0])
# remove a column through '.' access
y = x; y.DataName = [];
if (strcmp (genvarname ('_A'), 'x_A'))
 assert(size(y(:, 'x_IBIAS_')), [10 1])
else
 assert(size(y(:, '_IBIAS_')), [10 1])
end
assert(size(y), [10 6])
y = repmat([false true], 10, 1);
y(4) = true;
z = x(:, ["VBIAS"; "Freq"])==[-5.4 300e3];
assert(z.array(:, :), y)
assert(find(all(z, 2)), 4)
assert(sum(x(:, 'VBIAS')).array(), -51)
assert(cumsum(x(:, 'VBIAS')).array(), cumsum(x.array(:, 'VBIAS')))
assert(sum(x(:, 5:6), 2).array(), sum(x.array(:, 5:6), 2))
assert(cumsum(x(:, 5:6), 2).array(), cumsum(x.array(:, 5:6), 2))
assert(nth_element(x.array(:, 4:6), 2:3), nth_element(x(:, 4:6), 2:3).array)
y = x{};
assert(size(y), [10 7])
y = x{[2 5], [2 7]};
assert(y, {-5.8, "E"; -5.2, "C"})
y = x{}([2 5], [2 7]);
assert(y, {-5.8, "E"; -5.2, "C"})
y = x{1:2, 1:2}(4);
assert(y, {-5.8})
# remove a column through (:, name) access
y = x; y(:, "DataName") = [];
assert(size(y), [10 6])
# create an empty dataframe
y = dataframe([]);
assert(isempty(y), true)
y = x.df(:, 2:6);
Y = 2*pi*double(y.Freq).*y.C+y.GOUT;
z = dataframe(y,{{'Y'; Y}});
assert(size(z), [10 6])
assert(abs(z(1, "Y") - Y(1)).array, 0)
# direct matrix setting through struct access
y.Freq=[(1:10).' (10:-1:1).'];
# verify the "end" operator on the third dim
assert(y.array(2, 2, end), 9)
# direct setting through 3D matrix
y(:, ["C"; "G"], 1:2) = repmat(y(:, ["C"; "G"]), [1 1 2]);
y(4:5, 4:5) = NaN;
# test
if any(size(x) != [10 7]),
  error('x: wrong input size')
endif
if any(size(y) != [10 5 2]),
  error('y: wrong input size')
endif
# THIS MAY NOT CHANGE! numel is called by subsasgn and interfere
# if not returning 1
assert(numel(x), 1)
assert(numel(x, ':'), 70)
assert(numel(x, ':', 'Freq'), 10)
assert(numel(x, ':', [1 3 5]), 30)
assert(numel(x, ':', [1 3 5]), 30)
assert(numel(x, x(:, "OK_") == 'A', ["C"; "G*"]), 4)
# test simple slices
assert(x.VBIAS(1:6), (-6:.2:-5).')
assert(x.array(6:10, 2), (-5:.2:-4.2).')
assert(x.array(6, "OK_"), 'B')
assert(x.array(2, logical([0 0 1 1])), x.array(2, 3:4))
assert(size(y.array(:, :, :)), [10 5 2])
assert(size(y.array(:, :)), [10 10])
assert(size(y.array(:, 2, 2)), [10 1])
assert(size(y.array(:, 2)), [10 1])
assert(y.C(4:5), [NaN NaN])

myerr = false; errmsg = 'Line 90: Accessing dataframe past limits';
try
  x(1, 8)
  myerr = true;
catch
 end
 if (myerr) error (errmsg); end
 errmsg = 'Line 97: Accessing dataframe past limits';
 try
  x(11, 1)
  myerr = true;
catch
 end
 if (myerr) error (errmsg); end
 errmsg = 'Line 104: Accessing dataframe past limits';
 try
  x(1, logical(ones(1, 8)))
  myerr = true;
 catch
end
if (myerr) error (errmsg); end
errmsg = 'Line 111: Accessing dataframe with unknown column name';
 try 
  x.types{"FReq*"}
  myerr = true;
catch
end
if (myerr) error (errmsg); end  
 
# test
#!! removed -- output format may only be specified before selection
# select one column         
# assert(x(1:3, 1).cell(:), x.cell(1:3)(:))   
# assert(x(33:35).cell.', x(33:35).cell(:))
# select two columns        
assert(x.cell(1:10, 2:3)(:), x.cell(11:30)(:))        
errmsg = 'Line 126: Concatenating column of incompatible types';
 try 
  x(:);
  myerr = true;
catch
end
if (myerr) error (errmsg); end  
errmsg = 'Line 133: Concatenating column of incompatible types';
 try 
   x.dataframe(:); 
   myerr = true;
catch
end
if (myerr) error (errmsg); end  
errmsg = 'Line 140: Illegal access';
 try   
  x.dataframe.cell
  myerr = true;
catch
end
if (myerr) error (errmsg); end  
# test
# test modifying column type
x.types("Freq") = 'uint32'; x.types(2) = 'single';
# downclassing must occur !
assert(class(x.array(1, ["Freq"; "C"])), 'uint32')
# upclassing must occur !
assert(class(x.as.double(1, ["Freq"; "C"])), 'double')
errmsg = 'Line 154: Incorrect internal field sub-referencing';
 try   
  x.types{"Freq"}
  myerr = true;
catch
end
if (myerr) error (errmsg); end    
# error errmsg='line :mixing different types") 
# removed: this now works, but downclassing to int
# x([12:18 22:28 32:38]);
errmsg = 'Line 164: non-square access';
try
  x.dataframe([22:28 32:37]);
  myerr = true;
catch
end
if (myerr) error (errmsg); end    
errmsg = 'Line 171: non-square access';
try
  x.cell([1:19]);
 myerr = true;
catch
end
if (myerr) error (errmsg); end   
errmsg =  'Line 176: single-dimension name access';
try
  x('Freq');
  myerr = true;
catch
end
if (myerr) error (errmsg); end  
# test
# complex access
x(x(:, "OK_") == '?', ["C"; "G*"]) = NaN;
assert(x.array(4, 5:6), [NaN NaN])
# extract values
y = x.dataframe(x(:, "OK_") =='A', {"Freq", "VB*", "C", "G"});
# comparison using cell output class, because assert use (:)
assert(y.cell(:, 2:3), x.cell([1 7], ["VB*"; "C"]))
assert(x.array((33:35).'), x.array(3:5, 4))
# test further dereferencing
assert(x.array(:, "C")(2:4), x.array(2:4, "C"))
# complex modifications through cell access
z = dataframe(x, {"VB*", {"Polarity" ,"Sense"; ones(12,2), zeros(10,2)}});
assert(size(z), [12 9 2])
assert(z.Sense(11:12, :), NA*ones(2, 2))
assert(size(struct(z).x_over{2}, 2) - size(struct(x).x_over{2}, 2), 2)
x = dataframe(randn(3, 3)); y = x.array;
xl = x > 0; yl = y > 0;
a = zeros(size(yl)); b = a;
a(xl) = 1; b(yl) = 1;
assert(a, b)
[a, b] = sort(y(:)); y = reshape(b, 3, 3); x = dataframe(y);
a = zeros(size(yl)); b = a;
a(x) = 10:-1:2; b(y) = 10:-1:2;
assert(a, b)
x = dataframe(randn(3, 3)); y = randn(3, 3); z = dataframe(y);
assert((x+y(1)).array, x.array+y(1))
assert((y(1)+x).array, y(1)+x.array)
assert((x+y).array, x.array+y)
assert((y+x).array, y+x.array)
assert((x+z).array, x.array+z.array)
assert((bsxfun(@plus, x, z(1,:))).array, bsxfun(@plus, x.array, z.array(1,:)))
assert((bsxfun(@plus, x, z(:,1))).array, bsxfun(@plus, x.array, z.array(:,1)))
assert((bsxfun(@minus,z(1,:),x)).array, bsxfun(@minus,z.array(1,:),x.array))
assert((bsxfun(@minus,z(:,1),x)).array, bsxfun(@minus,z.array(:,1),x.array))
assert((x > 0).array, x.array > 0)
assert((0 > x).array, 0 > x.array)
assert((x > y).array, x.array > y);
assert((y > x).array, y > x.array);
assert((x > z).array, x.array > z.array)
assert((x*y(1)).array, x.array*y(1))
assert((y(1)*x).array, y(1)*x.array)
assert((x.*y).array, x.array.*y)
assert((y.*x).array, y.*x.array)
assert((z.*x).array, z.array.*x.array)
assert((x*y).array, x.array*y)
assert((y*x).array, y*x.array)
assert((x*z).array, x.array*z.array)
assert((x/y(1)).array, x.array/y(1))
assert((x./y).array, x.array./y)
assert((y./x).array, y./x.array)
assert((z./x).array, z.array./x.array)
assert((x/y).array, x.array/y)
assert((y/x).array, y/x.array)
assert((x/z).array, x.array/z.array)
# left division is a bit more complicated
assert((x(1, 1)\y).array, x.array(1, 1)\y, sqrt(eps))
assert((x(:, 1)\y).array, x.array(:, 1)\y, sqrt(eps))
assert((x(:, 1:2)\y).array, x.array(:, 1:2)\y, sqrt(eps))
assert((x\y).array, x.array\y, sqrt(eps))
assert((y\x).array, y\x.array, sqrt(eps))
assert((x\z).array, x.array\z.array, sqrt(eps))
x=dataframe(randn(4, 3, 2)); y=randn(4, 3, 2); z=dataframe(y);
assert((abs(sum(center(x)) < sqrt(eps)).array))
assert((x+y).array, x.array+y)
assert((y+x).array, y+x.array)
assert((x+z).array, x.array+z.array)
assert((bsxfun(@plus,x,z(1,:,:))).array, bsxfun(@plus,x.array,z.array(1,:,:)))
assert((bsxfun(@plus,x,z(:,1,:))).array, bsxfun(@plus,x.array,z.array(:,1,:)))
assert((bsxfun(@plus,z(1,:,:),x)).array, bsxfun(@plus,z.array(1,:,:),x.array))
assert((bsxfun(@plus,z(:,1,:),x)).array, bsxfun(@plus,z.array(:,1,:),x.array))
[a, b] = sort(x(:)); b = b(b <= 9); 
x = dataframe(reshape((1:9)(b), [3 3])); 
y = reshape((1:9)(b), [3 3]); z = dataframe(y);
assert(x(x(:)), y(x(:)))
assert(x(y(:)), y(y(:)))
z= x(x);
assert(z.array, y(x))
z = x(y);
assert(z.array, y(y)) 
disp('All tests passed');
