function [Res]=Resize(cpD)

L = size(cpD.X)


for i = 1:L(3)
    Res.X{i} = imresize(cpD.X(:,:,i), [512 512]);
    Res.Minf{i} = imresize(cpD.Minf(:,:,i), [512 512]);
    Res.Mmyo{i} = imresize(cpD.Mmyo(:,:,i),[512 512]);
    
    Res.Minf_inv{i} = imcomplement(Res.Minf{i});
    Res.Mmyo{i} = imcomplement(Res.Minf{i}); 
end