% Demostration for generating EDF/BDF/GDF-files
% DEMO3 is part of the biosig-toolbox
%    and it tests also Matlab/Octave for its correctness. 
% 

%	Copyright (C) 2000-2005,2006,2007,2008,2011,2013 by Alois Schloegl <alois.schloegl@gmail.com>
%    	This is part of the BIOSIG-toolbox http://biosig.sf.net/
%
%    BioSig is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    BioSig is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with BioSig.  If not, see <http://www.gnu.org/licenses/>.

Fs=1000; 
x = sin(2*pi*[0:10*Fs]'/Fs);


clear HDR;

VER   = version;
cname = computer;

% select file format 
HDR.TYPE='GDF';  
% HDR.TYPE='EDF';
%HDR.TYPE='BDF'; 
%HDR.TYPE='CFWB';
%HDR.TYPE='CNT';

% set Filename
HDR.FileName = 'test001.gdf';

% description of recording device 
HDR.Manufacturer.Name = 'BioSig';
HDR.Manufacturer.Model = 'demo3.m';
HDR.Manufacturer.Version = '2.84';
HDR.Manufacturer.SerialNumber = '00000000';

% recording identification, max 80 char.
HDR.RID = 'TestFile 001'; %StudyID/Investigation [consecutive number];
HDR.REC.Hospital   = 'BioSig Test Lab'; 
HDR.REC.Technician = get_current_username();
HDR.REC.Equipment  = 'biosig';
HDR.REC.IPaddr	   = [127,0,0,1];	% IP address of recording system 	
HDR.Patient.Name   = 'anonymous';  
HDR.Patient.Id     = 'P0000';	
HDR.Patient.Birthday = [1951 05 13 0 0 0];
HDR.Patient.Weight = 0; 	% undefined 
HDR.Patient.Height = 0; 	% undefined 
HDR.Patient.Sex    = 'f'; 	% 0: undefined,	1: male, 2: female 
HDR.Patient.Birthday = zeros(1,6); %    undefined 
HDR.Patient.Impairment.Heart = 0;  %	0: unknown 1: NO 2: YES 3: pacemaker 
HDR.Patient.Impairment.Visual = 0; %	0: unknown 1: NO 2: YES 3: corrected (with visual aid) 
HDR.Patient.Smoking = 0;           %	0: unknown 1: NO 2: YES 
HDR.Patient.AlcoholAbuse = 0; 	   %	0: unknown 1: NO 2: YES 
HDR.Patient.DrugAbuse = 0; 	   %	0: unknown 1: NO 2: YES 
HDR.Patient.Handedness = 0; 	   % 	unknown, 1:left, 2:right, 3: equal

% recording time [YYYY MM DD hh mm ss.ccc]
HDR.T0 = clock;	

% number of channels
HDR.NS = size(x,2);

% Duration of one block in seconds
HDR.SampleRate = Fs;
HDR.NRec = length(x);
HDR.SPR = 1;
% HDR.Dur = HDR.SPR/HDR.SampleRate;

% Samples within 1 block
HDR.AS.SPR = 1;	% samples per block; 0 indicates a channel with sparse sampling 
%HDR.AS.SampleRate = [1000;100;200;100;20;0];	% samplerate of each channel

% channel identification, max 80 char. per channel
HDR.Label={'chan 1'};

% Transducer, mx 80 char per channel
HDR.Transducer = {'Ag-AgCl'};

	% define datatypes (GDF only, see GDFDATATYPE.M for more details)
HDR.GDFTYP = 3*ones(1,HDR.NS);

% define scaling factors 
HDR.PhysMax = [1];
HDR.PhysMin = [-1];
HDR.DigMax  = repmat(2^15-1,size(HDR.PhysMax));
HDR.DigMin  = repmat(1-2^15,size(HDR.PhysMax));
HDR.FLAG.UCAL = 1; 	% data x is already converted to internal (usually integer) values (no rescaling within swrite);
HDR.FLAG.UCAL = 0; 	% data x will be converted from physical to digital values within swrite. 
% define filter settings 
HDR.Filter.Lowpass = [0];
HDR.Filter.Highpass = [NaN];
HDR.Filter.Notch = [0];
% define sampling delay between channels  
HDR.TOffset = [0]*1e-6;


% define physical dimension
HDR.PhysDim = {'uV'};	%% must be encoded in unicode (UTF8)
HDR.Impedance = [5000];         % electrode impedance (in Ohm) for voltage channels 
HDR.fZ = [NaN];                % probe frequency in Hz for Impedance channel

t = [Fs/4:Fs:size(x,1)]';
%HDR.NRec = 100;
HDR.VERSION = 3.0;        % experimental  
HDR.EVENT.POS = t;
HDR.EVENT.TYP = ones(size(t));
HDR.EVENT.SampleRate=Fs; 

HDR2=HDR;
HDR2=rmfield(HDR,'EVENT');
HDR2.FileName='test002.gdf';



EVT=HDR; 
EVT.FileName='test00a.evt';
EVT.EVENT.TYP = ones(size(t))*2;
EVT.NS=0;
EVT.SPR=0;
EVT.Filter.Lowpass = [];
EVT.Filter.Highpass = [];
EVT.Filter.Notch = [];
EVT.PhysDim = {};	%% must be encoded in unicode (UTF8)
EVT.Impedance = [];         % electrode impedance (in Ohm) for voltage channels 
EVT.fZ = [];                % probe frequency in Hz for Impedance channel
EVT.Label={};
EVT.Transducer = {};
EVT.GDFTYP = [];

EVT2=EVT;
EVT2.FileName='test00b.evt';
EVT2.EVENT.SampleRate=Fs*4; 
EVT2.SampleRate=Fs*4; 
EVT2.EVENT.POS=EVT2.EVENT.POS*4; 
EVT2.EVENT.TYP = ones(size(t))*3;
EVT2.NS=0;
EVT2.SPR=0;


HDR1 = sopen(HDR,'w');
HDR1 = swrite(HDR1,x);
HDR1 = sclose(HDR1);

HDR1 = sopen(HDR2,'w');
HDR1 = swrite(HDR1,x);
HDR1 = sclose(HDR1);

EVT1 = sopen(EVT,'w');
EVT1 = sclose(EVT1);

EVT1 = sopen(EVT2,'w');
EVT1 = sclose(EVT1);



