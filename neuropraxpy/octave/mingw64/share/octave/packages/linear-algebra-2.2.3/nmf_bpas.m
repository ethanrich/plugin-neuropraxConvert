## Copyright (c) 2012 by Jingu Kim and Haesun Park <jingu@cc.gatech.edu>
##
##    This program is free software: you can redistribute it and/or modify
##    it under the terms of the GNU General Public License as published by
##    the Free Software Foundation, either version 3 of the License, or
##    any later version.
##
##    This program is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##    GNU General Public License for more details.
##
##    You should have received a copy of the GNU General Public License
##    along with this program. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{W}, @var{H}, @var{iter}, @var{HIS}] = } nmf_bpas (@var{A}, @var{k})
## Nonnegative Matrix Factorization by Alternating Nonnegativity Constrained Least Squares
## using Block Principal Pivoting/Active Set method.
##
## This function solves one the following problems: given @var{A} and @var{k}, find @var{W} and @var{H} such that
##
## @group
##     (1) minimize 1/2 * || @var{A}-@var{W}@var{H} ||_F^2
##
##     (2) minimize 1/2 * ( || @var{A}-@var{W}@var{H} ||_F^2 + alpha * || @var{W} ||_F^2 + beta * || @var{H} ||_F^2 )
##
##     (3) minimize 1/2 * ( || @var{A}-@var{W}@var{H} ||_F^2 + alpha * || @var{W} ||_F^2 + beta * (sum_(i=1)^n || @var{H}(:,i) ||_1^2 ) )
## @end group
##
##     where @var{W}>=0 and @var{H}>=0 elementwise.
## The input arguments are @var{A} : Input data matrix (m x n) and @var{k} : Target low-rank.
##
##
## @strong{Optional Inputs}
## @table @samp
## @item Type
## Default is 'regularized', which is recommended for quick application testing unless 'sparse' or 'plain' is explicitly needed. If sparsity is needed for 'W' factor, then apply this function for the transpose of 'A' with formulation (3). Then, exchange 'W' and 'H' and obtain the transpose of them. Imposing sparsity for both factors is not recommended and thus not included in this software.
## @table @asis
## @item 'plain'
## to use formulation (1)
## @item 'regularized'
## to use formulation (2)
## @item 'sparse'
## to use formulation (3)
## @end table
##
## @item NNLSSolver
## Default is 'bp', which is in general faster.
## @table @asis
## item 'bp'
## to use the algorithm in [1]
## item 'as'
## to use the algorithm in [2]
## @end table
##
## @item Alpha
## Parameter alpha in the formulation (2) or (3). Default is the average of all elements in A. No good justfication for this default value, and you might want to try other values.
## @item  Beta
## Parameter beta in the formulation (2) or (3).
## Default is the average of all elements in A. No good justfication for this default value, and you might want to try other values.
## @item MaxIter
## Maximum number of iterations. Default is 100.
## @item MinIter
## Minimum number of iterations. Default is 20.
## @item MaxTime
## Maximum amount of time in seconds. Default is 100,000.
## @item Winit
## (m x k) initial value for W.
## @item Hinit
## (k x n) initial value for H.
## @item Tol
## Stopping tolerance. Default is 1e-3. If you want to obtain a more accurate solution, decrease TOL and increase MAX_ITER at the same time.
## @item Verbose
## If present the function will show information during the calculations.
## @end table
##
## @strong{Outputs}
## @table @samp
## @item W
## Obtained basis matrix (m x k)
## @item H
## Obtained coefficients matrix (k x n)
## @item iter
## Number of iterations
## @item HIS
## If present the history of computation is returned.
## @end table
##
## Usage Examples:
## @example
##  nmf_bpas (A,10)
##  nmf_bpas (A,20,'verbose')
##  nmf_bpas (A,30,'verbose','nnlssolver','as')
##  nmf_bpas (A,5,'verbose','type','sparse')
##  nmf_bpas (A,60,'verbose','type','plain','Winit',rand(size(A,1),60))
##  nmf_bpas (A,70,'verbose','type','sparse','nnlssolver','bp','alpha',1.1,'beta',1.3)
## @end example
##
## References:
##  [1] For using this software, please cite:@*
##      Jingu Kim and Haesun Park, Toward Faster Nonnegative Matrix Factorization: A New Algorithm and Comparisons,@*
##      In Proceedings of the 2008 Eighth IEEE International Conference on Data Mining (ICDM'08), 353-362, 2008@*
##  [2] If you use 'nnls_solver'='as' (see below), please cite:@*
##      Hyunsoo Kim and Haesun Park, Nonnegative Matrix Factorization Based @*
##      on Alternating Nonnegativity Constrained Least Squares and Active Set Method, @*
##      SIAM Journal on Matrix Analysis and Applications, 2008, 30, 713-730
##
## Check original code at @url{http://www.cc.gatech.edu/~jingu}
##
## @seealso{nmf_pg}
## @end deftypefn

