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

function [hAx, prim, varargin] = parseDrawInput(prim, valFun, type, defOpts, varargin)
%PARSEDRAWINPUT Parse input arguments for drawing functions: draw*.
% 
%   INPUT:
%       PRIM: The primitive object: line, plane, ...
%       VALFUN: An anonymous Function to validate PRIM
%       TYPE: The drawing type of PRIM: 'line', 'patch', ...
%       DEFOPTS: The default drawing options for PRIM as struct
%
%   OUTPUT:
%       HAX: The current or specified axes for drawing
%       PRIM: validated PRIM
%
% ------
% Author: oqilipo
% Created: 2017-10-13, using R2017b
% Copyright 2017

% Check if first input argument is an axes handle
if isAxisHandle(prim)
    hAx = prim;
    prim = varargin{1};
    varargin(1) = [];
else
    hAx = gca;
end

% Check if the primitive is valid
p=inputParser;
addRequired(p,'prim',valFun)
parse(p,prim)

% parse input arguments if there are any
if ~isempty(varargin)
    if length(varargin) == 1
        if isstruct(varargin{1})
            % if options are specified as struct, need to convert to 
            % parameter name-value pairs
            varargin = [fieldnames(varargin{1}) struct2cell(varargin{1})]';
            varargin = varargin(:)';
        else
            % if option is a single argument, assume it is the color
            switch type
                case 'line'
                    varargin = {'Color', varargin{1}};
                case 'patch'
                    varargin = {'FaceColor', varargin{1}};
            end
        end
    end
else
    % If no arguments are given, use the default options
    varargin = [fieldnames(defOpts) struct2cell(defOpts)]';
    varargin = varargin(:)';
end

end
