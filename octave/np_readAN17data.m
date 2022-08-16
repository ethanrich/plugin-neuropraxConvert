function [np_dataAN17] = np_readAN17data (filename, idx_begin, data_length, option)
%
% function [np_dataAN17] = np_readAN17data (filename, idx_begin, data_length, option)
%
% np_readAN17data reads data from a NEURO PRAX MR analyzed data file (*.AN17).
%
% Syntax:
%
%   [np_dataAN17] = np_readAN17data(filename,idx_begin,data_length,'samples');
%   [np_dataAN17] = np_readAN17data(filename,idx_begin,data_length,'time');
%
% Input data:
%
%   filename    -   the complete EEG filename with path
%                   (e. g.  C:\Document...\20030716103637.EEG)
%   idx_begin   -   the start index of the data block to be read
%   data_length -   the length of the data block to be read
%   option      -   if option = 'samples':
%                       the data block starts at sample 'idx_begin' from the recording;
%                       data_length is the number of samples to be read
%                   if option = 'time':
%                       the data block starts at time 'idx_begin' from the recording;
%                       data_length is the number of seconds to be read
%
%                   To read all data use: idx_start = 0, data_length = inf, option =
%                   'samples'.
%
% Output data:
%
%   np_dataAN17                 -   structure
%   np_dataAN17.data            -   data matrix of analyzed data
%                                   dimension of the matrix: (Nx(K+A))
%                                   N: number of samples
%                                   K: number of channels 
%                                   A: additional channels
%                                   The number of additional channels depends on
%                                   the used protocol during EEG recording.
%   np_dataAN17.t               -   discrete time vector for the recording
%   np_dataAN17.AddedChannels   -   a list of the additional channel names
%                                   in the AN17 file
%   np_dataAN17.protocol        -   the used protocol during recording

% Dateinamen aufbereiten, Infos lesen
[f,p]=fileparts(filename);
fileSeparator=filesep;
SrcFilename=[f fileSeparator p '.EEG'];
np_info=np_readfileinfo(SrcFilename,'NO_MINMAX');
SrcFilename=[f fileSeparator p '.' np_info.algorithm '.AN17'];

% Daten initialisieren, Startsamples und Blockl‰nge ermitteln
if (0==idx_begin) && (inf==data_length)
    N_start=0;
    N = np_info.N;                 
else
    switch upper(option)
        case 'SAMPLES', 
            N_start = idx_begin;
            N       = data_length;
        case 'TIME',
            N_start = round(idx_begin*np_info.fa);
            N       = round(data_length*np_info.fa);
        otherwise,
            error ('Bad specification for ''option''');
    end
    if (N_start<0)
        error ('idx_begin is to small.');
    end
    if ((N_start+N-1)>(np_info.N-1))
        error('data_length is to big.');
    end
end
NoAdditionalChannels=1;     % MRK-Kanal
if (1==strcmp(upper(np_info.algorithm),'IA'))
    NoAdditionalChannels=2;
    np_dataAN17.AddedChannels={'MRK','IA'};
end
if (1==strcmp(upper(np_info.algorithm),'PA'))
    NoAdditionalChannels=3;
    np_dataAN17.AddedChannels={'MRK','PD','HR'};
end
if (1==strcmp(upper(np_info.algorithm),'MR'))
    NoAdditionalChannels=4;
    np_dataAN17.AddedChannels={'MRK','IA','PD','HR'};
end
np_info.K=np_info.K+NoAdditionalChannels;
np_dataAN17.data=zeros(N,np_info.K);
np_dataAN17.data=single(np_dataAN17.data);
np_dataAN17.t=single((N_start:N_start+N-1)'./np_info.fa);
np_dataAN17.protocol=np_info.algorithm;

% -------------------------------------------------------------------------
% Messadten einlesen
%
% sequentielles Datenformat in Datei (K-Kanalindex, N-Sampleindex):
% x11 x21 x31 ... xK1 ...  
% x12 x22 x32 ... xK2 ...
% ...
% x1(N-1) x2(N-1) ... xK(N-1) ...
% x1N x2N x3N ... xKN
%
% einlesen in eine Matrix mit der Dimension: (KxN)
% anschlieﬂend transponieren in eine Matrix der Dimension: (NxK)
%
% -------------------------------------------------------------------------
fid=fopen(SrcFilename,'r');
if fid==-1,
    error(['Unable to open file "' SrcFilename '" . Error code: ' ferror(fid)]);
end
status=fseek(fid,N_start*np_info.K*4,'bof');    % 4 Byte pro Sample (float bzw. single)
if status~=0,
    fclose(fid);
    error('Unable to set filepointer to begin of data block.');
end
[np_dataAN17.data,count]=fread(fid,[np_info.K N],'float');      % lese Messdaten
np_dataAN17.data=single(np_dataAN17.data);
if count~=N*np_info.K,
    fclose(fid);
    error('Number of read samples unequal to product N*K.');
end
np_dataAN17.data=np_dataAN17.data';         % transponieren
fclose(fid);
