## Copyright (C) 2006 Søren Hauberg <soren@hauberg.org>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} @var{warped} = imremap (@var{im}, @var{XI}, @var{YI})
## @deftypefnx{Function File} @var{warped} = imremap (@var{im}, @var{XI}, @var{YI}, @var{interp}, @var{extrapval})
## @deftypefnx{Function File} @var{warped} = imremap (@var{im}, @var{XI}, @var{YI}, "bicubic", @var{padding})
## Applies any geometric transformation to the image @var{im}.
##
## The arguments @var{XI} and @var{YI} are lookup tables that define the resulting
## image
## @example
## @var{warped}(y,x) = @var{im}(@var{YI}(y,x), @var{XI}(y,x))
## @end example
## where @var{im} is assumed to be a continuous function, which is achieved
## by interpolation. Note that the image @var{im} is expressed in a (X, Y)-coordinate
## system and not a (row, column) system.
##
## The optional argument @var{method} defines the interpolation method to be
## used.  All methods supported by @code{interp2} can be used.  By default, the
## @code{linear} method is used.
##
## For @sc{matlab} compatibility, the methods @code{bicubic} (same as
## @code{cubic}), @code{bilinear} and @code{triangle} (both the same as
## @code{linear}) are also supported.
##
## All values of the result that fall outside the original image will
## be set to @var{extrapval}.  The default value of @var{extrapval} is 0.
## For bicubic interpolation it is possible to apply @var{padding} instead.
## Valid padding methods are: "replicate", "symmetric", "reflect", "circular".
##
## @seealso{imperspectivewarp, imrotate, imresize, imshear, interp2}
## @end deftypefn

function [warped] = imremap (im, XI, YI, interp = "linear", extrapval = 0)
  interp = interp_method (interp);

  if (nargin < 3 || nargin > 5)
    print_usage ();
  elseif (!  ((isnumeric (im) || islogical (im)) && ! issparse (im)
            && ! isempty (im)) || ndims (im) > 3)
    error ("imremap: IM must be a grayscale or RGB image.")
  elseif (! (size_equal (XI, YI) || (isvector (XI) && isvector (YI))) || ! ismatrix (XI) || ! isnumeric (XI))
    error ("imremap: XI and YI must be matrices of the same size or vectors");
  elseif (! ischar (interp))
    error ("imremap: INTERP must be a string with interpolation method")
  elseif (! isscalar (extrapval) && ! (ischar (extrapval) && strcmp (interp, "cubic")))
    error ("imremap: Specify a scalar EXTRAPVAL for constant padding or in case of bicubic interpolation a string for the PADDING method");
  endif

  ## check if interpolation points are a meshgrid and reduce to vectors if possible
  if (! isvector (XI) && size_equal (XI, YI) && all (all (repmat (XI(1, :), [rows(XI), 1]) == XI & repmat (YI(:, 1), [1, columns(YI)]) == YI)))
    XI = XI(1, :);
    YI = YI(:, 1);
  endif

  ## if XI and YI are vectors, make sure XI is a row vector and YI a column vector for broadcasting
  if (iscolumn (XI) && ! isvector (im))
    XI = XI';
  endif
  if (isrow (YI) && ! isvector (im))
    YI = YI';
  endif

  ## for bicubic interpolation do not use interp2, but another implementation for Matlab compatibility
  if (strcmp (interp, "cubic"))
    padding = "symmetric";
    if (ischar (extrapval))
      padding = extrapval;
    endif

    ## interpolate
    warped = bicubic_conv (double (im), XI, YI, padding);

    if (isscalar (extrapval))
      ## values got padded for smooth borders, but constant padding has been requested
      outside = (XI < 0.5) | (XI > columns (im) + 0.5) | ...
                (YI < 0.5) | (YI > rows (im) + 0.5);
      outside = repmat (outside, [1, 1, size(im,3)]);
      warped(outside) = extrapval;
    endif

  else
    sz = size (im);
    n_planes = prod (sz(3:end));
    sz(1) = size (YI, 1);
    sz(2) = size (XI, 2);
    warped = zeros (sz);
    for i = 1:n_planes
      # 1-pixel image planes:
      if isscalar (im(:,:,i))
        if (all (XI(:) == 1) && all (YI(:) == 1))
          warped(:,:,i) = double (im(:,:,i));
        else
          warped(:,:,i) = extrapval;
        endif
      # row image planes:
      elseif size(im, 1) == 1
        if (all (YI(:) == 1 ))
          warped(:,:,i) = ones (sz(1), 1) * interp1 ([1:size(im,2)], ...
              double (im(1,:,i)), XI, interp, extrapval);
        else
          warped(:,:,i) = extrapval;
        endif
      # col image planes:
      elseif size(im, 2) == 1
        if (all (XI(:) == 1))
          warped(:,:,i) = interp1 ([1:size(im,1)], double (im(:,1,i)), YI, ...
              interp, extrapval) * ones (1, sz(2));
        else
          warped(:,:,i) = extrapval;
        endif
      # 2d image planes:
      else
        warped(:,:,i) = interp2 (double (im(:,:,i)), XI, YI, interp, extrapval);
      endif
    endfor
  endif

  ## we return image on same class as input
  warped = cast (warped, class (im));
