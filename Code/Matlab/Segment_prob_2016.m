    function [out]=Segment_prob_2016(in)
%[Mmyo,DS, JC,out] = Segment_prob3_v2014_03(Pt,sigma_prior,fx,freq,TrueHeart,WS,HC,Plot,rcen,ccen)
%
% Segment_prob_2016(cpD,hcD);
%
% ... Segment_prob3 : bruker ikke info fra f�rste og siste slice i det hele
% tatt annet enn til � finne heart center-
%
%  Calls:    Find_heartcenter(Pt);  centro_morfologico(); ProbPriorHeart();
%
%--------  Parameters -----
%  Parameter for fourier_descriptor smoothing of countures.
%
%
%
%  written by K.Engan
%
%  .. Last changes:  March 2016
%
SumTest=0;
seprep=strel('square',3);  %  preprosesserings strucuturing el.
seFD=strel('square',4);

sigma2=0.5;    %  parameter for 3D gauss filt.
factor = 6;  %  parameter for 3D gauss filt.

pind=0.15;   %  parameter for midling over slicer

sigma_prior=15;
%fpi=2;       % factor for prior prob im
if isfield(in,'fx')==0
  fx=2;        % factor for prior X / no it,.
else
    fx=in.fx;
end
out.fx=fx;
if isfield(in,'freq')==0
  freq=0.01;        % factor for prior X / no it,.
else
    freq=in.freq;
end
out.freq=freq;
%freq=0.01;
%seotsu=strel('square',3);
%secm=strel('disk',2);

%----------

%if nargin < 10
    
%    if strcmp(HC,'GLC')
%        [rcen,ccen,X,Mmyo]=Find_heartcenterV(Pt);
%    else
%        [rcen,ccen,X,Imfin_sc,T,Gac,Mmyo,PixSize]=Find_heartcenter_v2014_01(Pt);
%    end
%else
%    [X,Mmyo,PixSize]=pre_crop_v2014_01(Pt);
%end

X=in.X;
[nr,nc,nsl]=size(X);
if isfield(in,'Mmyo')
  Mmyo=in.Mmyo;
end

if isfield(in,'PixSize')==0
   PixSize=ones(2,nsl).*0.7422;
else
   PixSize=in.PixSize;
end


X=X(:,:,2:(nsl-1));

if isfield(in,'Mmyo')
  Mmyo=Mmyo(:,:,2:(nsl-1));
end
  rcen=in.rcenter(2:(nsl-1));
  ccen=in.ccenter(2:(nsl-1));
PixSize=PixSize(:,2:(nsl-1));
[nr,nc,nsl]=size(X);


% ---------Finn Myo masker for sammenligning ..........
%se5=strel('disk',5);
if isfield(in,'Mmyo')
MmyoEpi=zeros(nr,nc,nsl);
MmyoEndo=zeros(nr,nc,nsl);
MmyoEpiP=zeros(nr,nc,nsl);
MmyoEndoP=zeros(nr,nc,nsl);
for i=1:nsl
    MmyoEpi(:,:,i)=imfill(Mmyo(:,:,i),'holes');
    if length(find(Mmyo(:,:,i)-MmyoEpi(:,:,i)))<100;
        TT=regionprops(Mmyo(:,:,i),'ConvexImage','BoundingBox');
        MmyoEpi(ceil(TT.BoundingBox(2)):ceil(TT.BoundingBox(2))+TT.BoundingBox(4)-1, ...
            ceil(TT.BoundingBox(1)):ceil(TT.BoundingBox(1))+TT.BoundingBox(3)-1,i)=TT.ConvexImage;
    end
    Labt=bwlabel(MmyoEpi(:,:,i)-Mmyo(:,:,i));
    if max(max(Labt))>1
        MmyoEndo(:,:,i)=Labt==Labt(rcen(i),ccen(i));
    else
        MmyoEndo(:,:,i)=Labt;
    end
    MmyoEpiP(:,:,i)=bwperim(MmyoEpi(:,:,i),8);
    MmyoEndoP(:,:,i)=bwperim(MmyoEndo(:,:,i),8);
end

%--- Test med SANN HJERTESENTER ---
%
if isfield(in,'TrueHeart')==0
    in.TrueHeart=0;
