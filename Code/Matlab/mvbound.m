function [boundary, nparts] = mvbound(inputimage, neighborhood)
% MVBOUND Odredivanje kontura dijelova binarne slike.
% P = MVBOUND(BW, N) vra?ca niz P granica svakog objekta
% na slici. N odreduje povezanost to?caka, a mo?ze biti
% 4 ili 8. Ako je izostavljen, podrazumijeva se 8.
% [P, N] = MVBOUND(BW, N) vra?ca i broj objekata N za koje
% je odredena granica.
ni = nargin;
no = nargout;
error(nargchk(1,2,ni));
% Odredi susjedstvo (podrazumijeva se 4-susjedstvo)
if 2 == ni
    if ((4 ~= neighborhood) & (8 ~= neighborhood))
        error('Dozvoljeno je 4 ili 8 susjedstvo.');
    end
else
    neighborhood = 8;
end
% Postavi smjerove i pomak
if 8 == neighborhood
    direction = [ [ 0 1]; [-1 1]; [-1 0]; [-1 -1];
    [ 0 -1]; [ 1 -1]; [ 1 0]; [ 1 1] ];
    skip = 2;
else
    direction = [ [0 1]; [-1 0]; [0 -1]; [1 0]];
    skip = 1;
end
% Ozna?cavanje nepovezanih dijelova
[labeled, nparts] = bwlabel(inputimage, neighborhood);
[x y] = size(labeled);
for i = 1 : nparts
    % Stvaramo matricu ve?cu za 2 reda i stupca
    image = zeros(x+2, y+2);
    % Uzimamo samo i-ti povezani dio
    image(2:x+1, 2:y+1) = (i == labeled);
    % Tra?zimo prvi element
    index = find(image);
    if ~isempty(index)
        % Element postoji
        n = 1;
        d = neighborhood - 1;
        [a b] = ind2sub(size(image),index(1));
        P(n) = a + b*sqrt(-1);
        % Provjeravamo da li se radi o izoliranoj to?cci
        notisolated = (1 ~= 1);
        for j = 1 : neighborhood
            next = [a b] + direction(j,:);
            if (1 == image(next(1), next(2)))
                notisolated = (1 == 1);
                break;
            end
        end
        % Pra?cenje granice
        while notisolated
            % Provjeravamo susjedstvo zadnje to?cke
            % Zakora?cimo vani
            d = mod(d + neighborhood - skip, neighborhood);
            for j = 1 : neighborhood
                % Odredimo koordinate susjeda u odabranom smjeru
                next = [a b] + direction(d + 1,:);
                % Provjeravamo da li je to?cka (p,q) ozna?cena
                if (1 == image(next(1),next(2)))
                    % Nova to?cka je pronadena
                    a = next(1);
                    b = next(2);
                    n = n + 1;
                    P(n) = a + b*sqrt(-1);
                    break;
                end
                % Ra?cunamo sljede?ci smjer
                d = mod(d + 1, neighborhood);
            end
            % Provjeravamo da li smo zatvorili konturu
            if (n > 2) & (P(n) == P(2)) & (P(n-1) == P(1))
                n = n - 2;
                break;
            end     
        end
        boundary{i} = P(1:n) - 1 - sqrt(-1);
    end
end