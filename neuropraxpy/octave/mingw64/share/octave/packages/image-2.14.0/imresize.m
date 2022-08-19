## Copyright (C) 2005 Søren Hauberg <soren@hauberg.org>
## Copyright (C) 2013 Carnë Draug <carandraug@octave.org>
## Copyright (C) 2022 Christof Kaufmann <christofkaufmann.dev@gmail.com>
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
## @deftypefn  {Function File} {} imresize (@var{im}, @var{scale})
## @deftypefnx {Function File} {} imresize (@var{im}, [@var{M} @var{N}])
## @deftypefnx {Function File} {} imresize (@dots{}, @var{method})
## @deftypefnx {Function File} {} imresize (@dots{}, @dots{}, @var{property}, @var{value}, @dots{})
## Resize image with interpolation
##
## Scales the image @var{im} by a factor @var{scale} or into the size @var{M}
## rows by @var{N} columns.  For example:
##
## @example
## @group
## imresize (im, 1);    # return the same image as input
## imresize (im, 1.5);  # return image 1.5 times larger
## imresize (im, 0.5);  # return image with half the size
## imresize (im, 2);    # return image with the double size
## imresize (im, [512 610]); # return image of size 512x610
## @end group
## @end example
##
## If @var{M} or @var{N} is @code{NaN}, it will be determined automatically so
## as to preserve aspect ratio.
##
## The optional argument @var{method} defines the interpolation method to be
## used.  The following methods are available, see below for custom methods.
## @table @code
## @item "nearest", "box"
## Nearest neighbor method.  Only the nearest pixel is used.  This gives hard
## edges.
##
## @item "linear", "bilinear", "triangle"
## Bilinear interpolation method using the four neighbor pixels.
##
## @item "cubic", "bicubic" (default)
## Bicubic interpolation method using the 16 neighbor pixels.  At the borders
## symmetric padding is used.  This is the default method.
## @end table
## By default, the @code{cubic} method is used.
##
## For custom interpolation kernels, specify a two-element cell array for
## @var{method}: @{@var{kernel}, @var{size}@}.  @var{kernel} must be an
## interpolation kernel function that can handle vector input.  It must be zero
## outside -@var{size}/2 <= x <= @var{size}/2.  The following example does a
## bilinear interpolation, just as using "bilinear":
## @example
## @group
## im = magic(6);
## lin = @@(x) (1 - abs(x)) .* (abs(x) < 1);
## size = 2;
## imresize(im, 0.5, @{lin, size@});
## @end group
## @end example
## Note that also for custom kernels anti-aliasing is applied by default.
##
## Additionally the following optional property-value-pairs can be used:
## @table @code
## @item "Antialiasing"
## If this is set to @code{true} and the scale factor in horizontal or vertical
## direction is less than 1, anti-aliasing will used for that direction.  This
## means the interpolation kernel is broadened by 1/scale to reduce the
## frequency components that cause aliasing effects.  Hence more neighbors than
## described above are used, e. g. "bilinear" with a scale of 0.5 in both
## directions uses 16 neighbors.  The default value is @code{true}, except for
## the method "nearest" / "box".
##
## @item "Method"
## The interpolation method as string or a custom interpolation kernel, see
## above.
##
## @item "OutputSize"
## Specify the output size @var{M} rows by @var{N} columns as vector
## [@var{M} @var{N}], see above.
##
## @item "Scale"
## Either a scalar to use the same scale factor for both direction or a vector
## [@var{scale_rows} @var{scale_columns}] to use different scaling factors.
## @end table
##
## Note: Currently there is no special support for categorical images or images
## with indexed colors.
##
## @seealso{imremap, imrotate, interp2}
## @end deftypefn

