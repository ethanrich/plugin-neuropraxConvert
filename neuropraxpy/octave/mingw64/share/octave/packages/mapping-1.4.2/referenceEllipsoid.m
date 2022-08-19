## Copyright (C) 2018-2022 Philip Nienhuis
## Copyright (C) 2014-2022 Alfredo Foltran <alfoltran@gmail.com>
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
## @deftypefn {Function File} {} referenceEllipsoid (@var{name}, @var{unit})
## Returns the parameters of an ellipsoid.
##
## @var{Name} can be the name (e.g., "wgs84") or (integer) EPSG code of a
## reference ellipoid.  Case is not important.  If the number or code 0
## (zero) is specified, referenceEllipsoid echoes a list of implemented
## ellipsoids to the screen.
##
## @var{unit} can be the name of any unit accepted by function
## validateLengthUnit.m.  Also here case is not important.
##
## The output consists of a scalar struct with fields "Code" (EPSG code of the
## ellipsoid), "Name" (name of the ellipsoid), "LengthUnit", "SemimajorAxis",
## "SemiminorAxis", "InverseFlattening", "Eccentricity", "Flattening",
## "ThirdFlattening", "MeanRadius", "SurfaceArea", and "Volume".
##
## If an output argument is supplied for input "0", that output is a struct
## array of all parameters of all implemented reference ellipsoids.
##
## Examples:
##
## @example
## >> E = referenceEllipsoid ("wgs84")
## E =
##
##  scalar structure containing the fields:
##
##    Code =  7030
##    Name = World Geodetic System 1984
##    LengthUnit = meter
##    SemimajorAxis =  6378137
##    SemiminorAxis =    6.3568e+06
##    InverseFlattening =  298.26
##    Eccentricity =  0.081819
##    Flattening =  0.0033528
##    ThirdFlattening =  0.0016792
##    MeanRadius =    6.3710e+06
##    SurfaceArea =    5.1007e+14
##    Volume =    1.0832e+21
## @end example
##
## The code number can be used:
##
## @example
## >> E = referenceEllipsoid (7019)
## E =
##
##  scalar structure containing the fields:
##
##    Code =       7019
##    Name = Geodetic Reference System 1980
##    LengthUnit = meter
##    SemimajorAxis = 6.3781e+06
##    SemiminorAxis = 6.3568e+06
##    InverseFlattening =     298.26
##    Eccentricity =   0.081819
##    Flattening =  0.0033528
##    ThirdFlattening =  0.0016792
##    MeanRadius =  6.371e+06
##    SurfaceArea = 5.1007e+14
##    Volume = 1.0832e+21
## @end example
##
## @example
## >> E = referenceEllipsoid ("wgs84", "km")
## E =
##
##  scalar structure containing the fields:
##
##    Code =  7030
##    Name = World Geodetic System 1984
##    LengthUnit = km
##    SemimajorAxis =  6378.1
##    SemiminorAxis =  6356.8
##    InverseFlattening =  298.26
##    Eccentricity =  0.081819
##    Flattening =  0.0033528
##    ThirdFlattening =  0.0016792
##    MeanRadius =  6371.0
##    SurfaceArea =    5.1007e+08
##    Volume =    1.0832e+12
## @end example
##
## @seealso{validateLengthUnit, wgs84Ellipsoid}
## @end deftypefn

## Function supplied by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9634

