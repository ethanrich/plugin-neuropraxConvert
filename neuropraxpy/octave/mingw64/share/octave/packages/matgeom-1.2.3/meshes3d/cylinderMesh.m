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

function varargout = cylinderMesh(cyl, varargin)
% Create a 3D mesh representing a cylinder.
%
%   [V, F] = cylinderMesh(CYL)
%   Computes vertex coordinates and face vertex indices of a mesh
%   representing a 3D cylinder given as [X1 Y1 Z1 X2 Y2 Z2 R].
%   
%   [V, F] = cylinderMesh(..., OPT)
%   with OPT = 'open' (0) (default) or 'closed' (1), specify if the bases 
%   of the cylinder should be included.
%   
%   [V, F] = cylinderMesh(..., NAME, VALUE);
%   Specifies one or several options using parameter name-value pairs.
%   Available options are:
%   'nPerimeter' the number of circles represeting the perimeter
%   'nRho' the number of circles along the hight
%
%   Example
%     % Draw a rotated cylinder
%     cyl = [0 0 0 10 20 30 5];
%     [v, f] = cylinderMesh(cyl);
%     figure;drawMesh(v, f, 'FaceColor', 'r');
%     view(3); axis equal;
%
%     % Draw three mutually intersecting cylinders
%       p0 = [30 30 30];
%       p1 = [90 30 30];
%       p2 = [30 90 30];
%       p3 = [30 30 90];
%       [v1 f1] = cylinderMesh([p0 p1 25]);
%       [v2 f2] = cylinderMesh([p0 p2 25]);
%       [v3 f3] = cylinderMesh([p0 p3 25],'closed','nPeri',40,'nRho',20);
%       figure; hold on;
%       drawMesh(v1, f1, 'FaceColor', 'r');
%       drawMesh(v2, f2, 'FaceColor', 'g');
%       drawMesh(v3, f3, 'FaceColor', 'b');
%       view(3); axis equal
%       set(gcf, 'renderer', 'opengl')
%  
%   See also
%     drawCylinder, torusMesh, sphereMesh

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2012-10-25,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

parser = inputParser;
addRequired(parser, 'cyl', @(x) validateattributes(x, {'numeric'},...
    {'size',[1 7],'real','finite','nonnan'}));
capParValidFunc = @(x) (islogical(x) ...
    || isequal(x,1) || isequal(x,0) || any(validatestring(x, {'open','closed'})));
addOptional(parser,'cap','open', capParValidFunc);
addParameter(parser, 'nPerimeter', 20, @(x) validateattributes(x,{'numeric'},...
    {'integer','scalar','>=',4}));
addParameter(parser, 'nRho', 10, @(x) validateattributes(x,{'numeric'},...
    {'integer','scalar','>=',2}));
parse(parser,cyl,varargin{:});
cyl=parser.Results.cyl;
cap=lower(parser.Results.cap(1));
NoPP=parser.Results.nPerimeter;
nRho=parser.Results.nRho;

% extract cylinder data
p1 = cyl(:, 1:3);
p2 = cyl(:, 4:6);
r  = cyl(:, 7);

% compute length and orientation
[theta, phi, rho] = cart2sph2d(p2 - p1);

% parametrisation on x
t = linspace(0, 2*pi, NoPP);
lx = r * cos(t);
ly = r * sin(t);

% parametrisation on z
lz = linspace(0, rho, nRho);

% generate surface grids
x = repmat(lx, [length(lz) 1]);
y = repmat(ly, [length(lz) 1]);
z = repmat(lz', [1 length(t)]);

% transform points 
trans = localToGlobal3d(p1, theta, phi, 0);
[x, y, z] = transformPoint3d(x, y, z, trans);

% convert to FV mesh
[vertices, faces] = surfToMesh(x, y, z, 'xPeriodic', true);

% Close cylinder
if cap == 'c' || cap == 1
    toe.vertices = [x(1,1:NoPP-1); y(1,1:NoPP-1); z(1,1:NoPP-1)]';
    toe.vertices(NoPP,:) = transformPoint3d([0 0 0], trans);
    toe.faces = [repmat(NoPP, 1, NoPP-1); [2:NoPP-1 1]; 1:NoPP-1]';
    
    top.vertices = [x(end,1:NoPP-1); y(end,1:NoPP-1); z(end,1:NoPP-1)]';
    top.vertices(NoPP,:) = transformPoint3d([0 0 rho], trans);
    top.faces = fliplr(toe.faces);
    
    [vertices, faces] = concatenateMeshes(vertices, triangulateFaces(faces), ...
        toe.vertices, toe.faces, top.vertices, top.faces);
end

% format output
varargout = formatMeshOutput(nargout, vertices, faces);
