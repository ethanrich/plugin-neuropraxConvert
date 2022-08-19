## Copyright (C) 2012-2019 Olaf Till <i7tiol@t-online.de>
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

## The simulated annealing code is translated and adapted from siman.c,
## written by Mark Galassi, of the GNU Scientific Library.

function [p_res, objf, cvg, outp] = __siman__ (f, pin, hook)

  ## passed constraints:
  ##
  ## hook.mc: matrix of linear constraints
  ##
  ## hook.vc: vector of linear constraints
  ##
  ## hook.f_cstr: function of all constraints
  ##
  ## hook.df_cstr: function of derivatives of all constraints
  ##
  ## hook.n_gencstr: number of non-linear constraints
  ##
  ## hook.eq_idx: logical index of equality constraints in all
  ## constraints
  ##
  ## hook.lbound, hook.ubound: bounds, subset of linear inequality
  ## constraints in mc and vc

  ## passed values of constraints for initial parameters
  pin_cstr = hook.pin_cstr;

  ## passed function for complementary pivoting, currently sqp is used
  ## instead
  ##
  ## cpiv = hook.cpiv;

  parclass = class (pin);

  ## passed simulated annealing parameters
  if (isempty (T_init = hook.siman.T_init))
    T_init = .01;
  endif
  if (isempty (T_min = hook.siman.T_min))
    T_min = 1.0e-5;
  endif
  if (isempty (mu_T = hook.siman.mu_T))
    mu_T = 1.005
  endif
  if (isempty (iters_fixed_T = hook.siman.iters_fixed_T))
    iters_fixed_T = 10;
  endif
  max_rand_step = hook.max_rand_step;

  ## passed options
  fixed = hook.fixed;
  verbose = strcmp (hook.Display, "iter");
  user_interaction = hook.user_interaction;
  siman_log = hook.siman_log;
  trace_steps = hook.trace_steps;
  save_state = ! isempty (hook.save_state);
  recover_state = ! isempty (hook.recover_state);
  ## Parallelization, if any, will be done within the iterations at a
  ## fixed temperature. Some parameter combinations will be tested in
  ## parallel, but an order will be defined for them and all results
  ## after the first accepted will be discarded. The time savings will
  ## depend on the frequency of accepted results. To limit time losses
  ## even in cases where the first of the parallel results is accepted,
  ## the number of parallel tests will not exceed the number of
  ## available processor cores.
  if ((parallel_local = hook.parallel_local))
    if (parallel_local > 1)
      np = parallel_local;
    else
      np = nproc ("current");
    endif
    np = int32 (np);
    np = ifelse (iters_fixed_T < np, iters_fixed_T, np);
    if (np < 2)
      parallel_local = false;
    endif
  endif


  ## some useful variables derived from passed variables
  n_lconstr = length (hook.vc);
  n_bounds = sum (hook.lbound != -Inf) + sum (hook.ubound != Inf);
  hook.ac_idx = true (n_lconstr + hook.n_gencstr, 1);
  hook.ineq_idx = ! hook.eq_idx;
  hook.leq_idx = hook.eq_idx(1:n_lconstr);
  hook.lineq_idx = hook.ineq_idx(1:n_lconstr);
  hook.lfalse_idx = false(n_lconstr, 1);

  nz = 20 * eps; # This is arbitrary. Accuracy of equality constraints.

  ## backend-specific checking of options and constraints
  ##
  ## equality constraints can not be met by chance
  if ((any (hook.eq_idx) || any (hook.lbound == hook.ubound)) && ! hook.stoch_regain_constr)
    error ("If 'stoch_regain_constr' is not set, equality constraints or identical lower and upper bounds are not allowed by simulated annealing backend.");
  endif
  ##
  if (any (pin < hook.lbound | pin > hook.ubound) ||
      any (pin_cstr.inequ.lin_except_bounds < 0) ||
      any (pin_cstr.inequ.gen < 0) ||
      any (abs (pin_cstr.equ.lin)) >= nz ||
      any (abs (pin_cstr.equ.gen)) >= nz)
    error ("Initial parameters violate constraints.");
  endif
  ##
  if (all (fixed))
    error ("no free parameters");
  endif
  ##
  idx = isna (max_rand_step);
  max_rand_step(idx) = 0.005 * pin(idx);

  ## set up for iterations
  done = false;
  if (recover_state)
    state = load (hook.recover_state);
    p = state.p;
    best_p = state.best_p;
    E = state.E;
    best_E = state.best_E;
    T = state.T;
    n_evals = state.n_evals;
    n_iter = state.n_iter;
    rand ("state", state.rstate);
    if (isfield (state, "log"))
      log = state.log;
    endif
    if (isfield (state, "trace"))
      trace = state.trace;
    endif
  else
    p = best_p = pin;
    E = best_E = f (pin);
    T = T_init;
    n_evals = 1;
    n_iter = 0;
    if (siman_log)
      log = zeros (0, 5, parclass);
    endif
    if (trace_steps)
      trace = [0, 0, E, pin.'];
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
  endif

  cvg = 1;

  unwind_protect

    if (parallel_local)

      parallel_ready = false;
      lerrm = lasterr ();
      lasterr ("");

      child_data = zeros (np, 4); # pipe descriptor for reading, pipe
                                # descriptor for writing, pid, line
                                # number
      child_data(:, 4) = 1 : np;

      ## create subprocesses
      for id = 1 : np

        ## parameter pipe
        [pdp_r, pdp_w, err, msg] = pipe ();
        if (err)
          error ("could not create pipe: %s", msg);
        endif
        ## result pipe
        [pdr_r, pdr_w, err, msg] = pipe ();
        if (err)
          error ("could not create pipe: %s", msg);
        endif
        child_data(id, 1) = pdr_r;
        child_data(id, 2) = pdp_w;

        if ((pid = fork ()) == 0)
          ## child
          pclose (pdp_w);
          pclose (pdr_r);
          try
            while (true)
              p = fload (pdp_r);
              if (ischar (p))
                pclose (pdp_r);
                pclose (pdr_w);
                __exit__ ();
              endif
              new_E = f (p);
              fsave (pdr_w, new_E);
              fflush (pdr_w);
            endwhile
          catch
            pclose (pdp_r);
            pclose (pdr_w);
            __exit__ ();
          end_try_catch
          ## end child
        elseif (pid > 0)
          ## parent
          child_data(id, 3) = pid;
          pclose (pdp_r);
          pclose (pdr_w);
        else
          ## fork error
          error ("could not fork");
        endif

      endfor ## create subprocesses

    endif # parallel_local

    ## simulated annealing
    while (! done)

      n_iter++;

      n_accepts = n_rejects = n_eless = 0;

      ## rand() for potential decisions on accepting a step with an
      ## increase is called here for all possibly parallized tests, to
      ## make the course of optimization potentially reproducible
      ## between parallelized and non-parallelized runs
      rand_store = rand (iters_fixed_T, 1);

      if (parallel_local)

        n_left = int32 (iters_fixed_T);

        while (n_left)

          ## number of currently used processes
          cnp = ifelse (np <= n_left, np, n_left);

          ## for restoration
          rand_states = cell (cnp - 1, 1);

          busy_children = true (cnp, 1);
          tp_E = zeros (cnp, 1, parclass); # results
          tp_p = cell (cnp, 1); # tested parameters

          for id = 1 : cnp

            ## all rand() calls are done in the parent process

            new_p = p + max_rand_step .* (2 * rand (size (p)) - 1);

            new_p = apply_constraints (p, new_p, hook, nz, verbose);

            ##

            tp_p{id} = new_p;

            if (id < cnp)
              rand_states{id} = rand ("state");
            endif

            fsave (child_data(id, 2), new_p);
            fflush (child_data(id, 2));

          endfor

          while (any (busy_children))

            [~, act] = ...
                select (child_data(busy_children, 1), [], [], -1);
            act_idx = child_data(busy_children, 4)(act);

            for id = act_idx.'

              res = fload (child_data(id, 1));
              tp_E(id) = res;

              busy_children(id) = false;

            endfor

          endwhile

          for (id = 1 : cnp)

            id_iters = double (iters_fixed_T - n_left + id);

            if (tp_E(id) < best_E)
              best_p = tp_p{id};
              best_E = tp_E(id);
            endif
            if (tp_E(id) < E)
              ## take a step
              p = tp_p{id};
              E = tp_E(id);
              n_eless++;
              if (trace_steps)
                trace(end + 1, :) = [n_iter, id_iters, E, p.'];
              endif
              break;
            elseif (rand_store(id_iters) < ...
                    exp (- (tp_E(id) - E) / T))
              ## take a step
              p = tp_p{id};
              E = tp_E(id);
              n_accepts++;
              if (trace_steps)
                trace(end + 1, :) = [n_iter, id_iters, E, p.'];
              endif
              break;
            else
              n_rejects++;
            endif

          endfor

          ## 'id' is now the number of (ordered) parallel tests up to
          ## the accepted one; we discard all other tests as invalid
          n_left -= id;
          if (int32 (id) < cnp)
            ## restore random generator
            rand ("state", rand_states{id})
          endif
          n_evals += id;

        endwhile # n_left

      else # ! parallel_local

        for id = 1 : iters_fixed_T

          new_p = p + max_rand_step .* (2 * rand (size (p)) - 1);

          new_p = apply_constraints (p, new_p, hook, nz, verbose);

          new_E = f (new_p);
          n_evals++;

          if (new_E < best_E)
            best_p = new_p;
            best_E = new_E;
          endif
          if (new_E < E)
            ## take a step
            p = new_p;
            E = new_E;
            n_eless++;
            if (trace_steps)
              trace(end + 1, :) = [n_iter, id, E, p.'];
            endif
          elseif (rand_store(id) < exp (- (new_E - E) / T))
            ## take a step
            p = new_p;
            E = new_E;
            n_accepts++;
            if (trace_steps)
              trace(end + 1, :) = [n_iter, id, E, p.'];
            endif
          else
            n_rejects++;
          endif

        endfor # iters_fixed_T

      endif # ! parallel_local

      if (verbose)
        printf ("temperature no. %i: %e, energy %e,\n", n_iter, T, E);
        printf ("tries with energy less / not less but accepted / rejected:\n");
        printf ("%i / %i / %i\n", n_eless, n_accepts, n_rejects);
      endif

      if (siman_log)
        log(end + 1, :) = [T, E, n_eless, n_accepts, n_rejects];
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

      ## cooling
      T /= mu_T;
      if (T < T_min)
        done = true;
      endif

      if (save_state)
        rstate = rand ("state");
        save ("-binary", hook.save_state, "p", "best_p", "E",
              "best_E", "T", "n_evals", "n_iter", "rstate",
              {"log"}(siman_log){:}, {"trace"}(trace_steps){:});
      endif

    endwhile

    ## 'regular' cleanup
    if (parallel_local)

      for (id = 1 : np)
        fsave (child_data(id, 2), "exit");
        pclose (child_data(id, 2));
        child_data(id, 2) = 0;
        pclose (child_data(id, 1));
        child_data(id, 1) = 0;
        waitpid (child_data(id, 3));
        child_data(id, 3) = 0;
      endfor

      parallel_ready = true; # try/catch would not handle ctrl-c

    endif


  unwind_protect_cleanup

    if (parallel_local)

      if (! parallel_ready)

        for (id = 1 : np)
          if (child_data(id, 1))
            pclose (child_data(id, 1));
          endif
          if (child_data(id, 2))
            pclose (child_data(id, 2));
          endif
          if (child_data(id, 3))
            kill (child_data(id, 3), 9);
            waitpid (child_data(id, 3));
          endif
        endfor

        nerrm = lasterr ();
        error ("no success, last error message: %s", nerrm);

      endif

      lasterr (lerrm);

    endif

  end_unwind_protect


  ## return result
  p_res = best_p;
  objf = best_E;
  outp.niter = n_iter;
  if (trace_steps)
    outp.trace = trace;
  endif
  if (siman_log)
    outp.log = log;
  endif

  if (([stop, outp.user_interaction] = ...
       __do_user_interaction__ (user_interaction, p_res,
                                struct ("iteration", n_iter,
                                        "fval", objf),
                                "done")))
    cvg = -1;
  endif

endfunction

function new_p = apply_constraints (p, new_p, hook, nz, verbose)

  if (hook.stoch_regain_constr)
    evidx = (abs ((ac = hook.f_cstr (new_p, hook.ac_idx))(hook.eq_idx)) >= nz);
    ividx = (ac(hook.ineq_idx) < 0);
    if (any (evidx) || any (ividx))
      nv = sum (evidx) + sum (ividx);
      if (sum (lbvidx = (new_p < hook.lbound)) + ...
          sum (ubvidx = (new_p > hook.ubound)) == ...
          nv)
        ## special case only bounds violated, set back to bound
        new_p(lbvidx) = hook.lbound(lbvidx);
        new_p(ubvidx) = hook.ubound(ubvidx);
      elseif (nv == 1 &&
              sum (t_eq = (abs (ac(hook.leq_idx)) >= nz)) + ...
              sum (t_inequ = (ac(hook.lineq_idx) < 0)) == 1)
        ## special case only one linear constraint violated, set back
        ## perpendicularly to constraint
        tidx = hook.lfalse_idx;
        tidx(hook.leq_idx) = t_eq;
        tidx(hook.lineq_idx) = t_inequ;
        c = hook.mc(:, tidx);
        d = ac(tidx);
        new_p -= c * (d / (c.' * c));
      else
        ## other cases, set back keeping the distance to original
        ## 'new_p' minimal, using quadratic programming, or sequential
        ## quadratic programming for nonlinear constraints
        [new_p, discarded, sqp_info] = ...
            sqp (new_p,
                 {@(x)sumsq(x-new_p), ...
                  @(x)2*(x-new_p), ...
                  @(x)2*eye(numel(p))},
                 {@(x)hook.f_cstr(x,hook.eq_idx), ...
                  @(x)hook.df_cstr(x,hook.eq_idx,
                              setfield(hook,"f",
                                       hook.f_cstr(x,hook.ac_idx)))},
                 {@(x)hook.f_cstr(x,hook.ineq_idx), ...
                  @(x)hook.df_cstr(x,hook.ineq_idx,
                              setfield(hook,"f",
                                       hook.f_cstr(x,hook.ac_idx)))});
        if (sqp_info != 101)
          error ("could not regain constraints");
        endif
      endif
    endif
  else
    n_retry_constr = 0;
    while (any (abs ((ac = hook.f_cstr (new_p, hook.ac_idx))(hook.eq_idx)) >= nz)
           || any (ac(hook.ineq_idx) < 0))
      new_p = p + hook.max_rand_step .* (2 * rand (size (p)) - 1);
      n_retry_constr++;
    endwhile
    if (verbose && n_retry_constr)
      printf ("%i additional tries of random step to meet constraints\n",
              n_retry_constr);
    endif
  endif

endfunction
