## Copyright (C) 2008, Thomas Treichl <thomas.treichl@gmx.net>
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
## @deftypefn {Function} {[@var{string}] =} asci ([@var{columns}])
## Print ASCII table.
##
## This function has been renamed @code{ascii} (note double i at the end of
## its name) and will be removed from future versions of the miscellaneous
## package. Please refer to @code{ascii} help text for its documentation.
##
## @end deftypefn

function [varargout] = asci (varargin)
  persistent warned = false;
  if (! warned)
    warned = true;
    warning ("asci() has been deprecated. Use ascii (note double i in the name) instead");
  endif
  [varargout{1:nargout}] = ascii (varargin{:});
endfunction