end
if in.TrueHeart==1
    for i=1:nsl
        Tepi=regionprops(MmyoEpi(:,:,i),'centroid','EquivDiameter');
        cepi(i,:)=Tepi.Centroid;
    end
    rcen=round(cepi(:,2)');
    ccen=round(cepi(:,1)');
end
end
% ----------------------------------------

Xcm=zeros(nr,nc,nsl);
for i=1:nsl
    Xcm(:,:,i)=centro_morfologico(X(:,:,i),seprep);
end
maxXcm=max(max(max(Xcm)));
Xcmsc=double(Xcm)/double(maxXcm);
Xpre_inv=ones(nr,nc,nsl)-Xcmsc;    %  Invers av preprosessert inn-bilde


%%
%   Use GraphCut 3D to find bloodpool based on previously found heart center.  
%   Find improved heartcenter based on this.    
%

sizeX=size(X);
Xtemp=zeros(sizeX);
probim_bp=zeros(sizeX);
sigmaBP=ones(nsl,1).*50;
sigmaBP(1)=30;
sigmaBP(2)=40;
sigmaBP=sigmaBP.*(0.7422 ./ PixSize(1,:)');
for i=1:nsl
    [probim_bp(:,:,i)] = ProbPriorHeart_BP(sizeX,rcen(i),ccen(i),0,sigmaBP(i));
    Xtemp(:,:,i)=double(Xcm(:,:,i)).*probim_bp(:,:,i);
end
[ubp] = CMF3D_Cut_KE(Xtemp);  %  3D graph cut for bloodpool area ( maybe including scar) 

Totbp=sum(ubp,3);
TT=Totbp>2;
TTBW=bwlabel(TT);
for j=1:max(max(TTBW))
    Temp=(TTBW==j);
    Arealbp(j)=sum(sum(Temp));
end
[Sizbp,Indbp]=max(Arealbp);
TT2=(TTBW==Indbp);
se=strel('disk',3);
BPMask=imdilate(TT2,se);
for i=1:nsl
   ubp(:,:,i)=ubp(:,:,i).*BPMask;
   SBP(i)=sum(sum(ubp(:,:,i)>0.3));
   if SBP(i)<1200
      bpTest(i)=0;
   else
       bpTest(i)=1;
   end
end

if sum(bpTest)>2
  for i=1:nsl
    [r,c]=find(ubp(:,:,i)>0.3);
    rcen2(i)=round(mean(r));
    ccen2(i)=round(mean(c));
  end
  rcm=floor(mean(rcen2(bpTest>0)));
  ccm=floor(mean(ccen2(bpTest>0)));
  ind=find(bpTest==0);
  rcen2(ind)=rcm;
  ccen2(ind)=ccm;
  rcen=rcen2;
  ccen=ccen2;
end

%%


%------------------
%  Prior Probability
%------------------
%sigma=nr/8;
%rad=ones(nsl,1).*40;
%rad(1:5)=[15 20 25 30 35]';
%rad(nsl)=35;
sigma=sigma_prior;  %  typisk 15
rad=ones(nsl,1).*37;
rad(1:4)=[24 29 32 35]';

%  0.7422 er typisk pixel st�rrelse.
%  korrigerer her tilfelle denne ikke stemmer.
rad=rad.*(0.7422 ./ PixSize(1,:)');

probim=zeros(sizeX);
for i=1:nsl
    [probim(:,:,i)]=ProbPriorHeart(sizeX,rcen(i),ccen(i),rad(i),sigma);
end

%-----------------
% Iterativ med gaussfiltrering i hver iterasjon
%-----------------

Xprob3D=probim;
for j=1:fx
    Xprob3D=Xprob3D.*Xpre_inv;
    Xprob3D=imgaussian(Xprob3D,sigma2,factor*sigma2);
    Xprob3D=Xprob3D./max(max(max(Xprob3D)));
end

%-----------------
% Iterativt med � ta hensyn til slicen foran og bak (men ikke filtrering i
% slicen
%-----------------

Xprob=probim;
Xprob2=Xprob;
for j=1:fx
    Xprob=Xprob.*Xpre_inv;
    Xprob2(:,:,1)=(1-pind)*Xprob(:,:,1)+pind*Xprob(:,:,2);
    for i=2:nsl-1
        Xprob2(:,:,i)=(1-2*pind)*Xprob(:,:,i)+pind*Xprob(:,:,i-1)+pind*Xprob(:,:,i+1);
    end
    Xprob2(:,:,nsl)=(1-pind)*Xprob(:,:,nsl)+pind*Xprob(:,:,nsl-1);
    Xprob2=Xprob2./max(max(max(Xprob2)));
    Xprob=Xprob2;
end

%-------------------
% Ikke ta hensyn til slicen foran og bak, bare forsterk modellen
% Med og uten 3D filtrering til slutt.
%-------------------

Xs=probim.*Xpre_inv.^fx;
Xs=Xs./max(max(max(Xs)));
%XsF=imgaussian(Xs,sigma2,factor*sigma2);

% Xscar=probim.^fpi.*Xcmsc.^fx;
% Xscar=Xscar./max(max(max(Xscar)));
% XscarF=imgaussian(Xscar,sigma2,factor*sigma2);


%---------------
% Legg sammen (Xs og Xprob), med og uten 3D filtrering
%---------------

Xpp=Xprob./(max(max(max(Xprob))));
Xss=Xs./(max(max(max(Xs))));
Xtot=Xpp+Xss;
Xtot=Xtot./max(max(max(Xtot)));
%--- 3D gauss filt

sigma3=1;
XtotF=imgaussian(Xtot,sigma3,factor*sigma3);
XtotF=XtotF./max(max(max(XtotF)));
%-----------


%--------- Finding Endo and epi from radial evaluation of prob.im.
%---

% [EpiFDPeri,EpiFDMask,EpiMask,EndoPeri,EndoMask]=EndoEpi_v2014_01(XtotF,X,rcen,ccen,PixSize,probim);

%%% pr�ve noe mer inne i denne,,,  (16juli2014)
%[out,test]=EndoEpi_v2014_03(XtotF,X,ubp,rcen,ccen,freq,PixSize);
%%% 
 [out]=EndoEpi_v2014_04(XtotF,X,ubp,rcen,ccen,freq,PixSize);


%
% if WS~=0
%   if WS==1
%     [EndoMaskWatersh]=Segment_watersh_comp(Pt,rcen,ccen,X,EpiFDMask);
%   elseif WS==2
%     [EndoMaskWatersh]=Segment_watersh_comp(Pt,rcen,ccen,XtotF.*255,EpiFDMask);
%   end
%      for j=1:nsl
%        EndoWSPeri(:,:,j)=bwperim(EndoMaskWatersh(:,:,j));
%        EndoWSFDPeri(:,:,j)=logical(fourier_descritorfilt_KE(double(EndoWSPeri(:,:,j)),freq));
%        temp=imdilate(EndoWSFDPeri(:,:,j),seFD);
%        EndoWSFDtemp=imfill(temp,'holes');
%        EndoWSFDMask(:,:,j)=imerode(EndoWSFDtemp,seFD);
%
%      end
% end
%

if isfield(in,'Mmyo')
  [out.DS,out.JC]=DS_JC_EndoEpi(out,Mmyo,MmyoEpi,MmyoEndo);
end
%[DS2,JC2]=DS_JC_EndoEpi(out2,Mmyo,MmyoEpi,MmyoEndo);
%[DSx,JCx]=DS_JC_EndoEpi(outx,Mmyo,MmyoEpi,MmyoEndo);

%if WS ~= 0
%    DS.EndototWatershed=EvaluaImagenDice(MmyoEndo(:,:,1:nsl),EndoMaskWatersh(:,:,1:nsl));
%    JC.EndototWatershed=EvaluaImagenJaccard(MmyoEndo(:,:,1:nsl),EndoMaskWatersh(:,:,1:nsl));
%    DS.EndoWSFDtot=EvaluaImagenDice(MmyoEndo(:,:,1:nsl),EndoWSFDMask(:,:,1:nsl));
%    JC.EndoWSFDtot=EvaluaImagenJaccard(MmyoEndo(:,:,1:nsl),EndoWSFDMask(:,:,1:nsl));
%    for i=1:nsl
        
%        DS.EndoWatershed(i) = EvaluaImagenDice(MmyoEndo(:,:,i),EndoMaskWatersh(:,:,i));
%        JC.EndoWatershed(i) = EvaluaImagenJaccard(MmyoEndo(:,:,i),EndoMaskWatersh(:,:,i));
%        DS.EndoWSFD(i) = EvaluaImagenDice(MmyoEndo(:,:,i),EndoWSFDMask(:,:,i));
%        JC.EndoWSFD(i) = EvaluaImagenJaccard(MmyoEndo(:,:,i),EndoWSFDMask(:,:,i));   
%   end
    
%end
end

