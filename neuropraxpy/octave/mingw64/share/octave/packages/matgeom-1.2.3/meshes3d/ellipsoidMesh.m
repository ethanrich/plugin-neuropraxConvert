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

function varargout = ellipsoidMesh(elli, varargin)
%ELLIPSOIDMESH Convert a 3D ellipsoid to face-vertex mesh representation.
%
%   [V, F] = ellipsoidMesh(ELLI)
%   ELLI is given by:
%   [XC YC ZC  A B C  PHI THETA PSI],
%   where (XC, YC, ZC) is the ellipsoid center, A, B and C are the half
%   lengths of the ellipsoid main axes, and PHI THETA PSI are Euler angles
%   representing ellipsoid orientation, in degrees.
%
%
%   See also
%   meshes3d, drawEllipsoid, sphereMesh, equivalentEllipsoid
%

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-03-12,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.


%% Default values

% number of meridians
nPhi    = 32;

% number of parallels
nTheta  = 16;


%% Extract input arguments

% Parse the input (try to extract center coordinates and radius)
if nargin == 0
    % no input: assumes ellipsoid with default shape
    elli = [0 0 0 5 4 3 0 0 0];
end

% default set of options for drawing meshes
options = {'FaceColor', 'g', 'linestyle', 'none'};

while length(varargin) > 1
    switch lower(varargin{1})
        case 'nphi'
            nPhi = varargin{2};
            
        case 'ntheta'
            nTheta = varargin{2};

        otherwise
            % assumes this is drawing option
            options = [options varargin(1:2)]; %#ok<AGROW>
    end

    varargin(1:2) = [];
end


%% Parse numerical inputs

% Extract ellipsoid parameters
xc  = elli(:,1);
yc  = elli(:,2);
zc  = elli(:,3);
a   = elli(:,4);
b   = elli(:,5);
c   = elli(:,6);
k   = pi / 180;
ellPhi   = elli(:,7) * k;
ellTheta = elli(:,8) * k;
ellPsi   = elli(:,9) * k;


%% Coordinates computation

% convert unit basis to ellipsoid basis
sca     = createScaling3d(a, b, c);
rotZ    = createRotationOz(ellPhi);
rotY    = createRotationOy(ellTheta);
rotX    = createRotationOx(ellPsi);
tra     = createTranslation3d([xc yc zc]);

% concatenate transforms
trans   = tra * rotZ * rotY * rotX * sca;


%% parametrisation of ellipsoid

% spherical coordinates
theta   = linspace(0, pi, nTheta+1);
phi     = linspace(0, 2*pi, nPhi+1);

% convert to cartesian coordinates
sintheta = sin(theta);
x = cos(phi') * sintheta;
y = sin(phi') * sintheta;
z = ones(length(phi),1) * cos(theta);

% transform mesh vertices
[x, y, z] = transformPoint3d(x, y, z, trans);

% convert to FV mesh
[vertices, faces] = surfToMesh(x, y, z, 'xPeriodic', false, 'yPeriodic', true);

% format output
varargout = formatMeshOutput(nargout, vertices, faces);
