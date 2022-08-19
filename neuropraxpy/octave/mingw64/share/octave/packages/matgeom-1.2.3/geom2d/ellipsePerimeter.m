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

function perim = ellipsePerimeter(ellipse, varargin)
%ELLIPSEPERIMETER Perimeter of an ellipse.
%
%   P = ellipsePerimeter(ELLI)
%   Computes the perimeter of an ellipse, using numerical integration.
%   ELLI is an ellipse, given using one of the following formats:
%   * a 1-by-5 row vector containing coordinates of center, length of
%       semi-axes, and orientation in degrees
%   * a 1-by-2 row vector containing only the lengths of the semi-axes.
%   The result
%
%   P = ellipsePerimeter(ELLI, TOL)
%   Specify the relative tolerance for numerical integration.
%
%
%   Example
%   P = ellipsePerimeter([30 40 30 10 15])
%   P = 
%       133.6489 
%
%   See also
%     ellipses2d, drawEllipse
%
%

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-02-20,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%% Parse input argument

if size(ellipse, 2) == 5
    ra = ellipse(:, 3);
    rb = ellipse(:, 4);
    
elseif size(ellipse, 2) == 2
    ra = ellipse(:, 1);
    rb = ellipse(:, 2);
    
elseif size(ellipse, 2) == 1
    ra = ellipse;
    rb = varargin{1};
    varargin(1) = [];
    
end

% relative tolerance 
tol = 1e-10;
if ~isempty(varargin)
    tol = varargin{1};
end


%% Numerical integration

n = length(ra);

perim = zeros(n, 1);

for i = 1:n
    % function to integrate
    f = @(t) sqrt(ra(i) .^ 2 .* cos(t) .^ 2 + rb(i) .^ 2 .* sin(t) .^ 2) ;

    % absolute tolerance from relative tolerance
    eps = tol * max(ra(i), rb(i));
    
    % integrate on first quadrant
    if verLessThan('matlab', '7.14')
        perim(i) = 4 * quad(f, 0, pi/2, eps); %#ok<DQUAD>
    else
        perim(i) = 4 * integral(f, 0, pi/2, 'AbsTol', eps);
    end
end

