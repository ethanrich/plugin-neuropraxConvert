## Author: Olaf Till <i7tiol@t-online.de>
## This file is granted to the public domain.

function [x, lambda, info, iter] = ...
         __qp__wrapper (x0, H, q, A, b, Ain, bin, maxit, rtol)

  persistent with_rtol;

  persistent err;

  if (isempty (with_rtol))

    [with_rtol, err] = check__qp__signature ();

  endif

  if (err)

    error "couldn't determine signature of __qp__";

  elseif (with_rtol)

    [x, lambda, info, iter] = ...
    __qp__ (x0, H, q, A, b, Ain, bin, maxit, rtol);

  else

    [x, lambda, info, iter] = ...
    __qp__ (x0, H, q, A, b, Ain, bin, maxit);

  endif

endfunction

function [with_rtol, err] = check__qp__signature ()

  err = false;

  with_rtol = false;

  try

    [x, f, i, l] = __qp__ (0, 1, 0, [], [], [], [], 10);

  catch

    try

      [x, f, i, l] = __qp__ (0, 1, 0, [], [], [], [], 10, .001);

      with_rtol = true;

    catch

      err = true;

    end_try_catch

  end_try_catch

endfunction
