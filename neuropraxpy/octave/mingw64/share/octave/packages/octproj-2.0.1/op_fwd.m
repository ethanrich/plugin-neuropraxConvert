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
## @deftypefn {}{[@var{X},@var{Y}] =}op_fwd(@var{lon},@var{lat},@var{params})
##
## This function projects geodetic coordinates into cartesian projected
## coordinates in the defined cartographic projection using the PROJ function
## proj_trans_generic().
##
## @var{lon} contains the geodetic longitude.
## @var{lat} contains the geodetic latitude.
## @var{params} is a text string containing the projection parameters in PROJ
## format (ONLY format '+' style, see https://proj.org/usage/index.html).
##
## @var{lon} or @var{lat} can be scalars, vectors or 2D matrices.
## Angular units are by default radians, although other units can be specified
## in @var{params}, so @var{lon} and @var{lat} must be congruent with
## @var{params}
##
## @var{X} contains the X projected coordinates.
## @var{Y} contains the Y projected coordinates.
##
## If a projection error occurs, the resultant coordinates for the affected
## points have both Inf value and a warning message is emitted (one for each
## erroneous point).
## Linear units are by default meters, although other can be specified in
## @var{params}, so @var{X} and @var{Y} will be congruent with @var{params}.
##
## @seealso{op_inv, op_transform}
## @end deftypefn




function [X,Y] = op_fwd(lon,lat,params)

try
    functionName = 'op_fwd';
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
    [lon,lat,rowWork,colWork] = checkInputArguments(lon,lat,params);
catch
    %error message
    error('\n\tIn function %s:\n\t -%s ',functionName,lasterr);
end

%*******************************************************************************
%COMPUTATION
%*******************************************************************************

try
    %check for NaN values
    lonNaN = isnan(lon);
    latNaN = isnan(lat);
    %calling oct function
    [X,Y] = _op_fwd(lon,lat,params);
    %set the originan NaN values
    X(lonNaN) = NaN;
    Y(latNaN) = NaN;
    %convert output vectors in matrices of adequate size
    X = reshape(X,rowWork,colWork);
    Y = reshape(Y,rowWork,colWork);
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
%!  [x,y]=op_fwd(-6*pi/180,43*pi/180,'+proj=utm +lon_0=3w +ellps=GRS80');
%!  assert(x,255466.98,1e-2)
%!  assert(y,4765182.93,1e-2)
%!error(op_fwd)
%!error(op_fwd(1,2,3,4))
%!error(op_fwd('string',2,3))
%!error(op_fwd(1,'string',3))
%!error(op_fwd(1,2,3))
%!error(op_fwd([1 2 3],[2 2;3 3],'+proj=utm +lon_0=3w +ellps=GRS80'))




%*****END OF TESTS*****
