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

function ptProj = projPointOnCylinder(pt, cyl, varargin)
%PROJPOINTONCYLINDER Project a 3D point onto a cylinder.
%
%   PTPROJ = projPointOnCircle3d(PT, CYLINDER).
%   Computes the projection of 3D point PT onto the CYLINDER. 
%   
%   Point PT is a 1-by-3 array, and CYLINDER is a 1-by-7 array.
%   Result PTPROJ is a 1-by-3 array, containing the coordinates of the
%   projection of PT onto the CYLINDER.
%
%   PTPROJ = projPointOnCircle3d(..., OPT)
%   with OPT = 'open' (0) (default) or 'closed' (1), specify if the bases 
%   of the cylinder should be included.
%
%   Example
%       demoProjPointOnCylinder
%
%   See also
%       projPointOnLine3d, projPointOnPlane, projPointOnCircle3d
%

% ---------
% Author: oqilipo
% Created: 2021-04-17, using R2020b
% Copyright 2021

parser = inputParser;
addRequired(parser, 'pt', @(x) validateattributes(x, {'numeric'},...
    {'size',[1 3],'real','finite','nonnan'}));
addRequired(parser, 'cyl', @(x) validateattributes(x, {'numeric'},...
    {'size',[1 7],'real','finite','nonnan'}));
capParValidFunc = @(x) (islogical(x) ...
    || isequal(x,1) || isequal(x,0) || any(validatestring(x, {'open','closed'})));
addOptional(parser,'cap','open', capParValidFunc);
parse(parser,pt,cyl,varargin{:});
pt = parser.Results.pt;
cyl = parser.Results.cyl;
cap = lower(parser.Results.cap(1));

% Radius of the cylinder
cylRadius = cyl(7);
% Height of the cylinder
cylBottom = -Inf;
cylHeight = Inf;
if cap == 'c' || cap == 1
    cylBottom = 0;
    cylHeight = distancePoints3d(cyl(1:3),cyl(4:6));
end
% Create a transformation for the point into a local cylinder coordinate 
% system. Align the cylinder axis with the z axis and translate the 
% starting point of the cylinder to the origin.
TFM = createRotationVector3d(cyl(4:6)-cyl(1:3), [0 0 1])*createTranslation3d(-cyl(1:3));
% cylTfm = [transformPoint3d(cyl(1:3), TFM) transformPoint3d(cyl(4:6), TFM) cylRadius];
% cylTfm2 = [0 0 0 0 0 cylHeight, cylRadius];
% assert(ismembertol(cylTfm,cylTfm2,'byRows',1,'DataScale',1e1))

% Transform the point.
ptTfm = transformPoint3d(pt,TFM);
% Convert the transformed point to cylindrical coordinates.
[ptTheta, ptRadius, ptHeight] = cart2cyl(ptTfm);

if ptRadius <= cylRadius && (ptHeight <= cylBottom || ptHeight >= cylHeight)
    % If point is inside the radius of the cylinder but outside its height
    if ptHeight <= cylBottom
        ptProj_cyl = [ptTheta, ptRadius, 0];
    else
        ptProj_cyl = [ptTheta, ptRadius, cylHeight];
    end
elseif ptRadius > cylRadius && (ptHeight <= cylBottom || ptHeight >= cylHeight)
    % If point is outside the cylinder's radius and height
    if ptHeight <= cylBottom
        ptProj_cyl = [ptTheta, cylRadius, 0];
    else
        ptProj_cyl = [ptTheta, cylRadius, cylHeight];
    end
elseif ptRadius < cylRadius && (ptHeight > cylBottom && ptHeight < cylHeight)
    % If point is inside the cylinder's radius and height
    deltaRadius = cylRadius - ptRadius;
    deltaHeight = cylHeight - ptHeight;
    if (deltaRadius < ptHeight && deltaRadius < deltaHeight) || isinf(cylBottom)
        % If the distance to the cylinder's surface is smaller than the
        % distance to the top and bottom surfaces.
        ptProj_cyl = [ptTheta, cylRadius, ptHeight];
    else
        if ptHeight < deltaHeight
            ptProj_cyl = [ptTheta, ptRadius, 0];
        else
            ptProj_cyl = [ptTheta, ptRadius, cylHeight];
        end
    end
elseif ptRadius >= cylRadius && (ptHeight > cylBottom && ptHeight < cylHeight)
    % If point is outside the radius of the cylinder and inside its height
    ptProj_cyl = [ptTheta, cylRadius, ptHeight];
end

% Convert the projected point back to Cartesian coordinates 
ptProj_cart = cyl2cart(ptProj_cyl);
% Transform the projected point back to the global coordinate system
ptProj = transformPoint3d(ptProj_cart,inv(TFM));

end