function im = imresize (im, varargin)

  if (nargin < 2 || nargin > 7)
    print_usage ();
  endif

  antialiasing = [];
  scale_or_M_N = [];
  scale = []; # for the property, that can specify [scale_rows, scale_cols]
  method = [];

  if (nargin/2 == round (nargin/2))  # even number of inputs (2, 4 or 6)
    ## imresize (im, scale_or_M_N)
    ## imresize (im, scale_or_M_N, property1, value1)
    ## imresize (im, scale_or_M_N, property1, value1, property2, value2)
    scale_or_M_N = varargin{1};
    n_start = 2;
  else                              # odd number of inputs (3, 5 or 7)
    ## imresize (im, property1, value1) # property1 must be Scale or OutputSize
    ## imresize (im, scale_or_M_N, method)
    ## imresize (im, scale_or_M_N, method, property1, value1)
    ## imresize (im, scale_or_M_N, method, property1, value1, property2, value2)
    if isnumeric(varargin{1})
      scale_or_M_N = varargin{1};
      method = varargin{2};
      n_start = 3;
    else
      n_start = 1;
    endif
  endif

  for n = n_start:2:(nargin-1)      # process parameter-values pairs
    if (strcmpi (varargin{n}, "Antialiasing"))
      antialiasing = varargin{n+1};
    elseif (strcmpi (varargin{n}, "Method"))
      method = varargin{n+1};
    elseif (strcmpi (varargin{n}, "OutputSize"))
      if (! isempty (scale_or_M_N))
        error ("imresize: OutputSize must not be specified, when SCALE or [M N] is also specified.")
      endif
      scale_or_M_N = varargin{n+1};
    elseif (strcmpi (varargin{n}, "Scale"))
      scale = varargin{n+1};
    else
      error ("imresize: invalid PROPERTY given")
    endif
  endfor

  ## defaults
  if (isempty (method))
    method = "cubic";
  elseif (ischar (method))
    ## convert to lower case. Replace "box" by "nearest", replace "bicubic" by "cubic" and replace "bilinear" and "triangle" by "linear".
    method = interp_method (method);
  endif

  if (isempty (antialiasing))
    if (strcmpi (method, "nearest"))
      antialiasing = false;
    else
      antialiasing = true;
    endif
  endif

  ## check input arguments
  if (isempty (scale_or_M_N) && isempty (scale))
    error ("imresize: Scale or output size must be specified.");
  elseif (! isempty(scale_or_M_N) && ! isempty (scale))
    error ("imresize: Scale and OutputSize must not be specified both.")
  elseif (! (islogical (antialiasing) || isnumeric (antialiasing)) || ! isscalar (antialiasing))
    ## accept also numbers as logical values (even complex, which Matlab does not accept)
    error ("imresize: Antialiasing must be true, false or a number (0 interpreted as false, otherwise as true).")
  elseif (! ((isnumeric (im) || islogical (im)) && ! issparse (im) && ! isempty (im)))
    error ("imresize: IM must be an image")
  elseif (! isempty (scale_or_M_N) && (! isnumeric (scale_or_M_N) || any (scale_or_M_N <= 0)))
    error ("imresize: SCALE or [M N] must be numeric positive values")
  elseif (! isempty (scale_or_M_N) && numel (scale_or_M_N) > 2)
    error ("imresize: SCALE or [M N] argument must be a scalar or a 2 element vector");
  elseif (! isempty (scale_or_M_N) && all (isnan (scale_or_M_N)))
    error ("imresize: In [M N] only one value may be NaN to maintain aspect ratio.")
  elseif (! isempty (scale) && (! isnumeric (scale) || any (scale <= 0) || any (isnan (scale)) || numel (scale) > 2))
    error ("imresize: Scale must be one or two numeric positive values")
  elseif (! ischar (method) && ! (iscell (method) && length (method) == 2))
    error ("imresize: METHOD must be a string with the interpolation method or a two-element cell array with a custom kernel and size.")
  endif


  in_rows = rows (im);
  in_cols = columns (im);

  if (isscalar (scale_or_M_N))
    scale = scale_or_M_N;
    scale_or_M_N = [];
  endif

  if (isempty (scale_or_M_N))
    if (isscalar (scale))
      scale_rows = scale;
      scale_cols = scale;
    else
      scale_rows = scale(1);
      scale_cols = scale(2);
    endif
    out_rows = ceil (in_rows * scale_rows);
    out_cols = ceil (in_cols * scale_cols);
  else
    # scale_or_M_N contains output size
    out_rows = scale_or_M_N(1);
    out_cols = scale_or_M_N(2);

    ## maintain aspect ratio if requested
    if (isnan (out_rows))
      out_rows = in_rows * (out_cols / in_cols);
    elseif (isnan (out_cols))
      out_cols = in_cols * (out_rows / in_rows);
    endif

    scale_rows = out_rows / in_rows;
    scale_cols = out_cols / in_cols;
    out_rows = ceil (out_rows);
    out_cols = ceil (out_cols);
  endif

  ## calculate the new pixel indices in terms of the old pixel indices
  off_rows = 1 / scale_rows / 2;
  off_cols = 1 / scale_cols / 2;
  idx_rows = 0.5 + off_rows + (0:out_rows-1) / scale_rows;
  idx_cols = 0.5 + off_cols + (0:out_cols-1) / scale_cols;

  ## trivial cases
  if (scale_rows == 1 && scale_cols == 1)
    ## no resizing to do
    return
  elseif (ischar (method) && strcmp (method, "nearest") ...
          && (! antialiasing || (scale_rows >= 1 && scale_cols >= 1)))
    idx_rows = max (min (idx_rows, in_rows), 1);
    idx_cols = max (min (idx_cols, in_cols), 1);
    im = im(round (idx_rows), round (idx_cols), :);
    return
  endif

  ## cast to floating point for accuracy
  orig_class = class (im);
  switch orig_class
    case {"int8", "uint8", "int16", "uint16"}
      im = single (im);
      idx_cols = single (idx_cols);
      idx_rows = single (idx_rows);
    case {"int32", "uint32", "int64", "uint64"}
      im = double (im);
  endswitch

  ## actual interpolation
  for scale_and_idx = {scale_cols, scale_rows;
                       idx_cols,   idx_rows';
                       2,          1}
    [scale, idx, axis] = scale_and_idx{:};
    if scale == 1
      continue;
    endif

    if (iscell (method))
      kernel_size = method{2};
      if (scale < 1 && antialiasing)
        kernel = @(h) scale * method{1} (scale * h);
        kernel_size /= scale;
      else
        kernel = method{1};
      endif
    elseif (strcmp (method, "nearest"))
      if (scale < 1)
        kernel = @(h) scale * box (scale * h);
        kernel_size = 1 / scale;
      else
        if axis == 1
          im = im(round (idx), :, :);
        else
          im = im(:, round (idx), :);
        endif
        continue;
      endif
    elseif (strcmp (method, "linear"))
      kernel_size = 2;
      if (scale < 1 && antialiasing)
        kernel = @(h) scale * triangle (scale * h);
        kernel_size /= scale;
      else
        kernel = @triangle;
      endif
    elseif (strcmp (method, "cubic"))
      kernel_size = 4;
      if (scale < 1 && antialiasing)
        kernel = @(h) scale * cubic (scale * h);
        kernel_size /= scale;
      else
        kernel = @cubic;
      endif
    else
      error ("imresize: Interpolation method not supported");
    endif

    ## When rounding the output size up, it can happen that some interpolation
    ## points lie out at the right or the bottom of the input image. For these
    ## points symmetric padding is very important and also used in Matlab.
    ## For an example, see tests below with scale 1/3.
    im = conv_interp_vec (im, idx, kernel, kernel_size, axis, "symmetric");
  endfor

  ## we return image on same class as input
  im = cast (im, orig_class);
