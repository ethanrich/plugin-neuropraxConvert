## Copyright (C) 2018 Martin Janda <janda.martin1@gmail.com>
##
## This program is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see
## <https://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {} {@var{c} =} imfuse (@var{a}, @var{b})
## @deftypefnx {} {[@var{c}, @var{rc}] =} imfuse (@var{a}, @var{ra}, @var{b}, @var{rb})
## @deftypefnx {} {@var{c} =} imfuse (@dots{}, @var{method})
## @deftypefnx {} {@var{c} =} imfuse (@dots{}, @var{name}, @var{value})
## Composite of two images.
##
## Combines two images using a specified @var{method}.  The smaller image gets
## padded with zeros to match the size of the bigger one.  The @var{method} is
## a char array and can have one of the following values:
##
## "falsecolor": Default.  Display each image as one (or more) [R G B]
## channels of the output image.  Images can be assigned to the output channels
## by passing the "ColorChannels" option (see below).
##
## "blend": Combines the images using alpha blending with both images equally
## transparent.
##
## "checkerboard": Masks both images with a 16x16 checkerboard stretched to fit
## the output image, each image masked with a negative version of the other's
## mask and combines the result.  The top left tile contains the top left part
## of the image @var{a}.
##
## "diff": Outputs an image that represents the absolute difference of
## grayscale versions of the images.  The result is also grayscale.
##
## "montage": Places @var{b} on the right side of @var{a}.  This method is
## useful for comparing a modified image with its original.
##
## Intensities of the images can be scaled before creating @var{c} by
## providing the "Scaling" option which can take one of the following values:
##
## "independent": Default.  Intensities of both images are scaled independently
## of each other.
##
## "joint": Intensities of both images are scaled as if all the pixels belonged
## to a single image coposed of @var{a} and @var{b}.
##
## "none": No scaling is applied.
##
## Output of the "falsecolor" method can be further modified by providing the
## "ColorChannels" option assigning image to one or two output [R G B]
## channels, given a three-element vector with values 0, 1 or 2, e.g. [0 2 1],
## that assigns @var{a} to the blue channel and @var{b} to the green channel.
## 0 means neither image gets assigned.  Accepts also two char-array values
## that represent shorthands for commonly used vectors: "green-magenta"
## for [2 1 2] and "red-cyan" for [1 2 2].
##
## When given @var{ra} and @var{rb}, images are positioned according to their
## positons in world coordinate system.  The output image spans the combined
## extent of the images.  Since both images can have different resolutions in
## both dimensions, the resolution of the output image in each dimension is
## the finer resolution of the two.  Resulting spatial referencing object
## is returned as @var{rc}.
##
##
## @seealso{imshowpair}
## @end deftypefn

function varargout = imfuse (varargin)
  if (nargin < 2)
    print_usage ();
  endif

  [a, b, ra, rb, method, scaling, color_channels] = parse_varargin (varargin{:});
  out_color_mode = get_out_color_mode (a, b, method);
  out_channels = get_out_channels (a, b, out_color_mode);
  img_a = adjust_channels (a, out_color_mode, out_channels);
  img_b = adjust_channels (b, out_color_mode, out_channels);
  [img_a, img_b] = apply_scaling (img_a, img_b, scaling);
  [img_a, img_b, rc] = resize_images (img_a, ra, img_b, rb, out_channels);

  switch (method)
    case "falsecolor"
      images = {img_a, img_b};
      img_c = zeros ([size(img_a, 1), size(img_a, 2), 3]);
      for i = 1:length (color_channels)
        channel = color_channels(i);
        if (channel > 0)
          part = images{channel};
          img_c(:, :, i) = part;
        endif
      endfor

    case "blend"
      img_c = 0.5 * (round(255 * img_a) + round(255 * img_b)) ./ 255;

    case "checkerboard"
      [m, n, _] = size (img_a);
      mask = checkerboard_mask (m, n);
      img_c = (img_a .* mask) + (img_b .* (! mask));

    case "diff"
      diff = abs(img_a - img_b);
      img_c = diff ./ max (diff (:));

    case "montage"
      img_c = [img_a, img_b];
  endswitch

  varargout{1} = uint8 (round (single (255) * img_c));
  if (! isempty (rc))
    varargout{2} = rc;
  endif
