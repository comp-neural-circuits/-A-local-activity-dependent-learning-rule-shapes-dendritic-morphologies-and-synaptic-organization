function [cvtd_mean, cvtd] = clustervstreedist(alldMat,allConlin,mats,prms)

nDen = size(alldMat,1);

Synlin = find(mats.Syn == 1);
%mats.GroupID(ismember(Synlin,Conlin))

ub = 400;
cvtd = zeros(ub,nDen);

for iden = 1:nDen
    for dist = 1:min(prms.maxdist,ub)
        if ismember(dist,alldMat{iden})
        synrep = zeros(size(allConlin{iden}));
        for linid = 1:size(synrep,2)
            lin = allConlin{iden}(linid);
            synsconsidered = ismember(Synlin,allConlin{iden}(alldMat{iden}(allConlin{iden} == lin,:) == dist));
            total_synsconsidered = sum(synsconsidered,'all');
            if total_synsconsidered == 0
                synrep(linid) = 2; %this is to mark this spot as invalid
                continue
            end
%             if sum(ismember(mats.GroupID(synsconsidered),(mats.GroupID(Synlin == lin))),'all')/total_synsconsidered > 0
%                 0+0;
%                 
%             end
            
            
            synrep(linid) = sum(ismember(mats.GroupID(synsconsidered),(mats.GroupID(Synlin == lin))),'all')/total_synsconsidered;
        end
        cvtd(dist,iden) = mean(synrep(synrep<2));
        else
         cvtd(dist,iden) = NaN;
        end
    end
end

cvtd_mean = mean(cvtd,2,'omitnan');


end

