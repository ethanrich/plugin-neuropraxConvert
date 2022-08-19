## Copyright (C) 2018-2022 Philip Nienhuis
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {} {@var{out} =} gpxread (@var{fname})
## @deftypefnx {} {@var{out} =} gpxread (@var{fname}, @dots{})
## Read data from a gpx file.
##
## Input argument @var{fname} (a character string) can be a valid file
## name or a valid URL (the latter experimental).
##
## If no other input arguments are given gpxread will read all data in
## @var{fname} into one output struct @var{out}.  The data to be read can
## be selected and/or limited by specifying one or more of the following
## optional property/value pairs (all case-insensitive):
##
## @itemize
## @item "FeatureType'
## This option (a mere "f" suffices) can be one of:
## @table @asis
## @item
## "WayPoint or simply "w": Read waypoints.
## @end item
##
## @item
## "Track" or "t": read tracks.
## @end item
##
## @item
## "Route" or "t": read routes.
## @end item
##
## @item
## "Auto" or "a" (default value): read all data.
## @end item
## @end table
##
## Multiple FeatureType property/value pairs can be specified.
## @end item
##
## @item "Index"
## The ensuing Index value should be a numeric value, or numeric vector,
## of indices of the features to be read.  Works currently only for waypoints.
## @end item
## @end itemize
##
## Output argument @var{out} is a struct array with field names Name,
## Lat, Lon, Ele, Time, and -in case of routes- Names.  "Name" refers
## to the name of the waypoints, tracks or routes that have been read.
## "Lat", "Lon" and "Ele" refer to the latitude, longitude and (if present
## in the file) elevation of the various features, in case of tracks field
## "Time" refers to the time of the trackpoint (again, if present in the
## file).  In case of tracks and routes these are vectors, each element
## corresponding to one track point.  For each individual track multiple
## track segments are separated by NaNs.  For routes the field "Names"
## contains a cell array holding the names of the individual route points.
##  "Time" fields for waypoints are ignored.
##
## Examples:
##
## @example
##   A = gpxread ("trip2.gpx", "feature", "track", "index", 2);
##   (which returns data from the second track in file "trip1.gpx")
## @end example
##
## @example
##   B = gpxread ("trip2.gpx", "f", "t", "f", "r");
##   (which returns track and route data from file "trip2.gpx")
## @end example
##
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2017-02-05

