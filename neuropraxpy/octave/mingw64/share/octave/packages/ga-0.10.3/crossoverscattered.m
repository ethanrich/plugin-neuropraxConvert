## Copyright (C) 2008, 2009, 2011 Luca Favatella <slackydeb@gmail.com>
## Copyright (C) 2019-2020 John D <john.donoghue@ieee.org>
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
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 7.1

## -*- texinfo -*-
## @deftypefn{Function File} {@var{xoverKids} =} crossoverscattered (@var{parents}, @var{options}, @var{nvars}, @var{FitnessFcn}, @var{unused}, @var{popuplation})
## Default crossover function for problems without linear constraints
##
## crossoverscattered creates a random binary vector and selects genes
## where the vector is a 1 from the first parent and a 0 from the next
## parent.
##
## @strong{Inputs}
## @table @var
## @item parents
## Row vector of parents chosen from selection function
## @item options
## options
## @item nvars
## Number of variables
## @item FitnessFcn
## Fitness function to use
## @item unused
## Placeholder variable not used
## @item population
## Matrix representing the current population
## @end table
##
## @strong{Outputs}
## @table @var
## @item xoverkids
## Crossover offspring matrix where roes correspond to children. The
## number of columns is the number of variables.
## @end table
## 
## @seealso{ga}
## @end deftypefn
function xoverKids = crossoverscattered (parents, options, nvars, FitnessFcn,
                                         unused,
                                         thisPopulation)

  ## simplified example (nvars == 4)
  ## p1 = [varA varB varC varD]
  ## p2 = [var1 var2 var3 var4]
  ## b = [1 1 0 1]
  ## child = [varA varB var3 varD]
  nc_parents = columns (parents);
  n_children = nc_parents / 2;
  p1(1:n_children, 1:nvars) = ...
      thisPopulation(parents(1, 1:n_children), 1:nvars);
  p2(1:n_children, 1:nvars) = ...
      thisPopulation(parents(1, n_children + (1:n_children)), 1:nvars);
  b(1:n_children, 1:nvars) = randi (2, n_children, nvars) - 1;
  xoverKids(1:n_children, 1:nvars) = ...
      b .* p1 + (ones (n_children, nvars) - b) .* p2;
endfunction


## number of input arguments
# TODO

## number of output arguments
# TODO

## type of arguments
# TODO

# TODO
