function sel = selectivityvstime_groups(SimVid,Syn,GroupID)
% This function computes input selectivity of dendrites (defined as the
% fraction of the activity group with the highest representation). 

T = size(SimVid,4);
nDen = size(SimVid,3);
nGID = max(GroupID(:));

sel = zeros(T,nDen,nGID);

for iden = 1:nDen
    for tt = 1:T
        ConSyn = SimVid(:,:,iden,tt)>1;
        % Check if there are synaptic connections
        if sum(ConSyn,'all') == 0 
            continue
        end
        
        ConSynID = ConSyn(Syn).*(GroupID);
        
        for gid = 1:nGID
            % Check if group-selectivity is higher than chance level
            % gid_sel = max(sum(ConSynID == gid,'all')/sum(ConSyn,'all'),1/nGID);
            gid_sel = sum(ConSynID == gid,'all')/sum(ConSyn,'all');
            sel(tt,iden,gid) = gid_sel;
        end
    end
    % Sort the groups contributions from high to low
    end_sel = sel(end,iden,:);
    [~, sel_idx] = sort(end_sel,'descend');
    sel(:,iden,:) = sel(:,iden,sel_idx);
end

sel = mean(sel,2);

end

