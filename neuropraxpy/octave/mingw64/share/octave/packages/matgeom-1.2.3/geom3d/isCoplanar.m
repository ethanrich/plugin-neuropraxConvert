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

function copl = isCoplanar(x,y,z,tol)
%ISCOPLANAR Tests input points for coplanarity in 3-space.
%
% COPL = isCoplanar(PTS)
% Tests the coplanarity of the input points in array PTS. Input array must
% be 4-by-3, each row containing coordinate of one point.
%
% COPL = isCoplanar(PTS, TOLERANCE)
% Specifies the tolerance value used for checking coplanarity. Default is
% zero.
% 
% 
% Example: 
%   iscoplanar([1 2 -2; -3 1 -14; -1 2 -6; 1 -2 -8], eps)

%
% Adapted from a function originally written by Brett Shoelson, Ph.D.
% brett.shoelson@joslin.harvard.edu
% https://fr.mathworks.com/matlabcentral/fileexchange/46-iscoplanar-m
%

if nargin == 0
	error('Requires at least one input argument.'); 
    
elseif nargin == 1
    if size(x,2) == 3
        % Matrix of all x,y,z is input
        pts = x;
        tol = 0;
    else
        error('Invalid input.')
    end
    
elseif nargin == 2
	if size(x,2) == 3
		% Matrix of all x,y,z is input
		pts = x;
		tol = y;
	else
		error('Invalid input.')
	end
elseif nargin == 3
	% Compile a matrix of all x,y,z
	pts = [x y z];
	tol = 0;
else
	pts = [x y z];
end

if size(x, 1) < 4
    error('Requires at least four points to compute coplanarity');
end

% replace first point at the origin and compute SVD of the matrix
sv = svd(bsxfun(@minus, pts(2:end,:), pts(1,:)));
copl = sv(3) <= tol * sv(1);

% % Alterantive version that computes the rank of the matrix
% rnk = rank(bsxfun(@minus, pts(2:end,:), pts(1,:)), tol);
% copl = rnk <= size(pts, 2) - 1;

% % Old version:
% %Compare all 4-tuples of point combinations; {P1:P4} are coplanar iff
% %det([x1 y1 z1 1;x2 y2 z2 1;x3 y3 z3 1;x4 y4 z4 1])==0
% tmp = nchoosek(1:size(pts,1),4);
% for ii = 1:size(tmp,1)
% 	copl = abs(det([pts(tmp(ii, :), :) ones(4,1)])) <= tolerance;
% 	if ~copl
% 		break
% 	end
% end
