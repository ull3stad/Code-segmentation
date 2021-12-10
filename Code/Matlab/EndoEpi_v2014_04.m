function [out]=EndoEpi_v2014_04(X,Xorig,ubp,rcen,ccen,freq,PixSize)
%----------
%   EndoEpi:  finds Endocardium and epicardium masks and perimeters.
%   calls:  RadialEval2 (finds epicardium), RadialEndocard2 (finds
%   endocard)
%   Is called by:  SegmentProb2.m
%   
%   Input: X  From Iterative prob.map. scheme
%   rcen:  row center coordinates for the slices
%   ccen: column center coordinates for the slices.
%
%  [EpiPeri,EpiMask,EndoPeri,EndoMask]=EndoEpi_v2014_02(XtotF,X,rcen,ccen);

%out =  EndoM       %  struct ut som inneholder disse bildene:
%       EpiM
%       EndoP
%       EpiP
%       EndoMFD
%       EpiMFD
%       EndoPFD
%       EpiPFD
%
%   
%-------
Smooth=2;
seFD=strel('square',4);

[nr,nc,nsl]=size(X);
sizeX=size(X);
Xu8=X./max(max(max(X)));
Xu8=uint8(Xu8.*255);
Xch=zeros(nr,nc,nsl);
XchO=zeros(nr,nc,nsl);
XO=zeros(nr,nc,nsl);
XOCl=zeros(nr,nc,nsl);

out=struct('EndoM',zeros(sizeX),'EpiM',zeros(sizeX),'EndoP',zeros(sizeX),...
    'EpiP',zeros(sizeX),'EndoMFD',zeros(sizeX),'EpiMFD',zeros(sizeX),...
    'EndoPFD',zeros(sizeX),'EpiPFD',zeros(sizeX));

for i=1:nsl
   Xch(:,:,i)=close_holes(Xu8(:,:,i));
  % Xh(:,:,i)=Xch(:,:,i)-Xu8(:,:,i); 
   Ots_th2=multithresh(Xch(:,:,i),4);
   XchO(:,:,i)=imquantize(Xch(:,:,i),Ots_th2);
  
   Ots_th=multithresh(Xu8(:,:,i),4);
   XO(:,:,i)=imquantize(Xu8(:,:,i),Ots_th);
end


[out]=RadialEval2_2014_04(XchO,rcen,ccen,Smooth,ubp,Xorig);


%[out.EpiM,test,test2]=RadialEval2_2014_03(XchO,rcen,ccen,Smooth,ubp,Xorig);
%   her er test = ind_asm (fra Radial_Eval) 
%[ubp2D,ubp]=bp_GraphCut(Xorig,rcen,ccen,PixSize);



%[out.EpiM,test]=RadialEval2_2014_01(XchO,rcen,ccen,Smooth);
%  her er test = test... (fra Radial_Eval) 


%[EpiMask,cnew]=Epi_pol(XchO,rcen,ccen);

%[EpiMask_u,EpiPFD,EpiMask]=EpiMask_v2014_01(Xoriplg,XchO,rcen,ccen);

%[X00,pos]=RadValXch_v2014_01(XchO,rcen,ccen);
%weight=3;
%[EpiMask,EpiPFD,EpiFDMask]=EpiMask_GraphCut_v01(Xorig,XchO+X00.*weight,rcen,ccen);


%[out]=EpiMask_GraphCut_v01(Xorig,Xch,XchO,rcen,ccen,PixSize,probim);


%-------- Remove outliers
[rr,cc]=find(sum(out.EpiM,3)==1);
for k=1:length(rr)
    out.EpiM(rr(k),cc(k),:)=0;
end

[rr,cc]=find(sum(out.EpiM(:,:,2:(nsl-1)),3)==(nsl-2));
for k=1:length(rr)
    out.EpiM(rr(k),cc(k),2:(nsl-2))=1;
end

%-------------------

% 
% se6=strel('disk',1);
 for i=1:nsl
   out.EpiP(:,:,i)=bwperim(out.EpiM(:,:,i),8);
%   XOCl(:,:,i)=imclose(XO(:,:,i),se6);
 end
% 
% %XendoOr=Xorig.*uint8(EpiMask);
% Xendo=XOCl.*out.EpiM;
% %[EndoPeri,EndoMask]=RadialEndocard(Xendo,MaxN,rcen,ccen,EpiMask);
% [out.EndoM]=RadialEndocard2_2014_v01(Xendo,ubp,rcen,ccen,Smooth);
% 
%-------- Remove outliers Endo
[rr,cc]=find(sum(out.EndoM,3)==1);
for k=1:length(rr)
    out.EndoM(rr(k),cc(k),:)=0;
end
[rr,cc]=find(sum(out.EndoM(:,:,2:(nsl-1)),3)==(nsl-2));
for k=1:length(rr)
    out.EndoM(rr(k),cc(k),2:(nsl-2))=1;
end

%------------------
for i=1:nsl
  out.EndoP(:,:,i)=bwperim(out.EndoM(:,:,i),8);
end

for i=1:nsl
  out.EpiPFD(:,:,i)=logical(fourier_descritorfilt_KE(double(out.EpiP(:,:,i)),freq));
  out.EndoPFD(:,:,i)=logical(fourier_descritorfilt_KE(double(out.EndoP(:,:,i)),freq));
  EpiPFDTemp=imdilate(out.EpiPFD(:,:,i),seFD);
  EpiPFDTemp=imfill(EpiPFDTemp,'holes');
  out.EpiMFD(:,:,i)=imerode(EpiPFDTemp,seFD);
  EndoPFDTemp=imdilate(out.EndoPFD(:,:,i),seFD);
  EndoPFDTemp=imfill(EndoPFDTemp,'holes');
  out.EndoMFD(:,:,i)=imerode(EndoPFDTemp,seFD);
end

out.Xpm=X;
out.Xorig=Xorig;
out.ubp=ubp;




