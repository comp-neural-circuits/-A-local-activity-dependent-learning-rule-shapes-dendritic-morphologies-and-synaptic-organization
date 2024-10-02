function [StabSyn , ConSyn , DiscoSyn , W , PRE, POST, dMat, SMat, Conlin, POSTbap, Somadist] = prune_synapses_morph(Dt , ConSyn , Conlin , W , StabSyn , DiscoSyn , PRE, POST, POSTbap, Somadist, dMat, SMat , prms)
    % judging the synapses by weight
    newDiscoSyn = false(size(Dt));
    for lin = Conlin
        linsyn = (Conlin == lin);
        if W(linsyn)>=prms.stabthr
            StabSyn(lin)=1;
        end
        if W(linsyn)<prms.stabthr
            StabSyn(lin)=0;
        end
        if W(linsyn)<prms.conthr
            ConSyn(lin)=0; % THIS LINE MIGHT BE DANGEROUS WITH THE MORPHING MATRICES
            newDiscoSyn(lin)=1;
            W = W(~linsyn); PRE = PRE(~linsyn); POST = POST(~linsyn); POSTbap = POSTbap(~linsyn); Somadist = Somadist(~linsyn); dMat = dMat(~linsyn,:); dMat = dMat(:,~linsyn); SMat = SMat(~linsyn,:); SMat = SMat(:,~linsyn);
            Conlin = Conlin(~linsyn);
        end
    end
    DiscoSyn = (DiscoSyn | newDiscoSyn);
end