endfunction

function [a, b, ra, rb, method, scaling, color_channels] = parse_varargin(varargin)
  check_is_image (varargin{1}, "A");
  a = varargin{1};

  if (isimage (varargin{2}))
    b = varargin{2};
    varargin(1:2) = [];
    ra = [];
    rb = [];
  elseif (is_imref (varargin{2}))
    if (length (varargin) < 4)
      error ("Octave:invalid-input-arg", ...
      "expected at least 4 arguments: A, RA, B, RB");
    endif

    validateattributes (varargin{2}, {"imref2d"}, {}, "imfuse", "RA");
    check_is_image (varargin{3}, "B");
    validateattributes (varargin{4}, {"imref2d"}, {}, "imfuse", "RB");

    ra = varargin{2};
    b = varargin{3};
    rb = varargin{4};
    varargin(1:4) = [];
  endif

  method_names = {"falsecolor", "blend", "checkerboard", "diff", "montage", ...
      "interpolation"};
  scaling_names = {"independent", "joint", "none"};
  scaling = scaling_names{1};
  method = [];

  green_magenta = [2, 1, 2];
  red_cyan = [1, 2, 2];
  color_channels = green_magenta;

  while (! isempty (varargin))
    if (isempty (method) && is_valid_method (varargin{1}, method_names))
      method = lower (varargin{1});
      if (strcmp (method, "interpolation"))
          error ("Octave:invalid-input-arg", ...
              "imshowpair: INTERPOLATION not implemented yet");
      endif
      varargin(1) = [];
    else
      if (length (varargin) < 2)
        error ("Octave:invalid-input-arg",
            "expected NAME, VALUE pairs or incorrect display method");
      endif
      validateattributes (varargin{1}, {"char"}, {"nonempty"}, "imfuse", ...
      "NAME");
      validateattributes (varargin{2}, {}, {"nonempty"}, "imfuse", "VALUE");
      name = varargin{1};
      value = varargin{2};

      switch (lower (name))
        case "scaling"
          if (! is_valid_scaling (value, scaling_names))
            error ("Octave:invalid-input-arg", "imfuse: SCALING expected to\
 be one of 'independent', 'joint', 'none'");
          endif
          scaling = value;
        case "colorchannels"
          if (ischar (value))
            switch (value)
              case "green-magenta"
                color_channels = green_magenta;
              case "red-cyan"
                color_channels = red_cyan;
              otherwise
                error ("Octave:invalid-input-arg", ...
                "imfuse: expected COLORCHANNELS to be one of 'green-magenta',\
 'red-cyan'");
            endswitch
          else
            validateattributes (value, {"numeric"}, ...
            {"integer", "vector", "numel", 3, ">=", 0, "<=", 2}, ...
            "imfuse", "COLORCHANNELS")
            if (! is_valid_channels (value))
              error ("Octave:invalid-input-arg", ...
              "imfuse: COLORCHANNELS must include values 1 and 2");
            endif
            color_channels = value;
          endif
        case "interpolation"
          error ("Octave:invalid-input-arg", ...
              "imshowpair: INTERPOLATION not implemented yet");
        otherwise
          error ("Octave:invalid-input-arg", ...
          strcat (name, " is not a recognized parameter"));
      endswitch

      varargin(1:2) = [];
    endif
  endwhile

  if (isempty (method))
    method = method_names{1};
  endif

endfunction

function check = is_imref (arg)
  check = isa (arg, "imref2d");
endfunction

function check = is_valid_method (arg, method_names)
  check = ischar (arg) && ismember (lower (arg), method_names);
endfunction

function check = is_valid_scaling (arg, scaling_names)
  check = ischar (arg) && ismember (lower (arg), scaling_names);
endfunction

function check = is_valid_channels (arg)
  check = find (arg == 1) != 0 && find (arg == 2) != 0;
endfunction

function check_is_image (arg, name)
  if (! isimage (arg))
    error ("Octave:invalid-input-arg", ...
    strcat(name, " expected to be logical, RGB or grayscale image"));
  endif
