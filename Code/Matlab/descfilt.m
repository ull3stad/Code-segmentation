function y=descfilt(FD,fc)
% y=descfil(FD,fc)
% Función que dado un descriptor de Fourier, elimina las altas frecuencias del
% mismo por encima de una frecuencia de corte fc. y devuelve el
% contorno suavizado.
% Sirve para evitar pequeñas rugosidades del contorno.

N=length(FD);
f=(0:(N-1))/N;
ind=find(f>0.5);
f(ind)=f(ind)-1;
ind=find(abs(f)>fc);
y=FD;
y(ind)=y(ind)*0;
y=ifft(y);
