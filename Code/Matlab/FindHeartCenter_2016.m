
function [out]=FindHeartCenter_2016(in)

%----- scaling
out=in;

out.X=double(in.X);

if isfield(in,'GausSmooth')==0
    in.GausSmooth=1;
end

if in.GausSmooth==1
   if isfield(in,'h')==0
     in.h=7; end
   if isfield(in,'sigma')==0
     in.sigma=1.5; end
   h=fspecial('gaussian',in.h,in.sigma);
   out.X=imfilter(out.X,h);
end
MaxX=max(max(max(out.X)));
out.X=uint8((out.X./double(MaxX)).*255);

[rn,cn,nosl]=size(out.X);

%----- Preprocessing and Circulart Hough Transform 

se=strel('square',10);
seg=strel('ball',3,3);
N=200;

max_met_gac=zeros(nosl,1);
Xac=uint8(zeros(rn,cn,nosl));
Icirc_met=zeros(rn,cn);
Gac_tot=zeros(rn,cn);
Gac=zeros(rn,cn,nosl);

for i=1:nosl
    
    Xcm=centro_morfologico(out.X(:,:,i),se);   % morphological noise removal
    Xao=areaopen(Xcm,N);
    Xac(:,:,i)=Xao;
    
    
    Gac(:,:,i)=imdilate(Xac(:,:,i),seg)-imerode(Xac(:,:,i),seg);
    Gac(:,:,i)=imclearborder(Gac(:,:,i));   %  remove all edges connected to the borders..
    Gac_tot=Gac_tot+double(Gac(:,:,i));
    
    % --- Circular Hough TRansform 
    edgethreshold_value = 0.5;
    sensitivity_value = 0.99;
    [cen_gac1, radi_gac1, met_gac1] = imfindcircles(Gac(:,:,i),[20 35],'ObjectPolarity','dark', 'Sensitivity', sensitivity_value,'EdgeThreshold',edgethreshold_value);
    [cen_gac2, radi_gac2, met_gac2] = imfindcircles(Gac(:,:,i),[20 35],'ObjectPolarity','bright', 'Sensitivity', sensitivity_value,'EdgeThreshold',edgethreshold_value);
    [cen_gac3, radi_gac3, met_gac3] = imfindcircles(Gac(:,:,i),[35 50],'ObjectPolarity','dark', 'Sensitivity', sensitivity_value,'EdgeThreshold',edgethreshold_value);
    [cen_gac4, radi_gac4, met_gac4] = imfindcircles(Gac(:,:,i),[35 50],'ObjectPolarity','bright', 'Sensitivity', sensitivity_value,'EdgeThreshold',edgethreshold_value);
    cen_gac{i}=[cen_gac1; cen_gac2; cen_gac3 ; cen_gac4];
    met_gac{i}=[met_gac1; met_gac2; met_gac3; met_gac4];
    radi_gac{i}=[radi_gac1; radi_gac2; radi_gac3; radi_gac4];
    
    %--  OBS coordinates in cen_gac are in the form :  column, row
    
    %-- Adding the metric of the circular hough transform at their actual
    %position making an image of added metrics as we propagate through the
    %slices. ----
    
    for j=1:length(met_gac{i})
        Icirc_met(floor(cen_gac{i}(j,2)),floor(cen_gac{i}(j,1)))=Icirc_met(floor(cen_gac{i}(j,2)),floor(cen_gac{i}(j,1)))+met_gac{i}(j);
    end;
    
    
    
    max_met_gac(i)=max(met_gac{i});
end

se_cm=strel('disk',5);
se_2=strel('disk',1);
Icm_close=imclose(Icirc_met,se_cm);
Icm_open=imopen(Icm_close,se_2);
Imfinal=imclearborder(Icm_open);
out.Imfin_sc=Imfinal./max(max(Imfinal));    %  Scaled probability area for heart center
%[mr, mc]=find(Imfinal_sc==1);        %  The most probable points



%%-----------



[nr,nc,nsl]=size(out.X);
out.ProbHC=zeros(nr,nc,nsl);

for i=1:nsl
   out.ProbHC(:,:,i)=out.Imfin_sc.*double(out.X(:,:,i));
   [rr{i},cc{i}]=find(out.ProbHC(:,:,i)==max(max(out.ProbHC(:,:,i))));
   out.rcenter(i)=rr{i}(1);
   out.ccenter(i)=cc{i}(1); 
end


%% ------  Plotting result if plotRes = 1
if isfield(in,'plot')==0
    in.plot=0;
end
if in.plot==1;
 for i=1:nsl
 figure(1);
 subplot(round(sqrt(nsl)),ceil(sqrt(nsl)),i)
 imshow(out.X(:,:,i),'Displayrange',[])
 hold on
 plot(out.ccenter(i),out.rcenter(i),'r*')
 
 end
end
