function [PRE , POST , W] = get_weight_dynamics(tt , W , PRE , POST , SynPositions , SMat , ConSyn , mats , prms)
    Waug = repmat(W,[size(SynPositions,2) 1]).*SMat;
%     Waug = repmat(W,[size(SynPositions,2) 1]);

    Sin = mats.Vid(:,:,tt).*ConSyn; Sin = Sin(mats.Syn);

    W = W + (1./prms.tauW)*( POST .*  (PRE + prms.offset) );
    W = min(max(W,prms.lowerbound),prms.upperbound);

    PRE = PRE*exp(-1./prms.tauPRE) + prms.phi*Sin'*(1 - exp(-1./prms.tauPRE));
    POST = POST*exp(-1./prms.tauPOST) + (Waug*Sin)'*(1 - exp(-1./prms.tauPOST));
end