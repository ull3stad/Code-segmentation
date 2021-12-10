function plotHeart_2(X)
figure
if iscell(X)
    nsl=length(X); 
 for i=1:nsl 
   subplot(round(sqrt(nsl)),ceil(sqrt(nsl)),i)
   imshow(double(X{i}(:,:)),'Displayrange',[])
  end
else
    nsl=size(X,3);
for i=1:nsl 
   subplot(round(sqrt(nsl)),ceil(sqrt(nsl)),i)
   imshow(double(X(:,:,i)),'Displayrange',[])
end
end