endfunction

## Cubic interpolation in 1d using a convolution kernel with a = -0.5 for MATLAB compatibility. Bicubic interpolation in interp2 is not MATLAB compatible.
function w = cubic01 (d, a)
  ## requires: all (abs (d(:)) <= 1)
  absd = abs (d);
  w = (a+2) * absd.^3 - (a+3) * absd.^2 + 1;
endfunction

function w = cubic12 (d, a)
  ## requires all (1 < abs (d(:)) && abs (d(:)) <= 2)
  absd = abs (d);
  w = a * absd.^3 - 5*a * absd.^2 + 8*a * absd - 4*a;
endfunction

function p = intpolcub (I1, I2, I3, I4, D, a = -0.5)
  ## requires: all (0 <= D(:) && D(:) < 1) && a < 1 && size_equal(I1, I2) && size_equal(I1, I3) && size_equal(I1, I4)
  p = I1 .* cubic12 (-1-D, a) + I2 .* cubic01 (-D, a) + ...
      I3 .* cubic01 (1-D, a) + I4 .* cubic12 (2-D, a);
endfunction

## padding by changing indices. Cannot mimic constant value padding, like zero padding
function idx = pad_indices (i, sz, method = "symmetric")
  if strcmp (method, "replicate")
    idx = max (min (i, sz), 1);
  elseif strcmp (method, "symmetric")
    idx = i - 1;
    m = mod (idx, sz);
    odd = mod (floor (idx / sz), 2) == 1;
    idx(odd) = sz - m(odd);
    idx(!odd) = m(!odd) + 1;
  elseif strcmp (method, "reflect")
    idx = i - 1;
    while (any (idx(:) < 0 | idx(:) >= sz))
      idx(idx < 0) = -idx(idx < 0);
      idx(idx >= sz) = 2*sz - 2 - idx(idx >= sz);
    endwhile
    idx += 1;
  elseif strcmp (method, "circular")
    idx = mod (i - 1, sz) + 1;
  else
    error (['Invalid argument for PADDING. Valid are "replicate", "symmetric", "reflect", "circular". You gave "', method, '"'])
  endif
endfunction

## extract elements using meshgrid from 2d or 3d matrix
function B = idx3 (A, Y, X)
  sz = size(A);
  if (length (sz) == 2)
    i = sub2ind (sz, Y, X);
  else
    X3 = repmat (X, [1, 1, sz(3)]);
    Y3 = repmat (Y, [1, 1, sz(3)]);
    ## Z is simply a 3d matrix, where the first channel is full of 1s, the second full of 2s, etc.
    Z3 = reshape (repelem (1:sz(3), size (X, 1) * size (X, 2), 1), ...
        [size(X,1), size(X,2), sz(3)]);
    i = sub2ind (sz, Y3, X3, Z3);
  endif
  B = A(i);
endfunction

