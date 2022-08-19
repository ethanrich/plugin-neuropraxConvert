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
## @deftypefn {}{[@var{X},@var{Y},@var{Z}] =}op_geod2geoc(@var{lon},@var{lat},@var{h},@var{a},@var{f})
##
## This function converts geodetic coordinates into cartesian tridimensional
## geocentric coordinates.
##
## @var{lon} contains the geodetic longitude, in radians.
## @var{lat} contains the geodetic latitude, in radians.
## @var{h} contains the ellipsoidal height, in meters.
## @var{a} is a scalar containing the semi-major axis of the ellipsoid, in
## meters.
## @var{f} is a scalar containing the flattening of the ellipsoid.
##
## @var{lon}, @var{lat} or @var{h} can be scalars, vectors or 2D matrices.
##
## @var{X} is the X geocentric coordinate, in meters.
## @var{Y} is the Y geocentric coordinate, in meters.
## @var{Z} the Z geocentric coordinate, in meters.
##
## @seealso{op_geoc2geod}
## @end deftypefn




function [X,Y,Z] = op_geod2geoc(lon,lat,h,a,f)

try
    functionName = 'op_geod2geoc';
    argumentNumber = 5;

%*******************************************************************************
%NUMBER OF INPUT ARGUMENTS CHECKING
%*******************************************************************************

    %number of input arguments checking
    if nargin~=argumentNumber
        error(['Incorrect number of input arguments (%d)\n\t         ',...
               'Correct number of input arguments = %d'],...
              nargin,argumentNumber);
    end

%*******************************************************************************
%INPUT ARGUMENTS CHECKING
%*******************************************************************************

    %checking input arguments
    [lon,lat,h,rowWork,colWork] = checkInputArguments(lon,lat,h,a,f);
catch
    %error message
    error('\n\tIn function %s:\n\t -%s ',functionName,lasterr);
end

%*******************************************************************************
%COMPUTATION
%*******************************************************************************

try
    %first squared eccentricity of the ellipsoid
    e2 = 2.0*f-f^2;
    %calling oct function
    [X,Y,Z] = _op_geod2geoc(lon,lat,h,a,e2);
    %convert output vectors in matrices of adequate size
    X = reshape(X,rowWork,colWork);
    Y = reshape(Y,rowWork,colWork);
    Z = reshape(Z,rowWork,colWork);
catch
    %error message
    error('\n\tIn function %s:\n\tIn function %s ',functionName,lasterr);
end




%*******************************************************************************
%AUXILIARY FUNCTION
%*******************************************************************************




function [a,b,c,rowWork,colWork] = checkInputArguments(a,b,c,d,e)

%a must be matrix type
if (~isnumeric(a))||isempty(a)
    error('The first input argument is not numeric');
end
%b must be matrix type
if (~isnumeric(b))||isempty(b)
    error('The second input argument is not numeric');
end
%c must be matrix type
if (~isnumeric(c))||isempty(c)
    error('The third input argument is not numeric');
end
%d must be scalar
if (~isscalar(d))||isempty(d)
    error('The fourth input argument is not a scalar');
end
%e must be scalar
if (~isscalar(e))||isempty(e)
    error('The fifth input argument is not a scalar');
end
%equalize dimensions
[a,b,c] = op_aux_equalize_dimensions(0,a,b,c);
%dimensions
[rowWork,colWork] = size(a);
%convert a, b and c in column vectors
a = reshape(a,rowWork*colWork,1);
b = reshape(b,rowWork*colWork,1);
c = reshape(c,rowWork*colWork,1);




%*****END OF FUNCIONS*****




%*****FUNCTION TESTS*****




%!test
%!  [x,y,z]=op_geod2geoc(pi/5,pi/3,1000,6378388,1/297);
%!  assert(x,2587045.81927379,1e-5)
%!  assert(y,1879598.80960088,1e-5)
%!  assert(z,5501461.60635409,1e-5)
%!error(op_geod2geoc)
%!error(op_geod2geoc(1,2,3,4,5,6))
%!error(op_geod2geoc('string',2,3,4,5))
%!error(op_geod2geoc(1,'string',3,4,5))
%!error(op_geod2geoc(1,2,'string',4,5))
%!error(op_geod2geoc(1,2,3,[4 4],5))
%!error(op_geod2geoc(1,2,3,4,[5 5]))
%!error(op_geod2geoc([1;1],[2 2 2],3,4,5))




%*****END OF TESTS*****
