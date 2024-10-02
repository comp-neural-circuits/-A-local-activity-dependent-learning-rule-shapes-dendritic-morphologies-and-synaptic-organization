function [newPRE , newPOST , newPOSTbap , W , bAP] = get_weight_dynamics_morph(Im , W , PRE , POST , POSTbap , SMat , ConSyn , Conlin , Somadist , prms)
    %% implements the updating scheme for the differential equations governing the synaptic weight
    Waug = repmat(W,[size(Conlin,2) 1]).*SMat; % get augmented weight matrix
    
    Sin = Im.*ConSyn; Sin = Sin(Conlin'); % get input to all currently connected synapses 
    
    newPOST = zeros(size(W)); newPOST(1,1:size(POST,2)) = POST;
    newPOSTbap = zeros(size(W)); newPOSTbap(1,1:size(POSTbap,2)) = POSTbap;
    newPRE = zeros(size(W)); newPRE(1,1:size(PRE,2)) = PRE;
    
    W = W + (1./prms.tauW)*( newPOST .*  (newPRE + prms.offset) ); % update weight according to Hebbian equation
    W = min(max(W,prms.lowerbound),prms.upperbound); % apply hard bounds

    newPRE = newPRE*exp(-1./prms.tauPRE) + prms.phi*Sin'*(1 - exp(-1./prms.tauPRE)); % update presynaptic accumulator
    newPOST = newPOST*exp(-1./prms.tauPOST) + (Waug*Sin)'*(1 - exp(-1./prms.tauPOST)); % update postsynaptic accumulator
    
    W_bAp_contr = W;
    W_bAp_contr(W_bAp_contr < prms.bAP_contr_thr) = 0;
    Soma_Smat = normpdf(Somadist, 0 , prms.sigma_s)*(sqrt(2*pi)*prms.sigma_s);
    SOMAbap = newPOST*((Soma_Smat.*W_bAp_contr)');
    bAP = (SOMAbap > prms.bAP_thr) & (rand < prms.bAPprob);
    if size(bAP) == 0
        bAP = false;
    end
  
    newPOSTbap = newPOSTbap*exp(-1./prms.tauPOST);
    thing = (Waug*Sin)'*(1 - exp(-1./prms.tauPOST));
    newPOSTbap = newPOSTbap + thing;
    newPOSTbap = newPOSTbap + bAP*prms.bAPstrength*normpdf(Somadist , 0 , prms.sigma_s)*(sqrt(2*pi)*prms.sigma_s)*(1 - exp(-1./prms.tauPOST));

end