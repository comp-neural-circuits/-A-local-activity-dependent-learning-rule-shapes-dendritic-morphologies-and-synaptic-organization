function [fp_somata,fp_dendrites] = posvsfinal(SimVid,maxdist)
% computes the final length of each dendrite vs the density of other somata
% (in the beginning) and other dendrites (in the end) in its vicinity

nDen = size(SimVid,4);


shell = [0 1 0; 1 0 1; 0 1 0];
star = [0 1 0; 1 1 1; 0 1 0];


linsom = zeros(1,nDen);
for iden = 1:nDen
    linsom(iden) = find(conv2(squeeze(SimVid(:,:,1,iden)),shell,'same') == 4);
end

somdist = zeros(nDen);
for iden = 1:nDen
    somapos = conv2(squeeze(sum(SimVid(:,:,1,:),4)),shell,'same') == 4;
    somapos(linsom(iden)) = 0;

    flower = false(size(somapos),'logical');
    flower(linsom(iden)) = 1;
    linsom1 = linsom == linsom(iden);

    for dist = 1:maxdist
        flower = logical(conv2(flower,star,'same'));
        for lin2 = find(flower & somapos)'
            linsom2 = linsom==lin2;
            somdist(linsom1 , linsom2) = dist;
            somdist(linsom2 , linsom1) = dist;
        end
        somapos = somapos & ~flower;
    end
end

somdist_relevance = somdist;
somdist_relevance(somdist_relevance > 0) = 1./(somdist_relevance(somdist_relevance > 0).*somdist_relevance(somdist_relevance > 0));

fp_somata(1,:) = sum(somdist_relevance,2);
for iden = 1:nDen
fp_somata(2,iden) = sum(SimVid(:,:,end,iden)>0,'all');
end

% repeating the process but for the final stage dendrites
fp_dendrites = zeros(nDen,1);
% for iden = 1:nDen
%     somapos = conv2(squeeze(sum(SimVid(:,:,1,:),4)),shell,'same') == 4;
%     somapos(linsom(iden)) = 0;
% 
%     flower = false(size(somapos),'logical');
%     flower(linsom(iden)) = 1; 
%     
%     for iden2 = 1:nDen
%         picture = SimVid(:,:,end,iden2)>0;
%         for dist = 1:maxdist
%             flower = logical(conv2(flower,star,'same'));
%             
%             fp_dendrites(iden) = fp_dendrites(iden) + sum(picture.*flower,'all')*(1/dist);
%         
%             picture = picture & ~flower;
%         end
%     end
% end

end

