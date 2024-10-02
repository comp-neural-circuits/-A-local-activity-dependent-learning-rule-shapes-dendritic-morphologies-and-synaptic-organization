function [StabSyn , ConSyn , DiscoSyn] = prune_synapses(Dt , ConSyn , SynPositions , W , StabSyn , DiscoSyn , prms)
    % judging the synapses by weight
    newDiscoSyn = false(size(Dt));
    for lin = find(ConSyn == 1)'
        linsyn = (SynPositions == lin);
        if W(linsyn)>=prms.stabthr
            StabSyn(lin)=1;
        end
        if W(linsyn)<prms.stabthr
            StabSyn(lin)=0;
        end
        if W(linsyn)<prms.conthr
            ConSyn(lin)=0;
            newDiscoSyn(lin)=1;
        end
    end
    DiscoSyn = (DiscoSyn | newDiscoSyn);
end