function [outp] = gpxread (fname, varargin)

  ## Input validation
  if (nargin < 1)
    print_usage ();
  elseif (! ischar (fname))
    error ("gpread: file name expected for arg 1\n");
  elseif (! isempty (cell2mat (cell2mat ...
           (regexp (fname, '(ftp://|http://|file://)', "tokens")))))
    url = true;
  else
    [pth, fnm, ext] = fileparts (fname);
    if (isempty (ext))
      fname = [fname ".gpx"];
    endif
    url = false;
  endif

  if (nargin < 2)
    gtr = grt = gpt = 1;
  else
    gtr = grt = gpt = 0;
  endif

  if (mod (nargin, 2) != 1)
    error ("gpxread: insufficient nr. of input arguments\n");
  endif

  idx = [];
  for ii=1:2:numel (varargin)
    if (ischar (varargin{ii}) && numel (varargin{ii}) > 0)
      switch lower (varargin{ii})(1)
        case "f"
          switch lower (varargin{ii+1})(1)
            case "t"
              gtr = 1;
            case "r"
              grt = 1;
            case "w"
              gpt = 1;
            case "a"
              gtr = grt = gpt = 1;
            otherwise
              error ("gpxread: unknown FeatureType '%s'", varargin{ii+1});
          endswitch
        case "i"
          idx = varargin{ii+1};
          if (! isnumeric (idx))
            error ("gpxread: numeric value or vector expected for arg.# %d\n", ii+1);
          else
            idx = uint32 (idx);
            gpt = 1;
          endif
        otherwise
          warning ("gpxread: unknown option '%s' - ignored\n", varargin{ii});
      endswitch
    else
      error (["gpxread: wrong argument type for arg. %d - 'FeatureType' or ", ...
              "'Index' expected"], ii+1);
    endif
  endfor

  if (url)
    ## Untested
    xml = urlread (fname);
  else
    fid = fopen (fname, "r");
    if (fid < 0)
      error ("gpxread: couldn't open file %s\n", fname);
    endif
    xml = fread (fid, Inf, "char=>char")';
    fclose (fid);
  endif

  outp = repmat (struct ("Type", "-", ...
                         "Lat",  [],  ...
                         "Lon",  [],  ...
                         "Ele",  [],  ...
                         "Time", [],  ...
                         "Name", "-"), 0, 1);

  if (gpt)
    ## (Try to) Read waypoints
    ptrnp = 'wpt lat="(.*?)" lon="(.*?)">.*?ele>(.*?)</ele.*?name>(.*?)</name';
    wpts = reshape (cell2mat ( regexp (xml, ptrnp, "tokens")'), [], 4);
    if (! isempty (wpts))
      wpts(:, 1:3) = num2cell (str2double (wpts(:, 1:3)));
      if (isempty (idx))
        idx = [1:size(wpts, 1)]';
      else
        idx(idx < 1) = [];
        idx(idx > size (wpts, 1)) = [];
      endif
      [outp(1:numel (idx)).Name] = deal (wpts(idx, 4){:});
      [outp(1:numel (idx)).Type] = deal ("WayPoint");
      [outp(1:numel (idx)).Lat] = deal (wpts(idx, 1){:});
      [outp(1:numel (idx)).Lon] = deal (wpts(idx, 2){:});
      [outp(1:numel (idx)).Ele] = deal (wpts(idx, 3){:});
    endif
  endif

  if (gtr)
    ## Read tracks
    ptrnt1A = '<trkpt lat="(.*?)" lon="(.*?)".*?ele>(.*?)</ele>.*?<time>(.*?)</time';
    ptrnt1B = '<trkpt lat="(.*?)" lon="(.*?)".*?time>(.*?)</time.*?ele>(.*?)</ele>';
    ptrnt1C = '<trkpt lat="(.*?)" lon="(.*?)".*?time>(.*?)</time.*?</trkpt>';
    ptrnt2 = '<trkpt lat="(.*?)" lon="(.*?)".*?ele>(.*?)</ele';
    ptrnt3 = '<trkpt lat="(.*?)" lon="(.*?)".*?</trkpt';
    [trk, ~, is] = getxmlnode (xml, "trk", 1, 1);
    itr = 0;
    if (is != 0)
      do
        ## For each track segment
        if (isempty (idx) || ismember (++itr, idx))
          [trkseg, ~, ist] = getxmlnode (trk, "trkseg", 1, 1);
          if (ist != 0)
            dcol = 0;
            outp(end+1).Type = "Track";
            outp(end).Name = getxmlnode (trk, "name", 1, 1);
            ## Check if tracks have time subnode. it points to first occurrence
            it = index (trkseg, "</time>", "first");
            ## Check if tracks have elevation subnodes. has_ele points to position
            has_ele = index (trkseg, "</ele>", "first");
            ## If there are time nodes, check ele/time node order
            if (it)
              if (! has_ele)
                ## No "ele" subnodes
                ptrnt = ptrnt1C;
                dcol = 3;
                ncols = 3;
              elseif (has_ele < it)
                ## ele nodes come before time nodes
                ptrnt = ptrnt1A;
                dcol = 4;
                ncols = 4;
              else
                ## time nodes come before ele nodes
                ptrnt = ptrnt1B;
                dcol = 3;
                ncols = 4;
              endif
            elseif (has_ele)
              ptrnt = ptrnt2;
              ncols = 3;
            else
              ## Just Lat and Lon nodes
              ptrnt = ptrnt3;
              ncols = 2;
            endif
            out = NaN (0, ncols);
            do
              arr = reshape (cell2mat (regexp (trkseg, ptrnt, "tokens")), ...
                            ncols, [])';
              if (dcol)
                ## Maybe mixed time formats. Morph all time formats into
                ## HH:MM:SS.FFF formats
                arr(:, dcol) = ...
                 regexprep (arr(:, dcol), 'T(\d{2}:\d{2}:\d{2})Z', "T$1.000Z");
                if (ncols == 4)
                  lastcol = 7 - dcol;
                else
                  lastcol = [];
                endif
                arr = [ (str2double (arr(:, [1:2 lastcol]))) ...
                        (datenum (arr(:, dcol), "yyyy-mm-ddTHH:MM:SS.FFFZ")) ];
              else
                arr = str2double (arr);
              endif
              out = [out; arr; NaN(1, ncols)];
              [trkseg, ~, ist] = getxmlnode (trk, "trkseg", ist, 1);
            until (ist == 0);
            out(end, :) = [];
            outp(end).Lat = out(:, 1);
            outp(end).Lon = out(:, 2);
            if (has_ele)
              outp(end).Ele = out(:, 3);
            endif
            if (it)
              outp(end).Time = out(:, dcol);
            endif
          endif
        endif
        [trk, ~, is] = getxmlnode (xml, "trk", is, 1);
      until (is == 0);
    endif
  endif

  if (grt)
    ## Read routes
    ptrnr = 'rtept lat="(.*?)" lon="(.*?)".*?ele>(.*?)</ele.*?name>(.*?)</name';
    [rte, ~, is] = getxmlnode (xml, "rte", 1, 1);
    irt = 0;
    if (is != 0)
      do
        if (isempty (idx) || ismember (++irt, idx))
          outp(end+1).Type = "Route";
          outp(end).Name = getxmlnode (rte, "name", 1, 1);
          [rteseg, ~, isr] = getxmlnode (rte, "rtept", 1, 1);
          rtp = reshape (cell2mat ( regexp (rte, ptrnr, "tokens")'), [], 4);
          [outp(end).Lat] = str2double (rtp(:, 1));
          [outp(end).Lon] = str2double (rtp(:, 2));
          [outp(end).Ele] = str2double (rtp(:, 3));
          [outp(end).Names] = rtp(:, 4);
        endif
       [rte, ~, is] = getxmlnode (xml, "rte", is, 1);
      until (is == 0);
    endif
  endif

endfunction
