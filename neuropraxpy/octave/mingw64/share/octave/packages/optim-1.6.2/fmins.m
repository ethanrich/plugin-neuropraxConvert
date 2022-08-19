## Copyright (C) 2003 Andy Adler <adler@ncf.ca>
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
## @deftypefn {Function File} {[@var{x}] =} fmins (@var{f},@var{X0},@var{options},@var{grad},@var{P1},@var{P2}, ...)
## 
## This function is deprecated and will be removed in the future. It
## is a frontend function, calling adsmax or mdsmax, and previously
## nmsmax, which is now in core Octave with a slightly different
## interface.
##
## Find the minimum of a funtion of several variables.
## By default the method used is the Nelder&Mead Simplex algorithm
##
## Example usage:
##   fmins(inline('(x(1)-5).^2+(x(2)-8).^4'),[0;0])
## 
## @strong{Inputs}
## @c use @asis and explicite @var in @table to avoid makeinfo warning
## @c `unlikely character , in @var' for `P1, P2, ...'.
## @table @asis 
## @item @var{f} 
## A string containing the name of the function to minimize
## @item @var{X0}
## A vector of initial parameters fo the function @var{f}.
## @item @var{options}
## Vector with control parameters (not all parameters are used)
## @verbatim
## options(1) - Show progress (if 1, default is 0, no progress)
## options(2) - Relative size of simplex (default 1e-3)
## options(6) - Optimization algorithm
##    if options(6)==0 - unused (previously Nelder & Mead simplex)
##    if options(6)==1 - Multidirectional search Method (default)
##    if options(6)==2 - Alternating Directions search
## options(5)
##    unused
## options(10) - Maximum number of function evaluations
## @end verbatim
## @item @var{grad}
## Unused
## @item @var{P1}, @var{P2}, ...
## Optional parameters for function @var{f} 
##
## @end table
## @end deftypefn

function ret=fmins(funfun, X0, options, grad, varargin)

    persistent warned = false;

    if (! warned)

      warned = true;

      warning ("Octave:deprecated-function",
               ["`fmins' has been deprecated and will be", ...
                " removed in the future.", ...
                " You can still call adsmax, mdsmax, or nmsmax", ...
                " (the latter is now in core Octave) directly."]);

    endif

    stopit = [1e-3, inf, inf, 1, 0, -1];
    minfun = 'nmsmax'; 

    if nargin < 3; options=[]; end

    if length(options)>=1; stopit(5)= options(1); end
    if length(options)>=2; stopit(1)= options(2); end
    if length(options)>=5;
        if options(6)==1; minfun= 'mdsmax';
        elseif options(6)==2; minfun= 'adsmax';
        else   error('options(6) does not correspond to known algorithm');
        end
    end
    if length(options)>=10; stopit(2)= options(10); end

    ret = feval(minfun, funfun,  X0, stopit, [], varargin{:});
endfunction
