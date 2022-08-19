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

% POLYNOMIALCURVES2D Planar Polynomial Curves
% Version 1.24 07-Jun-2018 .
%
% POLYNOMIALCURVES2D Manipulation of planar smooth curves
%   Polynomial curves are plane curves whose points are defined by a
%   polynomial for each x and y coordinate.
%   A polynomial curve is represented by 3 row vectors:
%   * the bounds of the parametrization
%   * the coefficients for the x coordinate (in increasing degree)
%   * the coefficients for the y coordinate (in increasing degree)
%
%   Example:
%   C = {[0 1], [3 4], [0 1 -1]};
%   represents the curve defined by:
%       x(t) = 3 + 4*t;
%       y(t) = t - t*t;
%   for t belonging to the interval [0 1].
%
%   As each coordinate are given by polynoms, it is possible to compute
%   various parameters like curvature, normal, or the exact geodesic length
%   of the curve.
%
%   For most functions, parameters are given as three separate arguments.
%   Sometimes, only the 2 parameters corresponding to the X and Y
%   coefficients are required. 
%
%
% Global features
%   polynomialCurveCentroid   - Compute the centroid of a polynomial curve
%   polynomialCurveProjection - Projection of a point on a polynomial curve
%   polynomialCurveLength     - Compute the length of a polynomial curve
%   polynomialCurvePoint      - Compute point corresponding to a position
%   polynomialCurvePosition   - Compute position on a curve for a given length
%
% Local features
%   polynomialCurveDerivative - Compute derivative vector of a polynomial curve
%   polynomialCurveNormal     - Compute the normal of a polynomial curve
%   polynomialCurveCurvature  - Compute the local curvature of a polynomial curve
%   polynomialCurveCurvatures - Compute curvatures of a polynomial revolution surface
%
% Fitting
%   polynomialCurveFit        - Fit a polynomial curve to a series of points
%   polynomialCurveSetFit     - Fit a set of polynomial curves to a segmented image
%
% Drawing
%   drawPolynomialCurve       - Draw a polynomial curve approximation
%
% Utilities
%   polynomialDerivate        - Derivate a polynomial
%   polyfit2                  - Polynomial approximation of a curve
%
%
% -----
% Author: David Legland
% e-mail: david.legland@inra.fr
% created the  07/11/2005.
% Project homepage: http://github.com/mattools/matGeom
% http://www.pfl-cepia.inra.fr/index.php?page=geom2d
% Copyright INRA - Cepia Software Platform.

help(mfilename);

%%   Deprecated functions:


%% Others...

