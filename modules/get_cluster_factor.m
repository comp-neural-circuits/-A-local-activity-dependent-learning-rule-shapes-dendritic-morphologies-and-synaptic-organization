function [Cluster] = get_cluster_factor(tt , iden , ConSyn , Cluster , SMat , mats)
    % calculating the clusterfactor for each synapse
    for igr = 1:size(mats.Groups,3)
        Grp = mats.Groups(:,:,igr) & ConSyn;
        Sin2 = Grp(mats.Syn);
        Cluster(:,tt,iden) = Cluster(:,tt,iden) + Sin2.*((SMat)*Sin2);
    end
    Totalcl = (SMat*(ConSyn(mats.Syn)));
    Totalcl(Totalcl==0) = 1;
    Cluster(:,tt,iden) = Cluster(:,tt,iden) ./ (Totalcl);
end