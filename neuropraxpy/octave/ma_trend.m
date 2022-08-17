function [trend1, trend2]=ma_trend(sig, ord);
% function [trend1,trend2]=ma_trend(sig, ord)
% Glaetten einer Zeitreihe mit moving-average Filter
%  Eingabe:
%  Zeitreihe 			sig
%  Ordnung des MA Filters	ord
%
%  Ausgabe:
%  Trend			trend1
%  Trend			trend2

% Autor: K. Schellhorn, BMTI, 1996
% Glaetten einer Zeitreihe mit MA Filter
% Literatur: Brockwell/Davis Time Series: Theory and Methods
% Implementierung von Formel (1.4.6)

Ny=length(sig);

x=[sig(1)*ones(ord,1); sig; sig(Ny)*ones(ord,1)];

B1=(1/(2*ord+1))*ones(2*ord+1,1);				% Formel (1.4.6)
out1=conv(B1,x);
trend1=out1(2*ord+1:2*ord+Ny);					% linearer Trend ueber das Zeitintervall 
								% der Laenge ord

x=[sig(1)*ones(7,1); sig; sig(Ny)*ones(7,1)];			% Formel (1.4.9)
B2=(1/320)*[-3 -6 -5 3 21 46 67 74 67 46 21 3 -5 -6 -3];	% Spencer Fenster (15 Punkte)
out2=conv(B2,x);
trend2=out2(2*7+1:2*7+Ny);					% Annahme: Trend durch Approx. 3. Grades
