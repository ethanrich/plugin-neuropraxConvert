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

function varargout = cvtUpdate(germs, points)
%CVTUPDATE Update germs of a CVT with given points.
%
%   G2 = cvtUpdate(G, PTS)
%   G: inital germs 
%   PTS: the points
%
%   Example
%   G = randPointDiscUnif(50);
%   P = randPointDiscUnif(10000);
%   G2 = cvtUpdate(G, P);
%
%   See also
%
%
%   Rewritten from programs found in
%   http://people.scs.fsu.edu/~burkardt/m_src/cvt/cvt.html
%
%  Reference:
%    Qiang Du, Vance Faber, and Max Gunzburger,
%    Centroidal Voronoi Tessellations: Applications and Algorithms,
%    SIAM Review, Volume 41, 1999, pages 637-676.
%

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2007-10-10,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.


%% Init

% number of germs and of points
Ng  = size(germs, 1);
N   = size(points, 1);

% initialize centroids with values of germs
centroids = germs;

% number of updates of each centroid
count = ones(Ng, 1);


%% Generate random points

% for each point, determines which germ is the closest ones
[dist, ind] = minDistancePoints(points, germs); %#ok<ASGLU>

h = zeros(Ng, 1);
for i = 1:Ng
    h(i) = sum(ind==i);
end


%% Centroids update

% add coordinate of each point to closest centroid
energy = 0;
for j = 1:N
    centroids(ind(j), :) = centroids(ind(j), :) + points(j, :);
    energy = energy + sum ( ( centroids(ind(j), :) - points(j, :) ).^2);
    count(ind(j)) = count(ind(j)) + 1;
end

% estimate coordinate by dividing by number of counts
centroids = centroids ./ repmat(count, 1, size(germs, 2));

% normalizes energy by number of sample points
energy = energy / N;


%% Format output

varargout{1} = centroids;
if nargout > 1
    varargout{2} = energy;
end

    
  
