## Copyright (C) 2016 Susi Lehtola
## Copyright (C) 2016 Julien Bect <jbect@users.sourceforge.net>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
##  any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see .

test gsl_sf_test

%!shared N, xd, xd2, xd3, xd4, xi, xi2, M
%! N = 10;                         # Vector length
%! xd = 0.1 + 0.8 * rand (N, 1);   # Vectors of positive values
%! xd2 = 0.1 + 0.8 * rand (N, 1);  #
%! xd3 = 0.1 + 0.8 * rand (N, 1);  #
%! xd4 = 0.1 + 0.8 * rand (N, 1);  #
%! xi = randperm (25, N)';         # Vectors of small integer values
%! xi2 = randperm (25, N)';        #
%! M = 0;                          # Mode argument

# In the following, we
# - compute values by loop to get reference values
# - compute values using vectorized implementation
# - compute just the value, not the error
# - check the three results are consistent

%!test # double -> double
%! clausen_sc=zeros(N,1);
%! clausen_sc_err=zeros(N,1);
%! for i=1:N
%!   [clausen_sc(i) clausen_sc_err(i)]=clausen(xd(i));
%! end
%! [clausen_vec clausen_vec_err] = gsl_sf_clausen(xd);
%! clausen_val = gsl_sf_clausen(xd);
%! assert(norm(clausen_val(:)-clausen_vec(:))==0.0)
%! assert(norm(clausen_sc(:)-clausen_vec(:))==0.0)
%! assert(norm(clausen_sc_err(:)-clausen_vec_err(:))==0.0)

%!test # (int, double) -> double
%! bessel_Jn_sc=zeros(N,1);
%! bessel_Jn_sc_err=zeros(N,1);
%! for i=1:N
%!   [bessel_Jn_sc(i) bessel_Jn_sc_err(i)] = gsl_sf_bessel_Jn(xi(i),xd(i));
%! end
%! [bessel_Jn_vec bessel_Jn_vec_err] = gsl_sf_bessel_Jn(xi,xd);
%! bessel_Jn_val = gsl_sf_bessel_Jn(xi,xd);
%! assert(norm(bessel_Jn_val(:)-bessel_Jn_vec(:))==0.0)
%! assert(norm(bessel_Jn_sc(:)-bessel_Jn_vec(:))==0.0)
%! assert(norm(bessel_Jn_sc_err(:)-bessel_Jn_vec_err(:))==0.0)

%!test # (double, double) to double
%! bessel_Jnu_sc=zeros(N,1);
%! bessel_Jnu_sc_err=zeros(N,1);
%! for i=1:N
%!    [bessel_Jnu_sc(i) bessel_Jnu_sc_err(i)] = gsl_sf_bessel_Jnu(xd(i),xd2(i));
%! end
%! [bessel_Jnu_vec bessel_Jnu_vec_err] = gsl_sf_bessel_Jnu(xd,xd2);
%! bessel_Jnu_val = gsl_sf_bessel_Jnu(xd,xd2);
%! assert(norm(bessel_Jnu_val(:)-bessel_Jnu_vec(:))==0.0)
%! assert(norm(bessel_Jnu_sc(:)-bessel_Jnu_vec(:))==0.0)
%! assert(norm(bessel_Jnu_sc_err(:)-bessel_Jnu_vec_err(:))==0.0)

%!test # (double, mode) to double
%! airy_Ai_sc=zeros(N,1);
%! airy_Ai_sc_err=zeros(N,1);
%! for i=1:N
%!   [airy_Ai_sc(i) airy_Ai_sc_err(i)] = gsl_sf_airy_Ai(xd(i),M);
%! end
%! [airy_Ai_vec airy_Ai_vec_err] = gsl_sf_airy_Ai(xd,M);
%! airy_Ai_val = gsl_sf_airy_Ai(xd,M);
%! assert(norm(airy_Ai_val(:)-airy_Ai_vec(:))==0.0)
%! assert(norm(airy_Ai_sc(:)-airy_Ai_vec(:))==0.0)
%! assert(norm(airy_Ai_sc_err(:)-airy_Ai_vec_err(:))==0.0)

