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

function varargout = drawLabels(varargin)
% Draw labels at specified positions.
%   
%   drawLabels(X, Y, LBL)
%   Draws labels LBL at positions given by X and Y.
%   LBL can be either a string array, or a number array. In this case,
%   string are created by using sprintf function, using the '%.2f' format.
%
%   drawLabels(POS, LBL)
%   Draws labels LBL at position specified by POS, where POS is a N-by-2
%   numeric array. 
%
%   drawLabels(..., NUMBERS, FORMAT)
%   Creates labels using sprintf function, with the mask given by FORMAT 
%   (e.g. '%03d' or '5.3f'), and the corresponding values.
%
%   drawLabels(..., PNAME, PVALUE)
%   Specifies additional parameters to the created labels. See 'text'
%   properties for available values.
%

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 15/12/2003.
%

%   HISTORY
%   09/03/2007: (re)implement it...
%   2011-10-11 add management of axes handle

% check if enough inputs are given
if isempty(varargin)
    error('wrong number of arguments in drawLabels');
end

% extract handle of axis to draw on
if isscalar(varargin{1}) && ishandle(varargin{1})
    ax = varargin{1};
    varargin(1) = [];
else
    ax = gca;
end

% process input parameters
var = varargin{1};
if size(var, 2) == 1
    % coordinates given as separate arguments
    if length(varargin) < 3
        error('wrong number of arguments in drawLabels');
    end
    px  = var;
    py  = varargin{2};
    lbl = varargin{3};
    varargin(1:3) = [];
else
    % parameters given as a packed array
    if length(varargin) < 2
        error('wrong number of arguments in drawLabels');
    end
    px  = var(:,1);
    py  = var(:,2);
    lbl = varargin{2};
    varargin(1:2) = [];
end

% format for displaying numeric values
format = '%.2f';
if ~isempty(varargin) 
    var1 = varargin{1};
    if ischar(var1) && var1(1) == '%'
        format = varargin{1};
        varargin(1) = [];
    end
end
if size(format, 1) == 1 && size(px, 1) > 1
    format = repmat(format, size(px, 1), 1);
end

% compute the strings that have to be displayed
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

% display the text
h = text(px, py, labels, 'parent', ax, varargin{:});

% format output
if nargout > 0
    varargout = {h};
end

