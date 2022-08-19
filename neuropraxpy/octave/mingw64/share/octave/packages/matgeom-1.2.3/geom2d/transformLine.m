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

function dest = transformLine(line, trans)
%TRANSFORMLINE Transform a line with an affine transform.
%
%   LINE2 = transformLine(LINE1, TRANS);
%   returns the line LINE1 transformed with affine transform TRANS. 
%   LINE1 has the form [x0 y0 dx dy], and TRANS is a transformation
%   matrix.
%
%   Format of TRANS can be one of :
%   [a b]   ,   [a b c] , or [a b c]
%   [d e]       [d e f]      [d e f]
%                            [0 0 1]
%
%   LINE2 = transformLine(LINES, TRANS);
%   Also work when LINES is a [N*4] array of double. In this case, LINE2
%   has the same size as LINE. 
%
%   See also:
%   lines2d, transforms2d, transformPoint
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 06/04/2004.
%

%   HISTORY
%   02/03/2007: rewrite function


% isolate points
points1 = line(:, 1:2);
points2 = line(:, 1:2) + line(:, 3:4);

% transform points 
points1 = transformPoint(points1, trans);
points2 = transformPoint(points2, trans);

dest = createLine(points1, points2);
