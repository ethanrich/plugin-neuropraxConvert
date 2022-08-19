## Copyright (C) 1998, 1999, 2000, 2002, 2005, 2006, 2007 Auburn University
## Copyright (C) 2010-2015   Lukas F. Reichlin
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{axis}, @var{angle}] =} q2rot (@var{q})
## @deftypefnx {Function File} {[@var{axis}, @var{angle}, @var{qn}] =} q2rot (@var{q})
## Extract vector/angle form of a unit quaternion @var{q}.
##
## @strong{Inputs}
## @table @var
## @item q
## Unit quaternion describing the rotation.
## Quaternion @var{q} can be a scalar or an array.
## In the latter case, @var{q} is reshaped to a row vector
## and the return values @var{axis} and @var{angle} are
## concatenated horizontally, accordingly.
## @end table
##
## @strong{Outputs}
## @table @var
## @item axis
## Eigenaxis as a 3-d unit vector @code{[x; y; z]}.
## If input argument @var{q} is a quaternion array,
## @var{axis} becomes a matrix where
## @var{axis(:,i)} corresponds to @var{q(i)}.
## @item angle
## Rotation angle in radians.  The positive direction is
## determined by the right-hand rule applied to @var{axis}.
## The angle lies in the interval [0, 2*pi].
## If input argument @var{q} is a quaternion array,
## @var{angle} becomes a row vector where
## @var{angle(i)} corresponds to @var{q(i)}.
## @item qn
## Optional output of diagnostic nature.
## @code{qn = reshape (q, 1, [])} or, if needed, 
## @code{qn = reshape (unit (q), 1, [])}.
## @end table
##
## @strong{Example}
## @example
## @group
## octave:1> axis = [0; 0; 1]
## axis =
## 
##    0
##    0
##    1
## 
## octave:2> angle = pi/4
## angle =  0.78540
## octave:3> q = rot2q (axis, angle)
## q = 0.9239 + 0i + 0j + 0.3827k
## octave:4> [vv, th] = q2rot (q)
## vv =
## 
##    0
##    0
##    1
## 
## th =  0.78540
## octave:5> theta = th*180/pi
## theta =  45.000
## octave:6>
## @end group
## @end example
##
## @end deftypefn

## Adapted from: quaternion by A. S. Hodel <a.s.hodel@eng.auburn.edu>
## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.4

function [vv, theta, q] = q2rot (q)

  if (nargin != 1 || nargout > 3)
    print_usage ();
  endif

  if (! isa (q, "quaternion"))
    error ("q2rot: require quaternion as input");
  endif

  if (any (abs (abs (q) - 1) > 1e-12))
    warning ("q2rot:normalizing", "q2rot: abs(q) != 1, normalizing");
    q = unit (q);   # do we still need this with the atan2 formula?
  endif

  q = reshape (q, 1, []);   # row vector

  ## According to Wikipedia,
  ## <http://en.wikipedia.org/wiki/Axis-angle_representation#Unit_quaternions>
  ## the formula using atan2
  ##    theta = 2 * atan2 (||x||, s)
  ## should be numerically more stable than
  ##    theta = 2 * acos (s)
  ## Possibly it helps if the quaternion has not exactly unit length.
  
  vv = [q.x; q.y; q.z];
  norm_vv = norm (vv, 2, "cols");
  theta = 2 * atan2 (norm_vv, q.w);

  ## NOTE: sin (theta/2) = norm (vv)
  idx = (norm_vv != 0);
  if (any (idx))
    vv(:, idx) ./= ones (3, 1) * norm_vv(idx);      # normalize vectors, prevent division by zero
  endif
  idx = ! idx;
  if (any (idx))
    vv(:, idx) = [1; 0; 0] * ones (1, nnz (idx));   # set real-valued quaternions to default value
  endif

endfunction


%!test
%! q = quaternion (2, 0, 0, 0);
%! w = warning ("query", "q2rot:normalizing");
%! warning ("off", w.identifier);
%! [vv, th, qn] = q2rot (q);
%! warning (w.identifier, w.state);
%! assert (vv, [1; 0; 0], 1e-4);
%! assert (th, 0, 1e-4);
%! assert (qn == quaternion (1), true);
