
function [cpD]=crop_heart_v2016(inD)
%----------------
%
%
%---------------- written by: Kjerst Engan
%
%last changes:  March 2016 , incase no deliniation, check
%                            for field Mmyo in inD. 
%
%----------------------------------------------------
plot =1;    %  if plot ==1, some results are plotted for illustration
%  if no wish to plot, set to 0.

%
%   
%---  We wish removing some areas around the edge of the image to
%   focus on the heart.  this is calledcropping   The parameter is set here.
crop_method=1;
cco=128;

%%--------------------------------

nosl=length(inD.X);
[r,c]=size(inD.X{1});
emptyslice=zeros(nosl,1);
if isfield(inD,'Mmyo')
    
    minx=zeros(nosl,1);
    maxx=zeros(nosl,1);
    miny=zeros(nosl,1);
    maxy=zeros(nosl,1);
    
    for i=1:nosl
        [x,y]=find(inD.Mmyo{i});
        if isempty(x)
            emptyslice(i)=1;
            minx(i)=r/2;
            miny(i)=r/2;
            maxx(i)=c/2;
            maxy(i)=c/2;
        else
            minx(i)=min(x);
            miny(i)=min(y);
            maxx(i)=max(x);
            maxy(i)=max(y);
        end
    end
    minpt=[min(minx) min(miny)];
    %maxpt=[max(maxx) max(maxy)];
    
    
    if crop_method==1
        if cco>min(minpt)
            disp('Crop Error!')
        elseif cco > (r-max(maxx))
            disp('Crop Error!')
        elseif cco > (c-max(maxy))
            disp('Crop Error!')
        end
    end
end

if crop_method==1
    nr=r-2*cco;
    nc=c-2*cco;
    cpD.X=zeros(nr,nc,nosl);
    if isfield(inD,'Mmyo')
        cpD.Mmyo=zeros(nr,nc,nosl);
        cpD.Minf=zeros(nr,nc,nosl);
    end
    
    for i=1:nosl
        cpD.X(:,:,i)=inD.X{i}(cco+1:r-cco,cco+1:c-cco);
        if isfield(inD,'Mmyo')
            cpD.Mmyo(:,:,i)=inD.Mmyo{i}(cco+1:r-cco,cco+1:c-cco);
            cpD.Minf(:,:,i)=inD.Minf{i}(cco+1:r-cco,cco+1:c-cco);
            cpD.cent{i}(1)=inD.cent{i}(1)-cco;
            cpD.cent{i}(2)=inD.cent{i}(2)-cco;
        end
    end
    
else
    
end