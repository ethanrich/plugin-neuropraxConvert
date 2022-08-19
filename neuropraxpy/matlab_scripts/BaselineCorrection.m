function [y] = BaselineCorrection (signal, fa, baseline, method, ith)
%
% function [y] = BaselineCorrection (signal, fa, baseline, method, ith)
%
% Baseline correction using different methods.
%
% signal    -   (NxK) signal matrix (N: samples; K: channels)
% fa        -   sampling frequency
% baseline  -   duration of baseline (s)
% method    -   correction method
%
%    'original'              -   no baseline correction
%    'remove_firstsample'    -   removes the first sample from each channel
%    'remove_middlesample'   -   removes the middle sample from each channel
%    'remove_lastsample'     -   removes the last sample from each channel
%    'remove_ithsample'      -   removes the "i"th sample from each channel
%    'remove_mean'           -   removes baseline mean in each channel
%    'remove_lintrend'       -   estimates the linear trend in baseline and
%                                detrends each channel
%

method=upper(method);
N=size(signal,1);
K=size(signal,2);
if (1==strcmp('ORIGINAL',method))
    y=signal;
end
if (1==strcmp('REMOVE_FIRSTSAMPLE',method))
    %
    % removes the first sample in each record
    % 
    % signal and y are (NxK) matrices
    % "first sample" is a (1xK) matrix;
    y=signal-ones(N,1)*signal(1,:);
end
if (1==strcmp('REMOVE_MIDDLESAMPLE',method))
    %
    % removes the middle sample in each record
    % 
    % signal and y are (NxK) matrices
    % "middle sample" is a (1xK) matrix;
    Middle=round(size(signal,1)/2);
    y=signal-ones(N,1)*signal(Middle,:);
end
if (1==strcmp('REMOVE_LASTSAMPLE',method))
    %
    % removes the last sample in each record
    % 
    % signal and y are (NxK) matrices
    % "last sample" is a (1xK) matrix;
    y=signal-ones(N,1)*signal(size(signal,1),:);
end
if (1==strcmp('REMOVE_ITHSAMPLE',method))
    %
    % removes the "i"th sample in each record
    % 
    % signal and y are (NxK) matrices
    % "ith sample" is a (1xK) matrix;
    y=signal-ones(N,1)*signal(ith,:);
end
if (1==strcmp('REMOVE_MEAN',method))
    %
    % removes the baseline mean in each record
    % 
    % signal and y are (NxK) matrices
    % "baseline mean" is a (1xK) matrix;
    baselineMean=mean(signal(1:round(baseline*fa),:),1);
    y=signal-ones(N,1)*baselineMean;
end
if (1==strcmp('REMOVE_LINTREND',method))
    %
    % removes the baseline linear trend in each record
    % 
    % signal and y are (NxK) matrices
    % "baseline trend" is a (1xK) matrix;
    X=[1:round(baseline*fa)]';
    for k=1:K
        B=robustfit(X,signal(1:round(baseline*fa),k));
        y(:,k)=signal(:,k)-B(1)-B(2).*[1:N]';
    end
end