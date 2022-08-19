## Copyright (C) 2010-2015   Lukas F. Reichlin
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Script File} {} test_quaternion
## Execute all available tests at once.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: December 2011
## Version: 0.1

test @quaternion/blkdiag
test @quaternion/diag
test @quaternion/diff
test @quaternion/end
test @quaternion/eq
test @quaternion/ge
test @quaternion/gt
test @quaternion/le
test @quaternion/log
test @quaternion/lt
test @quaternion/ndims
test @quaternion/ne
test @quaternion/numel

test q2rot
test rot2q
test rotm2q