endfunction

function rgb = to_rgb (img)
  if (isrgb (img))
    rgb = img;
  else
    rgb = repmat (img, [1, 1, 3]);
  endif
endfunction

function rc = get_output_spatial_ref (ra, rb)
  ## Output world extent
  x_world_a = ra.XWorldLimits;
  y_world_a = ra.YWorldLimits;
  x_world_b = rb.XWorldLimits;
  y_world_b = rb.YWorldLimits;
  x_world_d = [min(x_world_a(1), x_world_b(1)), ...
  max(x_world_a(2), x_world_b(2))];
  y_world_d = [min(y_world_a(1), y_world_b(1)), ...
  max(y_world_a(2), y_world_b(2))];

  ## Images can have different resolutions in both dimensions
  ## so the question is: what is the final resolution (image size)?
  ## Solution: for each dimension compute the number of pixels in the
  ## output image using the finer resolution of the two images.
  if (ra.PixelExtentInWorldX <= rb.PixelExtentInWorldX)
    x_ref = ra;
  else
    x_ref = rb;
  endif

  if (ra.PixelExtentInWorldY <= rb.PixelExtentInWorldY)
    y_ref = ra;
  else
    y_ref = rb;
  endif

  [iXA, _] = worldToIntrinsic (x_ref, x_world_d, y_world_d);
  [_, iYB] = worldToIntrinsic (y_ref, x_world_d, y_world_d);
  img_size = [ceil(iYB(2) - iYB(1)), ceil(iXA(2) - iXA(1))];
  rc = imref2d (img_size, x_world_d, y_world_d);
endfunction

function c = checkerboard_mask (m, n)
  v = repmat (eye (2), [8, 8]);
  c = logical (imresize (v, [m, n], "nearest"));
endfunction

function [img_a, img_b, rc] = resize_images (a, ra, b, rb, out_channels)
  if (isempty (ra) || isempty (rb))
    dims_a = size (a);
    dims_b = size (b);
    maxdims = max (dims_a(1:2), dims_b(1:2));
    m = maxdims(1);
    n = maxdims(2);
    out_dims = [m, n, out_channels];
    img_a = resize_image (a, out_dims, "pad");
    img_b = resize_image (b, out_dims, "pad");
    rc = [];
  else
    rc = get_output_spatial_ref (ra, rb);
    m = rc.ImageSize(1);
    n = rc.ImageSize(2);
    out_dims = [m, n, out_channels];
    img_a = resize_image_spatial (a, ra, rc, out_dims);
    img_b = resize_image_spatial (b, rb, rc, out_dims);
  endif
endfunction

function out_color_mode = get_out_color_mode (a, b, method)
  switch (method)
    case "falsecolor"
      out_color_mode = "gray";
    case "blend"
      out_color_mode = "same";
    case "checkerboard"
      out_color_mode = "same";
    case "diff"
      out_color_mode = "gray";
    case "montage"
      if (isrgb (a) || isrgb (b))
        out_color_mode = "same";
      else
        out_color_mode = "gray";
      endif
  endswitch
endfunction

function out_channels = get_out_channels (a, b, out_color_mode)
  switch (out_color_mode)
    case "gray"
      out_channels = 1;
    case "same"
      if (isrgb (a) || isrgb (b))
        out_channels = 3;
      else
        out_channels = 1;
      endif
  endswitch
endfunction

function img = resize_image_spatial (x, rx, rc, out_dims)
  img = zeros (out_dims);
  out_dims = get_spatial_output_dims (rx, rc, out_dims);
  [x_world, y_world] = intrinsicToWorld (rx, [1, rx.ImageSize(2)], ...
    [1, rx.ImageSize(1)]);
  [row_subs, col_subs] = worldToSubscript (rc, x_world, y_world);
  sub_img = resize_image (x, out_dims, "stretch");
  img(row_subs(1):row_subs(2), col_subs(1):col_subs(2), :) = sub_img;
endfunction

