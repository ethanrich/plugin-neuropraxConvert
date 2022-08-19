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

function out = planesBisector(plane1, plane2)
% PLANESBISECTOR  Bisector plane between two other planes.
% 
%   BIS = planesBisector(PL1, PL2);
%   Returns the planes that contains the intersection line between PL1 and
%   PL2 and that bisect the dihedral angle of PL1 and PL2. 
%   Note that computing the bisector of PL2 and PL1 (in that order) returns
%   the same plane but with opposite orientation.
%
%   Example
%     % Draw two planes together with their bisector
%     pl1 = createPlane([3 4 5], [1 2 3]);
%     pl2 = createPlane([3 4 5], [2 -3 4]);
%     % compute bisector
%     bis = planesBisector(pl1, pl2);
%     % setup display
%     figure; hold on; axis([0 10 0 10 0 10]);
%     set(gcf, 'renderer', 'opengl')
%     view(3);
%     % draw the planes
%     drawPlane3d(pl1, 'g');
%     drawPlane3d(pl2, 'g');
%     drawPlane3d(bis, 'b');
%
%   See also
%   planes3d, dihedralAngle, intersectPlanes
%
%   Author: Ben X. Kang
%   Dept. Orthopaedics & Traumatology
%   Li Ka Shing Faculty of Medicine
%   The University of Hong Kong
%   Pok Fu Lam, Hong Kong
%

% Let the two planes be defined by equations
% 
%  a1*x + b1*y + c1*z + d1 = 0
% 
% and
% 
%  a2*x + b2*y + c2*z + d2 = 0
% 
% in which vectors [a1,b1,c1] and [a2,b2,c2] are normalized to be of unit
% length (a^2+b^2+c^2 = 1). Then 
% 
%  (a1+a2)*x + (b1+b2)*y + (c1+c2)*z + (d1+d2) = 0
% 
% is the equation of the desired plane which bisects the dihedral angle
% between the two planes.  These coefficients cannot be all zero because
% the two given planes are not parallel.
% 
% Notice that there is a second solution to this problem
% 
%  (a1-a2)*x + (b1-b2)*y + (c1-c2)*z + (d1-d2) = 0
% 
% which also is a valid plane and orthogonal to the first solution. One of
% these planes bisects the acute dihedral angle, and the other the
% supplementary obtuse dihedral angle, between the two given planes.   


P1 = plane1(1:3);			% a point on the plane
n1 = planeNormal(plane1);	% the normal of the plane
% d1 = -dot(n1, P1);		% for line equation

P2 = plane2(1:3);
n2 = planeNormal(plane2);
% d2 = -dot(n2, P2);

if ~isequal(P1(1:3), P2(1:3))
	L = intersectPlanes(plane1, plane2);	% intersection of the given two planes
	Pt = L(1:3);							% a point on the line intersection
% 	v2 = cross(n1-n2, L(4:6));				% another vector lie on the bisect plane
% 	out = [v1, v2]';
else
	Pt = P1(1:3);
end

% use column-wise vector
out = createPlane(Pt, n1 - n2);


%%  EOF  %%
