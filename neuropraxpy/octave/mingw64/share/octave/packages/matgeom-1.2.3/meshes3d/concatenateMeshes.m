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

function varargout = concatenateMeshes(varargin)
% CONCATENATEMESHES Concatenate multiple meshes.
%
%   [V,F] = concatenateMeshes(V1,F1,V2,F2, ...)
%   Returns one mesh represented by vertices V and faces F by concatenating
%   the meshes defined by V1, V2, ... and F1, F2, ...
%
%   [V,F] = concatenateMeshes(MESH1, MESH2, ...)
%   where MESH1, MESH2, ... are structs or struct arrays with the fields  
%   vertices and faces
%
%   See also
%     splitMesh
%   
% ---------
% Authors: oqilipo (parsing), Alec Jacobson (loop)
% Created: 2017-09-12
% Copyright 2017

%% parsing inputs
assert(~isempty(varargin))

if isstruct(varargin{1})
    VF_fields = {'vertices','faces'};
    
    errorStructFields=['If the first input argument is a struct '...
        'with the fields vertices and faces the additonal ' ...
        'arguments must have the same format'];
    % Check, if all input arguments are structs
    assert(all(cellfun(@isstruct, varargin)), errorStructFields)
    % Check, if all structs contain the two fields vertices and faces
    assert(all(cellfun(@(x) all(ismember(fieldnames(x), ...
        VF_fields)), varargin)), errorStructFields)
    
    if length(varargin)==1
        errorArgAndStructLength = ['If the input is only one struct ' ...
            'it has to contain more than one mesh.'];
        assert(length(varargin{1})>1, ...
            errorArgAndStructLength)
    end
    
    % Order of the fields: vertices, faces
    varargin = cellfun(@(x) orderfields(x, VF_fields),varargin, 'UniformOutput',0);
    
    % Convert the structs into one cell array
    varargin = ...
        cellfun(@struct2cell, varargin, 'UniformOutput', false);
    varargin = cellfun(@squeeze, varargin, 'UniformOutput',0);
    varargin = reshape([varargin{:}],[],1)';
end

NoA = length(varargin);
assert(mod(NoA,2)==0);

cellfun(@(x) validateattributes(x, {'numeric'},...
    {'size',[NaN,3],'finite'}), varargin(1:2:end))
cellfun(@(x) validateattributes(x, {'numeric'},...
    {'integer'}), varargin(2:2:end))
% Check if all faces have the same number of columns
errorFacesRows='The faces of all meshes must have the same number of columns';
assert(numel(unique(cellfun(@(x) size(x,2), varargin(2:2:end))))==1, errorFacesRows)


%% loop
v=[];
f=[];
for m = 1:NoA/2
    vm = varargin{2*m-1};
    fm = varargin{2*m};
    f = [f; fm+size(v,1)]; %#ok<AGROW>
    v = [v; vm]; %#ok<AGROW>
end


%% parsing outputs
[v, f] = trimMesh(v, f);

switch nargout
    case 1
        mesh.vertices=v;
        mesh.faces=f;
        varargout{1}=mesh;
    case 2
        varargout{1}=v;
        varargout{2}=f;
end