%!test # (double, double, mode) to double
%! ellint_E_sc=zeros(N,1);
%! ellint_E_sc_err=zeros(N,1);
%! for i=1:N
%!   [ellint_E_sc(i) ellint_E_sc_err(i)] = gsl_sf_ellint_E(xd(i),xd2(i),M);
%! end
%! [ellint_E_vec ellint_E_vec_err] = gsl_sf_ellint_E(xd,xd2,M);
%! ellint_E_val = gsl_sf_ellint_E(xd,xd2,M);
%! assert(norm(ellint_E_val(:)-ellint_E_vec(:))==0.0)
%! assert(norm(ellint_E_sc(:)-ellint_E_vec(:))==0.0)
%! assert(norm(ellint_E_sc_err(:)-ellint_E_vec_err(:))==0.0)

%!test # (double, double, double, mode) to doubl
%! ellint_P_sc=zeros(N,1);
%! ellint_P_sc_err=zeros(N,1);
%! for i=1:N
%!   [ellint_P_sc(i) ellint_P_sc_err(i)] = gsl_sf_ellint_P(xd(i),xd2(i),xd3(i),M);
%! end
%! [ellint_P_vec ellint_P_vec_err] = gsl_sf_ellint_P(xd,xd2,xd3,M);
%! ellint_P_val = gsl_sf_ellint_P(xd,xd2,xd3,M);
%! assert(norm(ellint_P_val(:)-ellint_P_vec(:))==0.0)
%! assert(norm(ellint_P_sc(:)-ellint_P_vec(:))==0.0)
%! assert(norm(ellint_P_sc_err(:)-ellint_P_vec_err(:))==0.0)

%!test # (double, double, double, double, mode) to double
%! ellint_RJ_sc=zeros(N,1);
%! ellint_RJ_sc_err=zeros(N,1);
%! for i=1:N
%!   [ellint_RJ_sc(i) ellint_RJ_sc_err(i)] = gsl_sf_ellint_RJ(xd(i),xd2(i),xd3(i),xd4(i),M);
%! end
%! [ellint_RJ_vec ellint_RJ_vec_err] = gsl_sf_ellint_RJ(xd,xd2,xd3,xd4,M);
%! ellint_RJ_val = gsl_sf_ellint_RJ(xd,xd2,xd3,xd4,M);
%! assert(norm(ellint_RJ_val(:)-ellint_RJ_vec(:))==0.0)
%! assert(norm(ellint_RJ_sc(:)-ellint_RJ_vec(:))==0.0)
%! assert(norm(ellint_RJ_sc_err(:)-ellint_RJ_vec_err(:))==0.0)

%!test # int to double
%! airy_zero_Ai_sc=zeros(N,1);
%! airy_zero_Ai_sc_err=zeros(N,1);
%! for i=1:N
%!   [airy_zero_Ai_sc(i) airy_zero_Ai_sc_err(i)] = gsl_sf_airy_zero_Ai(xi(i));
%! end
%! [airy_zero_Ai_vec airy_zero_Ai_vec_err] = gsl_sf_airy_zero_Ai(xi);
%! airy_zero_Ai_val = gsl_sf_airy_zero_Ai(xi);
%! assert(norm(airy_zero_Ai_val(:)-airy_zero_Ai_vec(:))==0.0)
%! assert(norm(airy_zero_Ai_sc(:)-airy_zero_Ai_vec(:))==0.0)
%! assert(norm(airy_zero_Ai_sc_err(:)-airy_zero_Ai_vec_err(:))==0.0)

