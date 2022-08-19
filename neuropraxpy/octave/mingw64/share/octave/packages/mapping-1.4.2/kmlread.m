## Copyright (C) 2018-2022 Philip Nienhuis
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
## @deftypefn {} {@var{kml} =} kmlread (@var{fname})
## (EXPERIMENTAL) Read a Google kml file and return its contents in a struct.
##
## @var{name} is the name of a .kml file.
## Currently kmlread can read Point, LineString, Polygon, Track and Multitrack
## entries.
##
## @var{kml} is a struct with fields Type, Lat, Lon, Ele, Time and Name.  If
## the .kml file contained LineStrings and/or Polygons also field BoundingBox
## is present containing suitable values for the relevant items.
##
## @seealso{kmzread}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2018-05-03

function outp = kmlread (fname)

  fid = fopen (fname, "r");
  if (fid > 0)
    xml = fread (fid, Inf, "*char")';
    fclose (fid);
  else
    error ("kmlread: couldn't read %s", fname);
  endif

  outp = repmat (struct ("Type", "-", ...
                         "Lat",  [],  ...
                         "Lon",  [],  ...
                         "Ele",  [],  ...
                         "Time", [],  ...
                         "Name", "-"), 0, 1);

  ## Points
  is = 1;
  ipt = 0;
  while (is > 0)
    [pnt, il, is] = getxmlnode (xml, "Point", is, 1);
    if (is > 0)
      outp(end+1).Type = "Point";
      ++ipt;
      pnam = regexp (xml(max (1, il - 1000):il+7), ...
                     '<Placemark.*?>.*?<name>(.+?)</name>.*?<Point', "tokens");
      if (! isempty (pnam))
        pname = cell2mat (pnam){end};
        outp(end).Name = pname;
      else
        outp(end).Name = ["Point #" num2str(ipt)];
      endif
      coords = strrep (getxmlnode (pnt, "coordinates", 1, 1), ",", " ");
      xyz = sscanf (coords, "%f", Inf);
      outp(end).Lon = xyz(1);
      outp(end).Lat = xyz(2);
      if (numel (xyz) == 3)
        outp(end).Ele = xyz(3);
      endif
    endif
  endwhile

  ## Linestrings / Polylines
  is = 1;
  iln = 0;
  while (is > 0)
    [lin, il, is] = getxmlnode (xml, "LineString", is, 1);
    if (is > 0)
      outp(end+1).Type = "Line";
      ++iln;
      lnam = regexp (xml(max (1, il - 1000):il+12), ...
                     '<Placemark.*?>.*?<name>(.+?)</name>.*?<LineString', "tokens");
      if (! isempty (lnam))
        lnam = cell2mat (lnam){end};
        outp(end).Name = lnam;
      else
        outp(end).Name = ["Line #" num2str(iln)];
      endif
      coords = getxmlnode (lin, "coordinates", 1, 1);
      ## Check if we have Ele (Z). Coordinate tuples are separated by spaces
      lines = strsplit (strtrim (coords), {" ", "\n"});
      nd = numel (strfind (lines{1}, ",")) + 1;
      xyz = reshape (sscanf (strrep (coords, ",", " "), "%f", Inf)', nd, [])';
      outp(end).Lon = xyz(:, 1);
      outp(end).Lat = xyz(:, 2);
      outp(end).BoundingBox = [min(outp(end).Lon), max(outp(end).Lon); ...
                               min(outp(end).Lat), max(outp(end).Lat)];
      if (nd > 2)
        outp(end).Ele = xyz(:, 3);
        outp(end).BoundingBox = [outp(end).BoundingBox;
                                  min(outp(end).Ele), max(outp(end).Ele)];
      else
        outp(end).BoundingBox = [outp(end).BoundingBox;
                                 NaN, NaN];
      endif
    endif
  endwhile

  ## Polygons
  is = 1;
  ip = 0;
  while (is > 0)
    [pol, il, is] = getxmlnode (xml, "Polygon", is, 1);
    if (is > 0)
      outp(end+1).Type = "Polygon";
      ++ip;
      pnam = regexp (xml(max (1, il - 1000):il+12), ...
                     '<Placemark.*?>.*?<name>(.+?)</name>.*?<Polygon', "tokens");
      if (! isempty (pnam))
        pnam = cell2mat (pnam){end};
        outp(end).Name = pnam;
      else
        outp(end).Name = ["Polygon #" num2str (ip)];
      endif
      ir = 1;
      ## First get outer ring
      [ring, ~, ir] = getxmlnode (pol, "outerBoundaryIs", ir);
      coords = strrep (getxmlnode (ring, "coordinates", 1, 1), ",", " ");
      xyz = reshape (sscanf (coords, "%f", Inf)', 3, [])';
      ## FIXME check on CCW
      outp(end).Lon = xyz(:, 1);
      outp(end).Lat = xyz(:, 2);
      outp(end).Ele = xyz(:, 3);
      ## Next, any inner rings
      while (ir > 0)
        [ring, ~, ir] = getxmlnode (pol, "innerBoundaryIs", ir);
        if (ir > 0)
          coords = strrep (getxmlnode (ring, "coordinates", 1, 1), ",", " ");
          xyz = reshape (sscanf (coords, "%f", Inf)', 3, [])';
          ## FIXME check on CW
          outp(end).Lon = [outp(end).Lon; NaN; xyz(:, 1)];
          outp(end).Lat = [outp(end).Lat; NaN; xyz(:, 2)];
          outp(end).Ele = [outp(end).Ele; NaN; xyz(:, 3)];
        endif
      endwhile
      outp(end).BoundingBox = [min(outp(end).Lon), max(outp(end).Lon); ...
                               min(outp(end).Lat), max(outp(end).Lat); ...
                               min(outp(end).Ele), max(outp(end).Ele)];
    endif
  endwhile

  ## Tracks and MultiTracks
  ptrnT = '<when>(.*?)</when>';
  is = em = 1;
  it = 0;
  while (is > 0)
    if (em <= is)
      ## Try to get extent of multiTrack node
      [mtrk, ~, em] = getxmlnode (xml, "gx:MultiTrack", is, 1);
      if (em > 0)
        ## Get specific attributes for this Multitrack
        mtid = getxmlattv (mtrk, "id");
        intpm = str2double (getxmlnode (mtrk, "gx:interpolate", 10, 1));
        ## MultiTrack; start new struct item for next tracks
        outp(end+1).Type = "Track";
        ++it;
        if (isempty (mtid))
          outp(end).Name = ["Track #" num2str(it)];
        else
          outp(end).Name = mtid;
        endif
      endif
    endif

    [trk, ~, is] = getxmlnode (xml, "gx:Track", is, 1);
    if (is > 0)
      if (! em)
        ## Separate track; start new struct item
        outp(end+1).Type = "Track";
        ++it;
        tnam = getxmlattv (trk, "id");
        if (isempty (tnam))
          outp(end).Name = ["Track #" num2str(it)];
        else
          outp(end) = tnam;
        endif
        outp(end).BoundingBox = [min(outp(end).Lon), max(outp(end).Lon); ...
                                 min(outp(end).Lat), max(outp(end).Lat); ...
                                 min(outp(end).Ele), max(outp(end).Ele)];
      endif
      times = cell2mat (regexp (trk, ptrnT, "tokens"));
      ltime = cellfun ("numel", times);
      if (any (ltime < 20))
        ## Year resolution
        times(ltime == 4) = ...
         cellfun (@(x) [x "-00-00T00:00:00Z"], times(ltime == 4), "uni", 0);
        ## Month resolution
        times(ltime == 7) = ...
         cellfun (@(x) [x "-00T00:00:00Z"], times(ltime == 7), "uni", 0);
        ## Day resolution
        times(ltime == 10) = ...
         cellfun (@(x) [x "T00:00:00Z"], times(ltime == 10), "uni", 0);
      endif
      times = datenum (times, "yyyy-mm-ddTHH:MM:SSZ");
      ptrnP = '<gx:coord>(.+?) (.+?) (.+?)</gx:coord>';
      xyz = reshape (str2double (cell2mat (regexp (trk, ptrnP, "tokens"))), 3, [])';
      if (isempty (outp(end).Lat))
        outp(end).Lon = xyz(:, 1);
        outp(end).Lat = xyz(:, 2);
        outp(end).Ele = xyz(:, 3);
        if (! isempty (times))
          outp(end).Time = times;
        endif
      elseif (intpm)
        outp(end).Lon = [outp(end).Lon; xyz(:, 1)];
        outp(end).Lat = [outp(end).Lat; xyz(:, 2)];
        outp(end).Ele = [outp(end).Ele; xyz(:, 3)];
        if (! isempty (times))
          outp(end).Time = [outp(end).Time; times];
        endif
      else
        outp(end).Lon = [outp(end).Lon; NaN; xyz(:, 1)];
        outp(end).Lat = [outp(end).Lat; NaN; xyz(:, 2)];
        outp(end).Ele = [outp(end).Ele; NaN; xyz(:, 3)];
        if (! isempty (times))
          outp(end).Time = [outp(end).Time; NaN; times];
        endif
      endif
      outp(end).BoundingBox = [min(outp(end).Lon), max(outp(end).Lon); ...
                               min(outp(end).Lat), max(outp(end).Lat); ...
                               min(outp(end).Ele), max(outp(end).Ele)];
    endif

  endwhile

endfunction
