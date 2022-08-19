## Copyright (C) 2014-2019 Olaf Till <i7tiol@t-online.de>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## undocumented internal function

function parallel_local = __optimget_parallel_local__ (settings, default)

  min_version = "3.0.4";

  if ((parallel_local = optimget (settings, "parallel_local", default)))

    if (! exist ("__parallel_package_version__", "file") ||
        compare_versions (__parallel_package_version__ (),
                          min_version, "<"))

      parallel_local = false;

      warning ("optim:parallel_local",
               "option 'parallel_local=true' ignored, since no loaded parallel package of at least version %s found",
               min_version);

    endif

  endif

endfunction
