## Copyright (C) 2004, 2006 Michael Creel <michael.creel@uab.es>
## Copyright (C) 2017-2019 Olaf Till <i7tiol@t-online.de>
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
## @deftypefn{Function File} {[@var{p_res}, @var{objf}, @var{cvg}, @var{outp}] =} __samin__ (@var{f}, @var{pin}, @var{hook})
## Undocumented internal function.
## @end deftypefn

function [p_res, objf, cvg, outp] = __samin__ (f, pin, hook)

  ## References:
  ##
  ## The code follows the article: Goffe, William L. (1996) "SIMANN: A
  ## Global Optimization Algorithm using Simulated Annealing " Studies
  ## in Nonlinear Dynamics & Econometrics Oct96, Vol. 1 Issue 3.
  ##
  ## A notable difference is that the initial temperature is
  ## found automatically to ensure that the active bounds when the
  ## temperature begins to reduce cover the entire parameter space
  ## (defined as a n-dimensional rectangle that is the Cartesian
  ## product of the (lb_i, ub_i), i = 1,2,..n
  ##
  ## Also of note: Corana et. al., (1987) "Minimizing Multimodal
  ## Functions of Continuous Variables with the "Simulated Annealing"
  ## Algorithm", ACM Transactions on Mathematical Software, V. 13,
  ## N. 3.
  ##
  ## Goffe, et. al. (1994) "Global Optimization of Statistical
  ## Functions with Simulated Annealing", Journal of Econometrics,
  ## V. 60, N. 1/2.

  ## original code, in samin.cc, by Michael Creel
  ## <michael.creel@uab.es>
  ##
  ## converted to m-code, modified, and turned into a backend by Olaf
  ## Till <i7tiol@t-online.de>

  ## some backend specific defaults
  default_T_init = .1;
  default_mu_T = 1.2;
  default_iters_fixed_T = 100; # corresponds to 'nt * ns' in original
                               # algorithm, must be high since
                               # parameters are set back to optimum
                               # each temperature change
  default_niter_check_tolfun = 5;
  default_iters_adjust_step = 5;

  n = length (pin);

  ## passed constraints
  lbound = hook.lbound; # bounds, subset of linear inequality
  ubound = hook.ubound; # constraints in mc and vc

  ## passed simulated annealing parameters
  if (isempty (T_init = hook.siman.T_init))
    T_init = default_T_init;
  endif
  if (isempty (mu_T = hook.siman.mu_T))
    mu_T = default_mu_T;
  endif
  if (isempty (iters_fixed_T = hook.siman.iters_fixed_T))
    iters_fixed_T = default_iters_fixed_T;
  endif
  if (isempty (iters_adjust_step = hook.siman.iters_adjust_step))
    iters_adjust_step = default_iters_adjust_step;
  endif

  ## passed options
  ftol = hook.TolFun;
  if (isempty (paramtol = hook.TolX))
    paramtol = 1e-4 * max (ubound - lbound);
  endif
  if (isempty (maxiter = hook.MaxIter))
    maxiter = 1e10;
  endif
  fixed = hook.fixed;
  ## while we compare with nfcheck values, the original algorithm in
  ## samin.cc effectivly only compared with nfcheck - 1 values
  if (isempty (nfcheck = hook.niter_check_tolfun))
    nfcheck = default_niter_check_tolfun;
  endif
  switch hook.Display
    case "off"
      verbosity = 0;
    case "final"
      verbosity = 1;
    case "iter"
      verbosity = 2;
  endswitch
  user_interaction = hook.user_interaction;
  siman_log = hook.siman_log;
  trace_steps = hook.trace_steps;
  
  user_interaction = hook.user_interaction;

  ## backend-specific checking of options and constraints
  if (nfcheck < 1)
    error ("option 'niter_check_tolfun', if set, must be at least 1");
  endif
  if (mu_T <= 1)
    error ("option 'mu_T', if set, must be greater than 1");
  endif
  if (maxiter < 1)
    error ("option 'MaxIter', if set, must be greater than 1");
  endif
  if (any (isinf (lbound)) || any (isinf (ubound)))
    error ("for the chosen algorithm, lower and upper bounds must be set for each parameter");
  endif
  if (any (pin < lbound) || any (pin > ubound))
    error ("Initial parameters violate constraints.");
  endif
  fixed |= lbound == ubound;

  ## set up for iterations
  nacc = 0; # total accepted trials
  T = T_init; # temperature - will initially rise or fall to cover
              # parameter space, then it will fall
  converged = false;
  coverage_ok = false; # has parameter space been covered? when
                       # turning to 'true', temperature starts to fall
  fcheck = inf (nfcheck, 1); # most recent values, to compare to when
                             # checking convergence
  idfcheck = 1; # wraps around at nfcheck
  p = best_p = pin;
  E = best_E = f (pin);
  n_evals = 1;
  n_iter = 0;
  width = ubound - lbound;
  id_adjust_step = 0;
  nacp = zeros (n, 1);
  if (siman_log)
    log = zeros (0, 7);
  endif
  if (trace_steps)
    trace = [0, 0, E, T_init, pin.'];
  endif
  if (([stop, outp.user_interaction] = ...
       __do_user_interaction__ (user_interaction, p,
                                struct ("iteration", 0,
                                        "fval", E),
                                "init")))
    p_res = p;
    outp.niter = 0;
    objf = E;
    cvg = -1;
    return;
  endif

  ## main loop, first increase temperature until parameter space
  ## covered, then reduce until convergence
  while (! converged)

    if (++n_iter > maxiter)
      break;
    endif

    n_accepts = n_rejects = n_eless = n_outsidebounds = n_newopt = 0;

    for m = 1 : iters_fixed_T

      step = (2 * rand (n, 1) - 1) .* width;

      for h = 1 : n
        if (! fixed(h))

          new_p = p;

          new_p(h) += step(h);

          if (new_p(h) < lbound(h) || new_p(h) > ubound(h))

            new_p(h) = lbound(h) + rand (1) * (ubound(h) - lbound(h));

            n_outsidebounds++;

          endif

          new_E = f (new_p);
          n_evals++;

          if (new_E < best_E)
            best_p = new_p;
            best_E = new_E;
            n_newopt++;
          endif
          if (new_E < E)
            ## take a step
            p = new_p;
            E = new_E;
            n_eless++;
            nacc++;
            nacp(h)++;
            if (trace_steps)
              trace(end + 1, :) = [n_iter, m, E, T, p.'];
            endif
          elseif (rand (1) < exp (- (new_E - E) / T))
            ## take a step
            p = new_p;
            E = new_E;
            n_accepts++;
            nacc++;
            nacp(h)++;
            if (trace_steps)
              trace(end + 1, :) = [n_iter, m, E, T, p.'];
            endif
          else
            n_rejects++;
          endif
        endif
      endfor # parameters

      if (++id_adjust_step == iters_adjust_step)

        ## adjust maximum stepwidth so that approximately half of all
        ## evaluations are accepted

        ratio = nacp / iters_adjust_step;

        idh = ! fixed & (ratio > .6);

        idl = ! fixed & (ratio < .4);

        width(idh) .*= 1 + 5 * (ratio(idh) - .6);

        width(idl) ./= 1 + 5 * (.4 - ratio(idl));

        if (! coverage_ok &&
            all (width >= ubound - lbound))
          coverage_ok = true;
        endif

        width = min (width, ubound - lbound);

        id_adjust_step = 0;

        nacp = zeros (n, 1);

      endif

    endfor # iters_fixed_T

    if (siman_log)
      log(end + 1, :) = [T, E, n_eless, n_accepts, n_rejects, ...
                        n_outsidebounds, n_newopt];
    endif

    if (verbosity >= 2)
      printf ("temperature no. %i: %e, energy %e,\n", n_iter, T, E);
      printf ("tries with energy less / not less but accepted / rejected: / to far / new optimum\n");
      printf ("%i / %i / %i / %i / %i\n",
              n_eless, n_accepts, n_rejects, n_outsidebounds, n_newopt);
    endif

    if (([stop, outp.user_interaction] = ...
         __do_user_interaction__ (user_interaction, p,
                                  struct ("iteration", n_iter,
                                          "fval", E),
                                  "iter")))
      p_res = p;
      outp.niter = n_iter;
      objf = E;
      cvg = -1;
      if (trace_steps)
        outp.trace = trace;
      endif
      if (siman_log)
        outp.log = log;
      endif
      return;
    endif

    if (coverage_ok)

      atol = (abs (E) + sqrt (eps)) * ftol;

      if (all (abs (E - fcheck) <= atol) &&
          abs (E - best_E) <= atol &&
          all (width <= paramtol))

        converged = true;

      endif

      ## cooling
      T /= mu_T;

    else

      ## increase temperature quickly to expand search area to cover
      ## parameter space
      T *= 100;

    endif

    fcheck(idfcheck) = E;

    if (++idfcheck > nfcheck)
      idfcheck = 1;
    endif

    ## The original algorithm in samin.cc set E and p back to the
    ## current best_E and best_p after each temperature change.
    E = best_E;
    p = best_p;

  endwhile

  ## return result
  p_res = best_p;
  objf = best_E;
  outp.niter = n_iter;
  if (converged)
    cvg = 1;
  else
    cvg = 0;
  endif
  if (trace_steps)
    outp.trace = trace;
  endif
  if (siman_log)
    outp.log = log;
  endif

  if (verbosity)

    if (cvg)
      if (n_outsidebounds)
        printf ("samin: convergence near bounds\n");
      else
        printf ("samin: normal convergence\n");
      endif
    else
      printf ("samin: no convergence, MaxIter (%i) exceeded\n",
              maxiter);
    endif

    printf ("objective function: %e\n", objf);
    printf ("parameter #%i, value: %e, search width: %e\n",
            vertcat (1:n, p_res.', width.'));

  endif

  if (([stop, outp.user_interaction] = ...
       __do_user_interaction__ (user_interaction, p_res,
                                struct ("iteration", n_iter,
                                        "fval", objf),
                                "done")))
    cvg = -1;
  endif

endfunction
