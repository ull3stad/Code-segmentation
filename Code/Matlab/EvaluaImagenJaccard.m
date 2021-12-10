function JC = EvaluaImagenJaccard(imagetrue,imageautomatica,mm)
%
% Función que calcula el coeficiente de Jaccard, Si JC=1, la segmentacion
% es perfecta y si es mayor que 0.8 ya es bastante buena. Cero la
% segmentacion no se parece en ningun pixel con la manual.
%
%
interseccion=0;
x=0;
y=0;
i=1;
while i<=length(imagetrue(:,1))
    j=1;
    while j<=length(imageautomatica(1,:))
        if imagetrue(i,j)>=1 || imageautomatica(i,j)>=1
            if imagetrue(i,j)==imageautomatica(i,j)
                interseccion=interseccion+1;
            elseif imagetrue(i,j) == 1
                x=x+1;
            else
                y=y+1;
            end
        end
        j=j+1;
    end
    i=i+1;
end
JC = interseccion/(interseccion+x+y);
end