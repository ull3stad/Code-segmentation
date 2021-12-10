function [out]=RadialEval2_2014_04(X,rcen,ccen,SmoothParam,ubp,Xorig)
%---------------
%  Finding Epicardium mask (output BW is endocardium mask for all slices)
%  Is called by:  EndoEpi.m
%  
%  X: Output from probability map image 
%  rcen:  row center coordinates for the slices
%  ccen: column center coordinates for the slices.
%  SmoothParam:  postprocparameter
%----------------


%SmoothParam =4;
[nr,nc,nsl]=size(X);
fact=359;   %  for illustrasjonens skyld endret fra 400 til 359 
fi=0:2*pi/fact:2*pi;
lf=length(fi);
%Rfac=0.1;
Rfac=1;
rad=(0:Rfac:150);
Xtest=zeros(nr,nc,nsl);
%Xtest2=zeros(nr,nc,nsl);
BW=zeros(nr,nc,nsl);
RadInd=zeros(nsl,lf);
RadInd(:,1)=400;
RadInd2=RadInd;
RadIndbp=RadInd;
test=ones(length(fi),nsl);
test_ps=ones(length(fi),nsl);
%xind=zeros(nsl,length(fi));
%yind=zeros(nsl,length(fi));
ch=cell(nsl,1);
test2=zeros(length(fi),nsl);
minFac=30/Rfac;
RadVal=zeros(length(rad),length(fi));
RV_ubp=zeros(length(rad),length(fi));
RV_X=zeros(length(rad),length(fi));
RadIndEndo=zeros(nsl,lf);
testEndo=zeros(length(fi),nsl);
minEndoFac=20/Rfac;
MinMyoWidth=6;
MaxMyoWidth=12;

for i=1:nsl
    for j=1:length(fi)
        
        [xx,yy]=pol2cart(fi(j),rad);
        xr=round(xx);
        yr=round(yy);
        for l=1:length(xr)
            xrowind=max(1,min((yr(l)+rcen(i)),nr));
            xcolind=max(1,min((xr(l)+ccen(i)),nc));
            RadVal(l,j)=X(xrowind,xcolind,i);
            RV_ubp(l,j)=ubp(xrowind,xcolind,i);
            RV_X(l,j)=Xorig(xrowind,xcolind,i);
        end
        RV_X(:,j)=smooth(RV_X(:,j),10);
        %RadVal(:,j)=diag(X(yr+rcen(i),xr+ccen(i),i));
        for k=1:(length(RadVal(:,j))-1)
            if (RadVal(k+1,j)-RadVal(k,j)) < 0
                RadInd(i,j)=k+1;
                RadInd2(i,j)=k+1;
                RadIndbp(i,j)=k+1;
                test(j,i)=0;   %  setter test=0 når haar finnet kandidat punkt
                break;
            end
        end 
        if (i>1 && test(j,i)==1)
          if test(j,i-1)==0
              RadInd(i,j)=RadInd(i-1,j);
           %   test_ps(j,i)=0;
              test(j,i)=0;
          end
        end
        indbp=find(RV_ubp(:,j)>0.5,1,'last');
        if indbp>minEndoFac
            if test(j,i)==0
                if indbp>(RadInd(i,j)-MinMyoWidth)
                    RadIndEndo(i,j)=RadInd(i,j)-MinMyoWidth;
                elseif indbp<(RadInd(i,j)+MaxMyoWidth)
                    RadIndEndo(i,j)=RadInd(i,j)-MaxMyoWidth;
                else
                    RadIndEndo(i,j)=indbp;
                end
            else
               RadIndEndo(i,j)=indbp;
            end
        elseif test(j,i)==0
            RadIndEndo(i,j)=RadInd(i,j)-MinMyoWidth;
        else
            RadIndEndo(i,j)=minEndoFac;
            testEndo(j,i)=1;
        end
        if test(j,i)==1
            %indbp=find(RV_ubp(:,j)>0.5,1,'last');
            if indbp>minFac
                RadIndbp(i,j)=indbp;
