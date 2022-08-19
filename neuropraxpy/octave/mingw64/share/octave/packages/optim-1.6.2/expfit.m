## Copyright (C) 2022 Olaf Till <i7tiol@t-online.de>
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
## This is a deprecated wrapper to @code{pronyfit}, please see the
## documentation of the latter function.

function [a, c, rms] = expfit (deg, x1, h, y)

  persistent warned = false;

  if (! warned)

    warned = true;

    warning ("Octave:deprecated-function",
             ["`expfit' of the `optim' package has been", ...
              " renamed to `pronyfit'. Calling it with", ...
              " `expfit (...)' still works, but is deprecated", ...
              " and will stop working in the future.", ...
              " An `expfit' function, supposed to be", ...
              " compatible to the corresponding Matlab function,", ...
              " has been added to the `statistics' package."]);

  endif

  [a, c, rms] = pronyfit (deg, x1, h, y);

endfunction