endfunction


## box / nearest neighbor interpolation kernel.
function w = box (d)
  w = -0.5 < d & d <= 0.5;
endfunction

## linear interpolation kernel.
function w = triangle (d)
  absd = abs (d);
  absd01 = absd <= 1;
  w = (1 - absd) .* absd01;  ## for |d| <= 1
endfunction

## cubic interpolation kernel with a = -0.5 for MATLAB compatibility.
function w = cubic (h)
  absh = abs (h);
  absh01 = absh <= 1;
  absh12 = absh <= 2 & ~absh01;
  absh_sqr = absh .* absh;
  absh_cube = absh_sqr .* absh;
  w = (1.5 * absh_cube - 2.5 * absh_sqr + 1)             .* absh01 ...  ## for |h| <= 1
    + (-0.5 * absh_cube + 2.5 * absh_sqr - 4 * absh + 2) .* absh12;     ## for 1 < |h| <= 2
end


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
    error (['imresize: Invalid argument for PADDING. Valid are "replicate", "symmetric", "reflect", "circular". You gave "', method, '"'])
  endif
endfunction

## interpolation using convolution kernel
function out = conv_interp_vec (img, ZI, kernel, kernel_size, axis, padding = "symmetric")
  ## get indexes and distances
  idx = floor (ZI);
  DZ = ZI - idx;
  pad_size = ceil (kernel_size / 2);
  pad_border = size (img, axis);

  ## allocate output
  out_shape = size (img);
  out_shape(axis) = length (ZI);
  out = zeros (out_shape);

  ## interpolate
  for shift = 1-pad_size : pad_size
    h = shift - DZ;
    idx_padded = pad_indices (idx + shift, pad_border, padding);

    if axis == 1
      out += img(idx_padded, :, :) .* kernel (h);
    else
      out += img(:, idx_padded, :) .* kernel (h);
    endif
  endfor
endfunction

