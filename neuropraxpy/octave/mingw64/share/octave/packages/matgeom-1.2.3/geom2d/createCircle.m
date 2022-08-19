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

function circle = createCircle(varargin)
%CREATECIRCLE Create a circle from 2 or 3 points.
%
%   C = createCircle(P1, P2, P3);
%   Creates the circle passing through the 3 given points. 
%   C is a 1*3 array of the form: [XC YX R].
%
%   C = createCircle(P1, P2);
%   Creates the circle whith center P1 and passing throuh the point P2.
%
%   Works also when input are point arrays the same size, in this case the
%   result has as many lines as the point arrays.
%
%   Example
%   % Draw a circle passing through 3 points.
%     p1 = [10 15];
%     p2 = [15 20];
%     p3 = [10 25];
%     circle = createCircle(p1, p2, p3);
%     figure; hold on; axis equal; axis([0 50 0 50]);
%     drawPoint([p1 ; p2; p3]);
%     drawCircle(circle);
%
%   See also:
%   circles2d, createDirectedCircle
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 31/10/2003.
%


if nargin == 2
    % inputs are the center and a point on the circle
    p1 = varargin{1};
    p2 = varargin{2};
    x0 = p1(:,1);
    y0 = p1(:,2);
    r = hypot((p2(:,1)-x0), (p2(:,2)-y0));
    
elseif nargin == 3
    % inputs are three points on the circle
    p1 = varargin{1};
    p2 = varargin{2};
    p3 = varargin{3};

    % compute circle center
    line1 = medianLine(p1, p2);
    line2 = medianLine(p1, p3);
    point = intersectLines(line1, line2);
    x0 = point(:, 1); 
    y0 = point(:, 2);
    
    % circle radius
    r = hypot((p1(:,1)-x0), (p1(:,2)-y0));
end
    
% create array for returning result        
circle = [x0 y0 r];
