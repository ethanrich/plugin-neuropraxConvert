% LOGICAL [overload base function]

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec & LNE
%
%    Author:  Remi Stroh  <remi.stroh@lne.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (https://github.com/stk-kriging/stk/)
%
%    STK is free software: you can redistribute it and/or modify it under
%    the terms of the GNU General Public License as published by the Free
%    Software Foundation,  either version 3  of the License, or  (at your
%    option) any later version.
%
%    STK is distributed  in the hope that it will  be useful, but WITHOUT
%    ANY WARRANTY;  without even the implied  warranty of MERCHANTABILITY
%    or FITNESS  FOR A  PARTICULAR PURPOSE.  See  the GNU  General Public
%    License for more details.
%
%    You should  have received a copy  of the GNU  General Public License
%    along with STK.  If not, see <http://www.gnu.org/licenses/>.

function xdata = logical (x)

xdata = logical (x.data);

end % function


%!test
%! u = rand (4, 3);
%! x = stk_dataframe (u);
%! v = logical (x);
%! assert (strcmp (class(v), 'logical') && isequal (v, logical (u)))

%!test
%! u = (rand (4, 3) < 0.5);
%! x = stk_dataframe (u);
%! v = logical (x);
%! assert (strcmp (class (v), 'logical') && isequal (v, u))

%!test
%! u = uint8 (rand (4, 3) * 5);
%! x = stk_dataframe (u);
%! v = logical (x);
%! assert (strcmp (class (v), 'logical') && isequal (v, logical (u)))
