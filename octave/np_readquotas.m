function [q_38,q_49,q_16,q_27] = np_readquotas (filename)
%
% function [q_38,q_49,q_16,q_27] = np_readquotas (filename)
%
% NEURO PRAX (R) Read Quotas strings from *.EE_ file for each trial.
%
% Input data:
%   filename        -   the complete filename with path
%                       (e. g.  C:\Document...\20030716103637.EEG)
%
% Ouput data:
%
%   q_38    -   quotas for markertyp pair 3-8 (e.g. FB+ and FBQuote+)
%   q_49    -   quotas for markertyp pair 4-9 (e.g. FB- and FBQuote-)
%   q_16    -   quotas for markertyp pair 1-6 (e.g. TR+ and TRQuote+)
%   q_27    -   quotas for markertyp pair 2-7 (e.g. TR- and TRQuote-)
%
% eldith GmbH
% Gustav-Kirchhoff-Str. 5
% D-98693 Ilmenau
% Germany
% 25.04.2005


% Allgemeines
fileSeparator=filesep;

% init output data
q_38={};
q_49={};
q_16={};
q_27={};

% read markernames, markertypes and marker
try
    np_marker=np_readmarker(filename,0,inf,'samples');
catch
    error('Fehler beim Lesen der Markerdatei.');
end

% read the complete EE_ file as a string
[pfad,fn,ext]=fileparts(filename);
ext='.EE_';
fid=fopen([pfad fileSeparator fn ext],'r');
if fid==-1
    error(['Unable to read marker file ' filename]);
    return;
end
s=fscanf(fid,'%c',inf);
fclose(fid);
s=regexprep(s,'=','|');

% extract the quotas for pair: 3-8 (e.g. FB+ and FBQuote+)
idxMarkerTyp8=find(np_marker.markertyp==8);
if ~isempty(idxMarkerTyp8),
    marker=np_marker.marker{idxMarkerTyp8};
    if ~isempty(marker),
        q_38=cell(length(marker),1);
        for m=1:length(marker)
            idx=strfind(s,['|8:' num2str(marker(m))]);       % find the corresp. quote sample index
            [t,r]=strtok(s(idx(1):length(s)),'(');             % find '(' after sample index
            [t,r]=strtok(r,')');                            % extract quota string, e.g. (100)
            q_38{m}=t(2:length(t));                         % = quota-string (depends on the setup and protocol
        end
    end
end
    
% extract the quotas for pair: 4-9 (e.g. FB- and FBQuote-)
idxMarkerTyp9=find(np_marker.markertyp==9);
if ~isempty(idxMarkerTyp9),
    marker=np_marker.marker{idxMarkerTyp9};
    if ~isempty(marker),
        q_49=cell(length(marker),1);
        for m=1:length(marker)
            idx=strfind(s,['|9:' num2str(marker(m))]);       % find the corresp. quote sample index
            [t,r]=strtok(s(idx(1):length(s)),'(');             % find '(' after sample index
            [t,r]=strtok(r,')');                            % extract quota string, e.g. (100)
            q_49{m}=t(2:length(t));                         % = quota-string (depends on the setup and protocol
        end
    end
end

% extract the quotas for pair: 1-6 (e.g. TR+ and TRQuote+)
idxMarkerTyp6=find(np_marker.markertyp==6);
if ~isempty(idxMarkerTyp6),
    marker=np_marker.marker{idxMarkerTyp6};
    if ~isempty(marker),
        q_16=cell(length(marker),1);
        for m=1:length(marker)
            idx=strfind(s,['|6:' num2str(marker(m))]);       % find the corresp. quote sample index
            [t,r]=strtok(s(idx(1):length(s)),'(');             % find '(' after sample index
            [t,r]=strtok(r,')');                            % extract quota string, e.g. (100)
            q_16{m}=t(2:length(t));                         % = quota-string (depends on the setup and protocol
        end
    end
end

% extract the quotas for pair: 2-7 (e.g. TR- and TRQuote-)
idxMarkerTyp7=find(np_marker.markertyp==7);
if ~isempty(idxMarkerTyp7),
    marker=np_marker.marker{idxMarkerTyp7};
    if ~isempty(marker),
        q_27=cell(length(marker),1);
        for m=1:length(marker)
            idx=strfind(s,['|7:' num2str(marker(m))]);       % find the corresp. quote sample index
            [t,r]=strtok(s(idx(1):length(s)),'(');             % find '(' after sample index
            [t,r]=strtok(r,')');                            % extract quota string, e.g. (100)
            q_27{m}=t(2:length(t));                         % = quota-string (depends on the setup and protocol
        end
    end
end