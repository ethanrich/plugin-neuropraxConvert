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

function writePolygonSet(polys, filename)
%WRITEPOLYGONSET Write a set of simple polygons into a file.
%   
%   writePolygonSet(POLYS, FILENAME);
%   Writes the set of polygons in the file FILENAME.
%   Following format is used:
%     X11 X12 X13 ... X1N
%     Y11 Y12 Y13 ... Y1N
%     X21 X22 X23 ... X2N
%     Y21 Y22 Y23 ... Y2N
%   Each polygon may have a different number of vertices. 
%
%   See also:
%   polygons2d, readPolygonSet
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 14/01/2013.
%


% open file for reading
fid = fopen(filename, 'wt');

for i = 1:length(polys)
    poly = polys{i};
    n = size(poly, 1);
    
    % precompute format
    format = [repmat('%g ', 1, n) '\n'];
    
    % write one line for x, then one line for y
    fprintf(fid, format, poly(:,1)');
    fprintf(fid, format, poly(:,2)');    
end

% close file
fclose(fid);
