function imout=areaopen(im,N)
Thmax=max(im(:));
[f,c]=size(im);
pilaopenings=zeros(f,c,Thmax+1);
for k=0:Thmax
    pilaopenings(:,:,k+1)=double(bwareaopen(double(im)>=k,N)).*double(k);
end

imout=uint8(max(pilaopenings,[],3));
 