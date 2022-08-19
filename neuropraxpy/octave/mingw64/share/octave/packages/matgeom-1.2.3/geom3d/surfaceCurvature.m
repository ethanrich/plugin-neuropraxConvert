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

function kappa = surfaceCurvature(kappa1, kappa2, theta)
%SURFACECURVATURE Curvature on a surface from angle and principal curvatures.
%
%   usage:
%   KAPPA = surfaceCurvature(KAPPA1, KAPPA2, THETA)
%   return the curvature KAPPA of surface with respect to direction THETA.

%   KAPPA1 and KAPPA2 are the principal curvatures of the surface at the
%   considered point. THETA is angle of direction relative to angle of
%   first principal curvature KAPPA1.
%
%   Examples:
%   K = surfaceCurvature(KAPPA1, KAPPA2, 0) returns KAPPA1.
%   K = surfaceCurvature(KAPPA1, KAPPA2, pi/2) returns KAPPA2.
%
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 07/04/2004.
%

%   HISTORY
%   20/04/2004 change name and add doc.
%   14/06/2004 correct creation date

kappa = kappa1 * cos(theta).^2 + kappa2 * sin(theta).^2;
