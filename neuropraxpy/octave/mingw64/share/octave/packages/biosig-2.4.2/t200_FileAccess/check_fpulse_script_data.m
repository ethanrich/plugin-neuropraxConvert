function check_fpulse_file(F)
% function check_fpulse_file(F)
%
% see also: SLOAD, SOPEN, mexSLOAD

% Copyright (C) 2021 by Alois Schloegl <alois.schloegl@gmail.com>
%    This is part of the BIOSIG-toolbox https://biosig.sourceforge.io/
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


[dat,HDR]=mexSLOAD(F);
N0=length(HDR.EVENT.TYP==hex2dec('7ffe'))+1;
if isfield(HDR,'AS') && isfield(HDR.AS,'BCI2000'),
        scr = HDR.AS.BCI2000; 
end

flag = -1; 
N1   =  1; 
while ~isempty(scr)
	[tok,scr]=strtok(scr, char([10,13]));
	ix = strfind(tok,'//');
	if ~isempty(ix), tok = tok(1:ix(1)-1); end;
	if strfind(tok,'PULSE'), flag=0; end 
	ix0=strfind(tok, 'Protocol');
	ix1=strfind(tok, 'Frames');
	ix2=strfind(tok, 'Sweeps');
		
	[F1,r] = strtok(tok,char([9,32]));
	[F2,r] = strtok(r,char([9,32,abs('=')]));
	[F3,r] = strtok(r,char([9,32,abs('=;"')]));
	if (~isempty(ix1) || ~isempty(ix2)),
		flag=flag+1;
	end
	if (~isempty(ix0)),
		F3 = [F3(F3~='"'),'.fp3'];
		fid =fopen(F3,'w'); fwrite(fid,HDR.AS.BCI2000,'char'); fclose(fid);
	end
	if (flag>0) && (~isempty(ix1) || ~isempty(ix2)),
		% Frames x Sweeps	
		N1 = N1*str2num(F3);
	end
	if ~isempty(strfind(tok, 'EndSweep')); flag=flag-1; end
	if ~isempty(strfind(tok, 'EndFrame')); flag=flag-1; end
end	

eflag = 0;
if flag>0,
	eflag = 1;
	fprintf(1,'Number of tags Frame:EndFrame, Sweep:EndSweep do not match\n');
end
if N0~=N1,
	eflag = 1;
	fprintf(1,'Sweep numbers do not match with script (%d~=%d)\n',N0,N1);
end
if eflag,
	fprintf(1,'OK: event table does not match script.\n');		
	disp(HDR.AS.BCI2000);
else
	fprintf(1,'OK: event table matches script (%d==%d)\n',N0,N1);		
end	


