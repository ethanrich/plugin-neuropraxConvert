## Copyright (C) 2019 Juan Pablo Carbajal
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.

## Author: Juan Pablo Carbajal <ajuanpi+dev@gmail.com>
## Created: 2019-11-20

## -*- texinfo -*-
## @defun {@var{x} =} verLessThan ()
## Dummy function that retunrs true to all Matlab version queries.
##
## This function assumes that octave can cope with code written for the latest
## matlab version.
##
## It will be removed when Octave 6.0.0 is released as verLessThan in shipped
## with it.
##
## @end defun

function tf = verLessThan ()

  tf = false;

endfunction
