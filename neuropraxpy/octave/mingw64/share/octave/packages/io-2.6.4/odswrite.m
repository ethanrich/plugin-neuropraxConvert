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
## @deftypefn {Function File} @var{rstatus} = odswrite (@var{filename}, @var{arr})
## @deftypefnx {Function File} @var{rstatus} = odswrite (@var{filename}, @var{arr}, @var{wsh})
## @deftypefnx {Function File} @var{rstatus} = odswrite (@var{filename}, @var{arr}, @var{wsh}, @var{range})
## @deftypefnx {Function File} @var{rstatus} = odswrite (@var{filename}, @var{arr}, @var{wsh}, @var{range}, @var{reqintf})
## Write data to a spreadsheet file.
##
## For more info see the help for xlswrite.m.
##
## odsread.m is deprecated.  Currently it is a mere wrapper for xlswrite.m
##
## @seealso {xlswrite}
##
## @end deftypefn

## Author: Philip Nienhuis <pr.nienhuis at users.sf.net>
## Created: 2009-12-14

function [ rstatus ] = odswrite (varargin)

  rstatus = xlswrite (varargin{:});

endfunction
