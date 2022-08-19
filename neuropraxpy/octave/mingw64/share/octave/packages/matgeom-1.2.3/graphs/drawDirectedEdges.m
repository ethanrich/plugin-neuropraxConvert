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

function varargout = drawDirectedEdges(p, e, varargin)
%DRAWDIRECTEDEDGES Draw edges with arrow indicating direction.
% 
%   usage:
%   drawDirectedEdges(NODES, EDGES);
%
%   drawDirectedEdges(NODES, EDGES, STYLE);
%   specifies style of arrrows. Can be one of:
%   'left'
%   'right'
%   'arrow'
%   'triangle'
%   'fill'
%
%   drawDirectedEdges(NODES, EDGES, STYLE, DIRECT) : also specify the base
%   direction of all edges. DIRECT is true by default. If DIRECT is false
%   all edges are inverted.
%   
%   H = drawDirectedEdges(NODES, EDGES) : return handles to each of the
%   lines created.
%
%   TODO: now only style 'arrow' is implemented ...
%
%   -----
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 12/03/2003.
%

%   HISTORY


b=1;

if ~isempty(varargin)
    b = varargin{1};
end

h = zeros(length(e),1);
hold on;
for l=1:length(e)
    p1 = e(l, 1);
    p2 = e(l, 2);
    h(l*4) = line([p(p1,1) p(p2,1)], [p(p1,2) p(p2,2)]);
    
    % position of middles of edge
    xm = (p(p1,1) + p(p2,1))/2;
    ym = (p(p1,2) + p(p2,2))/2;
    
    % orientation of edge
    theta = atan2(p(p2,2) - p(p1,2), p(p2,1) - p(p1,1)) + (b==0)*pi;
    
    % pin of the arrow
    xa0 = xm + 10*cos(theta);
    ya0 = ym + 10*sin(theta);
    
    % right side of the arrow
    xa1 = xm + 3*cos(theta-pi/2);
    ya1 = ym + 3*sin(theta-pi/2);
    
    % left side of the arrow
    xa2 = xm + 3*cos(theta+pi/2);
    ya2 = ym + 3*sin(theta+pi/2);
    
    h(l*4+1) = line([xa1 xa0], [ya1 ya0]);
    h(l*4+2) = line([xa2 xa0], [ya2 ya0]);
end

if nargout==1
    varargout(1) = {h};
end
