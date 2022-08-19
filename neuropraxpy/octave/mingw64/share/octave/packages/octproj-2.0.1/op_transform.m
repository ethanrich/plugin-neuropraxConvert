## Copyright (C) 2009-2020, José Luis García Pallero, <jgpallero@gmail.com>
##
## This file is part of OctPROJ.
##
## OctPROJ is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {}{[@var{X2},@var{Y2}] =}op_transform(@var{X1},@var{Y1},@var{par1},@var{par2})
## @deftypefnx {}{[@var{X2},@var{Y2},@var{Z2}] =}op_transform(@var{X1},@var{Y1},@var{Z1},@var{par1},@var{par2})
## @deftypefnx {}{[@var{X2},@var{Y2},@var{Z2},@var{t2}] =}op_transform(@var{X1},@var{Y1},@var{Z1},@var{t1},@var{par1},@var{par2})
##
## This function transforms X/Y/Z/t, lon/lat/h/t points between two coordinate
## systems 1 and 2 using the PROJ function proj_trans_generic().
##
## @var{X1} contains the first coordinates in the source coordinate system,
## geodetic longitude or coordinate X.
## @var{Y1} contains the second coordinates in the source coordinate system,
## geodetic latitude or coordinate Y.
## @var{Z1} contains the third coordinates in the source coordinate system,
## ellipsoidal height or coordinate Z. This argument can be optional.
## @var{t1} contains the time coordinates in the source coordinate system. This
## argument can be optional.
## @var{par1} is a text string containing the projection parameters for the
## source system, in PROJ '+' format, as EPSG code or as WKT2 code.
## @var{par2} is a text string containing the projection parameters for the
## destination system, in PROJ '+' format, as EPSG code or as WKT2 code.
##
## @var{X1}, @var{Y1}, @var{Z1} or @var{t1} can be scalars, vectors or matrices
## with equal dimensions. @var{Z1} and/or @var{t1} can be zero-length matrices.
##
## @var{X2} contains the first coordinates in the destination coordinate system,
## geodetic longitude or coordinate X.
## @var{Y2} contains the second coordinates in the destination coordinate
## system, geodetic latitude or coordinate Y.
## @var{Z2} contains the third coordinates in the destination coordinate system,
## ellipsoidal height or coordinate Z.
## @var{t2} contains the time coordinates in the destination coordinate system.
##
## Angular units are by default radians, and linear meters, although other can
## be specified in @var{par1}, and @var{par2}, so the input data must be
## congruent, and output data will be congruent with the definitions.
##
##
## Note that in PROJ the +proj=latlong identifier works in degrees, not radians,
## for this transformation task.
##
## @seealso{op_fwd, op_inv}
## @end deftypefn




function [X2,Y2,Z2,t2] = op_transform(X1,Y1,Z1,t1,par1,par2)

try
    functionName = 'op_transform';
    minArgNumber = 4;
    maxArgNumber = 6;

%*******************************************************************************
%NUMBER OF INPUT ARGUMENTS CHECKING
%*******************************************************************************

    %number of input arguments checking
    if (nargin<minArgNumber)||(nargin>maxArgNumber)
        error(['Incorrect number of input arguments (%d)\n\t         ',...
               'Correct number of input arguments = %d or %d'],...
              nargin,minArgNumber,maxArgNumber);
    end

%*******************************************************************************
%INPUT ARGUMENTS CHECKING
%*******************************************************************************

    %checking input arguments
    if nargin==minArgNumber
        par2 = t1;
        par1 = Z1;
        Z1 = [];
        t1 = [];
    elseif nargin==(minArgNumber+1)
        par2 = par1;
        par1 = t1;
        t1 = [];
    end
    [X1,Y1,Z1,t1,rowWork,colWork] = checkInputArguments(X1,Y1,Z1,t1,par1,par2);
catch
    %error message
    error('\n\tIn function %s:\n\t -%s ',functionName,lasterr);
end

%*******************************************************************************
%COMPUTATION
%*******************************************************************************

