
function [probim] = ProbPriorHeart_BP( sizeX,rc,cc,varargin)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here



%rc    %  rowindex, center
%cc    % coulumn index, center

probim=zeros(sizeX(1),sizeX(2));

raddefault=0;
%sigmadefault=sizeX(1)/6;
sigmadefault=30;



if nargin > 3
  rad=varargin{1};
else
    rad=raddefault;
end
 
if nargin > 4   
    sigma=varargin{2};
else
    sigma=sigmadefault;
end
  
%---------------------

  for r=1:sizeX(1)
    for c=1:sizeX(2)
       
       d=sqrt((r-rc).^2+(c-cc).^2);
       probim(r,c)=normpdf(d,rad,sigma);
    end
  end
  probim=probim./max(max(probim));