function out_dims = get_spatial_output_dims (rx, rc, out_dims)
   [x_world, y_world] = intrinsicToWorld (rx, [1, rx.ImageSize(2)], ...
    [1, rx.ImageSize(1)]);
  [row_subs, col_subs] = worldToSubscript (rc, x_world, y_world);
  out_dims = [row_subs(2) - row_subs(1) + 1, col_subs(2) - col_subs(1) + 1, ...
    out_dims(3)];
endfunction

function out_img = adjust_channels (in_img, out_color_mode, out_channels)
  switch (out_color_mode)
    case "gray"
      if (isrgb (in_img))
        out_img = rgb2gray (in_img);
      else
        out_img = in_img;
      endif
    case "same"
      if (out_channels == 3)
        out_img = to_rgb (in_img);
      else
        out_img = in_img;
      endif
  endswitch
endfunction

function out_img = resize_image (in_img, out_dims, resize_mode)
  switch (resize_mode)
    case "pad"
      out_img = resize (in_img, out_dims);
    case "stretch"
      out_img = imresize (in_img, out_dims(1:2));
  endswitch
endfunction

function [a_scaled, b_scaled] = apply_scaling (a, b, scaling)
  a_intensity_range = [];
  b_intensity_range = [];
  a_shift = 0;
  b_shift = 0;

  switch (scaling)
    case "joint"
      if (isrgb (a))
        max_a = max (a, [], 1);
        max_a = max (max_a, [], 2);
        min_a = min (a, [], 1);
        min_a = min (min_a, [], 2);
      endif
      if (isrgb (b))
        max_b = max (b, [], 1);
        max_b = max (max_b, [], 2);
        min_b = min (b, [], 1);
        min_b = min (min_b, [], 2);
      endif
      if (! (isrgb (a) && isrgb (b)))
        max_a = max (double (a(:)));
        max_b = max (double (b(:)));
        min_a = min (double (a(:)));
        min_b = min (double (b(:)));
      endif
      min_ab = min (min_a, min_b);
      max_ab = max (max_a, max_b);
      a_shift = min_ab;
      b_shift = min_ab;
      a_intensity_range = max_ab - min_ab;
      b_intensity_range = max_ab - min_ab;
    case "independent"
      a_elems = a(:);
      b_elems = b(:);
      a_shift = min (a_elems);
      b_shift = min (b_elems);
      a_intensity_range = max (a_elems) - min (a_elems);
      b_intensity_range = max (b_elems) - min (b_elems);
    case "none"
      if (isinteger (a))
        a_intensity_range = 255;
      endif
      if (isinteger (b))
        b_intensity_range = 255;
      endif
  endswitch
  a_scaled = scale_img (a, a_intensity_range, a_shift);
  b_scaled = scale_img (b, b_intensity_range, b_shift);
endfunction

function out_img = scale_img (in_img, intensity_range, color_shift)
  if (! isempty (intensity_range))
    if (intensity_range == 0)
      intensity_range = 1;
    endif
    out_img = (single (in_img) - single (color_shift)) ./ single (intensity_range);
  else
    out_img = in_img;
  endif
endfunction

%!error id=Octave:invalid-fun-call imfuse ()
%!error id=Octave:invalid-input-arg imfuse (1, 1, "xxx")
%!error id=Octave:invalid-input-arg imfuse (1, 1, "interpolation")
%!error id=Octave:invalid-input-arg imfuse (1, 1, "ColorChannels", [0 0 0])
%!error id=Octave:invalid-input-arg imfuse (1, 1, "ColorChannels", [1 1 1])
%!error id=Octave:invalid-input-arg imfuse (1, 1, "ColorChannels", [2 2 2])
%!error id=Octave:expected-less-equal imfuse (1, 1, "ColorChannels", [42 0 0])
%!error id=Octave:expected-greater-equal imfuse (1, 1, "ColorChannels", [-1 2 0])
%!error id=Octave:invalid-input-arg imfuse (1, 1, "ColorChannels", "deep-purple")

%!assert (imfuse (1, 2, "blend"), uint8 (0))
%!assert (imfuse (1, 2, "blend", "Scaling", "independent"), uint8 (0))
%!assert (imfuse (1, 2, "blend", "Scaling", "joint"), uint8 (128))
%!assert (imfuse (1, 2, "blend", "Scaling", "none"), uint8 (255))
%!assert (imfuse (1, 2, "falsecolor"), uint8 (zeros (1, 1, 3)))

