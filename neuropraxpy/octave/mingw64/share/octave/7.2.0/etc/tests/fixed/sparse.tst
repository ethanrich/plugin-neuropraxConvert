## !!! DO NOT EDIT !!!
## THIS IS AN AUTOMATICALLY GENERATED FILE
## modify build-sparse-tests.sh to generate the tests you need.
##
## test_sparse
##
##    run preset sparse tests.  All should pass.
function [passes, tests] = test_sparse
  disp ("writing test output to sptest.log");
  test ("sparse.tst", "normal", "sptest.log");
endfunction


# ==============================================================


# ==============================================================


%!test # segfault test from edd@debian.org
%! n = 510;
%! sparse (kron ((1:n)', ones (n,1)), kron (ones (n,1), (1:n)'), ones (n));

%% segfault tests from Fabian@isas-berlin.de
%% Note that the last four do not fail, but rather give a warning
%% of a singular matrix, which is consistent with the full matrix
%% behavior.  They are therefore disabled.
%!testif HAVE_UMFPACK
%! assert (inv (sparse ([1,1;1,1+i])), sparse ([1-1i,1i;1i,-1i]), 10*eps);
%#!error inv ( sparse ([1,1;1,1]  ) );
%#!error inv ( sparse ([0,0;0,1]  ) );
%#!error inv ( sparse ([0,0;0,1+i]) );
%#!error inv ( sparse ([0,0;0,0]  ) );

%% error handling in constructor
%!error sparse (1,[2,3],[1,2,3])
%!error sparse ([1,1],[1,1],[1,2],3,3,"invalid")
%!error sparse ([1,3],[1,-4],[3,5],2,2)
%!error sparse ([1,3],[1,-4],[3,5i],2,2)
%!error sparse (-1,-1,1)

# ==============================================================

%!shared bf
%!test bf=realmin;
%% Make sure newly introduced zeros get eaten
%!assert (nnz (sparse ([bf,bf,1]).^realmax), 1)
%!assert (nnz (sparse ([1,bf,bf]).^realmax), 1)
%!assert (nnz (sparse ([bf,bf,bf]).^realmax), 0)

%!assert (nnz (sparse ([bf;bf;1]).^realmax), 1)
%!assert (nnz (sparse ([1;bf;bf]).^realmax), 1)
%!assert (nnz (sparse ([0.5;bf;bf]).^realmax), 0)

%!assert (nnz (sparse ([bf,bf,1])*realmin), 1)
%!assert (nnz (sparse ([1,bf,bf])*realmin), 1)
%!assert (nnz (sparse ([bf,bf,bf])*realmin), 0)

%!assert (nnz (sparse ([bf;bf;1])*realmin), 1)
%!assert (nnz (sparse ([1;bf;bf])*realmin), 1)
%!assert (nnz (sparse ([bf;bf;bf])*realmin), 0)

%!test bf=realmin+realmin*1i;
%% Make sure newly introduced zeros get eaten
%!assert (nnz (sparse ([bf,bf,1]).^realmax), 1)
%!assert (nnz (sparse ([1,bf,bf]).^realmax), 1)
%!assert (nnz (sparse ([bf,bf,bf]).^realmax), 0)

%!assert (nnz (sparse ([bf;bf;1]).^realmax), 1)
%!assert (nnz (sparse ([1;bf;bf]).^realmax), 1)
%!assert (nnz (sparse ([0.5;bf;bf]).^realmax), 0)

%!assert (nnz (sparse ([bf,bf,1])*realmin), 1)
%!assert (nnz (sparse ([1,bf,bf])*realmin), 1)
%!assert (nnz (sparse ([bf,bf,bf])*realmin), 0)

%!assert (nnz (sparse ([bf;bf;1])*realmin), 1)
%!assert (nnz (sparse ([1;bf;bf])*realmin), 1)
%!assert (nnz (sparse ([bf;bf;bf])*realmin), 0)

%!assert (nnz (sparse ([-1,realmin,realmin]).^1.5), 1)
%!assert (nnz (sparse ([-1,realmin,realmin,1]).^1.5), 2)

## Make sure scalar v==0 doesn't confuse matters
%!assert (nnz (sparse (1,1,0)), 0)
%!assert (nnz (sparse (eye (3))*0), 0)
%!assert (nnz (sparse (eye (3))-sparse (eye (3))), 0)
%!assert (full (sparse (eye (3))/0), full (eye (3)/0))


# ==============================================================

%!shared as,af,bs,bf
%!test af=[1+1i,2-1i,0,0;0,0,0,3+2i;0,0,0,4];
%!test bf=3;
%!test as = sparse (af);
%!test bs = bf;
%% Elementwise binary tests (uses as,af,bs,bf,scalar)
%!assert (as==bs, sparse (af==bf))
%!assert (bf==as, sparse (bf==af))

%!assert (as!=bf, sparse (af!=bf))
%!assert (bf!=as, sparse (bf!=af))

%!assert (as+bf, af+bf)
%!assert (bf+as, bf+af)

%!assert (as-bf, af-bf)
%!assert (bf-as, bf-af)

%!assert (as.*bf, sparse (af.*bf))
%!assert (bf.*as, sparse (bf.*af))

%!assert (as./bf, sparse (af./bf), 100*eps)
%!assert (bf.\as, sparse (bf.\af), 100*eps)

%!test
%! sv = as.^bf;
%! fv = af.^bf;
%! idx = find (af!=0);
%! assert (sv(:)(idx), sparse (fv(:)(idx)), 100*eps);

%% real values can be ordered (uses as,af)
%!assert (as<=bf, sparse (af<=bf))
%!assert (bf<=as, sparse (bf<=af))

%!assert (as>=bf, sparse (af>=bf))
%!assert (bf>=as, sparse (bf>=af))

%!assert (as<bf, sparse (af<bf))
%!assert (bf<as, sparse (bf<af))

%!assert (as>bf, sparse (af>bf))
%!assert (bf>as, sparse (bf>af))

%!test bf = bf+1i;
%!test bs = bf;
%% Elementwise binary tests (uses as,af,bs,bf,scalar)
%!assert (as==bs, sparse (af==bf))
%!assert (bf==as, sparse (bf==af))

%!assert (as!=bf, sparse (af!=bf))
%!assert (bf!=as, sparse (bf!=af))

%!assert (as+bf, af+bf)
%!assert (bf+as, bf+af)

%!assert (as-bf, af-bf)
%!assert (bf-as, bf-af)

%!assert (as.*bf, sparse (af.*bf))
%!assert (bf.*as, sparse (bf.*af))

%!assert (as./bf, sparse (af./bf), 100*eps)
%!assert (bf.\as, sparse (bf.\af), 100*eps)

%!test
%! sv = as.^bf;
%! fv = af.^bf;
%! idx = find (af!=0);
%! assert (sv(:)(idx), sparse (fv(:)(idx)), 100*eps);


# ==============================================================

%!test af=[1+1i,2-1i,0,0;0,0,0,3+2i;0,0,0,4];
%!test bf=[0,1-1i,0,0;2+1i,0,0,0;3-1i,2+3i,0,0];
%!test as = sparse(af);
%!test bs = sparse(bf);
%% Unary matrix tests (uses af,as)
%!assert (abs(as), sparse (abs(af)))
%!assert (acos(as), sparse (acos(af)))
%!assert (acosh(as), sparse (acosh(af)))
%!assert (angle(as), sparse (angle(af)))
%!assert (arg(as), sparse (arg(af)))
%!assert (asin(as), sparse (asin(af)))
%!assert (asinh(as), sparse (asinh(af)))
%!assert (atan(as), sparse (atan(af)))
%!assert (atanh(as), sparse (atanh(af)))
%!assert (ceil(as), sparse (ceil(af)))
%!assert (conj(as), sparse (conj(af)))
%!assert (cos(as), sparse (cos(af)))
%!assert (cosh(as), sparse (cosh(af)))
%!assert (exp(as), sparse (exp(af)))
%!assert (isfinite(as), sparse (isfinite(af)))
%!assert (fix(as), sparse (fix(af)))
%!assert (floor(as), sparse (floor(af)))
%!assert (imag(as), sparse (imag(af)))
%!assert (isinf(as), sparse (isinf(af)))
%!assert (isna(as), sparse (isna(af)))
%!assert (isnan(as), sparse (isnan(af)))
%!assert (log(as), sparse (log(af)))
%!assert (real(as), sparse (real(af)))
%!assert (round(as), sparse (round(af)))
%!assert (sign(as), sparse (sign(af)))
%!assert (sin(as), sparse (sin(af)))
%!assert (sinh(as), sparse (sinh(af)))
%!assert (sqrt(as), sparse (sqrt(af)))
%!assert (tan(as), sparse (tan(af)))
%!assert (tanh(as), sparse (tanh(af)))
%!assert (issparse (abs (as))  && isreal (abs (as)))
%!assert (issparse (real (as)) && isreal (real (as)))
%!assert (issparse (imag (as)) && isreal (imag (as)))

