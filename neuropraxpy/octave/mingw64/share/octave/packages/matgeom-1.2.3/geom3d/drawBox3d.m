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

function varargout = drawBox3d(box, varargin)
% Draw a 3D box defined by coordinate extents.
%   
%   drawBox3d(BOX);
%   Draw a box defined by its coordinate extents: 
%   BOX = [XMIN XMAX YMIN YMAX ZMIN ZMAX].
%   The function draws only the outline edges of the box.
%
%   Example
%     % Draw bounding box of a cubeoctehedron
%     [v e f] = createCubeOctahedron;
%     box3d = boundingBox3d(v);
%     figure; hold on;
%     drawMesh(v, f);
%     drawBox3d(box3d);
%     set(gcf, 'renderer', 'opengl')
%     axis([-2 2 -2 2 -2 2]);
%     view(3)
%
%   See Also:
%     boxes3d, boundingBox3d
%

% ---------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRA - TPV URPOI - BIA IMASTE
% created the 22/02/2010.
%

% Parse and check inputs
isBox3d = @(x) validateattributes(x,{'numeric'},...
    {'nonempty','nonnan','real','finite','size',[nan,6]});
defOpts.Color = 'b';
[hAx, box, varargin] = ...
    parseDrawInput(box, isBox3d, 'line', defOpts, varargin{:});


% box limits
xmin = box(:,1);
xmax = box(:,2);
ymin = box(:,3);
ymax = box(:,4);
zmin = box(:,5);
zmax = box(:,6);

nBoxes = size(box, 1);

gh=zeros(nBoxes,1);
for i=1:nBoxes
    % lower face (z=zmin)
    sh(1)=drawEdge3d(hAx, [xmin(i) ymin(i) zmin(i)     xmax(i) ymin(i) zmin(i)], varargin{:});
    sh(2)=drawEdge3d(hAx, [xmin(i) ymin(i) zmin(i)     xmin(i) ymax(i) zmin(i)], varargin{:});
    sh(3)=drawEdge3d(hAx, [xmax(i) ymin(i) zmin(i)     xmax(i) ymax(i) zmin(i)], varargin{:});
    sh(4)=drawEdge3d(hAx, [xmin(i) ymax(i) zmin(i)     xmax(i) ymax(i) zmin(i)], varargin{:});
 
    % front face (y=ymin)
    sh(5)=drawEdge3d(hAx, [xmin(i) ymin(i) zmin(i)     xmin(i) ymin(i) zmax(i)], varargin{:});
    sh(6)=drawEdge3d(hAx, [xmax(i) ymin(i) zmin(i)     xmax(i) ymin(i) zmax(i)], varargin{:});
    sh(7)=drawEdge3d(hAx, [xmin(i) ymin(i) zmax(i)     xmax(i) ymin(i) zmax(i)], varargin{:});

    % left face (x=xmin)
    sh(8)=drawEdge3d(hAx, [xmin(i) ymax(i) zmin(i)     xmin(i) ymax(i) zmax(i)], varargin{:});
    sh(9)=drawEdge3d(hAx, [xmin(i) ymin(i) zmax(i)     xmin(i) ymax(i) zmax(i)], varargin{:});

    % the last 3 remaining edges
    sh(10)=drawEdge3d(hAx, [xmin(i) ymax(i) zmax(i)     xmax(i) ymax(i) zmax(i)], varargin{:});
    sh(11)=drawEdge3d(hAx, [xmax(i) ymax(i) zmin(i)     xmax(i) ymax(i) zmax(i)], varargin{:});
    sh(12)=drawEdge3d(hAx, [xmax(i) ymin(i) zmax(i)     xmax(i) ymax(i) zmax(i)], varargin{:});
    
    gh(i) = hggroup(hAx);
    set(sh,'Parent',gh(i))
end

if nargout > 0
    varargout = {gh};
end