%!test
%! a = [0 1 2];
%! b = [0 10 20];
%! expected = uint8 (repmat ([0 128 255], [1 1 3]));
%! assert (imfuse (a, b), expected);

%!test
%! a = uint8 ([0 1 2]);
%! b = uint8 ([0 10 20]);
%! expected = uint8 (repmat ([0 128 255], [1 1 3]));
%! assert (imfuse (a, b), expected);

%!test
%! a = uint8 ([0 1 2]);
%! b = uint8 ([0 10 20]);
%! expected = uint8 (repmat ([0 128 255], [1 1 3]));
%! assert (imfuse (a, b, "falsecolor"), expected);

%!test
%! a = logical([0 1 1]);
%! b = logical([0 1 1]);
%! expected = uint8 (repmat ([0 255 255], [1 1 3]));
%! assert (imfuse (a, b), expected);

%!test
%! a = logical([0 1 1]);
%! b = logical([0 1 1]);
%! expected = uint8 (repmat ([0 255 255], [1 1 3]));
%! assert (imfuse (a, b, "falsecolor"), expected);

%!test
%! a = [0 1 2];
%! b = [0 10 20];
%! expected = uint8 (repmat ([0 255 255], [1 1 3]));
%! assert (imfuse (a, b, "Scaling", "none"), expected);

%!test
%! a = uint8 ([0 1 2]);
%! b = uint8 ([0 10 20]);
%! expected = uint8 (zeros ([1, 3, 3]));
%! expected(:, :, 1) = [0 10 20];
%! expected(:, :, 2) = [0 1 2];
%! expected(:, :, 3) = [0 10 20];
%! assert (imfuse (a, b, "Scaling", "none"), expected);

%!test
%! a = [0 1 2];
%! b = uint8 ([0 10 20]);
%! expected = uint8 (zeros ([1, 3, 3]));
%! expected(:, :, 1) = [0 10 20];
%! expected(:, :, 2) = [0 255 255];
%! expected(:, :, 3) = [0 10 20];
%! assert (imfuse (a, b, "Scaling", "none"), expected);

%!test
%! a = uint8 ([0 1 2]);
%! b = [0 10 20];
%! expected = uint8 (zeros ([1, 3, 3]));
%! expected(:, :, 1) = [0 255 255];
%! expected(:, :, 2) = [0 1 2];
%! expected(:, :, 3) = [0 255 255];
%! assert (imfuse (a, b, "Scaling", "none"), expected);

%!test
%! a = [0 .1 2];
%! b = [0 .01 .02];
%! expected = uint8 (zeros ([1, 3, 3]));
%! expected(:, :, 1) = [0 3 5];
%! expected(:, :, 2) = [0 26 255];
%! expected(:, :, 3) = [0 3 5];
%! assert (imfuse (a, b, "Scaling", "none"), expected);

%!test
%! a = [0 1 2];
%! b = [0 10 20];
%! expected = uint8 (zeros ([1, 3, 3]));
%! expected(:, :, 1) = [0 128 255];
%! expected(:, :, 2) = [0 13 26];
%! expected(:, :, 3) = [0 128 255];
%! assert (imfuse (a, b, "Scaling", "joint"), expected);

%!test
%! a = uint8 ([0 1 2]);
%! b = [0 10 20];
%! expected = uint8 (zeros ([1, 3, 3]));
%! expected(:, :, 1) = [0 128 255];
%! expected(:, :, 2) = [0 13 26];
%! expected(:, :, 3) = [0 128 255];
%! assert (imfuse (a, b, "Scaling", "joint"), expected);

%!test
%! a = [0 150 300];
%! b = uint8 ([0 10 20]);
%! expected = uint8 (zeros ([1, 3, 3]));
%! expected(:, :, 1) = [0 9 17];
%! expected(:, :, 2) = [0 128 255];
%! expected(:, :, 3) = [0 9 17];
%! assert (imfuse (a, b, "Scaling", "joint"), expected);

