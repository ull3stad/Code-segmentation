function z=remuest(B,n)
% z=remuest(y)
% Función para remuestrear el contorno ordenado de una figura con n puntos
% El primero NO está repetido 
% los puntos del contorno estarán ordenados por la función bordea.m
% EL número de puntos debería ser potencia entera de 2 para calcular luego la FFT.
% y mayor que el perímetro de la máxima figura
% z: Es de lo que se debe calcular la FFT para hallar el descriptor de Fourier.
% El remuestreo se hace con longitudes de segmento iguales.
%y(:,1)=round(real(B));
%y(:,2)=round(imag(B));
%%z=y(:,1)+j*y(:,2);
B2=zeros(length(B)+1,1);
B2(1:length(B))=B;
B2(length(B)+1)=B(1);
z=zeros(1,n);
% perim=0;
% d=ones(length(B));
% for (i=1:length(B)-1)
%     if (and((y(i+1,1)~=y(i,1)),(y(i+1,2)~=y(i,2)))) 
%         d(i)=sqrt(2);
%         perim=perim+sqrt(2);
%      else
%         perim=perim+1;
% end
% end
%B2=B(1:length(B)-1);
d=abs(diff(B2));
perim=sum(d);

salto=perim/(n-1);
z(1)=B(1);
porig=1;
for(k=2:n-1)
    %z(k-1)
    %z(porig+1)
distancia=abs(z(k - 1)-B2(porig+1));
%distancia
%pause
%k
%pause
if (distancia > salto)
% Pi_sig esta en la recta que une Pi_act con el Por_sig:
 fase = angle(B2(porig+1)-B2(porig));	
 inc_x = salto*cos(fase);
 inc_y = salto*sin(fase);
 z(k) = z(k-1) + (inc_x+j*inc_y);
else
 nuevosalto = salto - distancia;
 %if (nuevosalto > d(porig + 1))
  %   nuevosalto = nuevosalto - d(porig+1);
   %  porig=porig+1
     
 %end
     fase = angle(B2(porig+2)-B2(porig+1));
     inc_x = nuevosalto*cos(fase);
     inc_y = nuevosalto*sin(fase);
     %inc_x = salto*cos(fase);
     %inc_y = salto*sin(fase);
 	 z(k)=B(porig+1)+ inc_x+j*inc_y;
     porig = porig +1;
end
%z(k)
%pause
end
z(n)=z(1);
 end
