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

function progressbar(n,N,w)

% progressbar - display a progress bar
%
%    progressbar(n,N,w);
%
% displays the progress of n out of N.
% n should start at 1.
% w is the width of the bar (default w=20).
%
%   Copyright (c) Gabriel Peyré 2006

if nargin<3
    w = 20;
end

% progress char
cprog = '.';
cprog1 = '*';
% begining char
cbeg = '[';
% ending char
cend = ']';

p = min( floor(n/N*(w+1)), w);

global pprev;
if isempty(pprev)
    pprev = -1;
end

if not(p==pprev)
    ps = repmat(cprog, [1 w]);
    ps(1:p) = cprog1;
    ps = [cbeg ps cend];
    if n>1
        % clear previous string
        fprintf( repmat('\b', [1 length(ps)]) );
    end
    fprintf(ps);
end
pprev = p;
if n==N
    fprintf('\n');
end
