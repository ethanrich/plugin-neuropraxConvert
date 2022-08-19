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
## @deftypefn {}{[@var{lon},@var{lat}] =}op_inv(@var{X},@var{Y},@var{params})
##
## This function unprojects cartesian projected coordinates (in a defined
## cartographic projection) into geodetic coordinates using the PROJ function
## proj_trans_generic().
##
## @var{X} contains the X projected coordinates.
## @var{Y} contains the Y projected coordinates.
## @var{params} is a text string containing the projection parameters in PROJ
## format (ONLY format '+' style, see https://proj.org/usage/index.html).
##
## @var{X} or @var{Y} can be scalars, vectors or 2D matrices.
## Linear units are by default meters, although other can be specified in
## @var{params}, so @var{X} and @var{Y} must be congruent with @var{params}.
##
## @var{lon} is the geodetic longitude.
## @var{lat} is the geodetic latitude.
##
## If a projection error occurs, the resultant coordinates for the affected
## points have both Inf value and a warning message is emitted (one for each
## erroneous point).
## Angular units are by default radians, although other units can be specified
## in @var{params}, so @var{lon} and @var{lat} will be congruent with
## @var{params}
##
## @seealso{op_fwd, op_transform}
## @end deftypefn




function [lon,lat] = op_inv(X,Y,params)

try
    functionName = 'op_inv';
    argumentNumber = 3;

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
    [X,Y,rowWork,colWork] = checkInputArguments(X,Y,params);
catch
    %error message
    error('\n\tIn function %s:\n\t -%s ',functionName,lasterr);
end

%*******************************************************************************
%COMPUTATION
%*******************************************************************************

try
    %check for NaN values
    xNaN = isnan(X);
    yNaN = isnan(Y);
    %calling oct function
    [lon,lat] = _op_inv(X,Y,params);
    %set the originan NaN values
    lon(xNaN) = NaN;
    lat(yNaN) = NaN;
    %convert output vectors in matrices of adequate size
    lon = reshape(lon,rowWork,colWork);
    lat = reshape(lat,rowWork,colWork);
catch
    %error message
    error('\n\tIn function %s:\n\tIn function %s ',functionName,lasterr);
end




%*******************************************************************************
%AUXILIARY FUNCTION
%*******************************************************************************




function [a,b,rowWork,colWork] = checkInputArguments(a,b,params)

%a must be matrix type
if (~isnumeric(a))||isempty(a)
    error('The first input argument is not numeric');
end
%b must be matrix type
if (~isnumeric(b))||isempty(b)
    error('The second input argument is not numeric');
end
%params must be a text string
if ~ischar(params)
    error('The third input argument is not a text string');
end
%equalize dimensions
[a,b] = op_aux_equalize_dimensions(0,a,b);
%dimensions
[rowWork,colWork] = size(a);
%convert a, b and c in column vectors
a = reshape(a,rowWork*colWork,1);
b = reshape(b,rowWork*colWork,1);




%*****END OF FUNCIONS*****




%*****FUNCTION TESTS*****




%!test
%!  [lon,lat]=op_inv(255466.98,4765182.93,'+proj=utm +lon_0=3w +ellps=GRS80');
%!  assert(lon*180/pi,-6,1e-7)
%!  assert(lat*180/pi,43,1e-7)
%!error(op_inv)
%!error(op_inv(1,2,3,4))
%!error(op_inv('string',2,3))
%!error(op_inv(1,'string',3))
%!error(op_inv(1,2,3))
%!error(op_inv([1 2 3],[2 2;3 3],'+proj=utm +lon_0=3w +ellps=GRS80'))




%*****END OF TESTS*****
