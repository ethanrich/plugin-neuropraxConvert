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
## @deftypefn {Function File} [@var{ods}] = odsclose (@var{ods})
## @deftypefnx {Function File} [@var{ods}] = odsclose (@var{ods}, @var{filename})
## @deftypefnx {Function File} [@var{ods}] = odsclose (@var{ods}, "FORCE")
## Close a spreadsheet file pointer and if needed write the contents to disk.
##
## For more info see the help for xlsclose.m.
##
## odsclose.m is deprecated.  Currently it is a mere wrapper for xlsclose.m
##
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2009-12-13

function [ ods ] = odsclose (varargin)

  ods = xlsclose (varargin{:});

endfunction