%                 [px,ip]=findpeaks(RV_X(:,j));
%                 sval=RV_X(1,j);
%                 mval=min(RV_X(1:floor(90/Rfac),j));
%                 ii=find((px<(sval+mval)*0.5),1,'first');
%                 if isempty(ii)
%                     ii=find((ip>indbp),1,'first');
%                     if isempty(ii)
%                         RadInd2(i,j)=RadIndbp(i,j);
%                     else
%                         RadInd2(i,j)=ip(ii);
%                     end
%                 else
%                     RadInd2(i,j)=ip(ii);
%                 end
                RadInd(i,j)=RadIndbp(i,j);
                RadIndEndo(i,j)=RadInd(i,j)-MinMyoWidth;
                test(j,i)=0;
                test2(j,i)=1;
            end
        end
    end
    
    %RadIndOrig(i,:)=RadInd(i,:);
    
    [ind]=find(test(:,i)==0);
    medRI=median(RadInd(i,ind));
    for j=1:length(fi)
        if RadInd(i,j)==0
            RadInd(i,j)=medRI;
        end
    end
   RadInd(i,:)=smooth(RadInd(i,:),SmoothParam);
    
   [indEn]=find(testEndo(:,i)==0);
    medRIEn=median(RadIndEndo(i,ind));
    for j=1:length(fi)
        if testEndo(j,i)==1
            RadIndEndo(i,j)=medRIEn;
        end
    end
   RadIndEndo(i,:)=smooth(RadIndEndo(i,:),SmoothParam);
    
   
    
end
%RadIndSm=RadInd;
RInd=RadInd;

[stest]=sum(test');
ind_asm=find(stest==nsl);  %  ingen kandidatpunkt for noen slicer for de
ind_rest=find(stest<nsl);
for i=1:nsl
    for j=1:length(fi)
      if test(j,i)==1 && stest(j)<nsl
          ind0= test(j,:)==0;
          if i==1
            RInd(i,j)=mean(RadInd(ind0,j))-15;
          elseif i==2
              RInd(i,j)=mean(RadInd(ind0,j))-10;
          else
              RInd(i,j)=mean(RadInd(ind0,j));
          end
              
      end
    end

    
%     for j=1:length(fi)
%         [xind(i,j),yind(i,j)]=pol2cart(fi(j),Rfac.*RInd(i,j));   %  Used to be RadInd
%         rowind=max(1,min((round(yind(i,j)+rcen(i))),nr));
%         colind=max(1,min(round(xind(i,j)+ccen(i)),nc));
%         Xtest(rowind,colind,i)=1;
%     end
%     Props=regionprops(Xtest(:,:,i),'convexhull');
%     ch{i}=Props.ConvexHull;
%     BW(:,:,i)=roipoly(Xtest(:,:,i),ch{i}(:,1),ch{i}(:,2));
end
RInd2=RInd;
for i=1:nsl
    for k=1:length(ind_asm)  % vinkler uten kandidatpunkt for noen slicer
        ii=ind_asm(k);  
        [vm,im]=min(abs(ind_rest-ii));
        RInd2(i,ii)=RInd(i,ind_rest(vm));
    end
     for j=1:length(fi)
        [xind,yind]=pol2cart(fi(j),Rfac.*RInd2(i,j));   %  Used to be RadInd
        %rowind=max(1,min((round(yind+rcen(i))),nr));
        %colind=max(1,min(round(xind+ccen(i)),nc));
        %Xtest(rowind,colind,i)=1;
        repi(j)=max(1,min((round(yind+rcen(i))),nr));
        cepi(j)=max(1,min(round(xind+ccen(i)),nc));
        [xind,yind]=pol2cart(fi(j),Rfac.*RadIndEndo(i,j));   %  Used to be RadInd
        rendo(j)=max(1,min((round(yind+rcen(i))),nr));
        cendo(j)=max(1,min(round(xind+ccen(i)),nc));
        
    end
    %Props=regionprops(Xtest(:,:,i),'convexhull');
    %ch{i}=Props.ConvexHull;
    %BW(:,:,i)=roipoly(Xtest(:,:,i),ch{i}(:,1),ch{i}(:,2));
    
    cepi=smooth(cepi,10);
    repi=smooth(repi,10);
    CHindEp=convhull(cepi',repi');   
    
    cendo=smooth(cendo,10);
    rendo=smooth(rendo,10);
    CHindEn=convhull(cendo',rendo');    
    out.EndoM(:,:,i)=roipoly(ubp(:,:,i),cendo(CHindEn)',rendo(CHindEn)');
    out.EndoP(:,:,i)=bwperim(out.EndoM(:,:,i));
    out.EpiM(:,:,i)=roipoly(ubp(:,:,i),cepi(CHindEp)',repi(CHindEp)');
    out.EpiP(:,:,i)=bwperim(out.EpiM(:,:,i));
    
end



%[Modell]=SliceCompSegm(BW);
%save Epitest_ RadIndOrig RadIndSm RInd2 Xtest rcen ccen test fi