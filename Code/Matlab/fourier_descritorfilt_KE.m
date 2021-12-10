function Maskfilt=fourier_descritorfilt_KE(Mask,freq)
%Mask is binary [0,1]
% freq = 0.04;

Maskfilt=zeros(size(Mask));
if isempty(find(Mask,1))
else
    
    B=mvbound(Mask);
    B=B{1};
    l1=length(B);
    if l1<5
        
    else
        l=2^nextpow2(l1);
        z1=remuestv(B,l);
        [nr,nc]=size(Mask);
        
        Z1=fft(z1);
        p1=descfilt(Z1,freq);
        P1(:,2)=max(1,min(round(imag(p1)),nc));
        P1(:,1)=max(1,min(round(real(p1)),nr));
        
        for(i=1:length(P1))
            Maskfilt(P1(i,1),P1(i,2))=1;
        end
    end
end