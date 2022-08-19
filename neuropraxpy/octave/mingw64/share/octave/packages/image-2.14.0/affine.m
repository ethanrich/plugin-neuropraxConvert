## Copyright (C) 2017 Carnë Draug <carandraug@octave.org>
## Copyright (C) 2015 Motherboard <cantfind@gmail.com>
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
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

classdef affine

## -*- texinfo -*-
## @deftypefn   {Function File} {@var{tform} =} affine (@var{T})
## tform is a representation of an affine 2D or 3D transform.
##
## affine is a master class for affine2d/affine3d.
## For detailed description of all methods see the detailed
## documentation in affine2d or affine3d
##
## @seealso{affine2d, affine3d}
## @end deftypefn

  properties (SetAccess = protected)
    Dimensionality;
    T;
  endproperties

  methods (Access = protected)
    function [varargout] = transformPoints (this, T, varargin)
      nargs = numel (varargin);
      if (nargs == 1)
        U = varargin{1};
        N = rows (U);
        if (ndims (U) != 2 || columns (U) != this.Dimensionality)
          error ("transformPointsForward: U must be NxDimensionality");
        endif
      elseif (nargs == this.Dimensionality)
        N = numel (varargin{1});
        if (any (cellfun ("numel", varargin) != N))
          error ("transformPointsForward: U, V, W, ...  must have same numel");
        endif
        U = cellfun (@vec, varargin, "UniformOutput", false);
        U = cell2mat (U);
      else
        error ("affine: transformPoints: wrong number of arguments");
      endif
      U = [U ones(N, 1)];
      varargout{1} = (U * T)(:,1:this.Dimensionality);
      if (nargout > 1)
        varargout = num2cell (varargout{1}, 1);
      endif
    endfunction
  endmethods

  methods
    function this = affine (T)
      if (nargin != 1)
        error  ("To activate affine withot arguments use affine2d or affine3d");
      elseif (isscalar (T))
        if (fix (T) != T || T < 0)
          error ("affine: DIMENSIONALITY must be a non-negative integer");
        endif
        this.Dimensionality = T;
        this.T = eye (T+1);
      elseif (! issquare (T) || T(end) != 1
              || any (T(1:end-1,end) != 0))
        error ("affine: T must be an affine transform matrix");
      elseif (det (T(1:end-1,1:end-1)) == 0)
        error ("affine: transform must not be a singular matrix");
      else
        this.Dimensionality = rows (T) -1;
        this.T = T;
      endif
    endfunction

    function this = invert (this)
      this.T = inv (this.T);
      this.T(1:end-1, end) = 0;
      this.T(end) = 1;
    endfunction

    ## Check if transform is only rotation or translation.
    function check = isRigid (this)
      submatrix = this.T(1:end-1,1:end-1);
      check = abs (det (submatrix) - 1) < eps;
    endfunction

    ## Check if transform is only homogeneous scaling, rotation, reflection or
    ## translation.
    function check = isSimilarity (this)
      submatrix = this.T(1:end-1,1:end-1);
      s2 = submatrix*submatrix';
      check = all ((abs (s2 - s2(1,1) * eye (this.Dimensionality)) ...
                    < (eps * ones (this.Dimensionality)))(:));
    endfunction

    ## Check if transform is only a translation.
    function check = isTranslation (this)
      submatrix = this.T(1:end-1,1:end-1);
      check = !any ((abs (submatrix - eye (this.Dimensionality)) > 0)(:));
    endfunction

    ## given a bounding cube corner coordinates in xlims, ylims and
    ## zlims (top left front, right bottom back) - return the new
    ## bounding cube after transformation.
    function [varargout] = outputLimits (this, varargin)
      ## if (any (cellfun ('numel', varargin) != 2))
      ##   error ("outputLimits: LimitsIn must all be 2 elements vector");
      ## endif
      ## limits_in = cellfun (@vec, varargin);
      ## r = 2 * (this.dimensionality -1);
      ## for d = 1:this.dimensionality
      ##   limits_in{d}
      xlims2 = [xlims(:); xlims(:); xlims(:); xlims(:)];
      ylims2 = [ylims(:); ylims(end:-1:1)(:); ylims(:); ylims(end:-1:1)(:)];
      zlims2 = [zlims(:); zlims(:); zlims(end:-1:1)(:); zlims(end:-1:1)(:)];
      temp = [xlims2 ylims2 zlims2 ones(8,1)];
      temp = temp*this.T;
      limitsX = [min(temp(1:8,1)), max(temp(1:8,1))];
      limitsY = [min(temp(1:8,2)), max(temp(1:8,2))];
      limitsZ = [min(temp(1:8,3)), max(temp(1:8,3))];
    endfunction

    ## Apply transformation on the set of u, v, w points (1xn vectors)
    ## or on U (3xn matrix)
    function [varargout] = transformPointsForward (this, varargin)
      [varargout{1:nargout}] = transformPoints (this, this.T,
                                                varargin{:});
    endfunction

    ## Apply inverse transformation on the set of u, v, w points (1xn
    ## vectors) or on U (3xn matrix).
    function [varargout] = transformPointsInverse (this, varargin)
      [varargout{1:nargout}] = transformPoints (this, inv (this.T),
                                                varargin{:});
    endfunction
    
    function disp (this)
      printf ("  %s with properties:\n\n", class (this));
      printf ("               T: [%dx%d %s]\n", size (this.T), class (this.T));
      printf ("  Dimensionality: %d\n", this.Dimensionality);
    endfunction
  endmethods
endclassdef
