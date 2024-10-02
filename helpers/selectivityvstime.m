function sel = selectivityvstime(SimVid,Syn,GroupID)
% this function cumputes the global selectivity of a neuron to the input
% groups as sum of the representation percentages over chance level 

T = size(SimVid,4);
nDen = size(SimVid,3);
nGID = max(GroupID(:));

sel = zeros(T,nDen);

for iden = 1:nDen
    for tt = 1:T
        ConSyn = SimVid(:,:,iden,tt)>1;
        if sum(ConSyn,'all') == 0 
            continue
        end
        
        ConSynID = ConSyn(Syn).*(GroupID);
        
        for gid = 1:nGID
            sel(tt,iden) = sel(tt,iden) + max(sum(ConSynID == gid,'all')/sum(ConSyn,'all')-(1/nGID),0);
        end
        
        sel(tt,iden) = sel(tt,iden)/(1-(1/nGID));

    end
end

sel = mean(sel,2);

end