## bicubic interpolation using convolution kernel
function out = bicubic_conv (img, XI, YI, padding = "symmetric")
  ## make padded indices for smooth borders
  K = floor(XI);
  DX = XI - K;
  K_1 = pad_indices (K - 1, columns (img), padding);
  K0  = pad_indices (K    , columns (img), padding);
  K1  = pad_indices (K + 1, columns (img), padding);
  K2  = pad_indices (K + 2, columns (img), padding);

  L = floor(YI);
  DY = YI - L;
  L_1 = pad_indices (L - 1, rows (img), padding);
  L0  = pad_indices (L    , rows (img), padding);
  L1  = pad_indices (L + 1, rows (img), padding);
  L2  = pad_indices (L + 2, rows (img), padding);

  if (isvector (XI) && !isvector (img)) ## rectilinear interpolation grid using vectors
    ## interpolate in y-direction
    out_y = intpolcub (img(L_1,:,:), img(L0,:,:), img(L1,:,:), img(L2,:,:), DY);

    ## interpolate in x-direction
    out = intpolcub (out_y(:,K_1,:), out_y(:,K0,:), out_y(:,K1,:), out_y(:,K2,:), DX);

  else ## meshgrid interpolation
    ## interpolate in y-direction at gridpoints
    out_y_1 = intpolcub (idx3 (img, L_1, K_1), idx3 (img, L0, K_1), idx3 (img, L1, K_1), idx3 (img, L2, K_1), DY);
    out_y0  = intpolcub (idx3 (img, L_1, K0),  idx3 (img, L0, K0),  idx3 (img, L1, K0),  idx3 (img, L2, K0),  DY);
    out_y1  = intpolcub (idx3 (img, L_1, K1),  idx3 (img, L0, K1),  idx3 (img, L1, K1),  idx3 (img, L2, K1),  DY);
    out_y2  = intpolcub (idx3 (img, L_1, K2),  idx3 (img, L0, K2),  idx3 (img, L1, K2),  idx3 (img, L2, K2),  DY);

    ## interpolate in x-direction
    out = intpolcub (out_y_1, out_y0, out_y1, out_y2, DX);
  endif
endfunction

%!demo
%! ## Generate a synthetic image and show it
%! I = tril(ones(100)) + abs(rand(100)); I(I>1) = 1;
%! I(20:30, 20:30) = !I(20:30, 20:30);
%! I(70:80, 70:80) = !I(70:80, 70:80);
%! figure, imshow(I);
%! ## Resize the image to the double size and show it
%! [XI, YI] = meshgrid(linspace(1, 100, 200));
%! warped = imremap(I, XI, YI);
%! figure, imshow(warped);

%!demo
%! ## Generate a synthetic image and show it
%! I = tril(ones(100)) + abs(rand(100)); I(I>1) = 1;
%! I(20:30, 20:30) = !I(20:30, 20:30);
%! I(70:80, 70:80) = !I(70:80, 70:80);
%! figure, imshow(I);
%! ## Rotate the image around (0, 0) by -0.4 radians and show it
%! [XI, YI] = meshgrid(1:100);
%! R = [cos(-0.4) sin(-0.4); -sin(-0.4) cos(-0.4)];
%! RXY = [XI(:), YI(:)] * R;
%! XI = reshape(RXY(:,1), [100, 100]); YI = reshape(RXY(:,2), [100, 100]);
%! warped = imremap(I, XI, YI);
%! figure, imshow(warped);

%!test
%!
## Test padding indirectly
%! I = repmat([                      1  2  3  4                     ], [4, 1]);
%! xi       = [-6 -5 -4 -3 -2 -1  0  1  2  3  4  5  6  7  8  9 10 11];
%! exp_rep  = [ 1  1  1  1  1  1  1  1  2  3  4  4  4  4  4  4  4  4];
%! exp_sym  = [ 2  3  4  4  3  2  1  1  2  3  4  4  3  2  1  1  2  3];
%! exp_ref  = [ 2  1  2  3  4  3  2  1  2  3  4  3  2  1  2  3  4  3];
%! exp_cir  = [ 2  3  4  1  2  3  4  1  2  3  4  1  2  3  4  1  2  3];
%! yi       = 2.5;
%!
%! # rectilinear grid codepath
%! assert (imremap (I, xi, yi, "bicubic", "replicate"), exp_rep);
%! assert (imremap (I, xi, yi, "bicubic", "symmetric"), exp_sym);
%! assert (imremap (I, xi, yi, "bicubic", "reflect"),   exp_ref);
%! assert (imremap (I, xi, yi, "bicubic", "circular"),  exp_cir);
%!
%! # meshgrid codepath
%! XI = [xi/2; xi; xi/2]; % cannot be reduced to vector, we will assert only middle row
%! YI = repmat ([1.5; yi; 3.5], [1, length(xi)]);
%! assert (imremap (I, XI, YI, "bicubic", "replicate")(2,:), exp_rep);
%! assert (imremap (I, XI, YI, "bicubic", "symmetric")(2,:), exp_sym);
%! assert (imremap (I, XI, YI, "bicubic", "reflect")(2,:),   exp_ref);
%! assert (imremap (I, XI, YI, "bicubic", "circular")(2,:),  exp_cir);
