## Copyright (C) 2014-2021 Philip Nienhuis
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {Function File} {@var{ftype} =} __get_ftype__ (@var{fname})
## Get file type index from a file name, based on the file extension.
##
## Supported file type indices:
##  1 = .xls      (BIFF8, also BIFF5)
##  2 = .xlsx     (OOXML)
##  3 = .ods      (ODS 1.2)
##  4 = .sxc      (old OpenOffice.org format)
##  5 = .gnumeric (Gnumeric XML)
##  6 = .csv      (Comma Separated Values)
##  7 = .uof      (Unified Office Format)
##  8 = .fods     (ODS Flat XML)
##  9 = .dbf      (Dbase)
## 10 = .dif      (Digital InterchangeFormat)
##
## @var{ftype} is set to 0 (zero) for any other file type.
## @var{ftype} is set to empty for file names without extension.
## In those cases filtnam is set to empty
##
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2014-01-01

function [ftype, filtnam] = __get_ftype__ (fname)

  persistent filtnams;
  filtnams = {"MS Excel 97",                        ## .xls
              "Calc MS Excel 2007 XML",             ## .xlsx
              "calc8",                              ## .ods
              "StarOffice XML (Calc)",              ## .sxc
              "---gnumeric---",                     ## .gnumeric
              "Text CSV",                           ## .csv
              "UOF spreadsheet",                    ## .uos
              "OpenDocument Spreadsheet Flat XML",  ## .fods
              "dBase",                              ## .dbf
              "DIF"};                               ## .dif
  
  [~, ~, ext] = fileparts (fname);
  if (! isempty (ext))
    switch ext
      case ".xls"                       ## Regular (binary) BIFF
        ftype = 1;
      case {".xlsx", ".xlsm", ".xlsb"}  ## Zipped XML / OOXML. Catches xlsx, xlsb, xlsm
        ftype = 2;
      case ".ods"                       ## ODS 1.2 (Excel 2007+ & OOo/LO can read ODS)
        ftype = 3;
      case ".sxc"                       ## old OpenOffice.org 1.0 Calc
        ftype = 4;
      case ".gnumeric"                  ## Zipped XML / gnumeric
        ftype = 5;
      case ".csv"                       ## csv. Detected for xlsread afficionados
        ftype = 6;
      case ".uof"                       ## Unified Office Format
        ftype = 7;
      case ".fods"                      ## ODS Flat HTML
        ftype = 8;
      case ".dbf"                       ## Dbase
        ftype = 9;
      case ".dif"                       ## Digital Interchange Format
        ftype = 10;
      otherwise                         ## Any other type = non-supported 
        ftype = 0;
    endswitch
  else
    ftype = "";
  endif

  if (ftype > 0)
    filtnam = filtnams{ftype};
  else
    filtnam = "";
  endif

endfunction
