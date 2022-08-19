## Copyright (C) 2022 Philip Nienhuis
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
## along with this program.  If not, see <https://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {} {@var{retval} =} almanac ()
## @deftypefnx {} {@var{retval} =} almanac (@var{body})
## @deftypefnx {} {@var{retval} =} almanac (@var{body}, @var{param})
## @deftypefnx {} {@var{retval} =} almanac (@var{body}, @var{param}, @var{unit})
## Return basic info about one parameter of a celestial body.
##
## The celestial bodies and parameters that almanac can return are shown when
## invoking almanac without any parameters.
##
## Input parameters:
##
## @itemize
## @item @var{body} - celestial body for which info is requested
## (case-insensitive).
##
## @item @var{param} (optional) - the selected parameter whose value is
## requested.  If 'geoid' or 'ellipsoid' is specified a 1x2 vector comprising
## the semimajor axis and eccentricity of @var{body} is returned.  If 'Earth'
## is selected, a specific geoid name can be specified and the semimajor
## axis and eccentricity of that geoid are returned.
##
## @item @var{unit} (optional) - the unit in which the requested parameter is
## expressed.  Any unit recognized by function 'unitsratio' is accepted.
## @end itemize
##
## almamanc is merely a wrapper around, resp. based on, referenceEllipsoid.
##
## @seealso{referenceEllipsoid,referenceSphere,unitsratio}
## @end deftypefn

function retval = almanac (varargin)

  persistent a geoids;
  outerbodies = {"Sun", "Mercury", "Venus", "Moon", "Mars", "Jupiter", ...
                 "Saturn", "Neptune", "Uranus", "Pluto", "Unit Sphere"};
  unit = "meter";
  if (isempty (a) || isempty (geoids))
    a = referenceEllipsoid (0);
    geoids = setdiff (a(:, 3), [outerbodies {"Earth"}])';
  endif

  if (nargin == 0)
    ## Return info on celestial bodies
    if (nargout == 0)
      printf (["Implemented celestial bodies:\nSun\nMercury\nVenus\n", ...
               "Earth\nMoon\nMars\n\Jupiter\nSaturn\nNeptune\nUranus\n", ...
               "Pluto\nUnit Sphere\n"]);
    else
      retval = [outerbodies(1:3) {"Earth"} outerbodies(4:end)];
    endif

  elseif (nargin > 0 && ! iscellstr (varargin))
    error ("almanac: all input args should be text strings.");

  elseif (nargin == 1)
    ## Return info on parameters of a specific celestial body
    if (strcmpi (varargin{1}, 'earth'))
      printf ("Parameters for Earth:\n   ", varargin{1});
      printf (["radius, geoid, volume, surfacearea, or one of geoids ", ...
               "listed below.\nUnits:\n   degrees (deg), kilometers ", ... 
               "(km), nautical miles (nm), radians (rad) or statute ", ...
               "miles (sm)\nReference bodies:\n   sphere, geoid or actual\n"]);
      idx = find (! ismember (a(:, 3), [outerbodies {"Earth"}]));
      printf ("Available geoids:\n   %s\n", ...
       strjoin (cellfun (@(x) sprintf ("'%s'", x), a(idx, 3), "uni", 0), ", "));
    elseif (ismember (varargin{1}, lower (outerbodies)))
      printf ("Parameters for %s:\n   ", varargin{1});
      printf (["radius, geoid, volume or surfacearea.\nUnits:\n   degrees ", ...
               "(deg), kilometers (km), nauticalmiles (nm), radians (rad) ", ...
               "or statutemiles (sm)\nReference bodies:\n   sphere, geoid ", ... 
               "or actual\n"]);
    else
      error ("almanac: unknown celestial body.");
    end
    if (nargout > 0)
      retval = [];
    endif

  elseif (nargin >= 2)
    ## Return info on a specific celestial body with units
    param = varargin{2};
    if (nargin > 2)
      unit = varargin{3};
    endif
    idx = find (strncmpi (param, geoids, numel (param)));
    if (! isempty (idx))
      b = referenceEllipsoid (geoids{idx(1)}, unit);
      retval = [b.SemimajorAxis, b.Eccentricity];
    else
      b = referenceEllipsoid (varargin{1}, unit);
      switch lower (param)
        case "radius"
          retval = b.MeanRadius;
        case "volume"
          retval = b.Volume;
        case {"surfarea", "surfacearea"}
          retval = b.SurfaceArea;
        case {"geoid", "ellipsoid"}
          retval = [b.SemimajorAxis, b.Eccentricity];
        otherwise
          error ("almanac: unknown parameter requested - %s", param);
      endswitch
    endif

  endif

endfunction


%!test
%! assert (strcmpi (almanac (){1}, "Sun"), true);
%! assert (strcmpi (almanac (){12}, "Unit Sphere"), true);

%!test
%! assert (almanac ("sun", "radius", "sm"), 432285.77700111, 1e-6);

%!test
%! assert (almanac ("earth", "everest", "nm"), [3443.456768421318, 0.0814729809], 1e-9);

%!test
%! assert (almanac  ("jupiter", "ellipsoid", "km"), [71492.0   0.3543164], 1e-7);

%!error <unknown> almanac ("UFO")
%!error <all input args> almanac ("Moon", 12)
%!error <unknown parameter> almanac ("Mars", "flattening")

