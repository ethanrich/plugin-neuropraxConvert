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
## @deftypefn {Function File} {[@var{keys}, @var{vals}] =} keys_vals (@var{q})
## Return the list of keys as well as the assignable values for a quaternion q.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: April 2014
## Version: 0.1

function [keys, vals] = keys_vals (q)

  str = num2str (size (q), "%d ");
  str = regexprep (str, " ", "x");

  ## cell vector of keys
  keys = {"w";
          "x";
          "y";
          "z";
          "s";
          "v"};

  ## cell vector of values
  vals = {sprintf("real-valued array of type '%s', dimensions (%s)", class (q.w), str);
          sprintf("real-valued array of type '%s', dimensions (%s)", class (q.x), str);
          sprintf("real-valued array of type '%s', dimensions (%s)", class (q.y), str);
          sprintf("real-valued array of type '%s', dimensions (%s)", class (q.z), str);
          sprintf("scalar part of type 'quaternion', dimensions (%s)", str);
          sprintf("vector part of type 'quaternion', dimensions (%s)", str)};

endfunction