%% Unary matrix tests (uses af,as)
%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (1)
%!     assert (erf(as), sparse (erf(af)));
%!   else
%!     assert (erf(as), erf(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (1)
%!     assert (erfc(as), sparse (erfc(af)));
%!   else
%!     assert (erfc(as), erfc(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isalnum(as), sparse (isalnum(af)));
%!   else
%!     assert (isalnum(as), isalnum(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isalpha(as), sparse (isalpha(af)));
%!   else
%!     assert (isalpha(as), isalpha(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isascii(as), sparse (isascii(af)));
%!   else
%!     assert (isascii(as), isascii(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (iscntrl(as), sparse (iscntrl(af)));
%!   else
%!     assert (iscntrl(as), iscntrl(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isdigit(as), sparse (isdigit(af)));
%!   else
%!     assert (isdigit(as), isdigit(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isgraph(as), sparse (isgraph(af)));
%!   else
%!     assert (isgraph(as), isgraph(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (islower(as), sparse (islower(af)));
%!   else
%!     assert (islower(as), islower(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isprint(as), sparse (isprint(af)));
%!   else
%!     assert (isprint(as), isprint(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (ispunct(as), sparse (ispunct(af)));
%!   else
%!     assert (ispunct(as), ispunct(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isspace(as), sparse (isspace(af)));
%!   else
%!     assert (isspace(as), isspace(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isupper(as), sparse (isupper(af)));
%!   else
%!     assert (isupper(as), isupper(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isxdigit(as), sparse (isxdigit(af)));
%!   else
%!     assert (isxdigit(as), isxdigit(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");


%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   assert (tolower (as), as);
%!   assert (toupper (as), as);
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%% Unary matrix tests (uses af,as)
%!assert (issparse (as))
%!assert (!issparse (af))
%!assert (! (issparse (af) && iscomplex (af)))
%!assert (! (issparse (af) && isreal (af)))
%!assert (sum (as), sparse (sum (af)))
%!assert (sum (as,1), sparse (sum (af,1)))
%!assert (sum (as,2), sparse (sum (af,2)))
%!assert (cumsum (as), sparse (cumsum (af)))
%!assert (cumsum (as,1), sparse (cumsum (af,1)))
%!assert (cumsum (as,2), sparse (cumsum (af,2)))
%!assert (sumsq (as), sparse (sumsq (af)))
%!assert (sumsq (as,1), sparse (sumsq (af,1)))
%!assert (sumsq (as,2), sparse (sumsq (af,2)))
%!assert (prod (as), sparse (prod (af)))
%!assert (prod (as,1), sparse (prod (af,1)))
%!assert (prod (as,2), sparse (prod (af,2)))
%!assert (cumprod (as), sparse (cumprod (af)))
%!assert (cumprod (as,1), sparse (cumprod (af,1)))
%!assert (cumprod (as,2), sparse (cumprod (af,2)))

%!assert (min (as), sparse (min (af)))
%!assert (full (min (as(:))), min (af(:)))
%!assert (min (as,[],1), sparse (min (af,[],1)))
%!assert (min (as,[],2), sparse (min (af,[],2)))
%!assert (min (as,[],1), sparse (min (af,[],1)))
%!assert (min (as,0), sparse (min (af,0)))
%!assert (min (as,bs), sparse (min (af,bf)))
%!assert (max (as), sparse (max (af)))
%!assert (full (max (as(:))), max (af(:)))
%!assert (max (as,[],1), sparse (max (af,[],1)))
%!assert (max (as,[],2), sparse (max (af,[],2)))
%!assert (max (as,[],1), sparse (max (af,[],1)))
%!assert (max (as,0), sparse (max (af,0)))
%!assert (max (as,bs), sparse (max (af,bf)))

%!assert (as==as)
%!assert (as==af)
%!assert (af==as)
%!test
%! [ii,jj,vv,nr,nc] = find (as);
%! assert (af, full (sparse (ii,jj,vv,nr,nc)));
%!assert (nnz (as), sum (af(:)!=0))
%!assert (nnz (as), nnz (af))
%!assert (issparse (as.'))
%!assert (issparse (as'))
%!assert (issparse (-as))
%!assert (!as, sparse (!af))
%!assert (as.', sparse (af.'))
%!assert (as',  sparse (af'))
%!assert (-as, sparse (-af))
%!assert (!as, sparse (!af))
%!error [i,j] = size (af);as(i-1,j+1)
%!error [i,j] = size (af);as(i+1,j-1)
%!test
%! [Is,Js,Vs] = find (as);
%! [If,Jf,Vf] = find (af);
%! assert (Is, If);
%! assert (Js, Jf);
%! assert (Vs, Vf);
%!error as(0,1)
%!error as(1,0)
%!assert (find (as), find (af))
%!test
%! [i,j,v] = find (as);
%! [m,n] = size (as);
%! x = sparse (i,j,v,m,n);
%! assert (x, as);
%!test
%! [i,j,v,m,n] = find (as);
%! x = sparse (i,j,v,m,n);
%! assert (x, as);
%!assert (issparse (horzcat (as,as)))
%!assert (issparse (vertcat (as,as)))
%!assert (issparse (cat (1,as,as)))
%!assert (issparse (cat (2,as,as)))
%!assert (issparse ([as,as]))
%!assert (issparse ([as;as]))
%!assert (horzcat (as,as), sparse ([af,af]))
%!assert (vertcat (as,as), sparse ([af;af]))
%!assert (horzcat (as,as,as), sparse ([af,af,af]))
%!assert (vertcat (as,as,as), sparse ([af;af;af]))
%!assert ([as,as], sparse ([af,af]))
%!assert ([as;as], sparse ([af;af]))
%!assert ([as,as,as], sparse ([af,af,af]))
%!assert ([as;as;as], sparse ([af;af;af]))
%!assert (cat (2,as,as), sparse ([af,af]))
%!assert (cat (1,as,as), sparse ([af;af]))
%!assert (cat (2,as,as,as), sparse ([af,af,af]))
%!assert (cat (1,as,as,as), sparse ([af;af;af]))
%!assert (issparse ([as,af]))
%!assert (issparse ([af,as]))
%!assert ([as,af], sparse ([af,af]))
%!assert ([as;af], sparse ([af;af]))

%% Elementwise binary tests (uses as,af,bs,bf,scalar)
%!assert (as==bs, sparse (af==bf))
%!assert (bf==as, sparse (bf==af))

%!assert (as!=bf, sparse (af!=bf))
%!assert (bf!=as, sparse (bf!=af))

%!assert (as+bf, af+bf)
%!assert (bf+as, bf+af)

%!assert (as-bf, af-bf)
%!assert (bf-as, bf-af)

%!assert (as.*bf, sparse (af.*bf))
%!assert (bf.*as, sparse (bf.*af))

%!assert (as./bf, sparse (af./bf), 100*eps)
%!assert (bf.\as, sparse (bf.\af), 100*eps)

%!test
%! sv = as.^bf;
%! fv = af.^bf;
%! idx = find (af!=0);
%! assert (sv(:)(idx), sparse (fv(:)(idx)), 100*eps);

%!assert (as==bs, sparse (af==bf))
%!assert (as!=bs, sparse (af!=bf))
%!assert (as+bs, sparse (af+bf))
%!assert (as-bs, sparse (af-bf))
%!assert (as.*bs, sparse (af.*bf))
%!assert (as./bs, sparse (af./bf), 100*eps)
%!test
%! sv = as.^bs;
%! fv = af.^bf;
%! idx = find (af!=0);
%! assert(sv(:)(idx), sparse (fv(:)(idx)), 100*eps);

%% Matrix-matrix operators (uses af,as,bs,bf)
%!assert (as*bf', af*bf')
%!assert (af*bs', af*bf')
%!assert (as*bs', sparse (af*bf'))

%% Matrix diagonal tests (uses af,as,bf,bs)
%!assert (diag (as), sparse (diag (af)))
%!assert (diag (bs), sparse (diag (bf)))
%!assert (diag (as,1), sparse (diag (af,1)))
%!assert (diag (bs,1), sparse (diag (bf,1)))
%!assert (diag (as,-1), sparse (diag (af,-1)))
%!assert (diag (bs,-1), sparse (diag (bf,-1)))
%!assert (diag (as(:)), sparse (diag (af(:))))
%!assert (diag (as(:),1), sparse (diag (af(:),1)))
%!assert (diag (as(:),-1), sparse (diag (af(:),-1)))
%!assert (diag (as(:)'), sparse (diag (af(:)')))
%!assert (diag (as(:)',1), sparse (diag (af(:)',1)))
%!assert (diag (as(:)',-1), sparse (diag (af(:)',-1)))
%!assert (spdiags (as,[0,1]), [diag(af,0), diag(af,1)])
%!test
%! [tb,tc] = spdiags (as);
%! assert (spdiags (tb,tc,sparse (zeros (size (as)))), as);
%! assert (spdiags (tb,tc,rows (as),columns (as)), as);

%% Matrix diagonal tests (uses af,as,bf,bs)
%!assert (reshape (as,1,prod(size(as))), sparse (reshape (af,1,prod(size(af)))))
%!assert (reshape (as,prod(size(as)),1), sparse (reshape (af,prod(size(af)),1)))
%!assert (reshape (as,fliplr(size(as))), sparse (reshape (af,fliplr(size(af)))))
%!assert (reshape (bs,1,prod(size(as))), sparse (reshape (bf,1,prod(size(af)))))
%!assert (reshape (bs,prod(size(as)),1), sparse (reshape (bf,prod(size(af)),1)))
%!assert (reshape (bs,fliplr(size(as))), sparse (reshape (bf,fliplr(size(af)))))

%!testif HAVE_UMFPACK   # permuted LU
%! [L,U] = lu (bs);
%! assert (L*U, bs, 1e-10);

%!testif HAVE_UMFPACK   # simple LU + row permutations
%! [L,U,P] = lu (bs);
%! assert (P'*L*U, bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # simple LU + row/col permutations
%! [L,U,P,Q] = lu (bs);
%! assert (P'*L*U*Q', bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # LU with vector permutations
%! [L,U,P,Q] = lu (bs,'vector');
%! assert (L (P,:)*U (:,Q), bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # LU with scaling
%! [L,U,P,Q,R] = lu (bs);
%! assert (R*P'*L*U*Q', bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);


# ==============================================================

%!test # save ascii
%! savefile = tempname ();
%! as_save = as;
%! save ("-text", savefile, "bf", "as_save", "af");
%! clear as_save;
%! load (savefile, "as_save");
%! unlink (savefile);
%! assert (as_save, sparse (af));
%!test # save binary
%! savefile = tempname ();
%! as_save = as;
%! save ("-binary", savefile, "bf", "as_save", "af");
%! clear as_save;
%! load (savefile, "as_save");
%! unlink (savefile);
%! assert (as_save, sparse (af));
%!testif HAVE_HDF5   # save hdf5
%! savefile = tempname ();
%! as_save = as;
%! save ("-hdf5", savefile, "bf", "as_save", "af");
%! clear as_save;
%! load (savefile, "as_save");
%! unlink (savefile);
%! assert (as_save, sparse (af));
## FIXME: We should skip (or mark as a known bug) the test for
## saving sparse matrices to MAT files when using 64-bit indexing since
## that is not implemented yet.
%!test # save matlab
%! savefile = tempname ();
%! as_save = as;
%! save ("-mat", savefile, "bf", "as_save", "af");
%! clear as_save;
%! load (savefile, "as_save");
%! unlink (savefile);
%! assert (as_save, sparse (af));

# ==============================================================

%!test bf = real (bf);
%!test as = sparse(af);
%!test bs = sparse(bf);
%% Unary matrix tests (uses af,as)
%!assert (abs(as), sparse (abs(af)))
%!assert (acos(as), sparse (acos(af)))
%!assert (acosh(as), sparse (acosh(af)))
%!assert (angle(as), sparse (angle(af)))
%!assert (arg(as), sparse (arg(af)))
%!assert (asin(as), sparse (asin(af)))
%!assert (asinh(as), sparse (asinh(af)))
%!assert (atan(as), sparse (atan(af)))
%!assert (atanh(as), sparse (atanh(af)))
%!assert (ceil(as), sparse (ceil(af)))
%!assert (conj(as), sparse (conj(af)))
%!assert (cos(as), sparse (cos(af)))
%!assert (cosh(as), sparse (cosh(af)))
%!assert (exp(as), sparse (exp(af)))
%!assert (isfinite(as), sparse (isfinite(af)))
%!assert (fix(as), sparse (fix(af)))
%!assert (floor(as), sparse (floor(af)))
%!assert (imag(as), sparse (imag(af)))
%!assert (isinf(as), sparse (isinf(af)))
%!assert (isna(as), sparse (isna(af)))
%!assert (isnan(as), sparse (isnan(af)))
%!assert (log(as), sparse (log(af)))
%!assert (real(as), sparse (real(af)))
%!assert (round(as), sparse (round(af)))
%!assert (sign(as), sparse (sign(af)))
%!assert (sin(as), sparse (sin(af)))
%!assert (sinh(as), sparse (sinh(af)))
%!assert (sqrt(as), sparse (sqrt(af)))
%!assert (tan(as), sparse (tan(af)))
%!assert (tanh(as), sparse (tanh(af)))
%!assert (issparse (abs (as))  && isreal (abs (as)))
%!assert (issparse (real (as)) && isreal (real (as)))
%!assert (issparse (imag (as)) && isreal (imag (as)))

%% Unary matrix tests (uses af,as)
%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (1)
%!     assert (erf(as), sparse (erf(af)));
%!   else
%!     assert (erf(as), erf(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (1)
%!     assert (erfc(as), sparse (erfc(af)));
%!   else
%!     assert (erfc(as), erfc(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isalnum(as), sparse (isalnum(af)));
%!   else
%!     assert (isalnum(as), isalnum(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isalpha(as), sparse (isalpha(af)));
%!   else
%!     assert (isalpha(as), isalpha(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isascii(as), sparse (isascii(af)));
%!   else
%!     assert (isascii(as), isascii(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (iscntrl(as), sparse (iscntrl(af)));
%!   else
%!     assert (iscntrl(as), iscntrl(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isdigit(as), sparse (isdigit(af)));
%!   else
%!     assert (isdigit(as), isdigit(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isgraph(as), sparse (isgraph(af)));
%!   else
%!     assert (isgraph(as), isgraph(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (islower(as), sparse (islower(af)));
%!   else
%!     assert (islower(as), islower(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isprint(as), sparse (isprint(af)));
%!   else
%!     assert (isprint(as), isprint(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (ispunct(as), sparse (ispunct(af)));
%!   else
%!     assert (ispunct(as), ispunct(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isspace(as), sparse (isspace(af)));
%!   else
%!     assert (isspace(as), isspace(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isupper(as), sparse (isupper(af)));
%!   else
%!     assert (isupper(as), isupper(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isxdigit(as), sparse (isxdigit(af)));
%!   else
%!     assert (isxdigit(as), isxdigit(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");


%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   assert (tolower (as), as);
%!   assert (toupper (as), as);
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%% Unary matrix tests (uses af,as)
%!assert (issparse (as))
%!assert (!issparse (af))
%!assert (! (issparse (af) && iscomplex (af)))
%!assert (! (issparse (af) && isreal (af)))
%!assert (sum (as), sparse (sum (af)))
%!assert (sum (as,1), sparse (sum (af,1)))
%!assert (sum (as,2), sparse (sum (af,2)))
%!assert (cumsum (as), sparse (cumsum (af)))
%!assert (cumsum (as,1), sparse (cumsum (af,1)))
%!assert (cumsum (as,2), sparse (cumsum (af,2)))
%!assert (sumsq (as), sparse (sumsq (af)))
%!assert (sumsq (as,1), sparse (sumsq (af,1)))
%!assert (sumsq (as,2), sparse (sumsq (af,2)))
%!assert (prod (as), sparse (prod (af)))
%!assert (prod (as,1), sparse (prod (af,1)))
%!assert (prod (as,2), sparse (prod (af,2)))
%!assert (cumprod (as), sparse (cumprod (af)))
%!assert (cumprod (as,1), sparse (cumprod (af,1)))
%!assert (cumprod (as,2), sparse (cumprod (af,2)))

%!assert (min (as), sparse (min (af)))
%!assert (full (min (as(:))), min (af(:)))
%!assert (min (as,[],1), sparse (min (af,[],1)))
%!assert (min (as,[],2), sparse (min (af,[],2)))
%!assert (min (as,[],1), sparse (min (af,[],1)))
%!assert (min (as,0), sparse (min (af,0)))
%!assert (min (as,bs), sparse (min (af,bf)))
%!assert (max (as), sparse (max (af)))
%!assert (full (max (as(:))), max (af(:)))
%!assert (max (as,[],1), sparse (max (af,[],1)))
%!assert (max (as,[],2), sparse (max (af,[],2)))
%!assert (max (as,[],1), sparse (max (af,[],1)))
%!assert (max (as,0), sparse (max (af,0)))
%!assert (max (as,bs), sparse (max (af,bf)))

%!assert (as==as)
%!assert (as==af)
%!assert (af==as)
%!test
%! [ii,jj,vv,nr,nc] = find (as);
%! assert (af, full (sparse (ii,jj,vv,nr,nc)));
%!assert (nnz (as), sum (af(:)!=0))
%!assert (nnz (as), nnz (af))
%!assert (issparse (as.'))
%!assert (issparse (as'))
%!assert (issparse (-as))
%!assert (!as, sparse (!af))
%!assert (as.', sparse (af.'))
%!assert (as',  sparse (af'))
%!assert (-as, sparse (-af))
%!assert (!as, sparse (!af))
%!error [i,j] = size (af);as(i-1,j+1)
%!error [i,j] = size (af);as(i+1,j-1)
%!test
%! [Is,Js,Vs] = find (as);
%! [If,Jf,Vf] = find (af);
%! assert (Is, If);
%! assert (Js, Jf);
%! assert (Vs, Vf);
%!error as(0,1)
%!error as(1,0)
%!assert (find (as), find (af))
%!test
%! [i,j,v] = find (as);
%! [m,n] = size (as);
%! x = sparse (i,j,v,m,n);
%! assert (x, as);
%!test
%! [i,j,v,m,n] = find (as);
%! x = sparse (i,j,v,m,n);
%! assert (x, as);
%!assert (issparse (horzcat (as,as)))
%!assert (issparse (vertcat (as,as)))
%!assert (issparse (cat (1,as,as)))
%!assert (issparse (cat (2,as,as)))
%!assert (issparse ([as,as]))
%!assert (issparse ([as;as]))
%!assert (horzcat (as,as), sparse ([af,af]))
%!assert (vertcat (as,as), sparse ([af;af]))
%!assert (horzcat (as,as,as), sparse ([af,af,af]))
%!assert (vertcat (as,as,as), sparse ([af;af;af]))
%!assert ([as,as], sparse ([af,af]))
%!assert ([as;as], sparse ([af;af]))
%!assert ([as,as,as], sparse ([af,af,af]))
%!assert ([as;as;as], sparse ([af;af;af]))
%!assert (cat (2,as,as), sparse ([af,af]))
%!assert (cat (1,as,as), sparse ([af;af]))
%!assert (cat (2,as,as,as), sparse ([af,af,af]))
%!assert (cat (1,as,as,as), sparse ([af;af;af]))
%!assert (issparse ([as,af]))
%!assert (issparse ([af,as]))
%!assert ([as,af], sparse ([af,af]))
%!assert ([as;af], sparse ([af;af]))

%% Elementwise binary tests (uses as,af,bs,bf,scalar)
%!assert (as==bs, sparse (af==bf))
%!assert (bf==as, sparse (bf==af))

%!assert (as!=bf, sparse (af!=bf))
%!assert (bf!=as, sparse (bf!=af))

%!assert (as+bf, af+bf)
%!assert (bf+as, bf+af)

%!assert (as-bf, af-bf)
%!assert (bf-as, bf-af)

%!assert (as.*bf, sparse (af.*bf))
%!assert (bf.*as, sparse (bf.*af))

%!assert (as./bf, sparse (af./bf), 100*eps)
%!assert (bf.\as, sparse (bf.\af), 100*eps)

%!test
%! sv = as.^bf;
%! fv = af.^bf;
%! idx = find (af!=0);
%! assert (sv(:)(idx), sparse (fv(:)(idx)), 100*eps);

%!assert (as==bs, sparse (af==bf))
%!assert (as!=bs, sparse (af!=bf))
%!assert (as+bs, sparse (af+bf))
%!assert (as-bs, sparse (af-bf))
%!assert (as.*bs, sparse (af.*bf))
%!assert (as./bs, sparse (af./bf), 100*eps)
%!test
%! sv = as.^bs;
%! fv = af.^bf;
%! idx = find (af!=0);
%! assert(sv(:)(idx), sparse (fv(:)(idx)), 100*eps);

%% Matrix-matrix operators (uses af,as,bs,bf)
%!assert (as*bf', af*bf')
%!assert (af*bs', af*bf')
%!assert (as*bs', sparse (af*bf'))

%% Matrix diagonal tests (uses af,as,bf,bs)
%!assert (diag (as), sparse (diag (af)))
%!assert (diag (bs), sparse (diag (bf)))
%!assert (diag (as,1), sparse (diag (af,1)))
%!assert (diag (bs,1), sparse (diag (bf,1)))
%!assert (diag (as,-1), sparse (diag (af,-1)))
%!assert (diag (bs,-1), sparse (diag (bf,-1)))
%!assert (diag (as(:)), sparse (diag (af(:))))
%!assert (diag (as(:),1), sparse (diag (af(:),1)))
%!assert (diag (as(:),-1), sparse (diag (af(:),-1)))
%!assert (diag (as(:)'), sparse (diag (af(:)')))
%!assert (diag (as(:)',1), sparse (diag (af(:)',1)))
%!assert (diag (as(:)',-1), sparse (diag (af(:)',-1)))
%!assert (spdiags (as,[0,1]), [diag(af,0), diag(af,1)])
%!test
%! [tb,tc] = spdiags (as);
%! assert (spdiags (tb,tc,sparse (zeros (size (as)))), as);
%! assert (spdiags (tb,tc,rows (as),columns (as)), as);

%% Matrix diagonal tests (uses af,as,bf,bs)
%!assert (reshape (as,1,prod(size(as))), sparse (reshape (af,1,prod(size(af)))))
%!assert (reshape (as,prod(size(as)),1), sparse (reshape (af,prod(size(af)),1)))
%!assert (reshape (as,fliplr(size(as))), sparse (reshape (af,fliplr(size(af)))))
%!assert (reshape (bs,1,prod(size(as))), sparse (reshape (bf,1,prod(size(af)))))
%!assert (reshape (bs,prod(size(as)),1), sparse (reshape (bf,prod(size(af)),1)))
%!assert (reshape (bs,fliplr(size(as))), sparse (reshape (bf,fliplr(size(af)))))

%!testif HAVE_UMFPACK   # permuted LU
%! [L,U] = lu (bs);
%! assert (L*U, bs, 1e-10);

%!testif HAVE_UMFPACK   # simple LU + row permutations
%! [L,U,P] = lu (bs);
%! assert (P'*L*U, bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # simple LU + row/col permutations
%! [L,U,P,Q] = lu (bs);
%! assert (P'*L*U*Q', bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # LU with vector permutations
%! [L,U,P,Q] = lu (bs,'vector');
%! assert (L (P,:)*U (:,Q), bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # LU with scaling
%! [L,U,P,Q,R] = lu (bs);
%! assert (R*P'*L*U*Q', bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);


# ==============================================================

%!assert (as<=bs, sparse (af<=bf))
%!assert (as>=bs, sparse (af>=bf))
%!assert (as<bs, sparse (af<bf))
%!assert (as>bs, sparse (af>bf))

# ==============================================================

%!test af = real (af);
%!test as = sparse(af);
%!test bs = sparse(bf);
%% Unary matrix tests (uses af,as)
%!assert (abs(as), sparse (abs(af)))
%!assert (acos(as), sparse (acos(af)))
%!assert (acosh(as), sparse (acosh(af)))
%!assert (angle(as), sparse (angle(af)))
%!assert (arg(as), sparse (arg(af)))
%!assert (asin(as), sparse (asin(af)))
%!assert (asinh(as), sparse (asinh(af)))
%!assert (atan(as), sparse (atan(af)))
%!assert (atanh(as), sparse (atanh(af)))
%!assert (ceil(as), sparse (ceil(af)))
%!assert (conj(as), sparse (conj(af)))
%!assert (cos(as), sparse (cos(af)))
%!assert (cosh(as), sparse (cosh(af)))
%!assert (exp(as), sparse (exp(af)))
%!assert (isfinite(as), sparse (isfinite(af)))
%!assert (fix(as), sparse (fix(af)))
%!assert (floor(as), sparse (floor(af)))
%!assert (imag(as), sparse (imag(af)))
%!assert (isinf(as), sparse (isinf(af)))
%!assert (isna(as), sparse (isna(af)))
%!assert (isnan(as), sparse (isnan(af)))
%!assert (log(as), sparse (log(af)))
%!assert (real(as), sparse (real(af)))
%!assert (round(as), sparse (round(af)))
%!assert (sign(as), sparse (sign(af)))
%!assert (sin(as), sparse (sin(af)))
%!assert (sinh(as), sparse (sinh(af)))
%!assert (sqrt(as), sparse (sqrt(af)))
%!assert (tan(as), sparse (tan(af)))
%!assert (tanh(as), sparse (tanh(af)))
%!assert (issparse (abs (as))  && isreal (abs (as)))
%!assert (issparse (real (as)) && isreal (real (as)))
%!assert (issparse (imag (as)) && isreal (imag (as)))

%% Unary matrix tests (uses af,as)
%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (1)
%!     assert (erf(as), sparse (erf(af)));
%!   else
%!     assert (erf(as), erf(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (1)
%!     assert (erfc(as), sparse (erfc(af)));
%!   else
%!     assert (erfc(as), erfc(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isalnum(as), sparse (isalnum(af)));
%!   else
%!     assert (isalnum(as), isalnum(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isalpha(as), sparse (isalpha(af)));
%!   else
%!     assert (isalpha(as), isalpha(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isascii(as), sparse (isascii(af)));
%!   else
%!     assert (isascii(as), isascii(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (iscntrl(as), sparse (iscntrl(af)));
%!   else
%!     assert (iscntrl(as), iscntrl(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isdigit(as), sparse (isdigit(af)));
%!   else
%!     assert (isdigit(as), isdigit(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isgraph(as), sparse (isgraph(af)));
%!   else
%!     assert (isgraph(as), isgraph(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (islower(as), sparse (islower(af)));
%!   else
%!     assert (islower(as), islower(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isprint(as), sparse (isprint(af)));
%!   else
%!     assert (isprint(as), isprint(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (ispunct(as), sparse (ispunct(af)));
%!   else
%!     assert (ispunct(as), ispunct(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isspace(as), sparse (isspace(af)));
%!   else
%!     assert (isspace(as), isspace(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isupper(as), sparse (isupper(af)));
%!   else
%!     assert (isupper(as), isupper(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isxdigit(as), sparse (isxdigit(af)));
%!   else
%!     assert (isxdigit(as), isxdigit(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");


%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   assert (tolower (as), as);
%!   assert (toupper (as), as);
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%% Unary matrix tests (uses af,as)
%!assert (issparse (as))
%!assert (!issparse (af))
%!assert (! (issparse (af) && iscomplex (af)))
%!assert (! (issparse (af) && isreal (af)))
%!assert (sum (as), sparse (sum (af)))
%!assert (sum (as,1), sparse (sum (af,1)))
%!assert (sum (as,2), sparse (sum (af,2)))
%!assert (cumsum (as), sparse (cumsum (af)))
%!assert (cumsum (as,1), sparse (cumsum (af,1)))
%!assert (cumsum (as,2), sparse (cumsum (af,2)))
%!assert (sumsq (as), sparse (sumsq (af)))
%!assert (sumsq (as,1), sparse (sumsq (af,1)))
%!assert (sumsq (as,2), sparse (sumsq (af,2)))
%!assert (prod (as), sparse (prod (af)))
%!assert (prod (as,1), sparse (prod (af,1)))
%!assert (prod (as,2), sparse (prod (af,2)))
%!assert (cumprod (as), sparse (cumprod (af)))
%!assert (cumprod (as,1), sparse (cumprod (af,1)))
%!assert (cumprod (as,2), sparse (cumprod (af,2)))

%!assert (min (as), sparse (min (af)))
%!assert (full (min (as(:))), min (af(:)))
%!assert (min (as,[],1), sparse (min (af,[],1)))
%!assert (min (as,[],2), sparse (min (af,[],2)))
%!assert (min (as,[],1), sparse (min (af,[],1)))
%!assert (min (as,0), sparse (min (af,0)))
%!assert (min (as,bs), sparse (min (af,bf)))
%!assert (max (as), sparse (max (af)))
%!assert (full (max (as(:))), max (af(:)))
%!assert (max (as,[],1), sparse (max (af,[],1)))
%!assert (max (as,[],2), sparse (max (af,[],2)))
%!assert (max (as,[],1), sparse (max (af,[],1)))
%!assert (max (as,0), sparse (max (af,0)))
%!assert (max (as,bs), sparse (max (af,bf)))

%!assert (as==as)
%!assert (as==af)
%!assert (af==as)
%!test
%! [ii,jj,vv,nr,nc] = find (as);
%! assert (af, full (sparse (ii,jj,vv,nr,nc)));
%!assert (nnz (as), sum (af(:)!=0))
%!assert (nnz (as), nnz (af))
%!assert (issparse (as.'))
%!assert (issparse (as'))
%!assert (issparse (-as))
%!assert (!as, sparse (!af))
%!assert (as.', sparse (af.'))
%!assert (as',  sparse (af'))
%!assert (-as, sparse (-af))
%!assert (!as, sparse (!af))
%!error [i,j] = size (af);as(i-1,j+1)
%!error [i,j] = size (af);as(i+1,j-1)
%!test
%! [Is,Js,Vs] = find (as);
%! [If,Jf,Vf] = find (af);
%! assert (Is, If);
%! assert (Js, Jf);
%! assert (Vs, Vf);
%!error as(0,1)
%!error as(1,0)
%!assert (find (as), find (af))
%!test
%! [i,j,v] = find (as);
%! [m,n] = size (as);
%! x = sparse (i,j,v,m,n);
%! assert (x, as);
%!test
%! [i,j,v,m,n] = find (as);
%! x = sparse (i,j,v,m,n);
%! assert (x, as);
%!assert (issparse (horzcat (as,as)))
%!assert (issparse (vertcat (as,as)))
%!assert (issparse (cat (1,as,as)))
%!assert (issparse (cat (2,as,as)))
%!assert (issparse ([as,as]))
%!assert (issparse ([as;as]))
%!assert (horzcat (as,as), sparse ([af,af]))
%!assert (vertcat (as,as), sparse ([af;af]))
%!assert (horzcat (as,as,as), sparse ([af,af,af]))
%!assert (vertcat (as,as,as), sparse ([af;af;af]))
%!assert ([as,as], sparse ([af,af]))
%!assert ([as;as], sparse ([af;af]))
%!assert ([as,as,as], sparse ([af,af,af]))
%!assert ([as;as;as], sparse ([af;af;af]))
%!assert (cat (2,as,as), sparse ([af,af]))
%!assert (cat (1,as,as), sparse ([af;af]))
%!assert (cat (2,as,as,as), sparse ([af,af,af]))
%!assert (cat (1,as,as,as), sparse ([af;af;af]))
%!assert (issparse ([as,af]))
%!assert (issparse ([af,as]))
%!assert ([as,af], sparse ([af,af]))
%!assert ([as;af], sparse ([af;af]))

%% Elementwise binary tests (uses as,af,bs,bf,scalar)
%!assert (as==bs, sparse (af==bf))
%!assert (bf==as, sparse (bf==af))

%!assert (as!=bf, sparse (af!=bf))
%!assert (bf!=as, sparse (bf!=af))

%!assert (as+bf, af+bf)
%!assert (bf+as, bf+af)

%!assert (as-bf, af-bf)
%!assert (bf-as, bf-af)

%!assert (as.*bf, sparse (af.*bf))
%!assert (bf.*as, sparse (bf.*af))

%!assert (as./bf, sparse (af./bf), 100*eps)
%!assert (bf.\as, sparse (bf.\af), 100*eps)

%!test
%! sv = as.^bf;
%! fv = af.^bf;
%! idx = find (af!=0);
%! assert (sv(:)(idx), sparse (fv(:)(idx)), 100*eps);

%!assert (as==bs, sparse (af==bf))
%!assert (as!=bs, sparse (af!=bf))
%!assert (as+bs, sparse (af+bf))
%!assert (as-bs, sparse (af-bf))
%!assert (as.*bs, sparse (af.*bf))
%!assert (as./bs, sparse (af./bf), 100*eps)
%!test
%! sv = as.^bs;
%! fv = af.^bf;
%! idx = find (af!=0);
%! assert(sv(:)(idx), sparse (fv(:)(idx)), 100*eps);

%% Matrix-matrix operators (uses af,as,bs,bf)
%!assert (as*bf', af*bf')
%!assert (af*bs', af*bf')
%!assert (as*bs', sparse (af*bf'))

%% Matrix diagonal tests (uses af,as,bf,bs)
%!assert (diag (as), sparse (diag (af)))
%!assert (diag (bs), sparse (diag (bf)))
%!assert (diag (as,1), sparse (diag (af,1)))
%!assert (diag (bs,1), sparse (diag (bf,1)))
%!assert (diag (as,-1), sparse (diag (af,-1)))
%!assert (diag (bs,-1), sparse (diag (bf,-1)))
%!assert (diag (as(:)), sparse (diag (af(:))))
%!assert (diag (as(:),1), sparse (diag (af(:),1)))
%!assert (diag (as(:),-1), sparse (diag (af(:),-1)))
%!assert (diag (as(:)'), sparse (diag (af(:)')))
%!assert (diag (as(:)',1), sparse (diag (af(:)',1)))
%!assert (diag (as(:)',-1), sparse (diag (af(:)',-1)))
%!assert (spdiags (as,[0,1]), [diag(af,0), diag(af,1)])
%!test
%! [tb,tc] = spdiags (as);
%! assert (spdiags (tb,tc,sparse (zeros (size (as)))), as);
%! assert (spdiags (tb,tc,rows (as),columns (as)), as);

%% Matrix diagonal tests (uses af,as,bf,bs)
%!assert (reshape (as,1,prod(size(as))), sparse (reshape (af,1,prod(size(af)))))
%!assert (reshape (as,prod(size(as)),1), sparse (reshape (af,prod(size(af)),1)))
%!assert (reshape (as,fliplr(size(as))), sparse (reshape (af,fliplr(size(af)))))
%!assert (reshape (bs,1,prod(size(as))), sparse (reshape (bf,1,prod(size(af)))))
%!assert (reshape (bs,prod(size(as)),1), sparse (reshape (bf,prod(size(af)),1)))
%!assert (reshape (bs,fliplr(size(as))), sparse (reshape (bf,fliplr(size(af)))))

%!testif HAVE_UMFPACK   # permuted LU
%! [L,U] = lu (bs);
%! assert (L*U, bs, 1e-10);

%!testif HAVE_UMFPACK   # simple LU + row permutations
%! [L,U,P] = lu (bs);
%! assert (P'*L*U, bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # simple LU + row/col permutations
%! [L,U,P,Q] = lu (bs);
%! assert (P'*L*U*Q', bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # LU with vector permutations
%! [L,U,P,Q] = lu (bs,'vector');
%! assert (L (P,:)*U (:,Q), bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # LU with scaling
%! [L,U,P,Q,R] = lu (bs);
%! assert (R*P'*L*U*Q', bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);


# ==============================================================

%!test # save ascii
%! savefile = tempname ();
%! as_save = as;
%! save ("-text", savefile, "bf", "as_save", "af");
%! clear as_save;
%! load (savefile, "as_save");
%! unlink (savefile);
%! assert (as_save, sparse (af));
%!test # save binary
%! savefile = tempname ();
%! as_save = as;
%! save ("-binary", savefile, "bf", "as_save", "af");
%! clear as_save;
%! load (savefile, "as_save");
%! unlink (savefile);
%! assert (as_save, sparse (af));
%!testif HAVE_HDF5   # save hdf5
%! savefile = tempname ();
%! as_save = as;
%! save ("-hdf5", savefile, "bf", "as_save", "af");
%! clear as_save;
%! load (savefile, "as_save");
%! unlink (savefile);
%! assert (as_save, sparse (af));
## FIXME: We should skip (or mark as a known bug) the test for
## saving sparse matrices to MAT files when using 64-bit indexing since
## that is not implemented yet.
%!test # save matlab
%! savefile = tempname ();
%! as_save = as;
%! save ("-mat", savefile, "bf", "as_save", "af");
%! clear as_save;
%! load (savefile, "as_save");
%! unlink (savefile);
%! assert (as_save, sparse (af));

# ==============================================================

%!test bf = bf+1i*(bf!=0);
%!test as = sparse(af);
%!test bs = sparse(bf);
%% Unary matrix tests (uses af,as)
%!assert (abs(as), sparse (abs(af)))
%!assert (acos(as), sparse (acos(af)))
%!assert (acosh(as), sparse (acosh(af)))
%!assert (angle(as), sparse (angle(af)))
%!assert (arg(as), sparse (arg(af)))
%!assert (asin(as), sparse (asin(af)))
%!assert (asinh(as), sparse (asinh(af)))
%!assert (atan(as), sparse (atan(af)))
%!assert (atanh(as), sparse (atanh(af)))
%!assert (ceil(as), sparse (ceil(af)))
%!assert (conj(as), sparse (conj(af)))
%!assert (cos(as), sparse (cos(af)))
%!assert (cosh(as), sparse (cosh(af)))
%!assert (exp(as), sparse (exp(af)))
%!assert (isfinite(as), sparse (isfinite(af)))
%!assert (fix(as), sparse (fix(af)))
%!assert (floor(as), sparse (floor(af)))
%!assert (imag(as), sparse (imag(af)))
%!assert (isinf(as), sparse (isinf(af)))
%!assert (isna(as), sparse (isna(af)))
%!assert (isnan(as), sparse (isnan(af)))
%!assert (log(as), sparse (log(af)))
%!assert (real(as), sparse (real(af)))
%!assert (round(as), sparse (round(af)))
%!assert (sign(as), sparse (sign(af)))
%!assert (sin(as), sparse (sin(af)))
%!assert (sinh(as), sparse (sinh(af)))
%!assert (sqrt(as), sparse (sqrt(af)))
%!assert (tan(as), sparse (tan(af)))
%!assert (tanh(as), sparse (tanh(af)))
%!assert (issparse (abs (as))  && isreal (abs (as)))
%!assert (issparse (real (as)) && isreal (real (as)))
%!assert (issparse (imag (as)) && isreal (imag (as)))

%% Unary matrix tests (uses af,as)
%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (1)
%!     assert (erf(as), sparse (erf(af)));
%!   else
%!     assert (erf(as), erf(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (1)
%!     assert (erfc(as), sparse (erfc(af)));
%!   else
%!     assert (erfc(as), erfc(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isalnum(as), sparse (isalnum(af)));
%!   else
%!     assert (isalnum(as), isalnum(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isalpha(as), sparse (isalpha(af)));
%!   else
%!     assert (isalpha(as), isalpha(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isascii(as), sparse (isascii(af)));
%!   else
%!     assert (isascii(as), isascii(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (iscntrl(as), sparse (iscntrl(af)));
%!   else
%!     assert (iscntrl(as), iscntrl(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isdigit(as), sparse (isdigit(af)));
%!   else
%!     assert (isdigit(as), isdigit(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isgraph(as), sparse (isgraph(af)));
%!   else
%!     assert (isgraph(as), isgraph(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (islower(as), sparse (islower(af)));
%!   else
%!     assert (islower(as), islower(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isprint(as), sparse (isprint(af)));
%!   else
%!     assert (isprint(as), isprint(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (ispunct(as), sparse (ispunct(af)));
%!   else
%!     assert (ispunct(as), ispunct(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isspace(as), sparse (isspace(af)));
%!   else
%!     assert (isspace(as), isspace(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isupper(as), sparse (isupper(af)));
%!   else
%!     assert (isupper(as), isupper(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   if (0)
%!     assert (isxdigit(as), sparse (isxdigit(af)));
%!   else
%!     assert (isxdigit(as), isxdigit(af));
%!   endif
%! endif
%! warning (wn2s.state, "Octave:num-to-str");


%!test
%! wn2s = warning ("query", "Octave:num-to-str");
%! warning ("off", "Octave:num-to-str");
%! if (isreal (af))
%!   assert (tolower (as), as);
%!   assert (toupper (as), as);
%! endif
%! warning (wn2s.state, "Octave:num-to-str");

%% Unary matrix tests (uses af,as)
%!assert (issparse (as))
%!assert (!issparse (af))
%!assert (! (issparse (af) && iscomplex (af)))
%!assert (! (issparse (af) && isreal (af)))
%!assert (sum (as), sparse (sum (af)))
%!assert (sum (as,1), sparse (sum (af,1)))
%!assert (sum (as,2), sparse (sum (af,2)))
%!assert (cumsum (as), sparse (cumsum (af)))
%!assert (cumsum (as,1), sparse (cumsum (af,1)))
%!assert (cumsum (as,2), sparse (cumsum (af,2)))
%!assert (sumsq (as), sparse (sumsq (af)))
%!assert (sumsq (as,1), sparse (sumsq (af,1)))
%!assert (sumsq (as,2), sparse (sumsq (af,2)))
%!assert (prod (as), sparse (prod (af)))
%!assert (prod (as,1), sparse (prod (af,1)))
%!assert (prod (as,2), sparse (prod (af,2)))
%!assert (cumprod (as), sparse (cumprod (af)))
%!assert (cumprod (as,1), sparse (cumprod (af,1)))
%!assert (cumprod (as,2), sparse (cumprod (af,2)))

%!assert (min (as), sparse (min (af)))
%!assert (full (min (as(:))), min (af(:)))
%!assert (min (as,[],1), sparse (min (af,[],1)))
%!assert (min (as,[],2), sparse (min (af,[],2)))
%!assert (min (as,[],1), sparse (min (af,[],1)))
%!assert (min (as,0), sparse (min (af,0)))
%!assert (min (as,bs), sparse (min (af,bf)))
%!assert (max (as), sparse (max (af)))
%!assert (full (max (as(:))), max (af(:)))
%!assert (max (as,[],1), sparse (max (af,[],1)))
%!assert (max (as,[],2), sparse (max (af,[],2)))
%!assert (max (as,[],1), sparse (max (af,[],1)))
%!assert (max (as,0), sparse (max (af,0)))
%!assert (max (as,bs), sparse (max (af,bf)))

%!assert (as==as)
%!assert (as==af)
%!assert (af==as)
%!test
%! [ii,jj,vv,nr,nc] = find (as);
%! assert (af, full (sparse (ii,jj,vv,nr,nc)));
%!assert (nnz (as), sum (af(:)!=0))
%!assert (nnz (as), nnz (af))
%!assert (issparse (as.'))
%!assert (issparse (as'))
%!assert (issparse (-as))
%!assert (!as, sparse (!af))
%!assert (as.', sparse (af.'))
%!assert (as',  sparse (af'))
%!assert (-as, sparse (-af))
%!assert (!as, sparse (!af))
%!error [i,j] = size (af);as(i-1,j+1)
%!error [i,j] = size (af);as(i+1,j-1)
%!test
%! [Is,Js,Vs] = find (as);
%! [If,Jf,Vf] = find (af);
%! assert (Is, If);
%! assert (Js, Jf);
%! assert (Vs, Vf);
%!error as(0,1)
%!error as(1,0)
%!assert (find (as), find (af))
%!test
%! [i,j,v] = find (as);
%! [m,n] = size (as);
%! x = sparse (i,j,v,m,n);
%! assert (x, as);
%!test
%! [i,j,v,m,n] = find (as);
%! x = sparse (i,j,v,m,n);
%! assert (x, as);
%!assert (issparse (horzcat (as,as)))
%!assert (issparse (vertcat (as,as)))
%!assert (issparse (cat (1,as,as)))
%!assert (issparse (cat (2,as,as)))
%!assert (issparse ([as,as]))
%!assert (issparse ([as;as]))
%!assert (horzcat (as,as), sparse ([af,af]))
%!assert (vertcat (as,as), sparse ([af;af]))
%!assert (horzcat (as,as,as), sparse ([af,af,af]))
%!assert (vertcat (as,as,as), sparse ([af;af;af]))
%!assert ([as,as], sparse ([af,af]))
%!assert ([as;as], sparse ([af;af]))
%!assert ([as,as,as], sparse ([af,af,af]))
%!assert ([as;as;as], sparse ([af;af;af]))
%!assert (cat (2,as,as), sparse ([af,af]))
%!assert (cat (1,as,as), sparse ([af;af]))
%!assert (cat (2,as,as,as), sparse ([af,af,af]))
%!assert (cat (1,as,as,as), sparse ([af;af;af]))
%!assert (issparse ([as,af]))
%!assert (issparse ([af,as]))
%!assert ([as,af], sparse ([af,af]))
%!assert ([as;af], sparse ([af;af]))

%% Elementwise binary tests (uses as,af,bs,bf,scalar)
%!assert (as==bs, sparse (af==bf))
%!assert (bf==as, sparse (bf==af))

%!assert (as!=bf, sparse (af!=bf))
%!assert (bf!=as, sparse (bf!=af))

%!assert (as+bf, af+bf)
%!assert (bf+as, bf+af)

%!assert (as-bf, af-bf)
%!assert (bf-as, bf-af)

%!assert (as.*bf, sparse (af.*bf))
%!assert (bf.*as, sparse (bf.*af))

%!assert (as./bf, sparse (af./bf), 100*eps)
%!assert (bf.\as, sparse (bf.\af), 100*eps)

%!test
%! sv = as.^bf;
%! fv = af.^bf;
%! idx = find (af!=0);
%! assert (sv(:)(idx), sparse (fv(:)(idx)), 100*eps);

%!assert (as==bs, sparse (af==bf))
%!assert (as!=bs, sparse (af!=bf))
%!assert (as+bs, sparse (af+bf))
%!assert (as-bs, sparse (af-bf))
%!assert (as.*bs, sparse (af.*bf))
%!assert (as./bs, sparse (af./bf), 100*eps)
%!test
%! sv = as.^bs;
%! fv = af.^bf;
%! idx = find (af!=0);
%! assert(sv(:)(idx), sparse (fv(:)(idx)), 100*eps);

%% Matrix-matrix operators (uses af,as,bs,bf)
%!assert (as*bf', af*bf')
%!assert (af*bs', af*bf')
%!assert (as*bs', sparse (af*bf'))

%% Matrix diagonal tests (uses af,as,bf,bs)
%!assert (diag (as), sparse (diag (af)))
%!assert (diag (bs), sparse (diag (bf)))
%!assert (diag (as,1), sparse (diag (af,1)))
%!assert (diag (bs,1), sparse (diag (bf,1)))
%!assert (diag (as,-1), sparse (diag (af,-1)))
%!assert (diag (bs,-1), sparse (diag (bf,-1)))
%!assert (diag (as(:)), sparse (diag (af(:))))
%!assert (diag (as(:),1), sparse (diag (af(:),1)))
%!assert (diag (as(:),-1), sparse (diag (af(:),-1)))
%!assert (diag (as(:)'), sparse (diag (af(:)')))
%!assert (diag (as(:)',1), sparse (diag (af(:)',1)))
%!assert (diag (as(:)',-1), sparse (diag (af(:)',-1)))
%!assert (spdiags (as,[0,1]), [diag(af,0), diag(af,1)])
%!test
%! [tb,tc] = spdiags (as);
%! assert (spdiags (tb,tc,sparse (zeros (size (as)))), as);
%! assert (spdiags (tb,tc,rows (as),columns (as)), as);

%% Matrix diagonal tests (uses af,as,bf,bs)
%!assert (reshape (as,1,prod(size(as))), sparse (reshape (af,1,prod(size(af)))))
%!assert (reshape (as,prod(size(as)),1), sparse (reshape (af,prod(size(af)),1)))
%!assert (reshape (as,fliplr(size(as))), sparse (reshape (af,fliplr(size(af)))))
%!assert (reshape (bs,1,prod(size(as))), sparse (reshape (bf,1,prod(size(af)))))
%!assert (reshape (bs,prod(size(as)),1), sparse (reshape (bf,prod(size(af)),1)))
%!assert (reshape (bs,fliplr(size(as))), sparse (reshape (bf,fliplr(size(af)))))

%!testif HAVE_UMFPACK   # permuted LU
%! [L,U] = lu (bs);
%! assert (L*U, bs, 1e-10);

%!testif HAVE_UMFPACK   # simple LU + row permutations
%! [L,U,P] = lu (bs);
%! assert (P'*L*U, bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # simple LU + row/col permutations
%! [L,U,P,Q] = lu (bs);
%! assert (P'*L*U*Q', bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # LU with vector permutations
%! [L,U,P,Q] = lu (bs,'vector');
%! assert (L (P,:)*U (:,Q), bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # LU with scaling
%! [L,U,P,Q,R] = lu (bs);
%! assert (R*P'*L*U*Q', bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);


# ==============================================================

%!test af = [1+1i,2-1i,0,0;0,0,0,3+2i;0,0,0,4];
%! as = sparse (af);
%!test bf = [0,1-1i,0,0;2+1i,0,0,0;3-1i,2+3i,0,0];
%!test ;# invertible matrix
%! bf = af'*bf+max (abs ([af(:);bf(:)]))*sparse (eye (columns (as)));
%! bs = sparse (bf);

%% Matrix-matrix operators (uses af,as,bs,bf)
%!assert (as/bf, af/bf, 100*eps)
%!assert (af/bs, af/bf, 100*eps)
%!assert (as/bs, sparse (af/bf), 100*eps)
%!assert (bs\af', bf\af', 100*eps)
%!assert (bf\as', bf\af', 100*eps)
%!assert (bs\as', sparse (bf\af'), 100*eps)

%!testif HAVE_UMFPACK
%! assert(det(bs+speye(size(bs))), det(bf+eye(size(bf))), 100*eps*abs(det(bf+eye(size(bf)))));

%!testif HAVE_UMFPACK
%! [l,u] = lu (sparse ([1,1;1,1]));
%! assert (l*u, [1,1;1,1], 10*eps);

%!testif HAVE_UMFPACK
%! [l,u] = lu (sparse ([1,1;1,1+i]));
%! assert (l, sparse ([1,2,2],[1,1,2],1), 10*eps);
%! assert (u, sparse ([1,1,2],[1,2,2],[1,1,1i]), 10*eps);

%!testif HAVE_UMFPACK   # permuted LU
%! [L,U] = lu (bs);
%! assert (L*U, bs, 1e-10);

%!testif HAVE_UMFPACK   # simple LU + row permutations
%! [L,U,P] = lu (bs);
%! assert (P'*L*U, bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # simple LU + row/col permutations
%! [L,U,P,Q] = lu (bs);
%! assert (P'*L*U*Q', bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # LU with vector permutations
%! [L,U,P,Q] = lu (bs,'vector');
%! assert (L(P,:)*U(:,Q), bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # LU with scaling
%! [L,U,P,Q,R] = lu (bs);
%! assert (R*P'*L*U*Q', bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # inverse
%! assert (inv (bs)*bs, sparse (eye (rows (bs))), 1e-10);

%!assert (bf\as', bf\af', 100*eps)
%!assert (bs\af', bf\af', 100*eps)
%!assert (bs\as', sparse (bf\af'), 100*eps)


# ==============================================================

%!test bf = real (bf);
%! bs = sparse (bf);
%% Matrix-matrix operators (uses af,as,bs,bf)
%!assert (as/bf, af/bf, 100*eps)
%!assert (af/bs, af/bf, 100*eps)
%!assert (as/bs, sparse (af/bf), 100*eps)
%!assert (bs\af', bf\af', 100*eps)
%!assert (bf\as', bf\af', 100*eps)
%!assert (bs\as', sparse (bf\af'), 100*eps)

%!testif HAVE_UMFPACK
%! assert(det(bs+speye(size(bs))), det(bf+eye(size(bf))), 100*eps*abs(det(bf+eye(size(bf)))));

%!testif HAVE_UMFPACK
%! [l,u] = lu (sparse ([1,1;1,1]));
%! assert (l*u, [1,1;1,1], 10*eps);

%!testif HAVE_UMFPACK
%! [l,u] = lu (sparse ([1,1;1,1+i]));
%! assert (l, sparse ([1,2,2],[1,1,2],1), 10*eps);
%! assert (u, sparse ([1,1,2],[1,2,2],[1,1,1i]), 10*eps);

%!testif HAVE_UMFPACK   # permuted LU
%! [L,U] = lu (bs);
%! assert (L*U, bs, 1e-10);

%!testif HAVE_UMFPACK   # simple LU + row permutations
%! [L,U,P] = lu (bs);
%! assert (P'*L*U, bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # simple LU + row/col permutations
%! [L,U,P,Q] = lu (bs);
%! assert (P'*L*U*Q', bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # LU with vector permutations
%! [L,U,P,Q] = lu (bs,'vector');
%! assert (L(P,:)*U(:,Q), bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # LU with scaling
%! [L,U,P,Q,R] = lu (bs);
%! assert (R*P'*L*U*Q', bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # inverse
%! assert (inv (bs)*bs, sparse (eye (rows (bs))), 1e-10);

%!assert (bf\as', bf\af', 100*eps)
%!assert (bs\af', bf\af', 100*eps)
%!assert (bs\as', sparse (bf\af'), 100*eps)


# ==============================================================

%!test af = real (af);
%! as = sparse (af);
%% Matrix-matrix operators (uses af,as,bs,bf)
%!assert (as/bf, af/bf, 100*eps)
%!assert (af/bs, af/bf, 100*eps)
%!assert (as/bs, sparse (af/bf), 100*eps)
%!assert (bs\af', bf\af', 100*eps)
%!assert (bf\as', bf\af', 100*eps)
%!assert (bs\as', sparse (bf\af'), 100*eps)

%!testif HAVE_UMFPACK
%! assert(det(bs+speye(size(bs))), det(bf+eye(size(bf))), 100*eps*abs(det(bf+eye(size(bf)))));

%!testif HAVE_UMFPACK
%! [l,u] = lu (sparse ([1,1;1,1]));
%! assert (l*u, [1,1;1,1], 10*eps);

%!testif HAVE_UMFPACK
%! [l,u] = lu (sparse ([1,1;1,1+i]));
%! assert (l, sparse ([1,2,2],[1,1,2],1), 10*eps);
%! assert (u, sparse ([1,1,2],[1,2,2],[1,1,1i]), 10*eps);

%!testif HAVE_UMFPACK   # permuted LU
%! [L,U] = lu (bs);
%! assert (L*U, bs, 1e-10);

%!testif HAVE_UMFPACK   # simple LU + row permutations
%! [L,U,P] = lu (bs);
%! assert (P'*L*U, bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # simple LU + row/col permutations
%! [L,U,P,Q] = lu (bs);
%! assert (P'*L*U*Q', bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # LU with vector permutations
%! [L,U,P,Q] = lu (bs,'vector');
%! assert (L(P,:)*U(:,Q), bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # LU with scaling
%! [L,U,P,Q,R] = lu (bs);
%! assert (R*P'*L*U*Q', bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # inverse
%! assert (inv (bs)*bs, sparse (eye (rows (bs))), 1e-10);

%!assert (bf\as', bf\af', 100*eps)
%!assert (bs\af', bf\af', 100*eps)
%!assert (bs\as', sparse (bf\af'), 100*eps)


# ==============================================================

%!test bf = bf+1i*(bf!=0);
%! bs = sparse (bf);
%% Matrix-matrix operators (uses af,as,bs,bf)
%!assert (as/bf, af/bf, 100*eps)
%!assert (af/bs, af/bf, 100*eps)
%!assert (as/bs, sparse (af/bf), 100*eps)
%!assert (bs\af', bf\af', 100*eps)
%!assert (bf\as', bf\af', 100*eps)
%!assert (bs\as', sparse (bf\af'), 100*eps)

%!testif HAVE_UMFPACK
%! assert(det(bs+speye(size(bs))), det(bf+eye(size(bf))), 100*eps*abs(det(bf+eye(size(bf)))));

%!testif HAVE_UMFPACK
%! [l,u] = lu (sparse ([1,1;1,1]));
%! assert (l*u, [1,1;1,1], 10*eps);

%!testif HAVE_UMFPACK
%! [l,u] = lu (sparse ([1,1;1,1+i]));
%! assert (l, sparse ([1,2,2],[1,1,2],1), 10*eps);
%! assert (u, sparse ([1,1,2],[1,2,2],[1,1,1i]), 10*eps);

%!testif HAVE_UMFPACK   # permuted LU
%! [L,U] = lu (bs);
%! assert (L*U, bs, 1e-10);

%!testif HAVE_UMFPACK   # simple LU + row permutations
%! [L,U,P] = lu (bs);
%! assert (P'*L*U, bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # simple LU + row/col permutations
%! [L,U,P,Q] = lu (bs);
%! assert (P'*L*U*Q', bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # LU with vector permutations
%! [L,U,P,Q] = lu (bs,'vector');
%! assert (L(P,:)*U(:,Q), bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # LU with scaling
%! [L,U,P,Q,R] = lu (bs);
%! assert (R*P'*L*U*Q', bs, 1e-10);
%! ## triangularity
%! [i,j,v] = find (L);
%! assert (i-j>=0);
%! [i,j,v] = find (U);
%! assert (j-i>=0);

%!testif HAVE_UMFPACK   # inverse
%! assert (inv (bs)*bs, sparse (eye (rows (bs))), 1e-10);

%!assert (bf\as', bf\af', 100*eps)
%!assert (bs\af', bf\af', 100*eps)
%!assert (bs\as', sparse (bf\af'), 100*eps)


# ==============================================================

%!test bf = [5,0,1+1i,0;0,5,0,1-2i;1-1i,0,5,0;0,1+2i,0,5];
%! bs = sparse (bf);
%!testif HAVE_CHOLMOD
%! assert (chol (bs)'*chol (bs), bs, 1e-10);
%!testif HAVE_CHOLMOD
%! assert (chol (bs,'lower')*chol (bs,'lower')', bs, 1e-10);
%!testif HAVE_CHOLMOD
%! assert (chol (bs,'lower'), chol (bs)', 1e-10);

%!testif HAVE_CHOLMOD   # Return Partial Cholesky factorization
%! [RS,PS] = chol (bs);
%! assert (RS'*RS, bs, 1e-10);
%! assert (PS, 0);
%! [LS,PS] = chol (bs,'lower');
%! assert (LS*LS', bs, 1e-10);
%! assert (PS, 0);

%!testif HAVE_CHOLMOD   # Permuted Cholesky factorization
%! [RS,PS,QS] = chol (bs);
%! assert (RS'*RS, QS*bs*QS', 1e-10);
%! assert (PS, 0);
%! [LS,PS,QS] = chol (bs,'lower');
%! assert (LS*LS', QS*bs*QS', 1e-10);
%! assert (PS, 0);


# ==============================================================

%!test bf = real (bf);
%! bs = sparse (bf);
%!testif HAVE_CHOLMOD
%! assert (chol (bs)'*chol (bs), bs, 1e-10);
%!testif HAVE_CHOLMOD
%! assert (chol (bs,'lower')*chol (bs,'lower')', bs, 1e-10);
%!testif HAVE_CHOLMOD
%! assert (chol (bs,'lower'), chol (bs)', 1e-10);

%!testif HAVE_CHOLMOD   # Return Partial Cholesky factorization
%! [RS,PS] = chol (bs);
%! assert (RS'*RS, bs, 1e-10);
%! assert (PS, 0);
%! [LS,PS] = chol (bs,'lower');
%! assert (LS*LS', bs, 1e-10);
%! assert (PS, 0);

%!testif HAVE_CHOLMOD   # Permuted Cholesky factorization
%! [RS,PS,QS] = chol (bs);
%! assert (RS'*RS, QS*bs*QS', 1e-10);
%! assert (PS, 0);
%! [LS,PS,QS] = chol (bs,'lower');
%! assert (LS*LS', QS*bs*QS', 1e-10);
%! assert (PS, 0);


# ==============================================================

%!shared r,c,m,n,fsum,funiq
%!test
%! r = [1,1,2,1,2,3];
%! c = [2,1,1,1,2,1];
%! m = n = 0;
%%Assembly tests
%!test
%! m = max ([m;r(:)]);
%! n = max ([n;c(:)]);
%! funiq = fsum = zeros (m,n);
%! funiq(r(:) + m*(c(:)-1) ) = ones (size (r(:)));
%! funiq = sparse (funiq);
%! for k=1:length (r)
%!   fsum(r(k),c(k)) += 1;
%! endfor
%! fsum = sparse (fsum);
%!assert (sparse (r,c,1), sparse (fsum(1:max(r), 1:max(c))))
%!assert (sparse (r,c,1,"sum"), sparse (fsum(1:max (r),1:max (c))))
%!assert (sparse (r,c,1,"unique"), sparse (funiq(1:max (r),1:max (c))))
%!assert (sparse (r,c,1,m,n), sparse (fsum))
%!assert (sparse (r,c,1,m,n,"sum"), sparse (fsum))
%!assert (sparse (r,c,1,m,n,"unique"), sparse (funiq))

%!assert (sparse (r,c,1i), sparse (fsum(1:max (r),1:max (c))*1i))
%!assert (sparse (r,c,1i,"sum"), sparse (fsum(1:max (r),1:max (c))*1i))
%!assert (sparse (r,c,1i,"unique"), sparse (funiq(1:max (r),1:max (c))*1i))
%!assert (sparse (r,c,1i,m,n), sparse (fsum*1i))
%!assert (sparse (r,c,1i,m,n,"sum"), sparse (fsum*1i))
%!assert (sparse (r,c,1i,m,n,"unique"), sparse (funiq*1i))

%!test
%! if (issparse (funiq))
%!   assert (sparse (full (1i*funiq)), sparse (1i*funiq));
%! endif

%!assert (sparse (full (funiq)), funiq)



# ==============================================================

%!shared ridx,cidx,idx,as,af
%!test
%! af = [1+1i,2-1i,0,0;0,0,0,3+2i;0,0,0,4];
%! ridx = [1,3];
%! cidx = [2,3];
%!assert (sparse (42)([1,1]), sparse ([42,42]))
%!assert (sparse (42*1i)([1,1]), sparse ([42,42].*1i))
%!test as = sparse (af);

%% Point tests
%!test idx = ridx(:) + rows (as) * (cidx (:)-1);
%!assert (sparse (as(idx)), sparse (af(idx)))
%!assert (as(idx), sparse (af(idx)))
%!assert (as(idx'), sparse (af(idx')))
%!assert (as(flipud (idx(:))), sparse (af(flipud (idx(:)))))
%!assert (as([idx,idx]), sparse (af([idx,idx])))
%!assert (as(reshape ([idx;idx], [1,length(idx),2])), sparse(af(reshape ([idx;idx], [1,length(idx),2]))))

%% Slice tests
%!assert (as(ridx,cidx), sparse (af(ridx,cidx)))
%!assert (as(ridx,:), sparse (af(ridx,:)))
%!assert (as(:,cidx), sparse (af(:,cidx)))
%!assert (as(:,:), sparse (af(:,:)))
%!assert (as((rows (as):-1:1),:), sparse (af((size (af,1):-1:1),:)))
%!assert (as(:,(columns (as):-1:1)), sparse (af(:, (size (af,2):-1:1))))

%% Indexing tests
%!assert (full (as([1,1],:)), af([1,1],:))
%!assert (full (as(:,[1,1])), af(:,[1,1]))
%!test
%! [i,j,v] = find (as);
%! assert (as(i(1),j(1))([1,1]), sparse ([v(1), v(1)]));

%% Assignment test
%!test
%! ts = as; ts(:,:) = ts(fliplr (1:rows (as)),:);
%! tf = af; tf(:,:) = tf(fliplr (1:rows (af)),:);
%! assert (ts, sparse (tf));
%!test
%! ts = as; ts(fliplr (1:rows (as)),:) = ts;
%! tf = af; tf(fliplr (1:rows (af)),:) = tf;
%! assert (ts, sparse (tf));
%!test
%! ts = as; ts(:,fliplr (1:columns (as))) = ts;
%! tf = af; tf(:,fliplr (1:columns (af))) = tf;
%! assert (ts, sparse (tf));
%!test
%! ts(fliplr (1:rows (as))) = as(:,1);
%! tf(fliplr (1:rows (af))) = af(:,1);
%! assert (ts, sparse (tf));

%% Deletion tests
%!test
%! ts = as; ts(1,:) = []; tf = af; tf(1,:) = [];
%! assert (ts, sparse (tf));
%!test
%! ts = as; ts(:,1) = []; tf = af; tf(:,1) = [];
%! assert (ts, sparse (tf));

%% Test "end" keyword
%!assert (full (as(end)), af(end))
%!assert (full (as(1,end)), af(1,end))
%!assert (full (as(end,1)), af(end,1))
%!assert (full (as(end,end)), af(end,end))
%!assert (as(2:end,2:end), sparse (af(2:end,2:end)))
%!assert (as(1:end-1,1:end-1), sparse (af(1:end-1,1:end-1)))
%!test af = real (af);
%!test as = sparse (af);

%% Point tests
%!test idx = ridx(:) + rows (as) * (cidx (:)-1);
%!assert (sparse (as(idx)), sparse (af(idx)))
%!assert (as(idx), sparse (af(idx)))
%!assert (as(idx'), sparse (af(idx')))
%!assert (as(flipud (idx(:))), sparse (af(flipud (idx(:)))))
%!assert (as([idx,idx]), sparse (af([idx,idx])))
%!assert (as(reshape ([idx;idx], [1,length(idx),2])), sparse(af(reshape ([idx;idx], [1,length(idx),2]))))

%% Slice tests
%!assert (as(ridx,cidx), sparse (af(ridx,cidx)))
%!assert (as(ridx,:), sparse (af(ridx,:)))
%!assert (as(:,cidx), sparse (af(:,cidx)))
%!assert (as(:,:), sparse (af(:,:)))
%!assert (as((rows (as):-1:1),:), sparse (af((size (af,1):-1:1),:)))
%!assert (as(:,(columns (as):-1:1)), sparse (af(:, (size (af,2):-1:1))))

%% Indexing tests
%!assert (full (as([1,1],:)), af([1,1],:))
%!assert (full (as(:,[1,1])), af(:,[1,1]))
%!test
%! [i,j,v] = find (as);
%! assert (as(i(1),j(1))([1,1]), sparse ([v(1), v(1)]));

%% Assignment test
%!test
%! ts = as; ts(:,:) = ts(fliplr (1:rows (as)),:);
%! tf = af; tf(:,:) = tf(fliplr (1:rows (af)),:);
%! assert (ts, sparse (tf));
%!test
%! ts = as; ts(fliplr (1:rows (as)),:) = ts;
%! tf = af; tf(fliplr (1:rows (af)),:) = tf;
%! assert (ts, sparse (tf));
%!test
%! ts = as; ts(:,fliplr (1:columns (as))) = ts;
%! tf = af; tf(:,fliplr (1:columns (af))) = tf;
%! assert (ts, sparse (tf));
%!test
%! ts(fliplr (1:rows (as))) = as(:,1);
%! tf(fliplr (1:rows (af))) = af(:,1);
%! assert (ts, sparse (tf));

%% Deletion tests
%!test
%! ts = as; ts(1,:) = []; tf = af; tf(1,:) = [];
%! assert (ts, sparse (tf));
%!test
%! ts = as; ts(:,1) = []; tf = af; tf(:,1) = [];
%! assert (ts, sparse (tf));

%% Test "end" keyword
%!assert (full (as(end)), af(end))
%!assert (full (as(1,end)), af(1,end))
%!assert (full (as(end,1)), af(end,1))
%!assert (full (as(end,end)), af(end,end))
%!assert (as(2:end,2:end), sparse (af(2:end,2:end)))
%!assert (as(1:end-1,1:end-1), sparse (af(1:end-1,1:end-1)))

# ==============================================================

%!shared alpha,beta,df,pdf,lf,plf,uf,puf,bf,cf,bcf,tf,tcf,xf,ds,pds,ls,pls,us,pus,bs,cs,bcs,ts,tcs,xs
%!test alpha=1; beta=1;
%! n=8;
%! lf=diag (1:n); lf(n-1,1)=0.5*alpha; lf(n,2)=0.25*alpha; ls=sparse (lf);
%! uf=diag (1:n); uf(1,n-1)=2*alpha; uf(2,n)=alpha; us=sparse (uf);
%! ts=spdiags (ones (n,3),-1:1,n,n) + diag (1:n); tf = full (ts);
%! df = diag (1:n).* alpha; ds = sparse (df);
%! pdf = df(randperm (n), randperm (n));
%! pds = sparse (pdf);
%! plf = lf(randperm (n), randperm (n));
%! pls = sparse (plf);
%! puf = uf(randperm (n), randperm (n));
%! pus = sparse (puf);
%! bs = spdiags (repmat ([1:n]',1,4),-2:1,n,n).*alpha;
%! bf = full (bs);
%! cf = lf + lf'; cs = sparse (cf);
%! bcf = bf + bf'; bcs = sparse (bcf);
%! tcf = tf + tf'; tcs = sparse (tcf);
%! xf = diag (1:n) + fliplr (diag (1:n)).*beta;
%! xs = sparse (xf);
%!assert (ds\xf, df\xf, 1e-10)
%!assert (ds\xs, sparse (df\xf), 1e-10)
%!assert (pds\xf, pdf\xf, 1e-10)
%!assert (pds\xs, sparse (pdf\xf), 1e-10)
%!assert (ls\xf, lf\xf, 1e-10)
%!assert (sparse (ls\xs), sparse (lf\xf), 1e-10)
%!testif HAVE_UMFPACK
%! assert (pls\xf, plf\xf, 1e-10);
%!testif HAVE_UMFPACK
%! assert (sparse (pls\xs), sparse (plf\xf), 1e-10);
%!assert (us\xf, uf\xf, 1e-10)
%!assert (sparse (us\xs), sparse (uf\xf), 1e-10)
%!testif HAVE_UMFPACK
%! assert (pus\xf, puf\xf, 1e-10);
%!testif HAVE_UMFPACK
%! assert (sparse (pus\xs), sparse (puf\xf), 1e-10);
%!assert (bs\xf, bf\xf, 1e-10)
%!assert (sparse (bs\xs), sparse (bf\xf), 1e-10)
%!testif HAVE_UMFPACK
%! assert (cs\xf, cf\xf, 1e-10);
%!testif HAVE_UMFPACK
%! assert (sparse (cs\xs), sparse (cf\xf), 1e-10);
%!testif HAVE_UMFPACK
%! assert (bcs\xf, bcf\xf, 1e-10);
%!testif HAVE_UMFPACK
%! assert (sparse (bcs\xs), sparse (bcf\xf), 1e-10);
%!assert (ts\xf, tf\xf, 1e-10)
%!assert (sparse (ts\xs), sparse (tf\xf), 1e-10)
%!assert (tcs\xf, tcf\xf, 1e-10)
%!assert (sparse (tcs\xs), sparse (tcf\xf), 1e-10)

%% QR solver tests

%!function f (a, sz, feps)
%! b = randn (sz);
%! x = a \ b;
%! assert (a * x, b, feps);
%! b = randn (sz) + 1i*randn (sz);
%! x = a \ b;
%! assert (a * x, b, feps);
%! b = sprandn (sz(1),sz(2),0.2);
%! x = a \ b;
%! assert (sparse (a * x), b, feps);
%! b = sprandn (sz(1),sz(2),0.2) + 1i*sprandn (sz(1),sz(2),0.2);
%! x = a \ b;
%! assert (sparse (a * x), b, feps);
%!endfunction
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! a = alpha*sprandn (10,11,0.2) + speye (10,11);
%! f (a,[10,2],1e-10);
%! ## Test this by forcing matrix_type, as can't get a certain
%! ## result for over-determined systems.
%! a = alpha*sprandn (10,10,0.2) + speye (10,10);
%! matrix_type (a, "Singular");
%! f (a,[10,2],1e-10);

%% Rectanguar solver tests that don't use QR

%!test
%! ds = alpha * spdiags ([1:11]',0,10,11);
%! df = full (ds);
%! xf = beta * ones (10,2);
%! xs = speye (10,10);
%!assert (ds\xf, df\xf, 100*eps)
%!assert (ds\xs, sparse (df\xs), 100*eps)
%!test
%! pds = ds([2,1,3:10],:);
%! pdf = full (pds);
%!assert (pds\xf, pdf\xf, 100*eps)
%!assert (pds\xs, sparse (pdf\xs), 100*eps)
%!test
%! ds = alpha * spdiags ([1:11]',0,11,10);
%! df = full (ds);
%! xf = beta * ones (11,2);
%! xs = speye (11,11);
%!assert (ds\xf, df\xf, 100*eps)
%!assert (ds\xs, sparse (df\xs), 100*eps)
%!test
%! pds = ds([2,1,3:11],:);
%! pdf = full (pds);
%!assert (pds\xf, pdf\xf, 100*eps)
%!assert (pds\xs, sparse (pdf\xs), 100*eps)
%!test
%! us = alpha*[[speye(10,10);sparse(1,10)],[[1,1];sparse(9,2);[1,1]]];
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! assert (us*(us\xf), xf, 100*eps);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! assert (us*(us\xs), xs, 100*eps);
%!test
%! pus = us(:,[2,1,3:12]);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! assert (pus*(pus\xf), xf, 100*eps);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! assert (pus*(pus\xs), xs, 100*eps);
%!test
%! us = alpha*[speye(11,9),[1;sparse(8,1);1;0]];
%!testif HAVE_CXSPARSE
%! [c,r] = qr (us, xf);
%! assert (us\xf, r\c, 100*eps);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (us, xs);
%! r = matrix_type (r, "Singular"); ## Force Matrix Type
%! assert (us\xs, r\c, 100*eps);
%!test
%! pus = us(:,[1:8,10,9]);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (pus, xf);
%! r = matrix_type (r, "Singular"); ## Force Matrix Type
%! assert (pus\xf, r\c, 100*eps);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (pus, xs);
%! r = matrix_type (r, "Singular"); ## Force Matrix Type
%! assert (pus\xs, r\c, 100*eps);
%!test
%! ls = alpha*[speye(9,11);[1, sparse(1,8),1,0]];
%! xf = beta * ones (10,2);
%! xs = speye (10,10);
%!assert (ls*(ls\xf), xf, 100*eps)
%!assert (ls*(ls\xs), xs, 100*eps)
%!test
%! pls = ls([1:8,10,9],:);
%!assert (pls*(pls\xf), xf, 100*eps)
%!assert (pls*(pls\xs), xs, 100*eps)
%!test
%! ls = alpha*[speye(10,10), sparse(10,1);[1;1], sparse(2,9),[1;1]];
%! xf = beta * ones (12,2);
%! xs = speye (12,12);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (ls, xf);
%! assert (ls\xf, r\c, 100*eps);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (ls, xs);
%! r = matrix_type (r, "Singular"); ## Force Matrix Type
%! assert (ls\xs, r\c, 100*eps);
%!test
%! pls = ls(:,[1:8,10,9]);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (pls, xf);
%! r = matrix_type (r, "Singular"); ## Force Matrix Type
%! assert (pls\xf, r\c, 100*eps);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (pls, xs);
%! r = matrix_type (r, "Singular"); ## Force Matrix Type
%! assert (pls\xs, r\c, 100*eps);

%!test alpha=1; beta=1i;
%! n=8;
%! lf=diag (1:n); lf(n-1,1)=0.5*alpha; lf(n,2)=0.25*alpha; ls=sparse (lf);
%! uf=diag (1:n); uf(1,n-1)=2*alpha; uf(2,n)=alpha; us=sparse (uf);
%! ts=spdiags (ones (n,3),-1:1,n,n) + diag (1:n); tf = full (ts);
%! df = diag (1:n).* alpha; ds = sparse (df);
%! pdf = df(randperm (n), randperm (n));
%! pds = sparse (pdf);
%! plf = lf(randperm (n), randperm (n));
%! pls = sparse (plf);
%! puf = uf(randperm (n), randperm (n));
%! pus = sparse (puf);
%! bs = spdiags (repmat ([1:n]',1,4),-2:1,n,n).*alpha;
%! bf = full (bs);
%! cf = lf + lf'; cs = sparse (cf);
%! bcf = bf + bf'; bcs = sparse (bcf);
%! tcf = tf + tf'; tcs = sparse (tcf);
%! xf = diag (1:n) + fliplr (diag (1:n)).*beta;
%! xs = sparse (xf);
%!assert (ds\xf, df\xf, 1e-10)
%!assert (ds\xs, sparse (df\xf), 1e-10)
%!assert (pds\xf, pdf\xf, 1e-10)
%!assert (pds\xs, sparse (pdf\xf), 1e-10)
%!assert (ls\xf, lf\xf, 1e-10)
%!assert (sparse (ls\xs), sparse (lf\xf), 1e-10)
%!testif HAVE_UMFPACK
%! assert (pls\xf, plf\xf, 1e-10);
%!testif HAVE_UMFPACK
%! assert (sparse (pls\xs), sparse (plf\xf), 1e-10);
%!assert (us\xf, uf\xf, 1e-10)
%!assert (sparse (us\xs), sparse (uf\xf), 1e-10)
%!testif HAVE_UMFPACK
%! assert (pus\xf, puf\xf, 1e-10);
%!testif HAVE_UMFPACK
%! assert (sparse (pus\xs), sparse (puf\xf), 1e-10);
%!assert (bs\xf, bf\xf, 1e-10)
%!assert (sparse (bs\xs), sparse (bf\xf), 1e-10)
%!testif HAVE_UMFPACK
%! assert (cs\xf, cf\xf, 1e-10);
%!testif HAVE_UMFPACK
%! assert (sparse (cs\xs), sparse (cf\xf), 1e-10);
%!testif HAVE_UMFPACK
%! assert (bcs\xf, bcf\xf, 1e-10);
%!testif HAVE_UMFPACK
%! assert (sparse (bcs\xs), sparse (bcf\xf), 1e-10);
%!assert (ts\xf, tf\xf, 1e-10)
%!assert (sparse (ts\xs), sparse (tf\xf), 1e-10)
%!assert (tcs\xf, tcf\xf, 1e-10)
%!assert (sparse (tcs\xs), sparse (tcf\xf), 1e-10)

%% QR solver tests

%!function f (a, sz, feps)
%! b = randn (sz);
%! x = a \ b;
%! assert (a * x, b, feps);
%! b = randn (sz) + 1i*randn (sz);
%! x = a \ b;
%! assert (a * x, b, feps);
%! b = sprandn (sz(1),sz(2),0.2);
%! x = a \ b;
%! assert (sparse (a * x), b, feps);
%! b = sprandn (sz(1),sz(2),0.2) + 1i*sprandn (sz(1),sz(2),0.2);
%! x = a \ b;
%! assert (sparse (a * x), b, feps);
%!endfunction
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! a = alpha*sprandn (10,11,0.2) + speye (10,11);
%! f (a,[10,2],1e-10);
%! ## Test this by forcing matrix_type, as can't get a certain
%! ## result for over-determined systems.
%! a = alpha*sprandn (10,10,0.2) + speye (10,10);
%! matrix_type (a, "Singular");
%! f (a,[10,2],1e-10);

%% Rectanguar solver tests that don't use QR

%!test
%! ds = alpha * spdiags ([1:11]',0,10,11);
%! df = full (ds);
%! xf = beta * ones (10,2);
%! xs = speye (10,10);
%!assert (ds\xf, df\xf, 100*eps)
%!assert (ds\xs, sparse (df\xs), 100*eps)
%!test
%! pds = ds([2,1,3:10],:);
%! pdf = full (pds);
%!assert (pds\xf, pdf\xf, 100*eps)
%!assert (pds\xs, sparse (pdf\xs), 100*eps)
%!test
%! ds = alpha * spdiags ([1:11]',0,11,10);
%! df = full (ds);
%! xf = beta * ones (11,2);
%! xs = speye (11,11);
%!assert (ds\xf, df\xf, 100*eps)
%!assert (ds\xs, sparse (df\xs), 100*eps)
%!test
%! pds = ds([2,1,3:11],:);
%! pdf = full (pds);
%!assert (pds\xf, pdf\xf, 100*eps)
%!assert (pds\xs, sparse (pdf\xs), 100*eps)
%!test
%! us = alpha*[[speye(10,10);sparse(1,10)],[[1,1];sparse(9,2);[1,1]]];
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! assert (us*(us\xf), xf, 100*eps);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! assert (us*(us\xs), xs, 100*eps);
%!test
%! pus = us(:,[2,1,3:12]);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! assert (pus*(pus\xf), xf, 100*eps);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! assert (pus*(pus\xs), xs, 100*eps);
%!test
%! us = alpha*[speye(11,9),[1;sparse(8,1);1;0]];
%!testif HAVE_CXSPARSE
%! [c,r] = qr (us, xf);
%! assert (us\xf, r\c, 100*eps);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (us, xs);
%! r = matrix_type (r, "Singular"); ## Force Matrix Type
%! assert (us\xs, r\c, 100*eps);
%!test
%! pus = us(:,[1:8,10,9]);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (pus, xf);
%! r = matrix_type (r, "Singular"); ## Force Matrix Type
%! assert (pus\xf, r\c, 100*eps);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (pus, xs);
%! r = matrix_type (r, "Singular"); ## Force Matrix Type
%! assert (pus\xs, r\c, 100*eps);
%!test
%! ls = alpha*[speye(9,11);[1, sparse(1,8),1,0]];
%! xf = beta * ones (10,2);
%! xs = speye (10,10);
%!assert (ls*(ls\xf), xf, 100*eps)
%!assert (ls*(ls\xs), xs, 100*eps)
%!test
%! pls = ls([1:8,10,9],:);
%!assert (pls*(pls\xf), xf, 100*eps)
%!assert (pls*(pls\xs), xs, 100*eps)
%!test
%! ls = alpha*[speye(10,10), sparse(10,1);[1;1], sparse(2,9),[1;1]];
%! xf = beta * ones (12,2);
%! xs = speye (12,12);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (ls, xf);
%! assert (ls\xf, r\c, 100*eps);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (ls, xs);
%! r = matrix_type (r, "Singular"); ## Force Matrix Type
%! assert (ls\xs, r\c, 100*eps);
%!test
%! pls = ls(:,[1:8,10,9]);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (pls, xf);
%! r = matrix_type (r, "Singular"); ## Force Matrix Type
%! assert (pls\xf, r\c, 100*eps);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (pls, xs);
%! r = matrix_type (r, "Singular"); ## Force Matrix Type
%! assert (pls\xs, r\c, 100*eps);

%!test alpha=1i; beta=1;
%! n=8;
%! lf=diag (1:n); lf(n-1,1)=0.5*alpha; lf(n,2)=0.25*alpha; ls=sparse (lf);
%! uf=diag (1:n); uf(1,n-1)=2*alpha; uf(2,n)=alpha; us=sparse (uf);
%! ts=spdiags (ones (n,3),-1:1,n,n) + diag (1:n); tf = full (ts);
%! df = diag (1:n).* alpha; ds = sparse (df);
%! pdf = df(randperm (n), randperm (n));
%! pds = sparse (pdf);
%! plf = lf(randperm (n), randperm (n));
%! pls = sparse (plf);
%! puf = uf(randperm (n), randperm (n));
%! pus = sparse (puf);
%! bs = spdiags (repmat ([1:n]',1,4),-2:1,n,n).*alpha;
%! bf = full (bs);
%! cf = lf + lf'; cs = sparse (cf);
%! bcf = bf + bf'; bcs = sparse (bcf);
%! tcf = tf + tf'; tcs = sparse (tcf);
%! xf = diag (1:n) + fliplr (diag (1:n)).*beta;
%! xs = sparse (xf);
%!assert (ds\xf, df\xf, 1e-10)
%!assert (ds\xs, sparse (df\xf), 1e-10)
%!assert (pds\xf, pdf\xf, 1e-10)
%!assert (pds\xs, sparse (pdf\xf), 1e-10)
%!assert (ls\xf, lf\xf, 1e-10)
%!assert (sparse (ls\xs), sparse (lf\xf), 1e-10)
%!testif HAVE_UMFPACK
%! assert (pls\xf, plf\xf, 1e-10);
%!testif HAVE_UMFPACK
%! assert (sparse (pls\xs), sparse (plf\xf), 1e-10);
%!assert (us\xf, uf\xf, 1e-10)
%!assert (sparse (us\xs), sparse (uf\xf), 1e-10)
%!testif HAVE_UMFPACK
%! assert (pus\xf, puf\xf, 1e-10);
%!testif HAVE_UMFPACK
%! assert (sparse (pus\xs), sparse (puf\xf), 1e-10);
%!assert (bs\xf, bf\xf, 1e-10)
%!assert (sparse (bs\xs), sparse (bf\xf), 1e-10)
%!testif HAVE_UMFPACK
%! assert (cs\xf, cf\xf, 1e-10);
%!testif HAVE_UMFPACK
%! assert (sparse (cs\xs), sparse (cf\xf), 1e-10);
%!testif HAVE_UMFPACK
%! assert (bcs\xf, bcf\xf, 1e-10);
%!testif HAVE_UMFPACK
%! assert (sparse (bcs\xs), sparse (bcf\xf), 1e-10);
%!assert (ts\xf, tf\xf, 1e-10)
%!assert (sparse (ts\xs), sparse (tf\xf), 1e-10)
%!assert (tcs\xf, tcf\xf, 1e-10)
%!assert (sparse (tcs\xs), sparse (tcf\xf), 1e-10)

%% QR solver tests

%!function f (a, sz, feps)
%! b = randn (sz);
%! x = a \ b;
%! assert (a * x, b, feps);
%! b = randn (sz) + 1i*randn (sz);
%! x = a \ b;
%! assert (a * x, b, feps);
%! b = sprandn (sz(1),sz(2),0.2);
%! x = a \ b;
%! assert (sparse (a * x), b, feps);
%! b = sprandn (sz(1),sz(2),0.2) + 1i*sprandn (sz(1),sz(2),0.2);
%! x = a \ b;
%! assert (sparse (a * x), b, feps);
%!endfunction
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! a = alpha*sprandn (10,11,0.2) + speye (10,11);
%! f (a,[10,2],1e-10);
%! ## Test this by forcing matrix_type, as can't get a certain
%! ## result for over-determined systems.
%! a = alpha*sprandn (10,10,0.2) + speye (10,10);
%! matrix_type (a, "Singular");
%! f (a,[10,2],1e-10);

%% Rectanguar solver tests that don't use QR

%!test
%! ds = alpha * spdiags ([1:11]',0,10,11);
%! df = full (ds);
%! xf = beta * ones (10,2);
%! xs = speye (10,10);
%!assert (ds\xf, df\xf, 100*eps)
%!assert (ds\xs, sparse (df\xs), 100*eps)
%!test
%! pds = ds([2,1,3:10],:);
%! pdf = full (pds);
%!assert (pds\xf, pdf\xf, 100*eps)
%!assert (pds\xs, sparse (pdf\xs), 100*eps)
%!test
%! ds = alpha * spdiags ([1:11]',0,11,10);
%! df = full (ds);
%! xf = beta * ones (11,2);
%! xs = speye (11,11);
%!assert (ds\xf, df\xf, 100*eps)
%!assert (ds\xs, sparse (df\xs), 100*eps)
%!test
%! pds = ds([2,1,3:11],:);
%! pdf = full (pds);
%!assert (pds\xf, pdf\xf, 100*eps)
%!assert (pds\xs, sparse (pdf\xs), 100*eps)
%!test
%! us = alpha*[[speye(10,10);sparse(1,10)],[[1,1];sparse(9,2);[1,1]]];
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! assert (us*(us\xf), xf, 100*eps);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! assert (us*(us\xs), xs, 100*eps);
%!test
%! pus = us(:,[2,1,3:12]);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! assert (pus*(pus\xf), xf, 100*eps);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! assert (pus*(pus\xs), xs, 100*eps);
%!test
%! us = alpha*[speye(11,9),[1;sparse(8,1);1;0]];
%!testif HAVE_CXSPARSE
%! [c,r] = qr (us, xf);
%! assert (us\xf, r\c, 100*eps);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (us, xs);
%! r = matrix_type (r, "Singular"); ## Force Matrix Type
%! assert (us\xs, r\c, 100*eps);
%!test
%! pus = us(:,[1:8,10,9]);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (pus, xf);
%! r = matrix_type (r, "Singular"); ## Force Matrix Type
%! assert (pus\xf, r\c, 100*eps);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (pus, xs);
%! r = matrix_type (r, "Singular"); ## Force Matrix Type
%! assert (pus\xs, r\c, 100*eps);
%!test
%! ls = alpha*[speye(9,11);[1, sparse(1,8),1,0]];
%! xf = beta * ones (10,2);
%! xs = speye (10,10);
%!assert (ls*(ls\xf), xf, 100*eps)
%!assert (ls*(ls\xs), xs, 100*eps)
%!test
%! pls = ls([1:8,10,9],:);
%!assert (pls*(pls\xf), xf, 100*eps)
%!assert (pls*(pls\xs), xs, 100*eps)
%!test
%! ls = alpha*[speye(10,10), sparse(10,1);[1;1], sparse(2,9),[1;1]];
%! xf = beta * ones (12,2);
%! xs = speye (12,12);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (ls, xf);
%! assert (ls\xf, r\c, 100*eps);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (ls, xs);
%! r = matrix_type (r, "Singular"); ## Force Matrix Type
%! assert (ls\xs, r\c, 100*eps);
%!test
%! pls = ls(:,[1:8,10,9]);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (pls, xf);
%! r = matrix_type (r, "Singular"); ## Force Matrix Type
%! assert (pls\xf, r\c, 100*eps);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (pls, xs);
%! r = matrix_type (r, "Singular"); ## Force Matrix Type
%! assert (pls\xs, r\c, 100*eps);

%!test alpha=1i; beta=1i;
%! n=8;
%! lf=diag (1:n); lf(n-1,1)=0.5*alpha; lf(n,2)=0.25*alpha; ls=sparse (lf);
%! uf=diag (1:n); uf(1,n-1)=2*alpha; uf(2,n)=alpha; us=sparse (uf);
%! ts=spdiags (ones (n,3),-1:1,n,n) + diag (1:n); tf = full (ts);
%! df = diag (1:n).* alpha; ds = sparse (df);
%! pdf = df(randperm (n), randperm (n));
%! pds = sparse (pdf);
%! plf = lf(randperm (n), randperm (n));
%! pls = sparse (plf);
%! puf = uf(randperm (n), randperm (n));
%! pus = sparse (puf);
%! bs = spdiags (repmat ([1:n]',1,4),-2:1,n,n).*alpha;
%! bf = full (bs);
%! cf = lf + lf'; cs = sparse (cf);
%! bcf = bf + bf'; bcs = sparse (bcf);
%! tcf = tf + tf'; tcs = sparse (tcf);
%! xf = diag (1:n) + fliplr (diag (1:n)).*beta;
%! xs = sparse (xf);
%!assert (ds\xf, df\xf, 1e-10)
%!assert (ds\xs, sparse (df\xf), 1e-10)
%!assert (pds\xf, pdf\xf, 1e-10)
%!assert (pds\xs, sparse (pdf\xf), 1e-10)
%!assert (ls\xf, lf\xf, 1e-10)
%!assert (sparse (ls\xs), sparse (lf\xf), 1e-10)
%!testif HAVE_UMFPACK
%! assert (pls\xf, plf\xf, 1e-10);
%!testif HAVE_UMFPACK
%! assert (sparse (pls\xs), sparse (plf\xf), 1e-10);
%!assert (us\xf, uf\xf, 1e-10)
%!assert (sparse (us\xs), sparse (uf\xf), 1e-10)
%!testif HAVE_UMFPACK
%! assert (pus\xf, puf\xf, 1e-10);
%!testif HAVE_UMFPACK
%! assert (sparse (pus\xs), sparse (puf\xf), 1e-10);
%!assert (bs\xf, bf\xf, 1e-10)
%!assert (sparse (bs\xs), sparse (bf\xf), 1e-10)
%!testif HAVE_UMFPACK
%! assert (cs\xf, cf\xf, 1e-10);
%!testif HAVE_UMFPACK
%! assert (sparse (cs\xs), sparse (cf\xf), 1e-10);
%!testif HAVE_UMFPACK
%! assert (bcs\xf, bcf\xf, 1e-10);
%!testif HAVE_UMFPACK
%! assert (sparse (bcs\xs), sparse (bcf\xf), 1e-10);
%!assert (ts\xf, tf\xf, 1e-10)
%!assert (sparse (ts\xs), sparse (tf\xf), 1e-10)
%!assert (tcs\xf, tcf\xf, 1e-10)
%!assert (sparse (tcs\xs), sparse (tcf\xf), 1e-10)

%% QR solver tests

%!function f (a, sz, feps)
%! b = randn (sz);
%! x = a \ b;
%! assert (a * x, b, feps);
%! b = randn (sz) + 1i*randn (sz);
%! x = a \ b;
%! assert (a * x, b, feps);
%! b = sprandn (sz(1),sz(2),0.2);
%! x = a \ b;
%! assert (sparse (a * x), b, feps);
%! b = sprandn (sz(1),sz(2),0.2) + 1i*sprandn (sz(1),sz(2),0.2);
%! x = a \ b;
%! assert (sparse (a * x), b, feps);
%!endfunction
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! a = alpha*sprandn (10,11,0.2) + speye (10,11);
%! f (a,[10,2],1e-10);
%! ## Test this by forcing matrix_type, as can't get a certain
%! ## result for over-determined systems.
%! a = alpha*sprandn (10,10,0.2) + speye (10,10);
%! matrix_type (a, "Singular");
%! f (a,[10,2],1e-10);

%% Rectanguar solver tests that don't use QR

%!test
%! ds = alpha * spdiags ([1:11]',0,10,11);
%! df = full (ds);
%! xf = beta * ones (10,2);
%! xs = speye (10,10);
%!assert (ds\xf, df\xf, 100*eps)
%!assert (ds\xs, sparse (df\xs), 100*eps)
%!test
%! pds = ds([2,1,3:10],:);
%! pdf = full (pds);
%!assert (pds\xf, pdf\xf, 100*eps)
%!assert (pds\xs, sparse (pdf\xs), 100*eps)
%!test
%! ds = alpha * spdiags ([1:11]',0,11,10);
%! df = full (ds);
%! xf = beta * ones (11,2);
%! xs = speye (11,11);
%!assert (ds\xf, df\xf, 100*eps)
%!assert (ds\xs, sparse (df\xs), 100*eps)
%!test
%! pds = ds([2,1,3:11],:);
%! pdf = full (pds);
%!assert (pds\xf, pdf\xf, 100*eps)
%!assert (pds\xs, sparse (pdf\xs), 100*eps)
%!test
%! us = alpha*[[speye(10,10);sparse(1,10)],[[1,1];sparse(9,2);[1,1]]];
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! assert (us*(us\xf), xf, 100*eps);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! assert (us*(us\xs), xs, 100*eps);
%!test
%! pus = us(:,[2,1,3:12]);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! assert (pus*(pus\xf), xf, 100*eps);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! assert (pus*(pus\xs), xs, 100*eps);
%!test
%! us = alpha*[speye(11,9),[1;sparse(8,1);1;0]];
%!testif HAVE_CXSPARSE
%! [c,r] = qr (us, xf);
%! assert (us\xf, r\c, 100*eps);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (us, xs);
%! r = matrix_type (r, "Singular"); ## Force Matrix Type
%! assert (us\xs, r\c, 100*eps);
%!test
%! pus = us(:,[1:8,10,9]);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (pus, xf);
%! r = matrix_type (r, "Singular"); ## Force Matrix Type
%! assert (pus\xf, r\c, 100*eps);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (pus, xs);
%! r = matrix_type (r, "Singular"); ## Force Matrix Type
%! assert (pus\xs, r\c, 100*eps);
%!test
%! ls = alpha*[speye(9,11);[1, sparse(1,8),1,0]];
%! xf = beta * ones (10,2);
%! xs = speye (10,10);
%!assert (ls*(ls\xf), xf, 100*eps)
%!assert (ls*(ls\xs), xs, 100*eps)
%!test
%! pls = ls([1:8,10,9],:);
%!assert (pls*(pls\xf), xf, 100*eps)
%!assert (pls*(pls\xs), xs, 100*eps)
%!test
%! ls = alpha*[speye(10,10), sparse(10,1);[1;1], sparse(2,9),[1;1]];
%! xf = beta * ones (12,2);
%! xs = speye (12,12);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (ls, xf);
%! assert (ls\xf, r\c, 100*eps);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (ls, xs);
%! r = matrix_type (r, "Singular"); ## Force Matrix Type
%! assert (ls\xs, r\c, 100*eps);
%!test
%! pls = ls(:,[1:8,10,9]);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (pls, xf);
%! r = matrix_type (r, "Singular"); ## Force Matrix Type
%! assert (pls\xf, r\c, 100*eps);
%!testif HAVE_UMFPACK, HAVE_CXSPARSE
%! [c,r] = qr (pls, xs);
%! r = matrix_type (r, "Singular"); ## Force Matrix Type
%! assert (pls\xs, r\c, 100*eps);


# ==============================================================