## Test basic features.
%!test
%!
## Test scaling with 1:
%! in = [116  227  153   69  146  194   59  130  139  106
%!         2   47  137  249   90   75   16   24  158   44
%!       155   68   46   84  166  156   69  204   32  152
%!        71  221  137  230  210  153  192  115   30  118
%!       107  143  108   52   51   73  101   21  175   90
%!        54  158  143   77   26  168  113  229  165  225
%!         9   47  133  135  130  207  236   43   19   73];
%! assert (imresize (uint8 (in), 1, "nearest"), uint8 (in))
%! assert (imresize (uint8 (in), 1, "bicubic"), uint8 (in))
%!
## Test nearest neighbour with a scale factor of 2, also by aspect ratio preservation:
%! out = [116  116  227  227  153  153   69   69  146  146  194  194   59   59  130  130  139  139  106  106
%!        116  116  227  227  153  153   69   69  146  146  194  194   59   59  130  130  139  139  106  106
%!          2    2   47   47  137  137  249  249   90   90   75   75   16   16   24   24  158  158   44   44
%!          2    2   47   47  137  137  249  249   90   90   75   75   16   16   24   24  158  158   44   44
%!        155  155   68   68   46   46   84   84  166  166  156  156   69   69  204  204   32   32  152  152
%!        155  155   68   68   46   46   84   84  166  166  156  156   69   69  204  204   32   32  152  152
%!         71   71  221  221  137  137  230  230  210  210  153  153  192  192  115  115   30   30  118  118
%!         71   71  221  221  137  137  230  230  210  210  153  153  192  192  115  115   30   30  118  118
%!        107  107  143  143  108  108   52   52   51   51   73   73  101  101   21   21  175  175   90   90
%!        107  107  143  143  108  108   52   52   51   51   73   73  101  101   21   21  175  175   90   90
%!         54   54  158  158  143  143   77   77   26   26  168  168  113  113  229  229  165  165  225  225
%!         54   54  158  158  143  143   77   77   26   26  168  168  113  113  229  229  165  165  225  225
%!          9    9   47   47  133  133  135  135  130  130  207  207  236  236   43   43   19   19   73   73
%!          9    9   47   47  133  133  135  135  130  130  207  207  236  236   43   43   19   19   73   73];
%! assert (imresize (uint8 (in), 2, "nearest"), uint8 (out))
%! assert (imresize (uint8 (in), 2, "neAreST"), uint8 (out))
%! assert (imresize (uint8 (in), [14 NaN], "nearest"), uint8 (out))
%! assert (imresize (uint8 (in), [NaN 20], "nearest"), uint8 (out))
%!
## Test nearest neighbour with a scaling of 2 for x and 1 for y:
%! out = [116  116  227  227  153  153   69   69  146  146  194  194   59   59  130  130  139  139  106  106
%!          2    2   47   47  137  137  249  249   90   90   75   75   16   16   24   24  158  158   44   44
%!        155  155   68   68   46   46   84   84  166  166  156  156   69   69  204  204   32   32  152  152
%!         71   71  221  221  137  137  230  230  210  210  153  153  192  192  115  115   30   30  118  118
%!        107  107  143  143  108  108   52   52   51   51   73   73  101  101   21   21  175  175   90   90
%!         54   54  158  158  143  143   77   77   26   26  168  168  113  113  229  229  165  165  225  225
%!          9    9   47   47  133  133  135  135  130  130  207  207  236  236   43   43   19   19   73   73];
%! assert (imresize (uint8 (in), [7 20], "nearest"), uint8 (out))
%!
## Test nearest neighbour with a scaling of 1 for x and 2 for y:
%! out = [116  227  153   69  146  194   59  130  139  106
%!        116  227  153   69  146  194   59  130  139  106
%!          2   47  137  249   90   75   16   24  158   44
%!          2   47  137  249   90   75   16   24  158   44
%!        155   68   46   84  166  156   69  204   32  152
%!        155   68   46   84  166  156   69  204   32  152
%!         71  221  137  230  210  153  192  115   30  118
%!         71  221  137  230  210  153  192  115   30  118
%!        107  143  108   52   51   73  101   21  175   90
%!        107  143  108   52   51   73  101   21  175   90
%!         54  158  143   77   26  168  113  229  165  225
%!         54  158  143   77   26  168  113  229  165  225
%!          9   47  133  135  130  207  236   43   19   73
%!          9   47  133  135  130  207  236   43   19   73];
%! assert (imresize (uint8 (in), [14 10], "nearest"), uint8 (out))
%!
## Test equivalence of different input writing styles:
%! assert (imresize (uint8 (in), 1.5, "box"), imresize (uint8 (in), 1.5, "MeTHoD", "nearest"))
%! assert (imresize (uint8 (in), "Scale", 1.5, "Method", "box"), imresize (uint8 (in), 1.5, {@(h) -0.5 < h & h <= 0.5, 1}))
%! assert (imresize (uint8 (in), 1.5, "bicubic"), imresize (uint8 (in), 1.5, "cubic"))
%! assert (imresize (uint8 (in), [NaN, size(in,2)*1.5], "bicubic"), imresize (uint8 (in), 1.5, "cubic"))
%! assert (imresize (uint8 (in), [size(in,1)*1.5, NaN], "bicubic"), imresize (uint8 (in), 1.5, "cubic"))
%! assert (imresize (uint8 (in), "outputsize", [size(in,1)*1.5, NaN], "method", "bicubic"), imresize (uint8 (in), 1.5, "cubic"))
%! assert (imresize (uint8 (in), 1.5, "linear"), imresize (uint8 (in), 1.5, "LIneAR"))
%! assert (imresize (uint8 (in), 1.5, "linear"), imresize (uint8 (in), 1.5, "triangle"))

