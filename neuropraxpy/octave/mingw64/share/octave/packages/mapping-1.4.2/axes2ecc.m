## Copyright (C) 2018-2022 Philip Nienhuis
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} {@var{ecc} =} axes2ecc (@var{semimajor}, @var{semiminor})
## @deftypefnx {Function File} {} {@var{ecc} =} axes2ecc (@var{axes})
## Calculates the eccentricity from semimajor and semiminor axes.
##
## @var{semimajor} and @var{semiminor} are scalars or vectors of
## semimajor and semiminor axes, resp.  Alternatively, they can also be
## supplied as coordinate (row) vectors or a N2 matrix with each row
## consisting of a (semimajor, semiminor) pair.
##
## Output arg @var{ecc} is a scalar or column vector of eccentricities.
##
## Examples:
##
## Scalar input:
## @example
##    format long
##    axes2ecc (6378137, 6356752.314245)
##    => 0.0818191908429654
## @end example
##
## Row vector (semimajor, semiminor):
## @example
##  axes2ecc ([6378137, 6356752.314245])
##  =>  0.0818191908429654
## @end example
##
## Multivectors:
## @example
##    axes2ecc ([     71492, 66854; ...
##                  6378137, 6356752.314245])
##    ans =
##       0.3543163789650412
##       0.0818191908429654
## @end example
##
## @seealso{ecc2flat,flat2ecc}
## @end deftypefn

## Function supplied by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9492

function ecc = axes2ecc (semimajor, semiminor=[])

  if (nargin < 1)
    print_usage ();

  elseif (ischar (semimajor) || ischar (semiminor))
    error ("axes2ecc: input args must be numeric");

  elseif (nargin == 1)
    s = size (semimajor);
    if (s(2) != 2)
      error ("axes2ecc: Nx2 matrix expected for arg. #1");
    endif
    ecc = sqrt ((semimajor(:, 1) .^ 2 - semimajor(:, 2) .^ 2) ./ ...
                (semimajor(:, 1) .^ 2));
  else
    ecc = sqrt ((semimajor .^ 2 - semiminor .^ 2) ./ (semimajor .^ 2));
  endif

endfunction


%!test
%! semimajor = 6378137;
%! semiminor = 6356752.314245;
%! Earth = [ semimajor, semiminor ];
%! Jupiter = [ 71492 , 66854 ];
%! Planets = [ Jupiter ; Earth ];
%! assert (axes2ecc (semimajor, semiminor), 0.0818191908429654, 10e-12);
%! assert (axes2ecc (Earth), 0.0818191908429654, 10e-12);
%! assert (axes2ecc (Planets), [ 0.354316379; 0.081819190843 ], 10e-10);
%! assert (axes2ecc (Planets(:, 1), Planets(:, 2)), [ 0.354316379; 0.081819190843 ], 10e-10);

%!error <must be numeric> axes2ecc ("a", 1);
%!error <Nx2 matrix expected> axes2ecc ([1; 2]);