%!test # (int, double, double) to double
%! conicalP_cyl_reg_sc=zeros(N,1);
%! conicalP_cyl_reg_sc_err=zeros(N,1);
%! for i=1:N
%!   [conicalP_cyl_reg_sc(i) conicalP_cyl_reg_sc_err(i)] = gsl_sf_conicalP_cyl_reg(xi(i),xd(i),xd2(i));
%! end
%! [conicalP_cyl_reg_vec conicalP_cyl_reg_vec_err] = gsl_sf_conicalP_cyl_reg(xi,xd,xd2);
%! conicalP_cyl_reg_val = gsl_sf_conicalP_cyl_reg(xi,xd,xd2);
%! assert(norm(conicalP_cyl_reg_val(:)-conicalP_cyl_reg_vec(:))==0.0)
%! assert(norm(conicalP_cyl_reg_sc(:)-conicalP_cyl_reg_vec(:))==0.0)
%! assert(norm(conicalP_cyl_reg_sc_err(:)-conicalP_cyl_reg_vec_err(:))==0.0)

%!test # (int, int, double) to double
%! hyperg_U_int_sc=zeros(N,1);
%! hyperg_U_int_sc_err=zeros(N,1);
%! for i=1:N
%!   [hyperg_U_int_sc(i) hyperg_U_int_sc_err(i)] = gsl_sf_hyperg_U_int(xi(i),xi2(i),xd(i));
%! end
%! [hyperg_U_int_vec hyperg_U_int_vec_err] = gsl_sf_hyperg_U_int(xi,xi2,xd);
%! hyperg_U_int_val = gsl_sf_hyperg_U_int(xi,xi2,xd);
%! assert(norm(hyperg_U_int_val(:)-hyperg_U_int_vec(:))==0.0)
%! assert(norm(hyperg_U_int_sc(:)-hyperg_U_int_vec(:))==0.0)
%! assert(norm(hyperg_U_int_sc_err(:)-hyperg_U_int_vec_err(:))==0.0)

%!test # (int, int, double, double) to double
%! # Function has limits: n>=1, l = 0 .. n-1
%! n = max (xi, xi2) + 1;
%! l = min (xi, xi2);
%! hydrogenicR_sc=zeros(N,1);
%! hydrogenicR_sc_err=zeros(N,1);
%! for i=1:N
%!   [hydrogenicR_sc(i) hydrogenicR_sc_err(i)] = gsl_sf_hydrogenicR(n(i),l(i),xd(i),xd2(i));
%! end
%! [hydrogenicR_vec hydrogenicR_vec_err] = gsl_sf_hydrogenicR(n,l,xd,xd2);
%! hydrogenicR_val = gsl_sf_hydrogenicR(n,l,xd,xd2);
%! assert(norm(hydrogenicR_val(:)-hydrogenicR_vec(:))==0.0)
%! assert(norm(hydrogenicR_sc(:)-hydrogenicR_vec(:))==0.0)
%! assert(norm(hydrogenicR_sc_err(:)-hydrogenicR_vec_err(:))==0.0)

%!test # (double, int) to double
%! bessel_zero_Jnu_sc=zeros(N,1);
%! bessel_zero_Jnu_sc_err=zeros(N,1);
%! for i=1:N
%!   [bessel_zero_Jnu_sc(i) bessel_zero_Jnu_sc_err(i)] = gsl_sf_bessel_zero_Jnu(xd(i),xi(i));
%! end
%! [bessel_zero_Jnu_vec bessel_zero_Jnu_vec_err] = gsl_sf_bessel_zero_Jnu(xd,xi);
%! bessel_zero_Jnu_val = gsl_sf_bessel_zero_Jnu(xd,xi);
%! assert(norm(bessel_zero_Jnu_val(:)-bessel_zero_Jnu_vec(:))==0.0)
%! assert(norm(bessel_zero_Jnu_sc(:)-bessel_zero_Jnu_vec(:))==0.0)
%! assert(norm(bessel_zero_Jnu_sc_err(:)-bessel_zero_Jnu_vec_err(:))==0.0)

%!test # (double, double, double) to double
%! hyperg_U_sc=zeros(N,1);
%! hyperg_U_sc_err=zeros(N,1);
%! for i=1:N
%!   [hyperg_U_sc(i) hyperg_U_sc_err(i)] = gsl_sf_hyperg_U(xd(i),xd2(i),xd3(i));
%! end
%! [hyperg_U_vec hyperg_U_vec_err] = gsl_sf_hyperg_U(xd,xd2,xd3);
%! hyperg_U_val = gsl_sf_hyperg_U(xd,xd2,xd3);
%! assert(norm(hyperg_U_val(:)-hyperg_U_vec(:))==0.0)
%! assert(norm(hyperg_U_sc(:)-hyperg_U_vec(:))==0.0)
%! assert(norm(hyperg_U_sc_err(:)-hyperg_U_vec_err(:))==0.0)