## nearest neighbour test. The distance is the same for all neighbours here.
%!test
%! in = [116  227  153   69  146  194   59  130  139  106
%!         2   47  137  249   90   75   16   24  158   44
%!       155   68   46   84  166  156   69  204   32  152
%!        71  221  137  230  210  153  192  115   30  118
%!       107  143  108   52   51   73  101   21  175   90
%!        54  158  143   77   26  168  113  229  165  225
%!         9   47  133  135  130  207  236   43   19   73
%!       129   60   59  243   64  181  249   56   32   86];
%!
## Check that a pixel from the neighbour locations gets picked.
%! out = imresize (in, 0.5, "nearest", "Antialiasing", false);
%! for x = 1:columns (out)
%!   for y = 1:rows (out)
%!     x_in = 2 * (x-1) + 1;
%!     y_in = 2 * (y-1) + 1;
%!     sub = in(y_in:y_in+1, x_in:x_in+1);
%!     assert (any (any (sub == out(y, x))))
%!   endfor
%! endfor
%!
## Check that with anti-aliasing the mean of the neighbour pixels is used.
%! out = imresize (in, 0.5, "nearest", "Antialiasing", true);
%! for x = 1:columns (out)
%!   for y = 1:rows (out)
%!     x_in = 2 * (x-1) + 1;
%!     y_in = 2 * (y-1) + 1;
%!     val = mean (mean (in(y_in:y_in+1, x_in:x_in+1)));
%!     assert (val, out(y, x))
%!   endfor
%! endfor
%!
## Check that anti-aliasing also works in only y direction.
%! out = imresize (in,  "Scale", [0.5, 2],  "Method", "nearest",  "Antialiasing", true);
%! for x = 1:columns (out)
%!   for y = 1:rows (out)
%!     x_in = floor (0.5 * (x-1) + 1);
%!     y_in = 2 * (y-1) + 1;
%!     val = mean (in(y_in:y_in+1, x_in));
%!     assert (val, out(y, x))
%!   endfor
%! endfor
%!
## Check that anti-aliasing also works in only x direction.
%! out = imresize (in,  "Scale", [2, 0.5],  "Method", "nearest",  "Antialiasing", true);
%! for x = 1:columns (out)
%!   for y = 1:rows (out)
%!     x_in = 2 * (x-1) + 1;
%!     y_in = floor (0.5 * (y-1) + 1);
%!     val = mean (in(y_in, x_in:x_in+1));
%!     assert (val, out(y, x))
%!   endfor
%! endfor


## Test floating point range and and scaling of multi-channel images.
%!test
%!
## Do not enforce floating point images to be in the [0 1] range (bug #43846):
%! assert (imresize (repmat (5, [3 3]), 2), repmat (5, [6 6]), eps*100)
%!
## Similarly, do not enforce images to have specific dimensions and only
## expand on the first 2 dimensions:
%! assert (imresize (repmat (5, [3 3 2]), 2), repmat (5, [6 6 2]), eps*100)

## Test that scaling a multi-channel image is equivalent to scaling its channels.
%!test
%!
%! for channels = 1:3
%!   in = rand (5, 4, channels);
%!   for method = {"nearest", "bilinear", "bicubic"}
%!     out = imresize (in, 2, method{1});
%!     for i = 1:size (in, 3)
%!       assert (out(:, :, i), imresize (in(:, :, i), 2, method{1}))
%!     endfor
%!   endfor
%! endfor

## Test scaling down to a single row
%!test
%!
%! for channels = 1:3
%!   in = rand (5, 4, channels);
%!   out = imresize (in, [1, columns(in)], "nearest", "Antialiasing", true);
%!   for i = 1:columns (in)
%!     assert (out(1, i, :), mean (in(:, i, :), 1), 10*eps)
%!   endfor
%! endfor

