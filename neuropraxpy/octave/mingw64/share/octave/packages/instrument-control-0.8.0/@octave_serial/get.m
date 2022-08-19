## Copyright (C) 2014 Stefan Mahr <dac922@gmx.de>
## Copyright (C) 2019 John D <john.donoghue@ieee.org>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{struct} = } get (@var{serial})
## @deftypefnx {Function File} {@var{field} = } get (@var{serial}, @var{property})
## Get the properties of serial object.
##
## @subsubheading Inputs
## @var{serial} - instance of @var{octave_serial} class.@*
## @var{property} - name of property.@*
##
## @subsubheading Outputs
## When @var{property} was specified, return the value of that property.@*
## otherwise return the values of all properties as a structure.@*
##
## @seealso{@@octave_serial/set}
## @end deftypefn

function retval = get (serial, property)

  properties = {'name', 'type', 'status', 'baudrate', 'bytesize', 'parity', ...
                'stopbits', 'timeout', 'requesttosend', ...
		'dataterminalready', 'pinstatus', 'bytesavailable', ...
                'port'};

  if (nargin == 1)
    property = properties;
  elseif (nargin > 2)
    error ("Too many arguments.\n");
  end

  if !iscell (property)
    property = {property};
  end
  property = tolower(property);

  valid     = ismember (property, properties);
  not_found = {property{!valid}};

  if !isempty (not_found)
    msg = @(x) error("serial:get:InvalidArgument", ...
                     "Unknown property '%s'.\n",x);
    cellfun (msg, not_found);
  end

  property = {property{valid}};
  retval = {};
  for i=1:length(property)
    retval{end+1} = __srl_properties__ (serial, property{i});
  endfor

  if numel(property) == 1
    retval = retval{1};
  elseif (nargin == 1)
    retval = cell2struct (retval',properties);
  end

end
