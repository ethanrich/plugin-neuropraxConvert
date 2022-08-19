% Test_RAMPTON_FB.m
% MATLAB Script file for reading in EEG data from the "eldith NEURO PRAX" / "eldith THERA PRAX" (Datei German = data file)

% for Jennifer Gallagher / Richard Howard - Institute of Mental HealthUniversity of Nottingham
% any complaints send to Klaus.schellhorn@neuroconn.de
% JULY, 30th 2010

% (c) neuroConn GmbH, Ilmenau, Germany
% Dr. Falk Schlegelmilch, Dipl.-Ing. Klaus Schellhorn 2004 - 2010

close all
%clear all;                  % clear memory
clc;                        % clear working space view
figure(1); clf              % clear figure(1)
figure(2); clf              % clear figure(2)

Datei='D:\___NCG\Vorbereitung Auswertung Stockholm\20220520113305.EEG';
np_info=np_readfileinfo([Datei],'NO_MINMAX');  
np_data=np_readdata([Datei],0,inf,'samples');  
np_marker = np_readmarker([Datei],0,inf,'samples');



%
% select channels for display
% np_info.channels %on matlab command evokes: 
%
%
% ans = 
%
%    'VEOG_I'    'VEOG_II'    'HEOG_I'    'HEOG_II'    'FCz'    'REF_EEG'
%

sig=np_data.data(:,15)-np_data.data(:,30);    % EEG on EEG1 - REF_EEG

[trend1,trend2]=ma_trend(sig, 11);          % Moving Average Filter

sig=trend1;

sig1=sig-sig(1);                            % forcing the first sample to be 0 - just to deal with offsets
sig1=sig-sig(1);                            % forcing the first sample to be 0 - just to deal with offsets
t=[-199:2*400]/np_info.fa;                  % Time Vector for display t=0 on the 200th sample

%bl_type='remove_lintrend';                  % baselinetype calculation go to matlab and recall >>help BaselineCorrection to see other options
bl_type='remove_mean';                       % baselinetype calculation go to matlab and recall >>help BaselineCorrection to see other options
ith=200;                                     % sample at t=0 seconds

test_paired_pulse=np_data.DTRIG1_posTrig;   % reading out trigger events

rr=0; counter=0;                            
clc


for j=2:length(test_paired_pulse)-1,          
disp(['J= ' num2str(j)]); 

mx=sig1(test_paired_pulse(j)-199:test_paired_pulse(j)+2*400);

r=BaselineCorrection (mx, np_info.fa, 195/np_info.fa, bl_type, ith); % building baseline from the first to the 195 sample
rr=rr+r;
counter=counter+1;

plot(t,r,'r:');hold on;grid on; axis([-0.01 0.03 -600 400])     % plot all realisations or runs
end

xlabel('Time in s'); ylabel('µV')
hold on; set(plot(t,1/counter*rr,'k'),'Linewidth',[2]);hold on;grid on; axis([0.001 0.03 -1600 1400])   % plot mean value in black 
Title('FC3 - REF_EEG')

axis ij                             % negative values up
axis([-0.01 0.20 -15 15])           % force display to be in +/- 15 µV amplitude range and between time -0.01 0.2
legend('Raw Data, black line MEAN VALUE')