try
    %calling oct function
    [X2,Y2,Z2,t2] = _op_transform(X1,Y1,Z1,t1,par1,par2);
    %convert output vectors in matrices of adequate size
    X2 = reshape(X2,rowWork,colWork);
    Y2 = reshape(Y2,rowWork,colWork);
    if nargin==maxArgNumber
        Z2 = reshape(Z2,rowWork,colWork);
    end
catch
    %error message
    error('\n\tIn function %s:\n\tIn function %s ',functionName,lasterr);
end




%*******************************************************************************
%AUXILIARY FUNCTION
%*******************************************************************************




function [a,b,c,d,rowWork,colWork] = checkInputArguments(a,b,c,d,par1,par2)

%a must be matrix type
if (~isnumeric(a))||isempty(a)
    error('The first input argument is not numeric');
end
%b must be matrix type
if (~isnumeric(b))||isempty(b)
    error('The second input argument is not numeric');
end
%c must be matrix type
if ~isnumeric(b)
    error('The third input argument is not numeric');
end
%d must be matrix type
if ~isnumeric(b)
    error('The fourth input argument is not numeric');
end
%params must be a text string
if ~ischar(par1)
    error('The fifth input argument is not a text string');
end
%params must be a text string
if ~ischar(par2)
    error('The sixth input argument is not a text string');
end
%equalize dimensions
[a,b,c,d] = op_aux_equalize_dimensions(0,a,b,c,d);
%dimensions
[rowWork,colWork] = size(a);
%convert a, b and c in column vectors
a = reshape(a,rowWork*colWork,1);
b = reshape(b,rowWork*colWork,1);
if ~isempty(c)
    c = reshape(c,rowWork*colWork,1);
end
if ~isempty(d)
    d = reshape(d,rowWork*colWork,1);
end




%*****FUNCTION TESTS*****




%!test
%!  [x,y,h,t]=op_transform(-6,43,1000,10,...
%!                         '+proj=latlong +ellps=GRS80',...
%!                         '+proj=utm +lon_0=3w +ellps=GRS80');
%!  [lon,lat,H,T]=op_transform(x,y,h,t,'+proj=utm +lon_0=3w +ellps=GRS80',...
%!                           '+proj=latlong +ellps=GRS80');
%!  assert(x,255466.98,1e-2)
%!  assert(y,4765182.93,1e-2)
%!  assert(h,1000.0,1e-15)
%!  assert(lon,-6,1e-8)
%!  assert(lat,43,1e-8)
%!  assert(H,1000.0,1e-15)
%!  assert(T,10.0,1e-15)
%!test
%!  [x,y,h]=op_transform(-6,43,1000,...
%!                       '+proj=latlong +ellps=GRS80',...
%!                       '+proj=utm +lon_0=3w +ellps=GRS80');
%!  [lon,lat,H]=op_transform(x,y,h,'+proj=utm +lon_0=3w +ellps=GRS80',...
%!                           '+proj=latlong +ellps=GRS80');
%!  assert(x,255466.98,1e-2)
%!  assert(y,4765182.93,1e-2)
%!  assert(h,1000.0,1e-15)
%!  assert(lon,-6,1e-8)
%!  assert(lat,43,1e-8)
%!  assert(H,1000.0,1e-15)
%!test
%!  [x,y]=op_transform(-6,43,'+proj=latlong +ellps=GRS80',...
%!                     '+proj=utm +lon_0=3w +ellps=GRS80');
%!  [lon,lat]=op_transform(x,y,'+proj=utm +lon_0=3w +ellps=GRS80',...
%!                         '+proj=latlong +ellps=GRS80');
%!  assert(x,255466.98,1e-2)
%!  assert(y,4765182.93,1e-2)
%!  assert(lon,-6,1e-8)
%!  assert(lat,43,1e-8)
%!error(op_transform)
%!error(op_transform(1,2,3,4,5,6))
%!error(op_transform('string',2,3,4,5))
%!error(op_transform(1,'string',3,4,5))
%!error(op_transform(1,2,'string',4,5))
%!error(op_transform(1,2,3,'string',5))
%!error(op_transform(1,2,3,4,'string'))
%!error(op_transform(1,[2 3 4],[3 3;4 4],'+proj=latlong +ellps=GRS80',...
%!                   '+proj=utm +lon_0=3w +ellps=GRS80'))




%*****END OF TESTS*****
