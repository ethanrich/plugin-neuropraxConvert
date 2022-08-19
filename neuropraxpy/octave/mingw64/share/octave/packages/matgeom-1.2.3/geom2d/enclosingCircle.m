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

function circle = enclosingCircle(pts)
%ENCLOSINGCIRCLE Find the minimum circle enclosing a set of points.
%
%   CIRCLE = enclosingCircle(POINTS);
%   computes the circle CIRCLE=[xc yc r] which encloses all the points POINTS
%   given as a N-by-2 array.
%
%
%   Rewritten from a file from
%           Yazan Ahed (yash78@gmail.com)
%
%   which was rewritten from a Java applet by Shripad Thite:
%   http://heyoka.cs.uiuc.edu/~thite/mincircle/
%
%   See also:
%   circles2d, points2d, boxes2d, circumCircle
%

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% created the 07/07/2005.
% Copyright 2012 INRA - Cepia Software Platform.


% works on convex hull: it is faster
pts = pts(convhull(pts(:,1), pts(:,2)), :);

% call the recursive function
circle = recurseCircle(size(pts, 1), pts, 1, zeros(3, 2));



function circ = recurseCircle(n, p, m, b)
%    n: number of points given
%    m: an argument used by the function. Always use 1 for m.
%    bnry: an argument (3x2 array) used by the function to set the points that 
%          determines the circle boundry. You have to be careful when choosing this
%          array's values. I think the values should be somewhere outside your points
%          boundary. For my case, for example, I know the (x,y) I have will be something
%          in between (-5,-5) and (5,5), so I use bnry as:
%                       [-10 -10
%                        -10 -10
%                        -10 -10]


if m == 4
    circ = createCircle(b(1,:), b(2,:), b(3,:));
    return;
end

circ = [Inf Inf 0];

if m == 2
    circ = [b(1,1:2) 0];
elseif m == 3
    c = (b(1,:) + b(2,:))/2;
    circ = [c distancePoints(b(1,:), c)];
end


for i = 1:n
    if distancePoints(p(i,:), circ(1:2)) > circ(3)
        if sum(b(:,1)==p(i,1) & b(:,2)==p(i,2)) == 0
            b(m,:) = p(i,:);
            circ = recurseCircle(i, p, m+1, b);
        end
    end
end

