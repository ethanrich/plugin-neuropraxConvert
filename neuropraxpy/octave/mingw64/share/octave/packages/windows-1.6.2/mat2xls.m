## Copyright (C) 2007-2019  Michael Goffioul <michael.goffioul@swing.be>
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

## -*- texinfo -*-
## @deftypefn {Function File} {} mat2xls (@var{obj},@var{filename})
## Save @var{obj} as an Excel sheet into the file @var{filename}. The
## object @var{obj} must be either a cell matrix or a real matrix, that
## is a 2-dimensional object. All elements of the matrix are converted
## to Excel cells and put into the first worksheet, starting at cell A1.
## Supported types are real values and strings.
##
## If @var{filename} does not contain any directory, the file is saved
## in the current directory.
##
## This function is intended to demonstrate the use of the COM interface
## within octave. You need Excel installed on your computer to make this
## function work properly.
##
## Examples:
##
## @example
##   mat2xls (rand (10, 10), 'test1.xls');
##   mat2xls (@{'This', 'is', 'a', 'string'@}, 'test2.xls');
## @end example
##
## @end deftypefn

function mat2xls (obj, filename)

  if ((iscell (obj) || isnumeric (obj)) && length (size (obj)) == 2)

    # Open Excel application
    app = actxserver ("Excel.Application");

    # Create a new workbook and get the first worksheet
    wb = app.Workbooks.Add ();
    sh = wb.Worksheets (1);

    # Save object in Excel sheet, starting at cell A1
    r = sh.Range ("A1");
    r = r.Resize (size (obj, 1), size (obj, 2));
    r.Value = obj;
    delete (r);

    # Save workbook
    wb.SaveAs (canonicalize_file_name (filename));

    # Quit Excel and clean-up
    delete (sh);
    delete (wb);
    app.Quit ();
    delete (app);

  else

    error ("mat2xls: object must be a cell or real matrix");

  endif

endfunction
