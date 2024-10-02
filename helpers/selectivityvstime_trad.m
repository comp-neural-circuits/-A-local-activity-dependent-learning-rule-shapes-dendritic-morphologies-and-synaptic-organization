function sel = selectivityvstime_trad(SimVid,Syn,GroupID)
% this function cumputes the global selectivity of a neuron to the input
% groups in the traditional way (max - min)/(max+min)

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
        
        G_rep = zeros(nGID,1);
        
        for gid = 1:nGID
            G_rep(gid) = sum(ConSynID == gid,'all')/sum(ConSyn,'all');
        end
        
        sel(tt,iden) = (max(G_rep(:))-min(G_rep(:)))/(max(G_rep(:))+min(G_rep(:)));
        
    end
end

sel = mean(sel,2);

end

