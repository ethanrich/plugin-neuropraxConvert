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
## @deftypefn {Function File} [ @var{ods}, @var{rstatus} ] = oct2ods (@var{arr}, @var{ods})
## @deftypefnx {Function File} [ @var{ods}, @var{rstatus} ] = oct2ods (@var{arr}, @var{ods}, @var{wsh})
## @deftypefnx {Function File} [ @var{ods}, @var{rstatus} ] = oct2ods (@var{arr}, @var{ods}, @var{wsh}, @var{range})
## @deftypefnx {Function File} [ @var{ods}, @var{rstatus} ] = oct2ods (@var{arr}, @var{ods}, @var{wsh}, @var{range}, @var{options})
## Transfer data to spreadsheet file pointer @var{ods}.
##
## For more info see the help for oct2xls.m.
##
## oct2ods.m is deprecated.  Currently it is a mere wrapper for oct2xls.m
##
## @seealso {oct2xls}
##
## @end deftypefn

## Author: Philip Nienhuis <pr.nienhuis at users.sf.net>
## Created: 2009-12-13

function [a, b] = oct2ods (varargin)

  [a, b] = oct2xls (varargin{:});

endfunction