## Test scaling down to a single column
%!test
%!
%! for channels = 1:3
%!   in = rand (5, 4, channels);
%!   out = imresize (in, [rows(in), 1], "nearest", "Antialiasing", true);
%!   for i = 1:rows (in)
%!     assert (out(i, 1, :), mean (in(i, :, :), 2), 10*eps)
%!   endfor
%! endfor

## Test scaling down to a single pixel
%!test
%!
%! for channels = 1:3
%!   in = rand (5, 4, channels);
%!   out = imresize (in, [1, 1], "nearest", "Antialiasing", true);
%!   assert (out(1, 1, :), mean (mean (in(:, :, :))), 10*eps)
%! endfor

## Test linear interpolations against some reference results from matlab.
## The floating point error is less than 1e-13, but for int matlab uses an
## optimized algorithm. So a difference of 1 is acceptable.
%!test
%!
%! in = [116  227  153   69  146  194   59  130  139  106
%!         2   47  137  249   90   75   16   24  158   44
%!       155   68   46   84  166  156   69  204   32  152
%!        71  221  137  230  210  153  192  115   30  118
%!       107  143  108   52   51   73  101   21  175   90
%!        54  158  143   77   26  168  113  229  165  225
%!         9   47  133  135  130  207  236   43   19   73
%!       129   60   59  243   64  181  249   56   32   86];
%!
## Factor 0.91 yields same output size, but interpolation must not be skipped
%! out = [115  208  134  100  163  117  101  136  109  103
%!         26   61  149  182   95   53   41  116   73   60
%!        133  101   82  140  167  125  152   71  126  144
%!         88  184  137  164  142  145  110   81  104  108
%!         86  146  109   55   73  110  111  156  153  150
%!         33  104  131  100  130  184  147   97  133  142
%!         84   59  114  164  133  219  120   33   72   81
%!        126   60  104  181  116  218  125   38   77   86];
%! assert (imresize (uint8 (in), 0.91, "bilinear", "Antialiasing", false), uint8 (out), 1)
%!
## Factor 1.5, gives an output of size 12 x 15 (without requiring to round the size)
%! out = [116  172  215  165  111   82  133  170  171   81   95  132  138  123  106
%!         59   98  138  144  152  152  125  127  119   54   58   89  137  112   75
%!         27   39   62  110  172  202  123   96   78   36   40   68  123  100   62
%!        129   97   64   62   87  119  146  148  128   74  117  154   73   94  134
%!        113  129  136  101  125  162  183  172  151  135  146  139   53   83  135
%!         77  143  195  145  166  197  186  162  146  171  138   92   62   84  113
%!        101  129  149  120   98   81   78   82   91  111   77   56  132  123   95
%!         81  116  147  130   96   61   43   80  119  109  116  132  162  164  158
%!         46   93  139  141  114   80   50  109  168  141  166  189  151  171  200
%!         16   41   77  123  130  123  115  157  204  214  145   69   48   71   98
%!         69   62   61   89  143  174  112  146  202  235  147   46   30   53   80
%!        129   95   60   59  151  213   94  123  192  238  153   52   36   59   86];
%! assert (imresize (uint8 (in), 1.5, "bilinear"), uint8 (out), 1)
%!
## Factor 0.5, gives an output of size 4 x 5 (without requiring to round the size)
%! out = [ 98  152  126   58  112
%!        129  125  172  146   83
%!        116   96   80  116  164
%!         62  143  146  147   53];
%! assert (imresize (uint8 (in), 0.5, "bilinear", "Antialiasing", false), uint8 (out), 1)
%!
%! out = [108  136  125   89  107
%!        111  132  143  114   99
%!        106  110  106  127  136
%!         75  124  154  142   75];
%! assert (imresize (uint8 (in), 0.5, "bilinear", "Antialiasing", true), uint8 (out), 1)
%!
## Factor 4/3, gives an output of size 10.6667 x 13.3333 rounded up to 11 x 14
%! out = [116  185  199  143   80  117  164  177   76  103  133  135  110  106
%!         45   89  126  148  177  138  114  109   43   52   97  141   78   67
%!         59   57   73  114  177  145  114   96   45   71   99  108   88   85
%!        145  109   76   63   96  146  166  147   93  152  133   47  134  148
%!         82  157  174  137  201  208  186  156  174  145   90   42  111  122
%!         94  143  152  119  119  114  108  107  131   86   80  119  104  101
%!         87  126  139  114   69   49   67  109  106  102  126  167  145  141
%!         48  108  143  135   91   56   89  167  134  177  184  154  199  206
%!         15   44   88  133  129  121  149  204  219  124   55   44   85   92
%!         84   66   67  102  189  132  127  198  237  123   42   34   74   81
%!        129   86   60   82  220  131  108  190  241  128   47   39   79   86];
%! assert (imresize (uint8 (in), 4/3, "bilinear"), uint8 (out), 1)
%!
## Define custom bilinear interpolation kernel
%! lin = @(x) (1 - abs(x)) .* (abs(x) < 1);
%!
## Factor 1/3, gives an output of size 2.6667 x 3.3333 rounded up to 3 x 4
%! out = [ 47   90   24   44
%!        143   51   21   90
%!         60   64   56   86];
%! assert (imresize (uint8 (in), 1/3, "bilinear", "Antialiasing", false), uint8 (out), 1)
%! assert (imresize (uint8 (in), 1/3, {lin, 2}, "Antialiasing", false), uint8 (out), 1)
%!
%! out = [115  131  101  102
%!        114  117  120  121
%!         91  147  116   76];
%! assert (imresize (uint8 (in), 1/3, "bilinear", "Antialiasing", true), uint8 (out), 1)
%! assert (imresize (uint8 (in), 1/3, {lin, 2}, "Antialiasing", true), uint8 (out), 1)

