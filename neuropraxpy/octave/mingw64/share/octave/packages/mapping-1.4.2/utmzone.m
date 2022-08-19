## Copyright (C) 2019-2022 Philip Nienhuis
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSEll. See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{zone} =} utmzone (@var{lat} , @var{long})
## @deftypefnx {Function File} {@var{latlon} =} utmzone (@var{zone})
## @deftypefnx {Function File} {@var{lat}, @var{long} =} utmzone (@var{zone})
## Returns the zone given a latitude and longitude, or the latitude and
## longitude ranges given a zone.
##
## Examples:
##
## @example
## utmzone (43, -79)
## => ans =
## 17T
## @end example
##
## Can also handle the special zones of Norway
##
## @example
## utmzone (60, 5)
## => ans =
## 32V
## @end example
##
## For zones:
##
## @example
## utmzone ("17T")
## => ans =
##  40   48
## -84  -78
## @end example
##
## @example
## [lat, lon] = utmzone ("17T")
## =>
## lat =
##    40   48
## lon =
##   -84  -78
## @end example
##
## @end deftypefn

## Function supplied by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9756

function [zone, z2] = utmzone (lat, long)

  ## Since there is no I or O, the last 4 are special cases
  alphabet = ("CDEFGHJKLMNPQRSTUVWXABYZ");

  if (nargin < 2)
    if (ischar (lat) && numel (lat) > 1)
      num = sscanf (lat, "%f");
      if (num < 1)
        error ("utmzone: positive number expecte for zone");
      endif
      let = find (alphabet == upper (lat(end)));
      if (isempty (let))
        error ("utmzone: incorrect or no letter specified");
      endif
      switch upper (lat(end))
        case "A"
          lat  = [-80 -90];
          long = [-180 0];
          zone = [lat; long];
        case "B"
          lat  = [-80 -90];
          long = [0 180];
          zone = [lat; long];
        case "Y"
          lat  = [84 90];
          long = [-180 0];
          zone = [lat; long];
        case "Z"
          lat  = [84 90];
          long = [0 180];
          zone = [lat; long];
        case "X"
          lat  = [72 84];
          switch num
            case 31
              long = [0 9];
            case 33
              long = [9 21];
            case 35
              long = [21 33];
            case 37
              long = [33 42];
            case {32, 34, 36}
              error ("utmzone: zone %2iX does not exist", num);
            otherwise
              long = [(num - 1) * 6 - 180, (num * 6 - 180)];
          endswitch
          zone = [lat; long];
        case  "V"
          lat = [56 64];
          switch num
            case 31
              long = [0 3];
            case 32
              long = [3 12];
            otherwise
              long = [(num - 1) * 6 - 180, (num * 6 - 180)];
          endswitch
          zone = [lat; long];
        otherwise
          lat =  [(let - 1) * 8 - 80, (let * 8) - 80 ];
          long = [(num - 1) * 6 - 180, (num * 6 - 180)];
          zone = [lat; long];
      endswitch
    endif
    if (nargout ==2)
      zone = lat;
      z2 = long;
    endif

  elseif (isnumeric (lat) && isreal (lat) && isnumeric (long) && isreal (long))
    lat  = mean (lat);
    long = mean (long);
    if (lat <=  -80)
        if (long < 0)
          zone = "A";
        else
          zone = "B";
        endif
    elseif (lat >= 84)
        if long < 0
          zone = "Y";
        else
          zone = "Z";
        endif
    elseif (lat >= 72 && lat < 84)
        if (long >= 0 && long < 9)
          zone = "31X";
        elseif (long >= 9 && long < 21)
          zone = "33X";
        elseif (long >= 21 && long < 33)
          zone = "35X";
        elseif (long >= 33 && long < 42)
          zone = "37X";
        else
          zone = zone (lat, long);
        endif
    elseif (lat >= 56 && lat < 64)
        if (long >= 0 && long < 3)
          zone = "31V";
        elseif (long >= 3 && long < 12)
          zone = "32V";
        endif
    else
      zone = zone (lat, long);
    endif

  else
    error ("utmzone: numeric input expected for LAT en LON");

  endif

endfunction


function z = zone (lat, long)

  alphabet = ("CDEFGHJKLMNPQRSTUVWX");

  num = floor ((long + 180) / 6) + 1;
  idx = -80;
  ind = 0;
  while (lat > idx)
    idx = idx + 8;
    ind = ind + 1;
  endwhile
  let = alphabet (ind);
  z = strcat (num2str (num), let);

endfunction


%!test
%! lat = 43; ## From Wiki
%! long =  -79;
%! assert (utmzone (lat, long), "17T")
%!assert (utmzone ("17T"), [40, 48;-84, -78])
%!assert (utmzone (60, 5), "32V") ## For Bergen Norway
%!assert (utmzone ("32V"), [56, 64;3, 12])

%!error <zone> utmzone ("32X")
%!error <incorrect> utmzone ("31I")
%!error <incorrect> utmzone ("31O")
