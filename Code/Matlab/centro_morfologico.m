function imout=centro_morfologico(im,se)
% ime=im;
 imout=im;
 D=imout;
 while (sum(D(:))~= 0)
 fi1=imopen(imclose(imopen(imout,se),se),se);
 fi2=imclose(imopen(imclose(imout,se),se),se);
 imaux=imout;
 imout=min(max(imout,fi1),fi2);
 D=abs(imout-imaux);
 end