## Test bicubic interpolations against some reference results from matlab.
## The floating point error is less than 4e-13, but with integer Matlab rounds
## wrong. So a difference of 1 is acceptable.
## Factor 1.5, gives an output of size 12 x 15 (without requiring to round the size)
%!test
%! in = [116  227  153   69  146  194   59  130  139  106
%!         2   47  137  249   90   75   16   24  158   44
%!       155   68   46   84  166  156   69  204   32  152
%!        71  221  137  230  210  153  192  115   30  118
%!       107  143  108   52   51   73  101   21  175   90
%!        54  158  143   77   26  168  113  229  165  225
%!         9   47  133  135  130  207  236   43   19   73
%!       129   60   59  243   64  181  249   56   32   86];
%!
%! out = [116  187  237  171   94   61  135  191  187   75   91  142  140  124  108
%!         43   92  143  149  164  163  119  123  118   44   38   80  151  118   62
%!         13   21   47  107  195  228  115   81   70   24   19   56  137  105   48
%!        146   98   49   49   71  107  148  159  132   58  124  176   61   85  146
%!        118  139  144   92  116  168  201  188  159  140  167  158   27   69  153
%!         61  151  218  145  174  219  201  164  146  187  148   84   48   76  115
%!        102  132  151  119   90   72   72   72   83  114   60   31  144  130   80
%!         81  121  154  133   87   41   19   67  116   95  108  140  183  180  163
%!         37   95  152  150  117   73   35  108  179  130  174  214  153  176  219
%!          3   29   73  131  136  120  116  162  214  229  147   54   35   62   96
%!         67   54   51   83  153  187  111  141  210  255  149   22   13   42   74
%!        142   99   53   43  164  237   77  103  197  254  159   42   31   59   91];
%! assert (imresize (uint8 (in), 1.5, "bicubic"), uint8 (out), 1)
%!
## Factor 0.5, gives an output of size 4 x 5 (without requiring to round the size)
%! out = [ 92  164  123   38  118
%!        139  116  188  167   69
%!        121   87   67  108  180
%!         54  153  141  149   42];
%! assert (imresize (uint8 (in), 0.5, "bicubic", "Antialiasing", false), uint8 (out), 1)
%!
%! out = [105  140  126   81  109
%!        110  134  153  114   93
%!        108  108   94  127  146
%!         67  126  162  149   62];
%! assert (imresize (uint8 (in), 0.5, "bicubic", "Antialiasing", true), uint8 (out), 1)
%!
## Factor 4/3, gives an output of size 10.6667 x 13.3333 rounded up to 11 x 14
%! out = [116   203   221   141    62   110   180   191    70   104   143   136   111   106
%!         26    78   126   156   200   139   103   103    33    28    92   158    67    46
%!         51    35    51   112   195   146   101    87    29    57   100   114    81    74
%!        159   110    63    50    82   148   179   152    83   173   147    27   143   170
%!         70   171   189   134   217   226   193   158   186   157    83    25   114   135
%!         91   152   162   116   118   114   102    98   138    65    60   127    92    84
%!         90   130   144   111    52    24    50   101    94    86   129   190   146   135
%!         41   114   157   139    89    37    82   178   125   192   203   154   213   227
%!          4    33    89   141   127   118   151   213   232   119    35    34    81    92
%!         88    61    54    97   203   129   115   203   255   119    18    24    70    81
%!        147    91    43    68   247   125    80   191   255   130    33    37    83    94];
%! assert (imresize (uint8 (in), 4/3, "bicubic"), uint8 (out), 1)
%!
## Factor 1/3, gives an output of size 2.6667 x 3.3333 rounded up to 3 x 4
%! out = [ 47   90   24   44
%!        143   51   21   90
%!         60   64   56   86];
%! assert (imresize (uint8 (in), 1/3, "bicubic", "Antialiasing", false), uint8 (out), 1)
%!
%! out = [115  135   97  101
%!        113  119  124  125
%!         81  157  118   64];
%! assert (imresize (uint8 (in), 1/3, "bicubic", "Antialiasing", true), uint8 (out), 1)

