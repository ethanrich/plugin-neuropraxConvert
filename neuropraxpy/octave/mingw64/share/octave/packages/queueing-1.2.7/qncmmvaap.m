## Copyright (C) 2008, 2009, 2010, 2011, 2012, 2016, 2018, 2019 Moreno Marzolla
##
## This file is part of the queueing toolbox.
##
## The queueing toolbox is free software: you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation, either version 3 of the
## License, or (at your option) any later version.
##
## The queueing toolbox is distributed in the hope that it will be
## useful, but WITHOUT ANY WARRANTY; without even the implied warranty
## of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with the queueing toolbox. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
##
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qncmmvaap (@var{N}, @var{S}, @var{V})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qncmmvaap (@var{N}, @var{S}, @var{V}, @var{m})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qncmmvaap (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qncmmvaap (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z}, @var{tol})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qncmmvaap (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z}, @var{tol}, @var{iter_max})
##
## @cindex Mean Value Analysys (MVA), approximate
## @cindex MVA, approximate
## @cindex closed network, multiple classes
## @cindex multiclass network, closed
##
## This function is deprecated. Plase use @code{qncmmvabs} instead.
##
## @seealso{qncmmvabs}
##
## @end deftypefn

## Author: Moreno Marzolla <moreno.marzolla(at)unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X] = qncmmvaap( N, S, V, m, Z, tol, iter_max )
  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function",
            "qncmmvaap is deprecated. Please use qncmmvabs instead");
  endif
  [U R Q X] = qncmmvabs( varargin{:} );
endfunction
