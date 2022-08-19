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

function point = intersectLineEdge(line, edge, varargin)
%INTERSECTLINEEDGE Return intersection between a line and an edge.
%
%   P = intersectLineEdge(LINE, EDGE);
%   returns the intersection point of lines LINE and edge EDGE. 
%   LINE is a 1-by-4 array containing parametric representation of the line
%   (in the form [x0 y0 dx dy], see 'createLine' for details). 
%   EDGE is a 1-by-4 array containing the coordinates of first and second
%   points (in the form [x1 y1 x2 y2], see 'createEdge' for details). 
%   
%   In case of colinear line and edge, returns [Inf Inf].
%   If line does not intersect edge, returns [NaN NaN].
%
%   If each input is N-by-4 array, the result is a N-by-2 array containing
%   intersections for each couple of edge and line.
%   If one of the input has N rows and the other 1 row, the result is a
%   N-by-2 array.
%
%   P = intersectLineEdge(LINE, EDGE, TOL);
%   Specifies the tolerance option for determining if a point belongs to an
%   edge and if lines are parallel.
%
%   See also:
%   lines2d, edges2d, intersectEdges, intersectLines
%

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 31/10/2003.
%

%   HISTORY
%   19/02/2004: add support for multiple lines.
%   08/03/2007: update doc

% extract tolerance option
tol = 1e-14;
if ~isempty(varargin)
    tol = varargin{1};
end

% number of lines and edges
nLines = size(line, 1);
nEdges = size(edge, 1);

% origin and direction vector of lines
lx0 = line(:,1);
ly0 = line(:,2);
ldx = line(:,3);
ldy = line(:,4);

% origin and direction vector of edges
ex1 = edge(:,1);
ey1 = edge(:,2);
ex2 = edge(:,3);
ey2 = edge(:,4);
edx = ex2 - ex1;
edy = ey2 - ey1;

% normalizes direction vectors
ldn = hypot(ldx, ldy);
ldx = ldx ./ ldn;
ldy = ldy ./ ldn;

% normalizes direction vectors
edgeLength = hypot(edx, edy);
edx = edx ./ edgeLength;
edy = edy ./ edgeLength;

% indices of parallel lines
par = abs(ldx .* edy - edx .* ldy) < tol;

% indices of colinear lines
col = abs((ex1-lx0) .* ldy - (ey1-ly0) .* ldx) < tol & par ;

xi(col) = Inf;
yi(col) = Inf;
xi(par & ~col) = NaN;
yi(par & ~col) = NaN;

i = ~par;

% compute intersection points
if nLines == nEdges
	xi(i) = ((ey1(i)-ly0(i)).*ldx(i).*edx(i) + lx0(i).*ldy(i).*edx(i) - ex1(i).*edy(i).*ldx(i)) ./ ...
        (edx(i).*ldy(i)-ldx(i).*edy(i)) ;
	yi(i) = ((ex1(i)-lx0(i)).*ldy(i).*edy(i) + ly0(i).*ldx(i).*edy(i) - ey1(i).*edx(i).*ldy(i)) ./ ...
        (ldx(i).*edy(i)-edx(i).*ldy(i)) ;
elseif nLines == 1
	xi(i) = ((ey1(i)-ly0).*ldx.*edx(i) + lx0.*ldy.*edx(i) - ex1(i).*edy(i).*ldx) ./ ...
        (edx(i).*ldy-ldx.*edy(i)) ;
	yi(i) = ((ex1(i)-lx0).*ldy.*edy(i) + ly0.*ldx.*edy(i) - ey1(i).*edx(i).*ldy) ./ ...
        (ldx.*edy(i)-edx(i).*ldy) ;
elseif nEdges == 1
	xi(i) = ((ey1-ly0(i)).*ldx(i).*edx + lx0(i).*ldy(i).*edx - ex1(i).*edy.*ldx(i)) ./ ...
        (edx.*ldy(i)-ldx(i).*edy) ;
	yi(i) = ((ex1-lx0(i)).*ldy(i).*edy + ly0(i).*ldx(i).*edy - ey1(i).*edx.*ldy(i)) ./ ...
        (ldx(i).*edy-edx.*ldy(i)) ;
end

% format output arguments
point   = [xi' yi'];

% compute position of points projected on the supporting line, by using
% dot product and normalising by edge length
pos = bsxfun(@rdivide, ...
    bsxfun(@times, bsxfun(@minus, xi, ex1), edx) + ...
    bsxfun(@times, bsxfun(@minus, yi, ey1), edy), edgeLength);

% set coordinates of points outside edge to NaN
out = pos < -tol | pos > (1+tol);
point(out, :) = NaN;
