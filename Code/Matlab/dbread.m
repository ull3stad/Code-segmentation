function [Pt,drecs,bytes]=dbread(filepath)
d=dir(filepath);

N=length(d);
j=0;

for i=1:N
    idx=findstr('_',d(i).name);
    if isempty(idx)
    %    d(i).name
    else
       j=j+1;
       Pt{j,1}=d(i).name(1:idx(1)-1);
       drecs{j,1}=d(i).name;
       bytes(j,1)=d(i).bytes;
    end
end
Pt=unique(Pt);
%drecs;