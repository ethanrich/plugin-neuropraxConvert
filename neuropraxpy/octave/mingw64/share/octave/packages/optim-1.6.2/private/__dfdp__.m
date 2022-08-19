## Copyright (C) 1992-1994 Richard Shrager
## Copyright (C) 1992-1994 Arthur Jutan
## Copyright (C) 1992-1994 Ray Muzic
## Copyright (C) 2010-2019 Olaf Till <i7tiol@t-online.de>
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

function prt = __dfdp__ (p, func, hook)

  persistent first_call = true;

  ## functions setting hook.__check_first_call__ must do this call
  if (nargin == 1 && ischar (p) && strcmp (p, "reset"))
    first_call = true;
    return;
  endif    

  if (nargin > 2 && isfield (hook, "f"))
    f = hook.f;
  else
    f = func (p)(:);
  endif

  m = length (f);
  n = length (p);

  persistent fixed;
  persistent diff_onesided;
  persistent diffp;
  persistent TypicalX;
  persistent lbound;
  persistent ubound;
  persistent plabels;

  persistent parallel;
  persistent parfun;

  diffp_default = .001;
  ## Not 1 for TypicalX, to change previous courses of optimization
  ## less. The previous way was to set delta to diffp for parameters
  ## exactly zero and otherwise multiply diffp with the parameter value.
  TypicalX_default = .0001;

  if (nargin > 2)

    ## spare the whole option checking if the frontend does a reset
    ## before starting the algorithm (obligatory if it sets the field
    ## '__check_first_call__'), so we can determine if this is the first
    ## call, and it is indeed the first call
    if (! isfield (hook, "__check_first_call__") || first_call)

      first_call = false; # for the next call

      if (isfield (hook, "fixed"))
        fixed = hook.fixed;
      else
        fixed = false (n, 1);
      endif

      if (isfield (hook, "diffp"))
        diffp = hook.diffp;
        diffp(isna (diffp)) = diffp_default;
      else
        diffp = diffp_default * ones (n, 1);
      endif

      if (isfield (hook, "diff_onesided"))
        diff_onesided = hook.diff_onesided;
      else
        diff_onesided = false (n, 1);
      endif

      if (isfield (hook, "TypicalX"))
        TypicalX = abs (hook.TypicalX);
        TypicalX(isna (TypicalX)) = TypicalX_default;
      else
        TypicalX = TypicalX_default * ones (n, 1);
      endif

      if (isfield (hook, "lbound"))
        lbound = hook.lbound;
      else
        lbound = - Inf (n, 1);
      endif

      if (isfield (hook, "ubound"))
        ubound = hook.ubound;
      else
        ubound = Inf (n, 1);
      endif

      if (isfield (hook, "plabels"))
        plabels = hook.plabels;
      else
        plabels = num2cell (num2cell ((1:n).'));
      endif

      if (isfield (hook, "parallel_local"))
        parallel_local = hook.parallel_local;
      else
        parallel_local = false;
      endif

      if (isfield (hook, "parallel_net"))
        parallel_net = hook.parallel_net;
      else
        parallel_net = [];
      endif

      if (parallel_local || ! isempty (parallel_net))

        parallel = true;
        plabels = plabels(! fixed, :);
        ## error handler
        errh = @ (s, id, side) {[], true, s}{:};

        if (parallel_local && ! isempty (parallel_net))
          error ("If option 'parallel_net' is not empty, option 'parallel_local' must not be true.");
        endif

        if (parallel_local)

          if (parallel_local > 1)
            npr = parallel_local;
          else
            npr = nproc ("current");
          endif

          parfun = @ (func, ids, sides) pararrayfun (npr,
                                                     func, ids, sides,
                                                     "UniformOutput", false,
                                                     "VerboseLevel", 0,
                                                     "ErrorHandler", errh);

        else # ! isempty (parallel_net)
          parfun = @ (func, ids, sides) netarrayfun (parallel_net,
                                                     func, ids, sides,
                                                     "UniformOutput", false,
                                                     "ErrorHandler", errh);
        endif

      else
        parallel = false;
      endif

    endif

  else
    fixed = false (n, 1);
    diff_onesided = fixed;
    diffp = diffp_default * ones (n, 1);
    TypicalX = TypicalX_default * ones (n, 1);
    lbound = - Inf (n, 1);
    ubound = Inf (n, 1);
    plabels = num2cell (num2cell ((1:n).'));
    parallel = false;
  endif    

  prt = zeros (m, n, class (p)); # initialise Jacobian to Zero
  del = diffp .* max (abs (p), TypicalX);
  tpidx = p < 0;
  del(tpidx) = - del(tpidx);
  del(diff_onesided) = - del(diff_onesided); # keep course of
                                # optimization of previous versions
  absdel = abs (del);
  idxd = ~(diff_onesided | fixed); # double sided interval
  p1 = zeros (n, 1);
  p2 = p1;
  idxvs = false (n, 1);
  idx1g2w = idxvs;
  idx1le2w = idxvs;

  ## p may be slightly out of bounds due to inaccuracy, or exactly at
  ## the bound -> single sided interval
  idxvl = p <= lbound;
  idxvg = p >= ubound;
  p1(idxvl) = min (p(idxvl, 1) + absdel(idxvl, 1), ubound(idxvl, 1));
  idxd(idxvl) = false;
  p1(idxvg) = max (p(idxvg, 1) - absdel(idxvg, 1), lbound(idxvg, 1));
  idxd(idxvg) = false;
  idxs = ~(fixed | idxd); # single sided interval

  idxnv = ~(idxvl | idxvg); # current paramters within bounds
  idxnvs = idxs & idxnv; # within bounds, single sided interval
  idxnvd = idxd & idxnv; # within bounds, double sided interval
  ## remaining single sided intervals
  p1(idxnvs) = p(idxnvs) + del(idxnvs); # don't take absdel, this could
                                # change course of optimization without
                                # bounds with respect to previous
                                # versions
  ## remaining single sided intervals, violating a bound -> take largest
  ## possible direction of single sided interval
  idxvs(idxnvs) = p1(idxnvs, 1) < lbound(idxnvs, 1) | ...
      p1(idxnvs, 1) > ubound(idxnvs, 1);
  del1 = p(idxvs, 1) - lbound(idxvs, 1);
  del2 = ubound(idxvs, 1) - p(idxvs, 1);
  idx1g2 = del1 > del2;
  idx1g2w(idxvs) = idx1g2;
  idx1le2w(idxvs) = ~idx1g2;
  p1(idx1g2w) = max (p(idx1g2w, 1) - absdel(idx1g2w, 1),
                     lbound(idx1g2w, 1));
  p1(idx1le2w) = min (p(idx1le2w, 1) + absdel(idx1le2w, 1),
                      ubound(idx1le2w, 1));
  ## double sided interval
  p1(idxnvd) = min (p(idxnvd, 1) + absdel(idxnvd, 1),
                    ubound(idxnvd, 1));
  p2(idxnvd) = max (p(idxnvd, 1) - absdel(idxnvd, 1),
                    lbound(idxnvd, 1));

  del(idxs) = p1(idxs) - p(idxs);
  del(idxd) = p1(idxd) - p2(idxd);

  info.f = f;
  info.parallel = parallel;

  if (parallel)

    ## remove all entries corresponding to fixed parameters from some
    ## information used
    idx_non_fixed = ! fixed;
    p_non_fixed = p(idx_non_fixed, :);
    p1 = p1(idx_non_fixed, :);
    p2 = p2(idx_non_fixed, :);
    idxs_nf = idxs(idx_non_fixed, :);
    idxd_nf = ! idxs_nf;

    ## to choose between p1 and p2 by index (side 1 or 2)
    pdel = horzcat (p1, p2);

    ## set remaining fields of 'info' according to id of current
    ## parameter
    setinfo = @ (id, side) setfields (info, "side", side,
                                      "plabels", plabels(id, :));
    ## make current parameter set according to current id; if side is
    ## 0, it's set to 1
    cpset = @ (id, side) ...
              subsasgn (p_non_fixed,
                        struct ("type", "()", "subs",
                                {{id}}), pdel(id, max (side, 1)));
    ## supplement fixed parameters
    all_p = @ (cp) subsasgn (p, struct ("type", "()", "subs",
                                        {{idx_non_fixed}}), cp);
    ## func(), cpset(), all_p(), and setinfo() combined
    func_c = @ (id, side) ...
               {func(all_p(cpset(id, side)), setinfo (id, side))(:), ...
                false, []}{:};

    ## make up inputs
    n_non_fixed = numel (p_non_fixed);
    n_single = sum (idxs_nf);
    n_centered = n_non_fixed - n_single;
    sides_c = ids_c = cell (n_non_fixed, 1);
    sides_c(idxs_nf) = {0};
    sides_c(idxd_nf) = {[1; 2]};
    sides = vertcat (sides_c{:});
    [ids_c{idxs_nf}] = num2cell (1:n_non_fixed){idxs_nf};
    [ids_c{idxd_nf}] = num2cell (repmat (1:n_non_fixed, 2, 1), 1){idxd_nf};
    ids = vertcat (ids_c{:});

    ## parallel execution
    [fdel, err, info] = parfun (func_c, ids, sides);

    ## check for errors
    if (any ((err = [err{:}])))
      id = find (err, 1);
      error ("Some subprocesses, calling model function for finite differencing, returned and error. Message of first of these (with id %i): %s%s",
             id, info{id}.message, print_stack (info{id}));
    endif

    ## process output
    dummy = zeros (m, 0); # at least one argument for concatenation,
                          # so the result has correct dimmensions
    prt(:, idxs) = (horzcat (dummy, fdel{sides == 0}) - ...
                    f(:, ones (1, n_single))) ./ ...
                   del(idxs).'(ones (1, m), :);
    prt(:, idxd) = (horzcat (dummy, fdel{sides == 1}) - ...
                    horzcat (dummy, fdel{sides == 2})) ./ ...
                   del(idxd).'(ones (1, m), :);

  else # not parallel

    for j = 1:n
      if (~fixed(j))
        info.plabels = plabels(j, :);
        ps = p;
        ps(j) = p1(j);
        if (idxs(j))
          info.side = 0; # onesided interval
          tp1 = func (ps, info);
          prt(:, j) = (tp1(:) - f) / del(j);
        else
          info.side = 1; # centered interval, side 1
          tp1 = func (ps, info);
          ps(j) = p2(j);
          info.side = 2; # centered interval, side 2
          tp2 = func (ps, info);
          prt(:, j) = (tp1(:) - tp2(:)) / del(j);
        endif
      endif
    endfor

  endif

endfunction

function ret = print_stack (info)

  ret = "";

  if (isfield (info, "stack"))
    for id = 1 : numel (info.stack)
      ret = cstrcat (ret, sprintf ("\n    %s at line %i comumn %i",
                                   info.stack(id).name,
                                   info.stack(id).line,
                                   info.stack(id).column));
    endfor
  endif

endfunction
