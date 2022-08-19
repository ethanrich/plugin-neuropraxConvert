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

function silhouette = meshSilhouette(v, f, varargin)
%MESHSILHOUETTE Compute the 2D outline of a 3D mesh on an arbitrary plane.
%
%   ATTENTION: Very slow brute force approach! Keep the number of faces as
%   low as possible.
%
%   SILHOUETTE = meshSilhouette(MESH, PLANE)
%   Calculates the silhouette (2D outline) of the MESH projected on the
%   PLANE.
%
%   SILHOUETTE = meshSilhouette(MESH) uses the x-y plane.
%
%   SILHOUETTE = meshSilhouette(V, F, ...)
%
%   SILHOUETTE = meshSilhouette(..., 'visu', 1) visualizes the results.
%   By default the results are not visualized.
%
%   Example:
%     v = [5, 2, 6, 0, 3;  0, 2, 4, 2, 1;  -5, -6, -6, -7, -9]';
%     f = [1, 2, 4; 1, 5, 4; 1, 2, 5; 2, 3, 5; 2, 4, 3; 3, 4, 5];
%     sil = meshSilhouette(v, f, rand(1,9),'visu',1);
%   
%   See also:
%     projPointOnPlane
%
%   Source:
%     Sean de Wolski - https://www.mathworks.com/matlabcentral/answers/68004

% ---------
% Authors: oqilipo
% Created: 2020-07-29
% Copyright 2020

narginchk(1,5)
nargoutchk(0,1)

%% Parse inputs
% If first argument is a struct
if isstruct(v)
    if nargin > 1
        varargin=[{f} varargin{:}];
    end
    mesh = v;
    [v, f] = parseMeshData(v);
else
    mesh.vertices = v;
    mesh.faces = f;
end

p = inputParser;
logParValidFunc = @(x) (islogical(x) || isequal(x,1) || isequal(x,0));
addOptional(p,'plane',[0 0 0 1 0 0 0 1 0],@isPlane)
addParameter(p,'visualization',false,logParValidFunc);
parse(p, varargin{:});
plane = p.Results.plane;

% Transform into the x-y plane
TFM = createBasisTransform3d('g', plane);
v = transformPoint3d(v,TFM);

% Initialize final polygon vectors
[px, py] = boundary(polyshape(v(f(1,:),1) ,v(f(1,:),2), 'Simplify',false));
for i = 2:size(f,1)
    A = polyshape(v(f(i,:),1), v(f(i,:),2), 'Simplify',false);
    B = polyshape(px, py, 'Simplify',false);
    [px, py] = boundary(union(A,B));
end

% Transform back into the plane
silhouette = transformPoint3d([px,py,zeros(size(px))], inv(TFM));

if p.Results.visualization
    figure('Color','w'); axH = axes(); axis(axH, 'equal', 'tight')
    drawPolyline3d(axH, silhouette,'Color','r','LineWidth',3)
    drawPlane3d(axH, plane,'FaceAlpha',0.5)
    drawMesh(mesh,'FaceAlpha',0.5,'FaceColor','none')
    axis(axH, 'equal')
    camTar = nanmean(silhouette);
    axH.CameraTarget = camTar;
    axH.CameraPosition = camTar + ...
        planeNormal(plane)*vectorNorm3d(axH.CameraPosition-axH.CameraTarget);
    axH.CameraUpVector = plane(4:6);
    xlabel(axH, 'x'); ylabel(axH, 'y'); zlabel(axH, 'z');
end

end
