
function [Mmyokard,Minf,Mask]=mask_data(imS,xy,xys);

%-----------------------------------
%  Input:
%  imS er vektor med st�rrelsen p� bildet (image size).
%  xy er cellestruktur som inneholder konturene, de innplottede punktene
%    (cell structure with the points marked by the cardiologists for each slice)
%  xys er cellestruktur som inneholder konturene, spline interpolert fra xy
%    (spline interpolated contoures from the points marked by the cardiologists)
%
%  Mmyokard er masken til hjertemuskel   (binary mask of myocardium)
%  Minf er masken til infarktomr�det     (binary mask of infarction)
%-------------------------------------

N=imS(1);
M=imS(2);
Mask{1}=zeros(N,M);
Mask{2}=zeros(N,M);
Mask{3}=zeros(N,M);
Mmyokard=zeros(N,M);
Minf=zeros(N,M);

[ant_kont1 ant_kont2]=size(xy);
if max(ant_kont1, ant_kont2) < 2
else

    if ant_kont1<ant_kont2
        ant_kont=ant_kont2;
        t=1;
    else
        ant_kont=ant_kont1;
        t=0;
    end

    %Mask=cell(ant_kont,1);
    mi=0;

    if t==0
        for i=1:ant_kont
            [trash st]=size(xy{i});
            if st<5
                continue;
            end
            mi=mi+1;
            Mask{mi}=roipoly(N,M,xys{i}(1,:),xys{i}(2,:));
        end
        Mmyokard=Mask{1}-Mask{2};
        if mi==2
            Minf=zeros(N,M);
        elseif isempty(find(Mmyokard.*Mask{3}))
            Minf=Mmyokard;
        elseif mi==3
            Minf=Mask{3};
        else
            for j=3:mi
                Minf=Minf+Mask{j};
            end
        end
        Minf=Minf.*Mmyokard;
    else


        % [trash test]=size(xy{2});
        % if (sum(abs(xy{2}(:,1)-xy{2}(:,2)))==0) && (test == 2)
        %     Mmyokard=roipoly(N,M,xys{1}(1,:),xys{1}(2,:));
        %     xys_k=xys{1};
        %
        % else
        Mask{1}=roipoly(N,M,xys{1}(1,:),xys{1}(2,:));
        Mask{2}=roipoly(N,M,xys{2}(1,:),xys{2}(2,:));

        Mmyokard=Mask{1}-Mask{2};
        xys_k=xys{2};
        %end


        r(1,:)=(xys_k(1,:) -xys{3}(1,1));
        r(2,:)=(xys_k(2,:) -xys{3}(2,1));
        [trash index1]=min(sum(abs(r)));

        r(1,:)=(xys_k(1,:) -xys{3}(1,end));
        r(2,:)=(xys_k(2,:) -xys{3}(2,end));
        [trash index2]=min(sum(abs(r)));

        kont_inf=xys{3};
        ant= abs(index2-index1)-1;
        if index2>index1
            index=index2
        else
            index=index1;
        end

        for i=1:ant
            kont_inf=[kont_inf xys_k(:,index1-i)];
        end

        Mask{3}=roipoly(N,M,kont_inf(1,:),kont_inf(2,:));
        Minf=Mask{3}.*Mmyokard;
    end
end
% min(min(Minf))
% max(max(Minf))
% min(min(Mmyokard))
% max(max(Mmyokard))

Minf=abs(Minf);
Mmyokard=abs(Mmyokard);