## Reduce the size of a checkerboard, such that it turns into gray
%!test
%!
%! in = checkerboard (1, [2 2]);
%! out = [0.5  0.35
%!        0.5  0.35];
%! assert ( imresize (in, 0.5, "bilinear", "Antialiasing", false), out)

## check complex inputs (Matlab allows them)
%!test
%!
%! in = ones (2) + 1i;
%! out_nearest = imresize (in, 1.5, "nearest");
%! assert (out_nearest, ones (3) + 1i);
%! out_linear = imresize (in, 1.5, "linear");
%! assert (out_linear, ones (3) + 1i);
%! out_cubic = imresize (in, 1.5, "cubic");
%! assert (out_cubic, ones (3) + 1i, 1e-14);

## check resizing of 1 pixel rgb images
%!test
%!
%! in = cat (3, 10, 10, 10);
%! expected = 10 * ones (2, 2, 3);   # consistent with MATLAB behaviour
%!
%! out_nearest = imresize (in, [2, 2], "nearest");
%! assert (out_nearest, expected);
%! out_linear = imresize (in, [2, 2], "linear");
%! assert (out_linear, expected);
%! out_cubic = imresize (in, [2, 2], "cubic");
%! assert (out_cubic, expected);

## check resizing of row and col rgb images
%!test
%!
%! in_row = cat(3, [10,6],  [10,6],  [10,6]);
%!
%! plane_expected_nearest = [1; 1; 1] * [10, 10, 6, 6];
%! out_expected = cat (3, plane_expected_nearest, plane_expected_nearest, plane_expected_nearest);
%! out_nearest = imresize (in_row, [3, 4], "nearest");
%! assert (out_nearest, out_expected);
%!
%! plane_expected_linear = [1; 1; 1] * [10, 8, 6];
%! out_expected = cat (3, plane_expected_linear, plane_expected_linear, plane_expected_linear);
%! out_linear = imresize (in_row, [3, 3], "linear");
%! assert (out_linear, out_expected);
%!
%! plane_expected_cubic = [1; 1; 1] * [10.27777777777777, 8, 5.72222222222222];    # values from MATLAB
%! out_expected = cat (3, plane_expected_cubic, plane_expected_cubic, plane_expected_cubic);
%! out_cubic = imresize (in_row, [3, 3], "cubic");
%! assert (out_cubic, out_expected, 1e-13);
%!
%! in_col = cat(3, [10;6],  [10;6],  [10;6]);
%!
%! plane_expected_nearest = [10; 10; 6; 6] * [1, 1, 1];
%! out_expected = cat (3, plane_expected_nearest, plane_expected_nearest, plane_expected_nearest);
%! out_nearest = imresize (in_col, [4, 3], "nearest");
%! assert (out_nearest, out_expected);
%!
%! plane_expected_linear = [10; 8; 6] * [1, 1, 1];
%! out_expected = cat (3, plane_expected_linear, plane_expected_linear, plane_expected_linear);
%! out_linear = imresize (in_col, [3, 3], "linear");
%! assert (out_linear, out_expected);
%!
%! plane_expected_cubic = [10.27777777777777; 8; 5.72222222222222] * [1, 1, 1];    # values from MATLAB
%! out_expected = cat (3, plane_expected_cubic, plane_expected_cubic, plane_expected_cubic);
%! out_cubic = imresize (in_col, [3, 3], "cubic");
%! assert (out_cubic, out_expected, 1e-13);

## performance tests for scale down and scale up (commented out by default)
%!#test
%! r_big_int16 = randi(16000, 8000, 8000, "int16");
%! r_big_double = randi(16000, 8000, 8000);
%! tic; imresize (r_big_int16,  100/8000); toc;
%! tic; imresize (r_big_double, 100/8000); toc;
%!
%! r_small_int16 = randi(16000, 100, 100, "int16");
%! r_small_double = randi(16000, 100, 100);
%! tic; imresize (r_small_int16,  8000/100); toc;
%! tic; imresize (r_small_double, 8000/100); toc;
