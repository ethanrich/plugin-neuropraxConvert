## Copyright (C) 2021 David Legland
## All rights reserved.
## 
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
## 
##     1 Redistributions of source code must retain the above copyright notice,
##       this list of conditions and the following disclaimer.
##     2 Redistributions in binary form must reproduce the above copyright
##       notice, this list of conditions and the following disclaimer in the
##       documentation and/or other materials provided with the distribution.
## 
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS''
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
## ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
## DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
## SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
## CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
## OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
## OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
## 
## The views and conclusions contained in the software and documentation are
## those of the authors and should not be interpreted as representing official
## policies, either expressed or implied, of the copyright holders.

function polys = readPolygonSet(filename)
%READPOLYGONSET Read a set of simple polygons stored in a file.
%   
%   POLY = readPolygonSet(FILENAME);
%   Returns the polygon stored in the file FILENAME.
%   Polygons are assumed to be stored in text files, without headers, with
%   x and y coordinates packed in two separate lines:
%     X11 X12 X13 ... X1N
%     Y11 Y12 Y13 ... Y1N
%     X21 X22 X23 ... X2N
%     Y21 Y22 Y23 ... Y2N
%
%   Each polygon may have a different number of vertices. The result is a
%   cell array of polygon, each cell containing a N-by-2 array representing
%   the vertex coordinates.
%
%   See also:
%   polygons2d
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 11/04/2004.
%

% the set of polygons (no pre-allocation, as we do not know how many
% polygons are stored)
polys = {};

% index of polygon
p = 0;

% open file for reading
fid = fopen(filename, 'rt');

% use an infinite loop, terminated in case of EOF
while true
    % set of X, and Y coordinates 
    line1 = fgetl(fid);
    line2 = fgetl(fid);
    
    % break loop if end of file is reached
    if line1 == -1
        break;
    end
   
    % create a new polygon by concatenating vertex coordinates
    p = p + 1;
    polys{p} = [str2num(line1)' str2num(line2)']; %#ok<AGROW,ST2NM>
end    

% close file
fclose(fid);