## 2015 - Modified and adapted to Octave 4.0 by
## Juan Pablo Carbajal <ajuanpi+dev@gmail.com>

# TODO
# - Format code.
# - Vectorize loops.

function [W, H, iter, varargout] = nmf_bpas (A, k , varargin)
  page_screen_output (0, "local");

  [m,n] = size(A);
  ST_RULE = 1;

  # --- Parse arguments --- #
  isnummatrix = @(x) ismatrix (x) & isnumeric (x);
  parser = inputParser ();
  parser.FunctionName = "nmf_bpas";
  parser.addParamValue ('Winit', rand(m,k), isnummatrix);
  parser.addParamValue ('Hinit', rand(k,n), isnummatrix);
  parser.addParamValue ('Tol', 1e-3, @(x)x>0);
  parser.addParamValue ('Alpha', mean (A(:)), @(x)x>=0);
  parser.addParamValue ('Beta', mean (A(:)), @(x)x>=0);
  parser.addParamValue ('MaxIter', 100, @(x)x>0);
  parser.addParamValue ('MaxTime', 1e3, @(x)x>0);
  parser.addSwitch ('Verbose');

  val_type = @(x,c) ischar (x) && any (strcmpi (x,c));
  parser.addParamValue ('Type', 'regularized', ...
                            @(x)val_type (x,{'regularized', 'sparse','plain'}));
  parser.addParamValue ('NNLSSolver', 'bp', @(x)val_type (x,{'bp', 'as'}));

  parser.parse(varargin{:});

  % Default configuration
  par.m           = m;
  par.n           = n;
  par.type        = parser.Results.Type;
  par.nnls_solver = parser.Results.NNLSSolver;
  par.alpha       = parser.Results.Alpha;
  par.beta        = parser.Results.Beta;
  par.max_iter    = parser.Results.MaxIter;
  par.min_iter    = 20;
  par.max_time    = parser.Results.MaxTime;
  par.tol         = parser.Results.Tol;
  par.verbose     = parser.Results.Verbose;
  W               = parser.Results.Winit;
  H               = parser.Results.Hinit;

  # If the user asks for the 4th argument, it means they want the history
  # of the calculations.
  par.collectInfo     = nargout > 3;

  clear parser val_type isnummatrix
  # ------------------- --- #

  ### PARSING TYPE
  # TODO add callbacks here to use during main loop. See [1]
  % for regularized/sparse case
  salphaI = sqrt (par.alpha) * eye (k);
  zerokm = zeros (k,m);

  if ( strcmpi (par.type, 'regularized') )
    sbetaI = sqrt (par.beta) * eye (k);
    zerokn = zeros (k,n);
  elseif ( strcmpi (par.type, 'sparse') )
    sbetaE = sqrt (par.beta) * ones (1,k);
    betaI  = par.beta * ones (k,k);
    zero1n = zeros (1,n);
  endif
  ###

  if (par.collectInfo)
    % collect information for analysis/debugging
    [gradW, gradH] = getGradient (A,W,H,par.type,par.alpha,par.beta);
    initGrNormW    = norm (gradW,'fro');
    initGrNormH    = norm (gradH,'fro');
    initNorm       = norm (A,'fro');

    numSC   = 3;
    initSCs = zeros (numSC,1);
    for j = 1:numSC
      initSCs(j) = ...
             getInitCriterion (j,A,W,H,par.type,par.alpha,par.beta,gradW,gradH);
    endfor

    ver.initGrNormW = initGrNormW;
    ver.initGrNormH = initGrNormH;
    ver.initNorm    = initNorm;
    ver.SC1         = initSCs(1);
    ver.SC2         = initSCs(2);
    ver.SC3         = initSCs(3);
    ver.W_density   = length (find (W>0)) / (m * k);
    ver.H_density   = length (find (H>0)) / (n * k);

    tPrev = cputime;

    if (par.verbose)
      disp (ver);
    endif

  endif

  # Verbosity
  if (par.verbose)
    display (par);
  endif

  tStart   = cputime;
  tTotal   = 0;
  initSC   = getInitCriterion (ST_RULE,A,W,H,par.type,par.alpha,par.beta);
  SCconv   = 0;
  SC_COUNT = 3;

  #TODO: [1] Replace with callbacks avoid switching each time
  for iter = 1:par.max_iter

    switch par.type
      case 'plain'
          [H,gradHX,subIterH] = nnlsm (W,A,H,par.nnls_solver);
          [W,gradW,subIterW]  = nnlsm (H',A',W',par.nnls_solver);

          extra_term = 0;

      case 'regularized'
          [H,gradHX,subIterH] = nnlsm ([W;sbetaI],[A;zerokn],H,par.nnls_solver);
          [W,gradW,subIterW]  = nnlsm ([H';salphaI],[A';zerokm],W',par.nnls_solver);

          extra_term = par.beta * H;

      case 'sparse'
          [H,gradHX,subIterH] = nnlsm ([W;sbetaE],[A;zero1n],H,par.nnls_solver);
          [W,gradW,subIterW]  = nnlsm ([H';salphaI],[A';zerokm],W',par.nnls_solver);

          extra_term = betaI * H;
    endswitch

    gradH = ( W * W' ) * H - W * A + extra_term;
    W     = W';
    gradW = gradW';

    if (par.collectInfo)
    % collect information for analysis/debugging
      elapsed = cputime - tPrev;
      tTotal  = tTotal + elapsed;
      idx     = iter+1;

      ver.iter(idx)      = iter;
      ver.elapsed(idx)   = elapsed;
      ver.tTotal(idx)    = tTotal;
      ver.subIterW(idx)  = subIterW;
      ver.subIterH(idx)  = subIterH;
      ver.relError(idx)  = norm (A - W * H,'fro') / initNorm;
      ver.SC1(idx)       = ...
      getStopCriterion (1,A,W,H,par.type,par.alpha,par.beta,gradW,gradH) / initSCs(1);
      ver.SC2(idx)       = ...
      getStopCriterion (2,A,W,H,par.type,par.alpha,par.beta,gradW,gradH) / initSCs(2);
      ver.SC3(idx)       = ...
      getStopCriterion (3,A,W,H,par.type,par.alpha,par.beta,gradW,gradH) / initSCs(3);
      ver.W_density(idx) = length (find (W>0)) / (m * k);
      ver.H_density(idx) = length (find (H>0)) / (n * k);

      if (par.verbose)
          toshow = structfun (@(x)x(end), ver, "UniformOutput", false);
          display (toshow);
      endif

      tPrev = cputime;
    endif

    if (iter > par.min_iter)
        SC = getStopCriterion (ST_RULE,A,W,H,par.type,par.alpha,par.beta,gradW,gradH);

        if ( ( par.collectInfo && tTotal > par.max_time) || ...
             (~par.collectInfo && cputime-tStart > par.max_time ) )
          printf ("Stop: maximum total time reached.\n");
          break;

        elseif ( SC / initSC <= par.tol )
          SCconv = SCconv + 1;
          if (SCconv >= SC_COUNT)
            printf ("Stop: tolerance reached.\n");
            break;
          endif

        else
            SCconv = 0;
        endif

    endif

  endfor

  [m,n] = size (A);
  norm2 = sqrt (sum (W.^2,1));

  toNormalize      = norm2 > eps;
  W(:,toNormalize) = W(:,toNormalize) ./ norm2(toNormalize);
  H(toNormalize,:) = H(toNormalize,:) .* norm2(toNormalize)';

  final.iterations = iter;
  if (par.collectInfo)
      final.elapsed_total = tTotal;
  else
      final.elapsed_total = cputime - tStart;
  endif

  final.relative_error = norm (A - W * H,'fro') / norm(A,'fro');
  final.W_density = length (find (W>0)) / (m * k);
  final.H_density = length(find (H>0)) / (n * k);
  if (par.verbose)
    display (final);
  endif

  if (par.collectInfo)
    varargout{1} = ver;
  endif

endfunction

### Done till here Wed Mar 18 2015

%-------------------
% Utility Functions
%-------------------
function retVal = getInitCriterion(stopRule,A,W,H,type,alpha,beta,gradW,gradH)
% STOPPING_RULE : 1 - Normalized proj. gradient
%                 2 - Proj. gradient
%                 3 - Delta by H. Kim
%                 0 - None (want to stop by MAX_ITER or MAX_TIME)
    if nargin~=9
        [gradW,gradH] = getGradient(A,W,H,type,alpha,beta);
    end
    [m,k]=size(W);, [k,n]=size(H);, numAll=(m*k)+(k*n);
    switch stopRule
        case 1
            retVal = norm([gradW; gradH'],'fro')/numAll;
        case 2
            retVal = norm([gradW; gradH'],'fro');
        case 3
            retVal = getStopCriterion(3,A,W,H,type,alpha,beta,gradW,gradH);
        case 0
            retVal = 1;
    end

endfunction

function retVal = getStopCriterion(stopRule,A,W,H,type,alpha,beta,gradW,gradH)
% STOPPING_RULE : 1 - Normalized proj. gradient
%                 2 - Proj. gradient
%                 3 - Delta by H. Kim
%                 0 - None (want to stop by MAX_ITER or MAX_TIME)
    if nargin~=9
        [gradW,gradH] = getGradient(A,W,H,type,alpha,beta);
    end

    switch stopRule
        case 1
            pGradW = gradW(gradW<0|W>0);
            pGradH = gradH(gradH<0|H>0);
            pGrad = [gradW(gradW<0|W>0); gradH(gradH<0|H>0)];
            pGradNorm = norm(pGrad);
            retVal = pGradNorm/length(pGrad);
        case 2
            pGradW = gradW(gradW<0|W>0);
            pGradH = gradH(gradH<0|H>0);
            pGrad = [gradW(gradW<0|W>0); gradH(gradH<0|H>0)];
            retVal = norm(pGrad);
        case 3
            resmat=min(H,gradH); resvec=resmat(:);
            resmat=min(W,gradW); resvec=[resvec; resmat(:)];
            deltao=norm(resvec,1); %L1-norm
            num_notconv=length(find(abs(resvec)>0));
            retVal=deltao/num_notconv;
        case 0
            retVal = 1e100;
    end

endfunction

function [gradW,gradH] = getGradient(A,W,H,type,alpha,beta)
    switch type
        case 'plain'
            gradW = W*(H*H') - A*H';
            gradH = (W'*W)*H - W'*A;
        case 'regularized'
            gradW = W*(H*H') - A*H' + alpha*W;
            gradH = (W'*W)*H - W'*A + beta*H;
        case 'sparse'
            k=size(W,2);
            betaI = beta*ones(k,k);
            gradW = W*(H*H') - A*H' + alpha*W;
            gradH = (W'*W)*H - W'*A + betaI*H;
    end

endfunction

function [X,grad,iter] = nnlsm(A,B,init,solver)
    switch solver
        case 'bp'
            [X,grad,iter] = nnlsm_blockpivot(A,B,0,init);
        case 'as'
            [X,grad,iter] = nnlsm_activeset(A,B,1,0,init);
    end

endfunction

function [ X,Y,iter,success ] = nnlsm_activeset( A, B, overwrite, isInputProd, init)
% Nonnegativity Constrained Least Squares with Multiple Righthand Sides
%      using Active Set method
%
% This software solves the following problem: given A and B, find X such that
%            minimize || AX-B ||_F^2 where X>=0 elementwise.
%
% Reference:
%      Charles L. Lawson and Richard J. Hanson, Solving Least Squares Problems,
%            Society for Industrial and Applied Mathematics, 1995
%      M. H. Van Benthem and M. R. Keenan,
%            Fast Algorithm for the Solution of Large-scale Non-negativity-constrained Least Squares Problems,
%            J. Chemometrics 2004; 18: 441-450
%
% Written by Jingu Kim (jingu@cc.gatech.edu)
%               School of Computational Science and Engineering,
%               Georgia Institute of Technology
%
% Last updated Feb-20-2010
%
% <Inputs>
%        A : input matrix (m x n) (by default), or A'*A (n x n) if isInputProd==1
%        B : input matrix (m x k) (by default), or A'*B (n x k) if isInputProd==1
%        overwrite : (optional, default:0) if turned on, unconstrained least squares solution is computed in the beginning
%        isInputProd : (optional, default:0) if turned on, use (A'*A,A'*B) as input instead of (A,B)
%        init : (optional) initial value for X
% <Outputs>
%        X : the solution (n x k)
%        Y : A'*A*X - A'*B where X is the solution (n x k)
%        iter : number of iterations
%        success : 1 for success, 0 for failure.
%                  Failure could only happen on a numericall very ill-conditioned problem.

    if nargin<3, overwrite=0;, end
    if nargin<4, isInputProd=0;, end

    if isInputProd
        AtA=A;,AtB=B;
    else
        AtA=A'*A;, AtB=A'*B;
    end

    [n,k]=size(AtB);
    MAX_ITER = n*5;
    % set initial feasible solution
    if overwrite
        [X,iter] = solveNormalEqComb(AtA,AtB);
        PassSet = (X > 0);
        NotOptSet = any(X<0);
    else
        if nargin<5
            X = zeros(n,k);
            PassSet = false(n,k);
            NotOptSet = true(1,k);
        else
            X = init;
            PassSet = (X > 0);
            NotOptSet = any(X<0);
        end
        iter = 0;
    end

    Y = zeros(n,k);
    Y(:,~NotOptSet)=AtA*X(:,~NotOptSet) - AtB(:,~NotOptSet);
    NotOptCols = find(NotOptSet);

    bigIter = 0;, success=1;
    while(~isempty(NotOptCols))
        bigIter = bigIter+1;
        if ((MAX_ITER >0) && (bigIter > MAX_ITER))   % set max_iter for ill-conditioned (numerically unstable) case
            success = 0;, bigIter, break
        end

        % find unconstrained LS solution for the passive set
        Z = zeros(n,length(NotOptCols));
        [ Z,subiter ] = solveNormalEqComb(AtA,AtB(:,NotOptCols),PassSet(:,NotOptCols));
        iter = iter + subiter;
        %Z(abs(Z)<1e-12) = 0;                 % One can uncomment this line for numerical stability.
        InfeaSubSet = Z < 0;
        InfeaSubCols = find(any(InfeaSubSet));
        FeaSubCols = find(all(~InfeaSubSet));

        if ~isempty(InfeaSubCols)               % for infeasible cols
            ZInfea = Z(:,InfeaSubCols);
            InfeaCols = NotOptCols(InfeaSubCols);
            Alpha = zeros(n,length(InfeaSubCols));, Alpha(:,:) = Inf;
            InfeaSubSet(:,InfeaSubCols);
            [i,j] = find(InfeaSubSet(:,InfeaSubCols));
            InfeaSubIx = sub2ind(size(Alpha),i,j);
            if length(InfeaCols) == 1
                InfeaIx = sub2ind([n,k],i,InfeaCols * ones(length(j),1));
            else
                InfeaIx = sub2ind([n,k],i,InfeaCols(j)');
            end
            Alpha(InfeaSubIx) = X(InfeaIx)./(X(InfeaIx)-ZInfea(InfeaSubIx));

            [minVal,minIx] = min(Alpha);
            Alpha(:,:) = repmat(minVal,n,1);
            X(:,InfeaCols) = X(:,InfeaCols)+Alpha.*(ZInfea-X(:,InfeaCols));
            IxToActive = sub2ind([n,k],minIx,InfeaCols);
            X(IxToActive) = 0;
            PassSet(IxToActive) = false;
        end
        if ~isempty(FeaSubCols)                 % for feasible cols
            FeaCols = NotOptCols(FeaSubCols);
            X(:,FeaCols) = Z(:,FeaSubCols);
            Y(:,FeaCols) = AtA * X(:,FeaCols) - AtB(:,FeaCols);
            %Y( abs(Y)<1e-12 ) = 0;               % One can uncomment this line for numerical stability.

            NotOptSubSet = (Y(:,FeaCols) < 0) & ~PassSet(:,FeaCols);
            NewOptCols = FeaCols(all(~NotOptSubSet));
            UpdateNotOptCols = FeaCols(any(NotOptSubSet));
            if ~isempty(UpdateNotOptCols)
                [minVal,minIx] = min(Y(:,UpdateNotOptCols).*~PassSet(:,UpdateNotOptCols));
                PassSet(sub2ind([n,k],minIx,UpdateNotOptCols)) = true;
            end
            NotOptSet(NewOptCols) = false;
            NotOptCols = find(NotOptSet);
        end
    end

endfunction

function [ X,Y,iter,success ] = nnlsm_blockpivot( A, B, isInputProd, init )
% Nonnegativity Constrained Least Squares with Multiple Righthand Sides
%      using Block Principal Pivoting method
%
% This software solves the following problem: given A and B, find X such that
%              minimize || AX-B ||_F^2 where X>=0 elementwise.
%
% Reference:
%      Jingu Kim and Haesun Park, Toward Faster Nonnegative Matrix Factorization: A New Algorithm and Comparisons,
%      In Proceedings of the 2008 Eighth IEEE International Conference on Data Mining (ICDM'08), 353-362, 2008
%
% Written by Jingu Kim (jingu@cc.gatech.edu)
% Copyright 2008-2009 by Jingu Kim and Haesun Park,
%                        School of Computational Science and Engineering,
%                        Georgia Institute of Technology
%
% Check updated code at http://www.cc.gatech.edu/~jingu
% Please send bug reports, comments, or questions to Jingu Kim.
% This code comes with no guarantee or warranty of any kind. Note that this algorithm assumes that the
%      input matrix A has full column rank.
%
% Last modified Feb-20-2009
%
% <Inputs>
%        A : input matrix (m x n) (by default), or A'*A (n x n) if isInputProd==1
%        B : input matrix (m x k) (by default), or A'*B (n x k) if isInputProd==1
%        isInputProd : (optional, default:0) if turned on, use (A'*A,A'*B) as input instead of (A,B)
%        init : (optional) initial value for X
% <Outputs>
%        X : the solution (n x k)
%        Y : A'*A*X - A'*B where X is the solution (n x k)
%        iter : number of iterations
%        success : 1 for success, 0 for failure.
%                  Failure could only happen on a numericall very ill-conditioned problem.

    if nargin<3, isInputProd=0;, end
    if isInputProd
        AtA = A;, AtB = B;
    else
        AtA = A'*A;, AtB = A'*B;
    end

    [n,k]=size(AtB);
    MAX_ITER = n*5;
    % set initial feasible solution
    X = zeros(n,k);
    if nargin<4
        Y = - AtB;
        PassiveSet = false(n,k);
        iter = 0;
    else
        PassiveSet = (init > 0);
        [ X,iter ] = solveNormalEqComb(AtA,AtB,PassiveSet);
        Y = AtA * X - AtB;
    end
    % parameters
    pbar = 3;
    P = zeros(1,k);, P(:) = pbar;
    Ninf = zeros(1,k);, Ninf(:) = n+1;
    iter = 0;

    NonOptSet = (Y < 0) & ~PassiveSet;
    InfeaSet = (X < 0) & PassiveSet;
    NotGood = sum(NonOptSet)+sum(InfeaSet);
    NotOptCols = NotGood > 0;

    bigIter = 0;, success=1;
    while(~isempty(find(NotOptCols)))
        bigIter = bigIter+1;
        if ((MAX_ITER >0) && (bigIter > MAX_ITER))   % set max_iter for ill-conditioned (numerically unstable) case
            success = 0;, break
        end

        Cols1 = NotOptCols & (NotGood < Ninf);
        Cols2 = NotOptCols & (NotGood >= Ninf) & (P >= 1);
        Cols3Ix = find(NotOptCols & ~Cols1 & ~Cols2);
        if ~isempty(find(Cols1))
            P(Cols1) = pbar;,Ninf(Cols1) = NotGood(Cols1);
            PassiveSet(NonOptSet & repmat(Cols1,n,1)) = true;
            PassiveSet(InfeaSet & repmat(Cols1,n,1)) = false;
        end
        if ~isempty(find(Cols2))
            P(Cols2) = P(Cols2)-1;
            PassiveSet(NonOptSet & repmat(Cols2,n,1)) = true;
            PassiveSet(InfeaSet & repmat(Cols2,n,1)) = false;
        end
        if ~isempty(Cols3Ix)
            for i=1:length(Cols3Ix)
                Ix = Cols3Ix(i);
                toChange = max(find( NonOptSet(:,Ix)|InfeaSet(:,Ix) ));
                if PassiveSet(toChange,Ix)
                    PassiveSet(toChange,Ix)=false;
                else
                    PassiveSet(toChange,Ix)=true;
                end
            end
        end
        NotOptMask = repmat(NotOptCols,n,1);
        [ X(:,NotOptCols),subiter ] = solveNormalEqComb(AtA,AtB(:,NotOptCols),PassiveSet(:,NotOptCols));
        iter = iter + subiter;
        X(abs(X)<1e-12) = 0;            % for numerical stability
        Y(:,NotOptCols) = AtA * X(:,NotOptCols) - AtB(:,NotOptCols);
        Y(abs(Y)<1e-12) = 0;            % for numerical stability

        % check optimality
        NonOptSet = NotOptMask & (Y < 0) & ~PassiveSet;
        InfeaSet = NotOptMask & (X < 0) & PassiveSet;
        NotGood = sum(NonOptSet)+sum(InfeaSet);
        NotOptCols = NotGood > 0;
    end
endfunction

function [ Z,iter ] = solveNormalEqComb( AtA,AtB,PassSet )
% Solve normal equations using combinatorial grouping.
% Although this function was originally adopted from the code of
% "M. H. Van Benthem and M. R. Keenan, J. Chemometrics 2004; 18: 441-450",
% important modifications were made to fix bugs.
%
% Modified by Jingu Kim (jingu@cc.gatech.edu)
%             School of Computational Science and Engineering,
%             Georgia Institute of Technology
%
% Last updated Aug-12-2009

    iter = 0;
    if (nargin ==2) || isempty(PassSet) || all(PassSet(:))
        Z = AtA\AtB;
        iter = iter + 1;
    else
        Z = zeros(size(AtB));
        [n,k1] = size(PassSet);

        ## Fixed on Aug-12-2009
        if k1==1
            Z(PassSet)=AtA(PassSet,PassSet)\AtB(PassSet);
        else
            ## Fixed on Aug-12-2009
            % The following bug was identified by investigating a bug report by Hanseung Lee.
            [sortedPassSet,sortIx] = sortrows(PassSet');
            breaks = any(diff(sortedPassSet)');
            breakIx = [0 find(breaks) k1];
            % codedPassSet = 2.^(n-1:-1:0)*PassSet;
            % [sortedPassSet,sortIx] = sort(codedPassSet);
            % breaks = diff(sortedPassSet);
            % breakIx = [0 find(breaks) k1];

            for k=1:length(breakIx)-1
                cols = sortIx(breakIx(k)+1:breakIx(k+1));
                vars = PassSet(:,sortIx(breakIx(k)+1));
                Z(vars,cols) = AtA(vars,vars)\AtB(vars,cols);
                iter = iter + 1;
            end
        end
    end
endfunction

%!shared m, n, k, A
%! m = 30;
%! n = 20;
%! k = 10;
%! A = rand(m,n);

%!test
%! [W,H,iter,HIS]=nmf_bpas(A,k);

%!test
%! [W,H,iter,HIS]=nmf_bpas(A,k,'verbose');

%!test
%! [W,H,iter,HIS]=nmf_bpas(A,k,'verbose','nnlssolver','as');

%!test
%! [W,H,iter,HIS]=nmf_bpas(A,k,'verbose','type','sparse');

%!test
%! [W,H,iter,HIS]=nmf_bpas(A,k,'verbose','type','sparse','nnlssolver','bp','alpha',1.1,'beta',1.3);

%!test
%! [W,H,iter,HIS]=nmf_bpas(A,k,'verbose','type','plain','winit',rand(m,k));

%!demo
%! m = 300;
%! n = 200;
%! k = 10;
%!
%! W_org = rand(m,k);, W_org(rand(m,k)>0.5)=0;
%! H_org = rand(k,n);, H_org(rand(k,n)>0.5)=0;
%!
%! % normalize W, since 'nmf' normalizes W before return
%! norm2=sqrt(sum(W_org.^2,1));
%! toNormalize = norm2 > eps;
%! W_org(:,toNormalize) = W_org(:,toNormalize) ./ norm2(toNormalize);
%!
%! A = W_org * H_org;
%!
%! [W,H,iter,HIS]=nmf_bpas (A,k,'type','plain','tol',1e-4);
%!
%! % -------------------- column reordering before computing difference
%! reorder = zeros(k,1);
%! selected = zeros(k,1);
%! for i=1:k
%!    for j=1:k
%!        if ~selected(j), break, end
%!    end
%!    minIx = j;
%!
%!    for j=minIx+1:k
%!        if ~selected(j)
%!            d1 = norm(W(:,i)-W_org(:,minIx));
%!            d2 = norm(W(:,i)-W_org(:,j));
%!            if (d2<d1)
%!                minIx = j;
%!            end
%!        end
%!    end
%!    reorder(i) = minIx;
%!    selected(minIx) = 1;
%! end
%!
%! W_org = W_org(:,reorder);
%! H_org = H_org(reorder,:);
%! % ---------------------------------------------------------------------
%!
%! recovery_error_W = norm(W_org-W)/norm(W_org)
%! recovery_error_H = norm(H_org-H)/norm(H_org)
