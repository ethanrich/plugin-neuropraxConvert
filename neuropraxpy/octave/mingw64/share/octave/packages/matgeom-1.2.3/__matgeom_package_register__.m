## Copyright (C) 2016 Carnë Draug
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation; either version 3 of the
## License, or (at your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see
## <http:##www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {} {} __matgeom_package_register__ ()
## Undocumented internal function of matgeom package.
## @end deftypefn

## PKG_ADD: __matgeom_package_register__ (1);
## PKG_DEL: __matgeom_package_register__ (-1);

function subdir_paths = __matgeom_package_register__ (loading = 0)

  subdirlist = {"utils", "geom2d", "polygons2d", "graphs",...
                "geom3d","meshes3d","polynomialCurves2d"};
  ## Get full path, with luck we can retreive the package name from here
  base_pkg_path = fileparts (make_absolute_filename (mfilename ("fullpath")));

  subdir_paths = fullfile (base_pkg_path, subdirlist);

  if (loading > 0)

    ## Disable dummy verLessThan.m
    if compare_versions (version, '6.0.0', '>=')
      ## Check if this package still has varLessThan
      pkgverchecker = fullfile (base_pkg_path, 'verLessThan.');
      if exist ([pkgverchecker, 'm'], 'file')
        warning ('Octave:deprecated-function', 
            'Permanently renaming verLessThan.m since it is already present');
        ## The change is permanent and done only once
        ## Means that if testing in older version of Octave, needs re-install
        rename([pkgverchecker, 'm'], [pkgverchecker, 'deprecated']);
      endif
    endif

    addpath (subdir_paths{:});

  elseif (loading < 0)
    rmpath (subdir_paths{:});
  endif

endfunction
