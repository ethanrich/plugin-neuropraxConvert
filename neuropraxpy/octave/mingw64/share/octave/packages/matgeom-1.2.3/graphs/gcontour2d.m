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

function [nodes, edges] = gcontour2d(img)
%GCONTOUR2D Creates contour graph of a 2D binary image.
%
%
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 25/06/2004.
%

nodes = zeros([0 2]);
edges = zeros([0 2]);

D1 = size(img, 1);
D2 = size(img, 2);

% first direction for image
for i = 1:D1
    
    % find transitions between the two phases
    ind = find(img(i, 1:D2-1)~=img(i, 2:D2));
    
    % process each transition in direction 1
    for i2 = 1:length(ind)
        
        n1 = [i-.5 ind(i2)+.5];
        n2 = [i+.5 ind(i2)+.5];
        
        ind1 = find(ismember(nodes, n1, 'rows'));       
        ind2 = find(ismember(nodes, n2, 'rows'));
        if isempty(ind1)
            nodes = [nodes; n1]; %#ok<AGROW>
            ind1 = size(nodes, 1);
        end
        if isempty(ind2)
            nodes = [nodes; n2]; %#ok<AGROW>
            ind2 = size(nodes, 1);
        end
        
        edges(size(edges, 1)+1, 1:2) = [ind1(1) ind2(1)];
        
    end
end


% second direction for image
for i=1:D2
    
    % find transitions between the two phases
    ind = find(img(1:D1-1, i)~=img(2:D1, i));
    
    % process each transition in direction 1
    for i2 = 1:length(ind)
        
        n1 = [ind(i2)+.5 i-.5];
        n2 = [ind(i2)+.5 i+.5];
        
        ind1 = find(ismember(nodes, n1, 'rows'));       
        ind2 = find(ismember(nodes, n2, 'rows'));
        if isempty(ind1)
            nodes = [nodes; n1]; %#ok<AGROW>
            ind1 = size(nodes, 1);
        end
        if isempty(ind2)
            nodes = [nodes; n2]; %#ok<AGROW>
            ind2 = size(nodes, 1);
        end
        
        edges(size(edges, 1)+1, 1:2) = [ind1(1) ind2(1)];
        
    end
end

