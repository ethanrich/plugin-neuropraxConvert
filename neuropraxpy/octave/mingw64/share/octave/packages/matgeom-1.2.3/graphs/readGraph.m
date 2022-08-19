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

function [nodes, edges] = readGraph(fileName)
%READGRAPH Read a graph from a text file.
%
%   [NODES EDGES] = readGraph(FILENAME)
%
%   Example
%     % create a basic graph, save it to a file, and read it again
%     nodes = [10 10;20 10;10 20;20 20;27 15];
%     edges = [1 2;1 3;2 4;2 5;3 4;4 5];
%     writeGraph(nodes, edges, 'simpleGraph.txt');
%     [n2 e2] = readGraph('simpleGraph.txt');
%     figure; drawGraph(n2, e2); axis equal; axis([0 40 0 30]);
%
%   See also
%     writeGraph
%

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2014-01-21,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2014 INRA - Cepia Software Platform.


%% Open file and read header

% open file for reading in text mode
f = fopen(fileName, 'rt');
if f == -1
    error(['could not open file for reading: ' fileName]);
end

% check header
line = fgetl(f);
if ~ischar(line) 
    error(['can not read graph from empty file: ' fileName]);
end
if ~strcmpi(strtrim(line(2:end)), 'graph')
    error(['Wrong header line in file:' fileName]);
end


%% read node section

% check sub-header
line = fgetl(f);
if ~strcmpi(strtrim(line(2:end)), 'nodes')
    error(['Could not interpret node section in file:' fileName]);
end

% read the number of nodes
line = fgetl(f);
[nNodesStr, line] = strtok(line);
nNodes = str2double(nNodesStr);

% read number of dimension, assumes 2 by default if not specified
nDims = 2;
if ~isempty(line)
    nDims = str2double(strtok(line));
end

% read node coordinates
[nodes, nRead] = fscanf(f, '%g', [nDims nNodes]);
assert(nRead == nNodes * nDims, ...
    'Could not read all node info in file %s', fileName);
nodes = nodes';

% terminate the reading of current line
fgetl(f);


%% read edge section

% check sub-header
line = fgetl(f);
if ~strcmpi(strtrim(line(2:end)), 'edges')
    error(['Could not interpret edge section in file:' fileName]);
end

% read the number of nodes
line = fgetl(f);
nEdgesStr = strtok(line);
nEdges = str2double(nEdgesStr);

% read node indices of each edge
[edges, nRead] = fscanf(f, '%d %d\n', [2 nEdges]);
assert(nRead == nEdges * 2, ...
    'Could not read all edge info in file %s', fileName);
edges = edges';


%% Clean up

fclose(f);
