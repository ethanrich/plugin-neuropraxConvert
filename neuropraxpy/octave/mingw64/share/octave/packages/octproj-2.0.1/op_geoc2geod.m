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
## @deftypefn {}{[@var{lon},@var{lat},@var{h}] =}op_geoc2geod(@var{X},@var{Y},@var{Z},@var{a},@var{f})
##
## This function converts cartesian tridimensional geocentric coordinates into
## geodetic coordinates.
##
## @var{X} contains the X geocentric coordinate, in meters.
## @var{Y} contains the Y geocentric coordinate, in meters.
## @var{Z} contains the Z geocentric coordinate, in meters.
## @var{a} is a scalar containing the semi-major axis of the ellipsoid, in
## meters.
## @var{f} is a scalar containing the flattening of the ellipsoid.
##
## @var{X}, @var{Y} or @var{Z} can be scalars, vectors or 2D matrices.
##
## @var{lon} is the geodetic longitude, in radians.
## @var{lat} is the geodetic latitude, in radians.
## @var{h} is the ellipsoidal height, in meters.
##
## @seealso{op_geod2geoc}
## @end deftypefn




function [lon,lat,h] = op_geoc2geod(X,Y,Z,a,f)

try
    functionName = 'op_geoc2geod';
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
    [X,Y,Z,rowWork,colWork] = checkInputArguments(X,Y,Z,a,f);
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
    [lon,lat,h] = _op_geoc2geod(X,Y,Z,a,e2);
    %convert output vectors in matrices of adequate size
    lon = reshape(lon,rowWork,colWork);
    lat = reshape(lat,rowWork,colWork);
    h = reshape(h,rowWork,colWork);
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
%!  [lon,lat,h]=op_geoc2geod(2587045.819,1879598.809,5501461.606,6378388,1/297);
%!  assert(lon,0.628318530616265,1e-11)
%!  assert(lat,1.04719755124682,1e-11)
%!  assert(h,999.999401183799,1e-5)
%!error(op_geoc2geod)
%!error(op_geoc2geod(1,2,3,4,5,6))
%!error(op_geoc2geod('string',2,3,4,5))
%!error(op_geoc2geod(1,'string',3,4,5))
%!error(op_geoc2geod(1,2,'string',4,5))
%!error(op_geoc2geod(1,2,3,[4 4],5))
%!error(op_geoc2geod(1,2,3,4,[5 5]))
%!error(op_geoc2geod([1;1],[2 2 2],3,4,5))




%*****END OF TESTS*****
