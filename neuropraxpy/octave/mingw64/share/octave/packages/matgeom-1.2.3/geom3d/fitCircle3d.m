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

function [fittedCircle, circleNormal] = fitCircle3d(pts)
%FITCIRCLE3D Fit a 3D circle to a set of points.
%
%   [FITTEDCIRCLE, CIRCLENORMAL] = fitCircle3d(PTS)
%
%   Example
%     % points on a 2d circle with noise
%     nop = randi([5 50],1,1);
%     radius = randi([5 25],1,1);
%     points2d = circleToPolygon([0 0 radius], nop);
%     points2d(1,:) = [];
%     points2d = points2d + rand(size(points2d));
%     points2d(:,3)=rand(length(nop),1);
%     % apply random rotation and translation
%     [theta, phi] = randomAngle3d;
%     theta = rad2deg(theta);
%     phi = rad2deg(phi);
%     tfm = eulerAnglesToRotation3d(phi, theta, 0);
%     trans = randi([-250 250],3,1);
%     tfm(1:3,4)=trans;
%     points3d = awgn(transformPoint3d(points2d, tfm),1);
%     % fit 3d circle
%     [fittedCircle, circleNormal] = fitCircle3d(points3d);
%     % plot 3d points and 3d circle
%     figure('Color','w'); hold on; axis equal tight; view(3);
%     xlabel('X');ylabel('Y');zlabel('Z');
%     drawPoint3d(points3d)
%     drawCircle3d(fittedCircle, 'k')
%     drawVector3d(fittedCircle(1:3), circleNormal*fittedCircle(4))
%
%   See also
%   circle3dOrigin, circle3dPosition, circle3dPoint, intersectPlaneSphere
%   drawCircle3d, drawCircleArc3d, drawEllipse3d
%
% ------
% Authors: oqilipo, David Legland
% created: 2017-05-09

% Mean of all points
meanPoint = mean(pts,1);

% Center points by subtracting the meanPoint
centeredPoints = pts - repmat(meanPoint,size(pts,1),1);

% Project 3D data to a plane
[~,~,V]=svd(centeredPoints);
tfmPoints = transformPoint3d(centeredPoints, V');

% Fit a circle to the points in the xy-plane
circleParamter = CircleFitByTaubin(tfmPoints(:,1:2));
center2d = circleParamter(1:2); 
radius=circleParamter(3);
center3d = transformPoint3d([center2d, 0], [inv(V'), meanPoint']);
circleNormal = V(:,3)';
[theta, phi, ~] = cart2sph2(circleNormal);
fittedCircle = [center3d radius rad2deg(theta) rad2deg(phi) 0];

end

% Circle Fit (Taubin method)
% version 1.0 (2.24 KB) by Nikolai Chernov
% http://www.mathworks.com/matlabcentral/fileexchange/22678
function Par = CircleFitByTaubin(XY)

%--------------------------------------------------------------------------
%  
%     Circle fit by Taubin
%      G. Taubin, "Estimation Of Planar Curves, Surfaces And Nonplanar
%                  Space Curves Defined By Implicit Equations, With 
%                  Applications To Edge And Range Image Segmentation",
%      IEEE Trans. PAMI, Vol. 13, pages 1115-1138, (1991)
%
%     Input:  XY(n,2) is the array of coordinates of n points x(i)=XY(i,1), y(i)=XY(i,2)
%
%     Output: Par = [a b R] is the fitting circle:
%                           center (a,b) and radius R
%
%     Note: this fit does not use built-in matrix functions (except "mean"),
%           so it can be easily programmed in any programming language
%
%--------------------------------------------------------------------------

n = size(XY,1);      % number of data points

centroid = mean(XY);   % the centroid of the data set

%     computing moments (note: all moments will be normed, i.e. divided by n)

Mxx = 0; Myy = 0; Mxy = 0; Mxz = 0; Myz = 0; Mzz = 0;

for i=1:n
    Xi = XY(i,1) - centroid(1);  %  centering data
    Yi = XY(i,2) - centroid(2);  %  centering data
    Zi = Xi*Xi + Yi*Yi;
    Mxy = Mxy + Xi*Yi;
    Mxx = Mxx + Xi*Xi;
    Myy = Myy + Yi*Yi;
    Mxz = Mxz + Xi*Zi;
    Myz = Myz + Yi*Zi;
    Mzz = Mzz + Zi*Zi;
end

Mxx = Mxx/n;
Myy = Myy/n;
Mxy = Mxy/n;
Mxz = Mxz/n;
Myz = Myz/n;
Mzz = Mzz/n;

%    computing the coefficients of the characteristic polynomial

Mz = Mxx + Myy;
Cov_xy = Mxx*Myy - Mxy*Mxy;
A3 = 4*Mz;
A2 = -3*Mz*Mz - Mzz;
A1 = Mzz*Mz + 4*Cov_xy*Mz - Mxz*Mxz - Myz*Myz - Mz*Mz*Mz;
A0 = Mxz*Mxz*Myy + Myz*Myz*Mxx - Mzz*Cov_xy - 2*Mxz*Myz*Mxy + Mz*Mz*Cov_xy;
A22 = A2 + A2;
A33 = A3 + A3 + A3;

xnew = 0;
ynew = 1e+20;
epsilon = 1e-12;
IterMax = 20;

% Newton's method starting at x=0

for iter=1:IterMax
    yold = ynew;
    ynew = A0 + xnew*(A1 + xnew*(A2 + xnew*A3));
    if abs(ynew) > abs(yold)
       disp('Newton-Taubin goes wrong direction: |ynew| > |yold|');
       xnew = 0;
       break;
    end
    Dy = A1 + xnew*(A22 + xnew*A33);
    xold = xnew;
    xnew = xold - ynew/Dy;
    if (abs((xnew-xold)/xnew) < epsilon), break, end
    if (iter >= IterMax)
        disp('Newton-Taubin will not converge');
        xnew = 0;
    end
    if (xnew<0.)
        fprintf(1,'Newton-Taubin negative root:  x=%f\n',xnew);
        xnew = 0;
    end
end

%  computing the circle parameters

DET = xnew*xnew - xnew*Mz + Cov_xy;
Center = [Mxz*(Myy-xnew)-Myz*Mxy , Myz*(Mxx-xnew)-Mxz*Mxy]/DET/2;

Par = [Center+centroid , sqrt(Center*Center'+Mz)];

end    %    CircleFitByTaubin