function Ell = referenceEllipsoid (name="unit sphere", unit="meter")

  ## List of implemented codes. To be updated if codes are added.
  persistent codes;
  if (isempty (codes))
    codes = {"7001", "Airy 1830",                       "Airy30"; ...
             "7002", "Airy Modified 1849",              "Airy49"; ...
             "7003", "Australian National Spheroid",    " "; ...
             "7004", "Bessel 1841",                     "Bessel"; ...
             "7005", "Bessel Modified",                 " "; ...
             "7006", "Bessel Namibia",                  " "; ...
             "7007", "Clarke 1858",                     " "; ...
             "7008", "Clarke 1866",                     "Clarke66"; ...
             "7009", "Clarke 1866 Michigan",            " "; ...
             " ",    "Clarke 1878"                      " "; ...
             "7010", "Clarke 1880 (Benoit)",            "Clarke80"; ...
             "7011", "Clarke 1880 (IGN)",               " "; ...
             "7012", "Clarke 1880 (RGS)",               " "; ...
             "7013", "Clarke 1880 (Arc)",               " "; ...
             "7014", "Clarke 1880 (SGA 1922)",          " "; ...
             "7015", "Everest 1830 (1937 Adjustment)",  "Everest"; ...
             "7016", "Everest 1830 (1967 Definition)",  " "; ...
             "7018", "Everest 1830 Modified",           " "; ...
             "7019", "grs80",                           "1980"; ...
             " ",    "Hayford",                         " "; ...
             "7020", "Helmert 1906",                    " "; ...
             "7021", "Indonesian National Spheroid",    " "; ...
             "7022", "int24",                           "1924"; ...
             " ",    "New International 1967"           "1967"; ...
             "7024", "Kras40",                          "Krasovsky"; ...
             " ",    "Maupertius",                      " "; ...
             "7025", "NWL 9D",                          " "; ...
             "7027", "Plessis 1817",                    " "; ...
             "7028", "Struve 1860",                     " "; ...
             "7029", "War Office",                      " "; ...
             "7030", "Wgs84",                           "1984"; ...
             "7031", "GEM 10C",                         " "; ...
             "7032", "OSU86F",                          " "; ...
             "7033", "OSU91A",                          " "; ...
             "7034", "Clarke 1880",                     " "; ...
             "7035", "Sphere",                          " "; ...
             "7036", "GRS 1967",                        " "; ...
             "7041", "Average Terrestrial System 1977", " "; ...
             "7042", "Everest (1830 Definition)",       " "; ...
             " ",    "wgs66",                           " "; ...
             "7043", "Wgs72",                           "1972"; ...
             "7044", "Everest 1830 (1962 Definition)",  " "; ...
             "7045", "Everest 1830 (1975 Definition)",  " "; ...
             "7046", "Bessel Namibia (GLM)",            " "; ...
             "7047", "GRS 1980 Authalic Sphere",        " "; ...
             "7048", "GRS 1980 Authalic Sphere",        " "; ...
             "7049", "Xian 1980",                       " "; ...
             "7050", "GRS 1967 (SAD69)",                " "; ...
             "7051", "Danish 1876",                     " "; ...
             "7052", "Clarke 1866 Authalic Sphere",     " "; ...
             "7053", "Hough 1960",                      " "; ...
             " ",    "IERS 1989",                       " "; ...
             " ",    "IERS 2003",                       " "; ...
             " ",    "Sun",                             " "; ...
             " ",    "Mercury",                         " "; ...
             " ",    "Venus",                           " "; ...
             " ",    "Earth",                           " "; ...
             " ",    "Moon",                            " "; ...
             " ",    "Mars",                            " "; ...
             " ",    "Jupiter",                         " "; ...
             " ",    "Saturn",                          " "; ...
             " ",    "Uranus",                          " "; ...
             " ",    "Neptune",                         " "; ...
             " ",    "Pluto",                           " "; ...
             " ",    "Unit Sphere",                     " "};
  endif

  if (isnumeric (name) && isreal (name))
    name = num2str (fix (name));
  elseif (! ischar (name))
    error ("referenceEllipsoid: value must be a string or integer number");
  elseif (strcmp (name, " "))
    error ("referenceEllipsoid: name required");
  endif

  if (! ischar (unit))
    error ("referenceEllipsoid: length name expected for input arg. #2");
  endif

  switch lower (name)
    ## Semimajor axis and Inverse flattening from
    ## USER's HANDBOOK ON DATUM TRANSFORMATIONS INVOLVING WGS 84
    ## 3rd Edition, July 2003, (Last correction August 2008),
    ## Special Publication No. 60
    ## Codenames are from https://epsg.io/
    ## Planet values from Report of the IAU Working Group on
    ## CartographicCoordinates and Rotational Elements: 2015

    case lower (codes(1, :))
      Code = 7001;
      Name = "Airy 1830";
      SemimajorAxis = 6377563.396;
      InverseFlattening = 299.3249646;

    case lower (codes(2, :))
      Code = 7002;
      Name = "Airy Modified 1849";
      SemimajorAxis = 6377340.189;
      InverseFlattening = 299.3249646;

    case lower (codes(3, :))
      Code = 7003;
      Name = "Australian National Spheroid";
      SemimajorAxis = 6378160;
      InverseFlattening = 298.25;

    case lower (codes(4, :))
      Code = 7004;
      Name = "Bessel 1841";
      SemimajorAxis = 6377397.155;
      InverseFlattening = 299.1528128;

    case lower (codes(5, :))
      Code = 7005;
      Name = "Bessel Modified";
      SemimajorAxis = 6377492.018;
      InverseFlattening = 299.1528128;

    case lower (codes(6, :))
      Code = 7006;
      Name = "Bessel Namibia";
      SemimajorAxis = 6377483.865;
      InverseFlattening = 299.1528128;

    case lower (codes(7, :))
      Code = 7007;
      Name = "Clarke 1858";
      SemimajorAxis = 20926348;
      InverseFlattening = 294.260676369;

    case lower (codes(8, :))
      Code = 7008;
      Name = "Clarke 1866";
      SemimajorAxis = 6378206.4;
      InverseFlattening = 294.978698213898;

    case lower (codes(9, :))
      Code = 7009;
      Name = "Clarke 1866 Michigan";
      SemimajorAxis = 20926631.531;
      InverseFlattening = 294.978697164674;

    case lower (codes(10, :))
      Code = [];
      Name = "Clarke 1878";
      SemimajorAxis = 6378190;
      InverseFlattening = 293.4659980;

    case lower (codes(11, :))
      Code = 7010;
      Name = "Clarke 1880 (Benoit)";
      SemimajorAxis = 6378300.789;
      InverseFlattening = 293.466315538981;

    case lower (codes(12, :))
      Code = 7011;
      Name = "Clarke 1880 (IGN)";
      SemimajorAxis = 6378249.2;
      InverseFlattening = 293.466021293627;

    case lower (codes(13, :))
      Code = 7012;
      Name = "Clarke 1880 (RGS)";
      SemimajorAxis = 6378249.145;
      InverseFlattening = 293.465;

    case lower (codes(14, :))
      Code = 7013;
      Name = "Clarke 1880 (Arc)";
      SemimajorAxis = 6378249.145;
      InverseFlattening = 293.4663077;

    case lower (codes(15, :))
      Code = 7014;
      Name = "Clarke 1880 (SGA 1922)";
      SemimajorAxis = 6378249.2;
      InverseFlattening = 293.46598;

    case lower (codes(16, :))
      Code = 7015;
      Name = "Everest 1830 (1937 Adjustment)";
      SemimajorAxis = 6377276.34518;
      InverseFlattening = 300.8017;

    case lower (codes(17, :))
      Code = 7016;
      Name = "Everest 1830 (1967 Definition)";
      SemimajorAxis = 6377298.556;
      InverseFlattening = 300.8017;

    case lower (codes(18, :))
      Code = 7018;
      Name = "Everest 1830 Modified";
      SemimajorAxis = 6377304.063;
      InverseFlattening = 300.8017;

    case lower (codes(19, :))
      Code = 7019;
      Name = "GRS 1980";
      SemimajorAxis = 6378137;
      InverseFlattening = 298.257222101;

    case lower (codes(20, :))
      Code = [];
      Name = "Hayford";
      SemimajorAxis = 6378388;
      InverseFlattening = 297;

    case lower (codes(21, :))
      Code = 7020;
      Name = "Helmert 1906";
      SemimajorAxis = 6378200;
      InverseFlattening = 298.3;

    case lower (codes(22, :))
      Code = 7021;
      Name = "Indonesian National Spheroid";
      SemimajorAxis = 6378160;
      InverseFlattening = 298.247;

    case lower (codes(23, :))
      Code = 7022;
      Name = "International 1924";
      SemimajorAxis = 6378388;
      InverseFlattening = 297;

    case lower (codes(24, :))
      Code = [];
      Name = "New International 1967";
      SemimajorAxis = 6378157.5;
      InverseFlattening = 298.24961539;

    case lower (codes(25, :))
      Code = 7024;
      Name = "Krasovsky 1940";
      SemimajorAxis = 6378245;
      InverseFlattening = 298.3;

    case lower (codes(26, :))
      Code = [];
      Name = "Maupertius";
      SemimajorAxis = 6397300;
      InverseFlattening = 191;

    case lower (codes(27, :))
      Code = 7025;
      Name = "NWL 9D";
      SemimajorAxis = 6378145;
      InverseFlattening = 298.25;

    case lower (codes(28, :))
      Code = 7027;
      Name = "Plessis 1817";
      SemimajorAxis = 6376523;
      InverseFlattening = 308.64;

    case lower (codes(29, :))
      Code = 7028;
      Name = "Struve 1860";
      SemimajorAxis = 6378298.3;
      InverseFlattening = 294.73;

    case lower (codes(30, :))
      Code = 7029;
      Name = "War Office";
      SemimajorAxis = 6378300;
      InverseFlattening = 296;

    case lower (codes(31, :))
      Code = 7030;
      Name = "World Geodetic System 1984";
      SemimajorAxis = 6378137;
      InverseFlattening = 298.257223563;

    case lower (codes(32, :))
      Code = 7031;
      Name = "GEM 10C";
      SemimajorAxis = 6378137;
      InverseFlattening = 298.257223563;

    case lower (codes(33, :))
      Code = 7032;
      Name = "OSU86F";
      SemimajorAxis = 6378136.2;
      InverseFlattening = 298.257223563;

    case lower (codes(34, :))
      Code = 7033;
      Name = "OSU91A";
      SemimajorAxis = 6378136.3;
      InverseFlattening = 298.257223563;

    case lower (codes(35, :))
      Code = 7034;
      Name = "Clarke 1880";
      SemimajorAxis = 20926202;
      InverseFlattening = 293.465;

    case lower (codes(36, :))
      Code = 7035;
      Name = "Sphere";
      SemimajorAxis = 6371000;
      InverseFlattening = Inf;

    case lower (codes(37, :))
      Code = 7036;
      Name = "GRS 1967";
      SemimajorAxis = 6378160;
      InverseFlattening = 298.247167427;

    case lower (codes(38, :))
      Code = 7041;
      Name = "Average Terrestrial System 1977";
      SemimajorAxis = 6378135;
      InverseFlattening = 298.257;

    case lower (codes(39, :))
      Code = 7042;
      Name = "Everest (1830 Definition)";
      ## SemimajorAxis = 20922931.8; # Indian feet (= 0.99999566 British foot)
      SemimajorAxis = 6377281.935116282;
      InverseFlattening = 300.8017;

    case lower (codes(40, :))
      Code = [];
      Name = "World Geodetic System 1966";
      SemimajorAxis = 6378145;
      InverseFlattening = 298.25;

    case lower (codes(41, :))
      Code = 7043;
      Name = "World Geodetic System 1972";
      SemimajorAxis = 6378135;
      InverseFlattening = 298.26;

    case lower (codes(42, :))
      Code = 7044;
      Name = "Everest 1830 (1962 Definition)";
      SemimajorAxis = 6377301.243;
      InverseFlattening = 300.8017255;

    case lower (codes(43, :))
      Code = 7045;
      Name = "Everest 1830 (1975 Definition)";
      SemimajorAxis = 6377299.151;
      InverseFlattening = 300.8017255;

    case lower (codes(44, :))
      Code = 7046;
      Name = "Bessel Namibia (GLM)";
      SemimajorAxis = 6377397.155;
      InverseFlattening = 299.1528128;

    case lower (codes(45, :))
      Code = 7047;
      Name = "GRS 1980 Authalic Sphere";
      SemimajorAxis = 6370997;
      InverseFlattening = Inf;

    case lower (codes(46, :))
      Code = 7048;
      Name = "GRS 1980 Authalic Sphere";
      SemimajorAxis = 6371007;
      InverseFlattening = Inf;

    case lower (codes(47, :))
      Code = 7049;
      Name = "Xian 1980";
      SemimajorAxis = 6378140;
      InverseFlattening = 298.257;

    case lower (codes(48, :))
      Code = 7050;
      Name = "GRS 1967 (SAD69)";
      SemimajorAxis = 6378160;
      InverseFlattening = 298.25;

    case lower (codes(49, :))
      Code = 7051;
      Name = "Danish 1876";
      SemimajorAxis = 6377019.27;
      InverseFlattening = 300;

    case lower (codes(50, :))
      Code = 7052;
      Name = "Clarke 1866 Authalic Sphere";
      SemimajorAxis = 6370997;
      InverseFlattening = Inf;

    case lower (codes(51, :))
      Code = 7053;
      Name = "Hough 1960";
      SemimajorAxis = 6378270;
      InverseFlattening = 297;

    case lower (codes(52, :))
      Code = [];
      Name = "IERS 1989";
      SemimajorAxis = 6378136;
      InverseFlattening = 298.257;

    case lower (codes(53, :))
      Code = [];
      Name = "IERS 2003";
      SemimajorAxis = 6378136.6;
      InverseFlattening = 298.25642;

    case lower (codes(54, :))
      Code = [];
      Name = "Sun";
      SemimajorAxis = 695700000;
      InverseFlattening = 111111;

    case lower (codes(55, :))
      Code = [];
      Name = "Mercury";
      SemimajorAxis = 2440530;
      InverseFlattening = 1075;

    case lower (codes(56, :))
      Code = [];
      Name = "Venus";
      SemimajorAxis = 6051800;
      InverseFlattening = Inf;

    case lower (codes(57, :))
      Code = [];
      Name = "Earth";
      SemimajorAxis = 6378137;
      InverseFlattening = 298.2572235630;

    case lower (codes(58, :))
      Code = [];
      Name = "Moon";
      SemimajorAxis = 1738100;
      InverseFlattening = 833.33;

    case lower (codes(59, :))
      Code = [];
      Name = "Mars";
      SemimajorAxis = 3396190;
      InverseFlattening =  169.894;

    case lower (codes(60, :))
      Code = [];
      Name = "Jupiter";
      SemimajorAxis = 71492000;
      InverseFlattening =  15.4144;

    case lower (codes(61, :))
      Code = [];
      Name = "Saturn";
      SemimajorAxis = 60268000;
      InverseFlattening = 10.208;

    case lower (codes(62, :))
      Code = [];
      Name = "Uranus";
      SemimajorAxis = 25559000;
      InverseFlattening = 43.616;

    case lower (codes(63, :))
      Code = [];
      Name = "Neptune";
      SemimajorAxis = 24764000;
      InverseFlattening = 58.5437;

    case lower (codes(64, :))
      Code = [];
      Name = "Pluto";
      SemimajorAxis = 1188300;
      InverseFlattening = Inf;

    case lower (codes(65, :))
      Code = [];
      Name = "Unit Sphere";
      SemimajorAxis = 1;
      InverseFlattening = Inf;

    case "0"
      if (nargout > 0)
        Ell = [(num2cell (1:size (codes, 1))') codes] ;
      else
        ## Show list of codes
        printf ("\n referenceEllipsoid.m:\n list of implemented ellipsoids:\n");
        printf (" Code               Alias 1          Alias 2\n");
        printf (" ====               =======          =======\n");
        for ii=1:size (codes, 1)
          printf ("%5s  %20s  %15s\n", codes (ii, :){:});
        endfor
      endif
      return

    otherwise
      error ("referenceEllipsoid: ellipsoid %s has not been implemented", name)

  endswitch

  ## Calculations
  Ell = param_calc (Code, Name, SemimajorAxis, InverseFlattening, unit);

endfunction


function ell = param_calc (Code, Name, SemimajorAxis, InvF, unit)

  ell.Code              = Code;
  ell.Name              = Name;
  ratio   = unitsratio (unit, "Meters");
  ell.LengthUnit        = unit;
  Major   = SemimajorAxis * ratio;
  ell.SemimajorAxis     = Major;
  Inverse = InvF;
  ell.InverseFlattening = InvF;
  Ecc     = flat2ecc (1 / InvF);
  ell.Eccentricity      = Ecc;
  Minor   = minaxis (Major, Ecc);
  ell.SemiminorAxis     = Minor;
  ell.Flattening        = 1 / InvF;
  ell.ThirdFlattening   = (Major - Minor) / (Major + Minor);
  ell.MeanRadius        = (2 * Major + Minor) / 3;
  ## From Knud Thomsen this results in a max error of 1.061 %:
  P       = 1.6075;
  Surface = 4 * pi * ((Major^(2*P) +  2 * (Major * Minor)^P) / 3 )^(1/P);
  ell.SurfaceArea       = Surface;
  ell.Volume            = (4 * pi) / 3 * Major^2 * Minor;

endfunction


%!test
%!
%! E = referenceEllipsoid ("wgs84");
%! assert ( E.SemiminorAxis, 6356752.314245, 10e-7 )
%! assert ( E.Eccentricity, 0.081819221456, 10e-8)
%! assert ( E.Flattening, 1 / 298.2572235630, 10e-8 )

%!error <value must be a string> referenceEllipsoid ( 7i )
%!error <not been implemented> referenceEllipsoid ( "yy" )
%!error <name required> referenceEllipsoid ( " " )
