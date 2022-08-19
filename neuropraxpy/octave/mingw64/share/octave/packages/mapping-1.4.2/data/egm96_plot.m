## Copyright (C) 2020-2022 Philip Nienhuis
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

##==============================================================================
## Script to produce the base grid:

fid = fopen ("WW15MGH.GRD", "r");
egm96 = textscan (fid, "%f", "headerlines", 2, "whitespace", "", ...
                 "delimiter", " \n", "multipledelimsasone", 1);
fclose (fid);
egm96 = single (reshape (egm96{1}, 1441, [])');
save -v6 egm96geoid.mat egm96

##==============================================================================
## Script to produce egm96geoid.png:

if (! exist ("egm96") == 5)
  load egm96geoid;
endif
contourf (flipud (egm96));
colorbar ();

set (gca, "xtick", [0.5:80:1441]);
xtl = get (gca, "xticklabel");
xtl = cellfun (@(x) sprintf("%d", int32 (str2double (x)) / 4), xtl, "uni", 0);
set (gca, "xticklabel", xtl, "fontsize", 8);

set (gca, "ytick", [40.5:80:721]);
ytl = get (gca, "yticklabel");
ytl = cellfun (@(x) sprintf("%d", int32 (str2double (x) / 4 - 90)), ytl, "uni", 0);
set (gca, "yticklabel", ytl, "fontsize", 8);

axis equal;
grid on;
xlabel ("Longitude");
ylabel ("Latitude");
title ("EGM96 geoid height in m (15' x 15'grid)");

print ("egm96geoid.png");


