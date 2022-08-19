## Copyright (C) 2018-2019 Olaf Till <i7tiol@t-online.de>
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

## -*- texinfo -*-
## @deftypefn {Function File} __struct_options__ ()
## Returns structure relating callback names to _struct or _pstruct
## options.
## @end deftypefn

function ret = __struct_options__ ()

  persistent sopts = ...
  struct ( ...
           "f", "f_pstruct", # model function
           "objf", "objf_pstruct", # objective function
           "dfdp", "df_pstruct", # gradient or jacobian
           "hessian", "hessian_pstruct", # hessian
           "f_genicstr", "f_inequc_pstruct", # general inequality constraints
           "df_genicstr", "df_inequc_pstruct", # jacobian of general
                                           # inequality constraints
           "f_genecstr", "f_equc_pstruct", # general equality constraints
           "df_genecstr", "df_equc_pstruct", # jacobian of general
                                             # equality constraints
           "imc", "imc_struct", # matrix of linear inequality constraints
           "emc", "emc_struct" # matrix of linear equality constraints
         );

  ret = sopts;

endfunction
