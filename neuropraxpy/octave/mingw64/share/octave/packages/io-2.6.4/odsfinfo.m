## Copyright (C) 2009-2021 Philip Nienhuis
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
## @deftypefn {Function File} [@var{filetype}] = odsfinfo (@var{filename} [, @var{reqintf}])
## @deftypefnx {Function File} [@var{filetype}, @var{sh_names}] = odsfinfo (@var{filename} [, @var{reqintf}])
## @deftypefnx {Function File} [@var{filetype}, @var{sh_names}, @var{nmranges}] = odsfinfo (@var{filename} [, @var{reqintf}])
## @deftypefnx {Function File} [@var{filetype}, @var{sh_names}, @var{fformat}, @var{nmranges}] = odsfinfo (@var{filename} [, @var{reqintf}])
## Query a spreadsheet file for some info about its contents.
##
## For more info see the help for xlsfinfo.m.
##
## odsfinfo.m is deprecated.  Currently it is a mere wrapper for xlsfinfo.m
##
## @seealso {xlsfinfo}
##
## @end deftypefn

## Author: Philip Nienhuis <pr.nienhuis at users.sf.net>
## Created: 2009-12-17

function [a, b, c, d] = odsfinfo (varargin)

  [a, b, c, d] = xlsfinfo.m (varargin{:});
  
endfunction