%!test
%! a = uint8 ([0 1 2]);
%! b = uint8 ([0 10 20]);
%! expected = uint8 (zeros ([1, 3, 3]));
%! expected(:, :, 1) = [0 128 255];
%! expected(:, :, 2) = [0 13 26];
%! expected(:, :, 3) = [0 128 255];
%! assert (imfuse (a, b, "Scaling", "joint"), expected);

%!test
%! a = [0 1 2];
%! b = [0 10 20];
%! expected = uint8 (zeros ([1, 3, 3]));
%! expected(:, :, 1) = [0 0 0];
%! expected(:, :, 2) = [0 128 255];
%! expected(:, :, 3) = [0 13 26];
%! assert (imfuse (a, b, "Scaling", "joint", "ColorChannels", [0 2 1]), expected);

%!test
%! a = [0 1 2];
%! b = [0 10 15];
%! c = imfuse (a, b, "ColorChannels", "red-cyan");
%! expected = uint8 (zeros (1, 3, 3));
%! expected(:, :, 1) = [0 128 255];
%! expected(:, :, 2) = [0 170 255];
%! expected(:, :, 3) = [0 170 255];
%! assert (c, expected);

%!test
%! a = [0 1 2];
%! b = [0 10 15];
%! c = imfuse (a, b, "ColorChannels", "green-magenta");
%! expected = uint8 (zeros (1, 3, 3));
%! expected(:, :, 1) = [0 170 255];
%! expected(:, :, 2) = [0 128 255];
%! expected(:, :, 3) = [0 170 255];
%! assert (c, expected);

%!test
%! a = [0 5 2];
%! b = [0 10 20];
%! assert (imfuse (a, b, "diff"), uint8 ([0 213 255]));

%!test
%! a = [0 5 2];
%! b = [0 10 20];
%! assert (imfuse (a, b, "diff", "Scaling", "joint"), uint8 ([0 71 255]));

%!test
%! a = [0 5 2];
%! b = [0 10 20];
%! assert (imfuse (a, b, "blend"), uint8 ([0 192 179]));

%!test
%! a = magic (5);
%! b = a';
%! c = imfuse (a, b, "falsecolor");
%! expected = zeros (5, 5, 3);
%! expected(:, :, 1) = [
%!        170  234   32   96  106
%!        244   43   53  117  181
%!          0   64  128  191  255
%!         74  138  202  213   11
%!        149  159  223   21   85];
%! expected(:, :, 2) = [
%!        170  244    0   74  149
%!        234   43   64  138  159
%!         32   53  128  202  223
%!         96  117  191  213   21
%!        106  181  255   11   85];
%! expected(:, :, 3) = [
%!        170  234   32   96  106
%!        244   43   53  117  181
%!          0   64  128  191  255
%!         74  138  202  213   11
%!        149  159  223   21   85];
%! assert (c, uint8 (expected));

%!test
%! a = magic (5);
%! b = a';
%! assert (imfuse (uint8 (a), uint8 (b), "blend", "Scaling", "none"),
%! uint8 ([17  24   3   9  13
%!         24   5   7  13  17
%!          3   7  13  20  24
%!          9  13  20  21   3
%!         13  17  24   3   9]));

%!test
%! a = magic (5);
%! b = 2 * a';
%! assert (imfuse (a, b, "blend", "Scaling", "independent"),
%! uint8 ([170  239   16   85  128
%!         239   43   59  128  170
%!          16   59  128  197  239
%!          85  128  197  213   16
%!         128  170  239   16   85]));

%!test
%! a = magic (5);
%! b = 2 * a';
%! assert (imfuse (a, b, "blend", "Scaling", "joint"),
%! uint8 ([128  177   18   68   91
%!         180   34   44   94  130
%!          11   47   96  146  182
%!          63   99  149  159   13
%!         102  125  175   16   65]));

%!test
%! a = [0 1.2 5];
%! b = [5 6.13 12];
%! assert (imfuse (a, b, "blend"), uint8 ([0 51 255]));

%!test
%! a = [0 5 2];
%! b = [0 10 20];
%! assert (imfuse (a, b, "blend", "Scaling", "joint"), uint8 ([0 96 141]));

