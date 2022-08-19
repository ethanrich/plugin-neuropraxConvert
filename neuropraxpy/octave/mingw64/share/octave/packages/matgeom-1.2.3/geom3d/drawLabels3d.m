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

function varargout = drawLabels3d(varargin)
%DRAWLABELS3D Draw text labels at specified 3D positions.
%   
%   drawLabels3d(X, Y, Z, LBL) draw labels LBL at position X and Y.
%   LBL can be either a string array, or a number array. In this case,
%   string are created by using sprintf function, with '%.2f' mask.
%
%   drawLabels3d(POS, LBL) draw labels LBL at position specified by POS,
%   where POS is a N-by-3 int array.
%
%   drawLabels3d(..., NUMBERS, FORMAT) create labels using sprintf function,
%   with the mask given by FORMAT (e. g. '%03d' or '5.3f'), and the
%   corresponding values.
%
%   See also 
%     drawLabels
%

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 31/01/2019.
%

%   HISTORY
%   2019-01-31 write 3D version from drawLabels


%% Parse input arguments

% check if enough inputs are given
if isempty(varargin)
    error('wrong number of arguments in drawLabels3d');
end

% extract handle of axis to draw on
if isAxisHandle(varargin{1})
    axH = varargin{1};
    varargin(1) = [];
else
    axH = gca;
end

% process input parameters
var = varargin{1};
if size(var, 2) == 1
    % coordinates given as separate arguments
    if length(varargin) < 4
        error('wrong number of arguments in drawLabels');
    end
    px  = var;
    py  = varargin{2};
    pz  = varargin{3};
    lbl = varargin{4};
    varargin(1:4) = [];
else
    % parameters given as a packed array
    if length(varargin) < 2
        error('wrong number of arguments in drawLabels');
    end
    if size(var, 2) < 3
        error('Requires coordinates array to have at least three columns');
    end
    px  = var(:,1);
    py  = var(:,2);
    pz  = var(:,3);
    lbl = varargin{2};
    varargin(1:2) = [];
end

% parse format for displaying numeric values
format = '%.2f';
if ~isempty(varargin)
    if varargin{1}(1) == '%'
        format = varargin{1};
        varargin(1)=[];
    end
end
if size(format, 1) == 1 && size(px, 1) > 1
    format = repmat(format, size(px, 1), 1);
end


%% compute the strings that have to be displayed
labels = cell(length(px), 1);
if isnumeric(lbl)
    for i = 1:length(px)
        labels{i} = sprintf(format(i,:), lbl(i));
    end
elseif ischar(lbl)
    for i = 1:length(px)
        labels{i} = lbl(i,:);
    end
elseif iscell(lbl)
    labels = lbl;
end
labels = char(labels);


%% display the text
h = text(axH, px, py, pz, labels, varargin{:});


%% format output
if nargout > 0
    varargout = {h};
end

