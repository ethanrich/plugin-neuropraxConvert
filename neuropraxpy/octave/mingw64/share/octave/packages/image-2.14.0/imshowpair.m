## Copyright (C) 2021 Martin Janda <janda.martin1@gmail.com>
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
## @deftypefn {} {@var{c} =} imshowpair (@var{a}, @var{b})
## @deftypefnx {} {[@var{c}, @var{rc}] =} imshowpair (@var{a}, @var{ra}, @var{b}, @var{rb})
## @deftypefnx {} {@var{c} =} imshowpair (@dots{}, @var{method})
## @deftypefnx {} {@var{c} =} imshowpair (@dots{}, @var{name}, @var{value})
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
## @seealso{imfuse}
## @end deftypefn

function img = imshowpair (varargin)
  if (nargin < 2)
    print_usage ();
  endif

  [a, b, ra, rb, method, scaling, color_channels, parent] = parse_varargin(varargin{:});
  if (isempty (ra) || isempty (rb))
    c = imfuse (a, b, method, "ColorChannels", color_channels, "Scaling", scaling);
  else
    [c, rc] = imfuse (a, ra, b, rb, method, "ColorChannels", color_channels, "Scaling", scaling);
  endif
  img = imshow (c);
  if (! isempty (parent))
    set (img, "parent", parent);
  endif
endfunction

function [a, b, ra, rb, method, scaling, color_channels, parent] = parse_varargin(varargin)
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

    validateattributes (varargin{2}, {"imref2d"}, {}, "imshowpair", "RA");
    check_is_image (varargin{3}, "B");
    validateattributes (varargin{4}, {"imref2d"}, {}, "imshowpair", "RB");

    ra = varargin{2};
    b = varargin{3};
    rb = varargin{4};
    varargin(1:4) = [];
  endif

  method_names = {"falsecolor", "blend", "checkerboard", "diff", "montage" ...
      "interpolation"};
  scaling_names = {"independent", "joint", "none"};
  scaling = scaling_names{1};
  method = [];
  parent = [];

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
        msg =  "expected NAME, VALUE pairs or incorrect display method";
        error ("Octave:invalid-input-arg", ["imshowpair: ", msg]);
      endif
      validateattributes (varargin{1}, {"char"}, {"nonempty"}, "imshowpair", "NAME");
      validateattributes (varargin{2}, {}, {"nonempty"}, "imshowpair", "VALUE");
      name = varargin{1};
      value = varargin{2};

      switch (lower (name))
        case "scaling"
          if (! is_valid_scaling (value, scaling_names))
            msg = "SCALING expected to be one of 'independent', 'joint', 'none'";
            error ("Octave:invalid-input-arg", ["imshowpair: ", msg]);
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
                msg = "expected COLORCHANNELS to be one of 'green-magenta', 'red-cyan'";
                error ("Octave:invalid-input-arg", ["imshowpair: ", msg]);
            endswitch
          else
            validateattributes (value, {"numeric"}, ...
            {"integer", "vector", "numel", 3, ">=", 0, "<=", 2}, ...
            "imshowpair", "COLORCHANNELS")
            if (! is_valid_channels (value))
              error ("Octave:invalid-input-arg", ...
                  "imshowpair: COLORCHANNELS must include values 1 and 2");
            endif
            color_channels = value;
          endif
        case "parent"
          parent = value;
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

%!error id=Octave:invalid-fun-call imshowpair ()
%!error id=Octave:invalid-fun-call imshowpair (1)
%!error id=Octave:invalid-input-arg imshowpair (uint8 (200.*rand (100)), ...
%!    uint8 (200.*rand (100)), "interpolation")
%!error id=Octave:invalid-input-arg imshowpair (uint8 (200.*rand (100)), ...
%!    uint8 (200.*rand (100)), "xxxxx")
%!error id=Octave:invalid-input-arg imshowpair (1, 1, "ColorChannels", [0 0 0])
%!error id=Octave:invalid-input-arg imshowpair (1, 1, "ColorChannels", [1 1 1])
%!error id=Octave:invalid-input-arg imshowpair (1, 1, "ColorChannels", [2 2 2])
%!error id=Octave:expected-less-equal imshowpair (1, 1, "ColorChannels", [42 0 0])
%!error id=Octave:expected-greater-equal imshowpair (1, 1, "ColorChannels", [-1 2 0])
%!error id=Octave:invalid-input-arg imshowpair (1, 1, "ColorChannels", "deep-purple")
%!test
%! A = uint8 (200.*rand (100));
%! B = uint8 (150.*rand (100));
%! RA = imref2d (size (A), 0.5, 0.5);
%! RB = imref2d (size (B), 0.5, 0.5);
%! figure;
%! Ax=axes;
%! assert (imshowpair (A, B));
%! assert (imshowpair (A, RA, B, RB));
%! assert (imshowpair (A, B, "blend"));
%! assert (imshowpair (A, B, "falsecolor", "ColorChannels", "red-cyan"));
%! assert (imshowpair (A, B, "Parent", Ax));
%! assert (imshowpair (A, B, "montage", "Scaling", "joint"));
%! close;
