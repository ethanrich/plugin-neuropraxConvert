## Copyright (C) 2002 Etienne Grossmann <etienne@egdn.net>
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
## @deftypefn{Function File} {[@var{p_res}, @var{objf}, @var{cvg}, @var{outp}] =} __d2_min__ (@var{f}, @var{pin}, @var{hook})
## Undocumented internal function.
## @end deftypefn

function [p_res, objf, cvg, outp] = __d2_min__ (f, pin, hook)

### modified by Olaf Till <i7tiol@t-online.de>

  n = length (pin);

  ## constants
  maxinner = 30;
  tcoeff = 0.5;			# Discount on total weight
  ncoeff = 0.5;			# Discount on weight of newton
  ocoeff = 1.5;			# Factor for outwards searching

  ## passed function for gradient of objective function
  grad_f = hook.dfdp;

  ## passed function for hessian of objective function
  if (isempty (hess_f = hook.hessian))
    error ("this backend requires a supplied Hessian function");
  endif

  ## is it the inverse of the hessian?
  inverse_hessian = hook.inverse_hessian;

  ## passed options
  ftol = hook.TolFun;
  if (isempty (utol = hook.TolX)) utol = 10 * sqrt (eps); endif
  if (isempty (maxout = hook.MaxIter)) maxout = 1000; endif
  fixed = hook.fixed;
  verbose = strcmp (hook.Display, "iter");
  prudent = strcmp (hook.FunValCheck, "on");
  user_interaction = hook.user_interaction;

  ## some useful variables derived from passed variables
  n = numel (pin);

  ## backend-specific checking of options and constraints
  if (all (fixed))
    error ("no free parameters");
  endif

  ## fill constant fields of hook for derivative-functions; some fields
  ## may be backend-specific
  dfdp_hook.fixed = fixed; # this may be handled by the frontend, but
                                # the backend still may add to it




  ## set up for iterations
  p = pbest = pin;
  vf = fbest = eval_objf (f, pin, prudent);
  nobjf = 1;

  if (([stop, outp.user_interaction] = ...
       __do_user_interaction__ (user_interaction, p,
                                struct ("iteration", 0,
                                        "fval", vf),
                                "init")))
    p_res = p;
    outp.niter = 0;
    outp.nobj = nobjf;
    objf = vf;
    cvg = -1;
    return;
  endif

  for (niter = 1 : maxout)

    [grad, hessian] = ...
        eval_grad_hessian (grad_f, hess_f, p, n, prudent,
                           setfield (dfdp_hook, "f", vf));

    grad = grad(:);

    if (inverse_hessian)
      inv_hessian = hessian;
    else
      inv_hessian = pinv (hessian);
    endif
      
    fold = vf;

    if (verbose)
      printf ("d2_min: niter=%d, objf=%8.3g\n", niter, vf);
    endif

    dnewton = - inv_hessian * grad; # Newton step
    if (dnewton' * grad > 0)
      ## Heuristic for negative hessian
      dnewton = -100 * grad;
    endif

    wn = 1; # Weight of Newton step
    wt = 1; # Total weight
    done_inner = false; # false = not found, true = ready to quit inner loop

    for (ninner = 1 : maxinner) # inner loop

      dp = wt * (wn * dnewton - (1 - wn) * grad);
      pnew = p + dp;

      if (verbose)
        printf ("total weight: %8.3g, newtons weight: %8.3g, objf=%8.3g, newton norm: %8.3g, deriv norm: %8.3g\n",
	        wt, wn, fbest, norm (wt * wn * dnewton),
                norm (wt * (1 - wn) * d));
      endif

      fnew = eval_objf (f, pnew, prudent);
      nobjf++;

      if (fnew < fbest)

        dbest = dp;
        fbest = fnew;
        pbest = pnew;

        done_inner = true; # will go out at next increase

        if (verbose)
          printf ("d2_min: found better value\n");
        endif

      elseif (done_inner)

        if (verbose)
          printf ("d2_min: quitting %d th inner loop\n", ninner);
        endif

        break;

      endif

      wt *= tcoeff; # reduce norm of proposed step
      wn *= ncoeff; # and bring it closer to derivative

    endfor # end of inner loop

    if (ninner == maxinner)
      printf ("d2_min: too many inner loops (objf: %8.3g)\n", fnew);
      wbest = 0;
    else
      ## look for improvement along dbest

      wbest = 1;

      wn = ocoeff;
      pnew = p + wn * dbest;
      fnew = eval_objf (f, pnew, prudent);
      nobjf++;

      while (fnew < fbest)

        fbest = fnew;
        wbest = wn;
        pbest = pnew;

        wn *= ocoeff;
        pnew = p + wn * dbest;
        fnew = eval_objf (f, pnew, prudent);
        nobjf++;

        if (verbose)
          printf ("d2_min: looking further: objf: %8.3g\n", fnew);
        endif

      endwhile

    endif

    if (verbose)
      printf ("d2_min: inner loop: fbest: %8.5g, fold: %8.5g\n",
              fbest, fold);
    endif

    if (fbest < fold)
      ## improvement found
      vf = fbest;
      p = pbest;
    endif

    if (([stop, outp.user_interaction] = ...
         __do_user_interaction__ (user_interaction, p,
                                  struct ("iteration", niter,
                                          "fval", vf),
                                  "iter")))
      p_res = p;
      outp.niter = niter;
      outp.nobjf = nobjf;
      objf = vf;
      cvg = -1;
      return;
    endif

    if (fold - fbest < ((abs (fold) + sqrt (eps)) * abs (ftol)))
      if (verbose)
        printf ("d2_min: quitting, niter: %-3d, objf: %8.3g, fold: %8.3g\n",
                niter, vf, fold);
      endif
      cvg = 3;
      break;
    elseif (max (abs (wbest * dbest)) < ...
            (max (abs (pbest)) + sqrt (eps)) * abs (utol))
      cvg = 2;
      break;
    elseif (niter == maxout)
      cvg = 0
    endif

    pbest = p;

  endfor

  ## return result
  p_res = pbest;
  objf = fbest;
  outp.niter = niter;
  outp.nobjf = nobjf;

  if (([stop, outp.user_interaction] = ...
       __do_user_interaction__ (user_interaction, p_res,
                                struct ("iteration", niter,
                                        "fval", objf),
                                "done")))
    cvg = -1;
  endif

endfunction

function ret = eval_objf (f, p, prudent)

  ret = f (p);

  if (prudent && (! isnumeric (ret) || isnan (ret) || numel (ret) > 1))
    error ("objective function returns inadequate output");
  endif

endfunction

function [grad, hessian] = ...
      eval_grad_hessian (grad_f, hess_f, p, n, prudent, hook)

  persistent first_call = true;

  grad = grad_f (p, hook);

  hessian = hess_f (p);

  if (first_call)

    first_call = false;

    if (prudent && (! isnumeric (grad) || numel (grad) != n))
      error ("gradient function returns inadequate output");
    endif

    if (prudent && (! isnumeric (hessian) || any (size (hessian) != n)))
      error ("hessian function returns inadequate output");
    endif

  endif

endfunction