%!test
%! a = [0 5 2];
%! b = [0 10 20];
%! assert (imfuse (a, b, "montage"), uint8 ([0 255 102 0 128 255]));

%!test
%! a = zeros (1, 100);
%! b = 2 * ones (1, 100);
%! assert (imfuse (a, b, "montage"), uint8 ([zeros(1, 200)]));
%! assert (imfuse (a, b, "montage", "Scaling", "none"),
%!   uint8 ([zeros(1, 100), 255 * ones(1, 100)]));

%!test
%! a = zeros (1, 100, 3);
%! b = 2 * ones (1, 100);
%! assert (imfuse (a, b, "montage"), uint8 ([zeros(1, 200, 3)]));

%!test
%! a = 0.1 * ones (50, 50);
%! b = 0.2 * ones (50, 50);
%! c = imfuse (a, b, "checkerboard", "Scaling", "none");
%! d = imresize (repmat([26, 51; 51, 26], [8, 8]), [50, 50], "nearest");
%! assert (all (c(:) == d(:)));

%!test
%! a = zeros (2, 2);
%! b = zeros (2, 2);
%! ra = imref2d (size (a), [0, 2], [0, 2]);
%! rb = imref2d (size (b), [0, 2], [2, 4]);
%! [c, rc] = imfuse (a, ra, b, rb, "falsecolor");
%! assert (rc.ImageSize, [4, 2]);
%! assert (rc.XWorldLimits, [0, 2]);
%! assert (rc.YWorldLimits, [0, 4]);
%! assert (rc.PixelExtentInWorldX, 1);
%! assert (rc.PixelExtentInWorldY, 1);
%! assert (rc.ImageExtentInWorldX, 2);
%! assert (rc.ImageExtentInWorldY, 4);
%! assert (rc.XIntrinsicLimits, [0.5, 2.5]);
%! assert (rc.YIntrinsicLimits, [0.5, 4.5]);
%! assert (c, uint8 (zeros (4, 2, 3)));

%!xtest
%! a = zeros (5, 3);
%! b = ones (6, 5);
%! ra = imref2d (size (a), [15, 30], [2, 4]);
%! rb = imref2d (size (b), [10, 50], [5.5, 6.7]);
%! [c, rc] = imfuse (a, ra, b, rb, "falsecolor");
%! assert (rc.ImageSize, [24, 8]);
%! assert (rc.XWorldLimits, [10, 50]);
%! assert (rc.YWorldLimits, [2, 6.7]);
%! assert (rc.PixelExtentInWorldX, 5);
%! assert (rc.PixelExtentInWorldY, 0.19583333, 10e-9);
%! assert (rc.ImageExtentInWorldX, 40);
%! assert (rc.ImageExtentInWorldY, 4.7);
%! assert (rc.XIntrinsicLimits, [0.5, 8.5]);
%! assert (rc.YIntrinsicLimits, [0.5, 24.5]);
%! expected = uint8 (zeros (24, 8, 3));
%! expected(19:23, 2:7, 1) = 255 * ones (5, 6);
%! expected(19:23, 2:7, 3) = 255 * ones (5, 6);
%! assert (c, expected);

%!test
%! a = uint8 (reshape (1:1:9, [1 3 3]));
%! b = uint8 (reshape (10:2:26, [1 3 3]));
%! c = imfuse (a, b);
%! expected = uint8 (zeros (1, 3, 3));
%! expected(:, :, 1) = [0 128 255];
%! expected(:, :, 2) = [0 128 255];
%! expected(:, :, 3) = [0 128 255];
%! assert (c, expected);

%!test
%! a = uint8 (reshape (1:1:9, [1 3 3]));
%! b = uint8 (reshape (10:2:26, [1 3 3]));
%! c = imfuse (a, b, "Scaling", "independent");
%! expected = uint8 (zeros (1, 3, 3));
%! expected(:, :, 1) = [0 128 255];
%! expected(:, :, 2) = [0 128 255];
%! expected(:, :, 3) = [0 128 255];
%! assert (c, expected);

