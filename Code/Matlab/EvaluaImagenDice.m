function DS = EvaluaImagenDice(imagetrue,imageautomatica)
%
% Función que calcula el coeficiente de Dice, Si DS=1, la segmentacion
% es perfecta y si es cero la segmentacion no se parece en ningun pixel 
% con la manual.
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
            end
            if imagetrue(i,j) == 1
                x=x+1;
            end
            if imageautomatica(i,j) == 1
                y=y+1;
            end
        end
        j=j+1;
    end
    i=i+1;
end
DS = 2*interseccion/(x+y);
end