%!test # (double, double, double, double) to double
%! hyperg_2F1_sc=zeros(N,1);
%! hyperg_2F1_sc_err=zeros(N,1);
%! for i=1:N
%!   [hyperg_2F1_sc(i) hyperg_2F1_sc_err(i)] = gsl_sf_hyperg_2F1(xd(i),xd2(i),xd3(i),xd4(i));
%! end
%! [hyperg_2F1_vec hyperg_2F1_vec_err] = gsl_sf_hyperg_2F1(xd,xd2,xd3,xd4);
%! hyperg_2F1_val = gsl_sf_hyperg_2F1(xd,xd2,xd3,xd4);
%! assert(norm(hyperg_2F1_val(:)-hyperg_2F1_vec(:))==0.0)
%! assert(norm(hyperg_2F1_sc(:)-hyperg_2F1_vec(:))==0.0)
%! assert(norm(hyperg_2F1_sc_err(:)-hyperg_2F1_vec_err(:))==0.0)

%!test # unsigned int to double
%! fact_sc=zeros(N,1);
%! fact_sc_err=zeros(N,1);
%! for i=1:N
%!   [fact_sc(i) fact_sc_err(i)] = gsl_sf_fact(xi(i));
%! end
%! [fact_vec fact_vec_err] = gsl_sf_fact(xi);
%! fact_val = gsl_sf_fact(xi);
%! assert(norm(fact_val(:)-fact_vec(:))==0.0)
%! assert(norm(fact_sc(:)-fact_vec(:))==0.0)
%! assert(norm(fact_sc_err(:)-fact_vec_err(:))==0.0)

%!test # (unsigned int, unsigned int) to double
%! choose_sc=zeros(N,1);
%! choose_sc_err=zeros(N,1);
%! # Parameters must satisfy n>m
%! n = max (xi, xi2) + 1;
%! m = min (xi, xi2);
%! for i=1:N
%!   [choose_sc(i) choose_sc_err(i)] = gsl_sf_choose(n(i),m(i));
%! end
%! [choose_vec choose_vec_err] = gsl_sf_choose(n,m);
%! choose_val = gsl_sf_choose(n,m);
%! assert(norm(choose_val(:)-choose_vec(:))==0.0)
%! assert(norm(choose_sc(:)-choose_vec(:))==0.0)
%! assert(norm(choose_sc_err(:)-choose_vec_err(:))==0.0)


% Test bessel_jl_array (LD_D_array.cc.template)

%!test
%! lmax = 3;
%! y = gsl_sf_bessel_jl_array (lmax, 1.33);
%! assert (size (y), [1 lmax+1]);
%! assert (isa (y, 'double') && all (isfinite (y)))

%!error<Invalid call> gsl_sf_bessel_jl_array ()              # ERROR: not enought input args
%!error<Invalid call> gsl_sf_bessel_jl_array (3)             # ERROR: not enought input args
%!error<Invalid call> gsl_sf_bessel_jl_array (3, 1.33, 7)    # ERROR: too many input args
%!error<negative>     gsl_sf_bessel_jl_array (-1, 1.2)       # ERROR: arg1 < 0
%!error<upper limit>  gsl_sf_bessel_jl_array (10^100, 1.2)   # ERROR: arg1 overflow
%!error<integer>      gsl_sf_bessel_jl_array (0.5, 2)        # ERROR: arg1 non-integer
%!error<complex>      gsl_sf_bessel_jl_array (3 + 1i, 1.33)  # ERROR: arg1 complex
%!error<complex>      gsl_sf_bessel_jl_array (3, 1.33 + 1i)  # ERROR: arg2 complex