%!test
%! a = uint8 (reshape (1:1:9, [1 3 3]));
%! b = uint8 (reshape (10:2:26, [1 3 3]));
%! c = imfuse (a, b, "Scaling", "joint");
%! expected = uint8 (zeros (1, 3, 3));
%! expected(:, :, 1) = [191 223 255];
%! expected(:, :, 2) = [0 16 32];
%! expected(:, :, 3) = [191 223 255];
%! assert (c, expected);

%!test
%! a = uint8 (reshape (1:1:9, [1 3 3]));
%! b = uint8 (reshape (10:2:26, [1 3 3]));
%! c = imfuse (a, b, "Scaling", "none");
%! expected = uint8 (zeros (1, 3, 3));
%! expected(:, :, 1) = [15 17 19];
%! expected(:, :, 2) = [3 4 5];
%! expected(:, :, 3) = [15 17 19];
%! assert (c, expected);

%!xtest
%! a = zeros (5, 3);
%! b = ones (5, 3);
%! ra = imref2d (size (a), [10, 20], [30, 40]);
%! rb = imref2d (size (b), [10, 20], [30, 40]);
%! [c, rc] = imfuse (a, ra, b, rb, "falsecolor");
%! expected = uint8 (zeros (5, 3, 3));
%! expected(:, 1:2, 1) = 255 * ones (5, 2);
%! expected(:, 1:2, 3) = 255 * ones (5, 2);
%! assert (rc.ImageSize, [5, 3]);
%! assert (rc.XWorldLimits, [10, 20]);
%! assert (rc.YWorldLimits, [30, 40]);
%! assert (rc.PixelExtentInWorldX, 3.33333333, 10e-9);
%! assert (rc.PixelExtentInWorldY, 2);
%! assert (rc.ImageExtentInWorldX, 10);
%! assert (rc.ImageExtentInWorldY, 10);
%! assert (rc.XIntrinsicLimits, [0.5, 3.5]);
%! assert (rc.YIntrinsicLimits, [0.5, 5.5]);
%! assert (c, expected);

%!test
%! a = zeros (5, 5);
%! b = ones (5, 5);
%! ra = imref2d (size (a), [10, 20], [30, 40]);
%! rb = imref2d (size (b), [10, 20], [30, 40]);
%! [c, rc] = imfuse (a, ra, b, rb, "falsecolor");
%! expected = uint8 (zeros (5, 5, 3));
%! assert (rc.ImageSize, [5, 5]);
%! assert (rc.XWorldLimits, [10, 20]);
%! assert (rc.YWorldLimits, [30, 40]);
%! assert (rc.PixelExtentInWorldX, 2);
%! assert (rc.PixelExtentInWorldY, 2);
%! assert (rc.ImageExtentInWorldX, 10);
%! assert (rc.ImageExtentInWorldY, 10);
%! assert (rc.XIntrinsicLimits, [0.5, 5.5]);
%! assert (rc.YIntrinsicLimits, [0.5, 5.5]);
%! assert (c, expected);

%!test
%! a = magic (5);
%! b = ones (5, 5);
%! ra = imref2d (size (a), [10, 20], [30, 40]);
%! rb = imref2d (size (b), [10, 20], [30, 40]);
%! [c, rc] = imfuse (a, ra, b, rb, "falsecolor", "Scaling", "independent");
%! expected = uint8 (zeros (5, 5, 3));
%! expected(:, :, 2) = [
%!        170  244    0   74  149
%!        234   43   64  138  159
%!         32   53  128  202  223
%!         96  117  191  213   21
%!        106  181  255   11   85];
%! assert (rc.ImageSize, [5, 5]);
%! assert (rc.XWorldLimits, [10, 20]);
%! assert (rc.YWorldLimits, [30, 40]);
%! assert (rc.PixelExtentInWorldX, 2);
%! assert (rc.PixelExtentInWorldY, 2);
%! assert (rc.ImageExtentInWorldX, 10);
%! assert (rc.ImageExtentInWorldY, 10);
%! assert (rc.XIntrinsicLimits, [0.5, 5.5]);
%! assert (rc.YIntrinsicLimits, [0.5, 5.5]);
%! assert (c, expected);
