function [SimVid , SynVid , GroupsVid, alldMat , allSomaFire ,allConlin , allWtrace] = DenGrowth_2D_moving_syns_fixed(prms , mats)
    % this is exactly the same as DenGrowth_2D but it uses the new inputs "mats.move" and
    % "prms.lifetime" to implement movement of synapses in a certain weighted radius after their
    % lifetime expires or kills them with a chance of "prms.syndeath"
    
    % the lifetime of a synapse only goes down while it is not connected to
    % a dendrite but it does not get refreshed by getting connected.
    
    % possible issues:
    % it might turn out that the stability of the dendrites in the end
    % relied on the diffusion of signals from their rejected synapses which
    % will now move away eventually. this is why syndeath might be
    % necessary to get stability here. 
    % if the movement is to small dendrites might connect to the same
    % synapse again and again.

    % LAST STEP: implement synapse death, this is somewhat tricky because
    % we cannot just forget about the synapse since that would mess up
    % SynPos


    % The purpose of this function is to take an image of a Neuron and a video of the fireing patterns potential
    % synapses in the area to create a mats.Video of the mats.Dendrite growing and
    % stabilizing according to the synaptic activity

    % all input images/videos are 2D binary images/videos with the same framesize
    % they all meant to portray different aspects of exactly the same area

    % some inputs can be made functions of eg time or total length

    % Input:    - "mats.Dend" is a stack of 2D binary images of the full neurons
    %           - "mats.Soma" is a stack of 2D binary images of only the somas in
    %           the same order as in mats.Dend
    %           - "mats.Syn" is an image of all of the potential mats.Synapses in the
    %           - "mats.Area" is an image of the area that the neurons are allowed
    %           to expand into
    %           - "mats.Syn" is an image of all of the potential synapses
    %           - "mats.Groups" is a stack of images where each image portrays one
    %           mats.Groups of mats.Synapses
    %           - "mats.Vid" is a video that shows how each potential synapse would
    %           fire if it had become an actual synapse
    %           - "mats.Noise" is a video that contains noise to disturb the growth
    %           stimulating transmitters of the synapses. It does not need to
    %           be of the same length as mats.Vid
    %           - "mats.DiffusionMat" is a matrix that determines how the growth
    %           stimulating transmitters dissolve by convolution
    %           - "prms.agentfreq" is the rate (given as a positive integer) at which the somas emit
    %           growth/retraction stimulating pulses
    %           - "prms.agentspeed" is the rate (given as a positive integer) at
    %           which these pulses propagate
    %           - "prms.desens" is the factor by which the sensitivity of the
    %           dendrite is modified if a branch has been retracted
    %           - "prms.signalint" is the intensity of the growth stimulating
    %           signals
    %           - "prms.initialweight" is the initial synaptic weigth that is given
    %           to each synapse upon formation
    %           - "prms.tauPRE","prms.tauPOST" and "prms.tauW" are the plasticity constans of
    %           the presynaptic accumulator, the postynaptic accumulator and
    %           the snyaptic weigths respectively. Higher values induce lower
    %           plasticity
    %           - "prms.offset" is the threshold that the presnyaptic activity must
    %           hold in order for a synapse to gain weight and not lose it
    %           - "prms.phi" is the presynaptic scaling constant
    %           - "prms.normSTD" is the variance of the normal distribution that is
    %           used to determine the influence that a given synapse has on
    %           another synapses postsnyaptic accumulator by applying aid
    %           normal distribution to the distace between those synapses
    %           - "prms.stabthr" is the threshold that a synaptic weight must have in
    %           oder to prevent the dendrite from retracting from that synapse
    %           - "prms.consthr" is the threshold that a synaptic weight must have
    %           in order to remain connected to the dendrite while the dendrite
    %           has not yet retracted from the synapse
    %           - "prms.lowerbound" and "prms.upperbound" are exactly what the name says
    %           for the synaptic weights
    %
    %           All input images/videos are 2D binary images/videos with the same framesize
    %           and they are meant to portray different aspects of exactly the
    %           same area.
    %
    %           IDEA: All of the inputs could be given as a function of
    %           something like time or dendrite length.

    % Output:   - "SimVid" is stack of in8 videos that with one meaning 
    %           presence of neuron and 2 meaning presence of synapse on that
    %           neuron
    %           - "Weights" is a stack of images that protray the evolution of
    %           synaptic weights for each neuron
    %           - "Cluster" is a stack of images that contain the ratio of
    %           synapses of the same group in the potential postynaptic
    %           accumulation of each synapse at each point in time for each
    %           neuron
    %           - "alldistMat" is a stack of the distance Matrices of the
    %           snynapses for each nueron.
    %           - "Sens" is a stack of doulbe images containing the sensitivity
    %           for each neuron
    %% get simulation constants
    T = size(mats.S,2); % P1 = size(mats.Dend,1); P2 = size(mats.Dend,2);
    simSize = size(mats.Dend); nDen = size(mats.Dend,3); % nSyn = length(find(mats.Syn ==1));
    %% init variables
    SimVid = zeros([simSize(1:2),ceil((T+1)/prms.agentspeed),nDen],'int8'); % preallocating
    allSomaFire = false([T nDen]);
    allWtrace = zeros([sum(mats.Syn,'all') ceil((T+1)/prms.agentspeed) nDen]);         
    
    % setting the first frame to be the initial state
    for iden = 1:nDen; SimVid(:,:,1,iden) = int8(full(mats.Dend(:,:,iden))); end
    
    % density of growth stimulating transmitters at each point
    Trans = zeros(size(mats.Dend,1),size(mats.Dend,2)); 

    % locations of all/scout/growth/retraction/afterimage agents
    allAgents = (false(simSize)); allScoutAgents = (false(simSize)); allGrowthAgents = (false(simSize)); allRetractorAgents = (false(simSize)); allOldAgents = (false(simSize));
    
    % image of all synapses connected/stabilized/disconnected
    allConSyn = false(simSize); allStabSyn = false(simSize); allDiscoSyn = false(simSize); allDt = false(simSize); FireImage = false(size(mats.Syn));
    
    %weights/presynaptic/postsynaptic accumulator
    allW = cell(nDen,1); allPRE = cell(nDen,1);  allPOST = cell(nDen,1); allPOSTbap = cell(nDen,1); % Weights = zeros([nSyn,nDen,ceil(T/prms.agentspeed)]);
    
    % the distance/S/Sens matrix for the synapses
    allSomadist = cell(nDen,1);
    alldMat = cell(nDen,1);
    allSMat = cell(nDen,1);
    allSens = repmat(mats.Area,[1 1 nDen]);
    
    allConlin = cell(nDen,1);
    
    % initializing the synapses
    Syn = mats.Syn;
    SynPos = find(mats.Syn ==1);
    % SynLife = ceil(lognrnd(prms.lifetime_mu,prms.lifetime_sigma,size(SynPos)));
    SynLife = ceil(lognrnd(prms.lifetime_mu,prms.lifetime_sigma,size(SynPos)));
    DeadSyn = false(size(Syn));
 
    SynVid = false([size(Syn),T]);
    % TransVid = zeros([size(Syn),T]);

    % create 2D groups matrix to track synapses with their groupID
    allGroupsMat = zeros(size(Syn));
    for i = 1:size(mats.Groups, 3)
        allGroupsMat = allGroupsMat + i * mats.Groups(:, :, i);
    end
    GroupsVid = zeros([size(allGroupsMat),T]);
    GroupsVid(:,:,1) = allGroupsMat;

    %% main loop over time
    for tt = 1:T % the timestep
        % time logging
        if mod(tt , 100) == 0; fprintf('%d, ',tt); end
        if mod(tt , 1000) == 0; fprintf('\n',tt); end
        

        % compute transmitter matrix
        % CNoise = randn(simSize(1:2))/(prms.signalint*prms.noisedown);
        Trans = (conv2(Trans,mats.DiffusionMat,'same') + (Syn-(sum(allConSyn,3)>0)).*(prms.signalint)); % dissolving the transmitters and having unconnected synapses emit new ones
        % TransNoise = Trans + CNoise; % laying the noise on top of the transmitters (If you do it this way the noise is not seen as part of the transmitters and is not kept and dissolved in the next step, but you could also directly add the noise to the transmitters
        TransNoise = Trans+double(mats.Noise(:,:,mod(tt,size(mats.Noise,3))+1));
        
        % % recording transmitters
        % TransVid(:,:,tt) = TransNoise;
        
        %% loop over individual dendrites
        if mod(tt,prms.agentspeed) == 1 %determining if it is time to move the agents
            
                for iden = 1:nDen % the mats.Dendrite that is being processed
                % extracting the respective values from the "all"-stacks
                Dt = allDt(:,:,iden); ConSyn = allConSyn(:,:,iden);  StabSyn = allStabSyn(:,:,iden);  DiscoSyn = allDiscoSyn(:,:,iden); Sens = allSens(:,:,iden);
                W = allW{iden}; PRE = allPRE{iden}; POST = allPOST{iden}; POSTbap = allPOSTbap{iden}; Somadist = allSomadist{iden}; dMat = alldMat{iden}; SMat = allSMat{iden};
            
                
                DI = Dt.*(TransNoise); % transmitter density on dendrite deterred by mats.Noise
                OutI = Sens.*(ones(size(Dt))-Dt).*(TransNoise).*mats.Area; % transmitter density outside the dendrite deterred by mats.Noise

                % extracting values from "all"-stacks
                Agents = allAgents(:,:,iden); ScoutAgents = allScoutAgents(:,:,iden); GrowthAgents = allGrowthAgents(:,:,iden); RetractorAgents = allRetractorAgents(:,:,iden); AncientAgents = allOldAgents(:,:,iden);

                % memorizing Agent locations before this step
                allOldAgents(:,:,iden) = Agents;

                % grow dendrite
                [GrowthAgents , ScoutAgents , Dt] = grow_dendrite(iden ,Dt , DI , GrowthAgents , OutI , ScoutAgents , StabSyn , mats , prms);
                % retract dendrite
                [Dt , RetractorAgents , ScoutAgents , Sens] = retract_dendrite(ScoutAgents , RetractorAgents , StabSyn , Dt , Sens , prms);
                
                %% No idea why this was implemented (also not in baseline model)
                % % killing growth agents that arrive at synapses, except directly
                % % at the soma
                % GrowthAgents = GrowthAgents & ~(mats.Syn & ~ConSyn & ~(conv2(mats.Soma(:,:,iden),ones(5),'same')>0));
                %%

                %accumulating the positions of all agents
                Agents = ScoutAgents | GrowthAgents | RetractorAgents;
                
                %%
                SplitAgents = (ScoutAgents & (conv2(full(Dt),[0 1 0;1 0 1;0 1 0],'same')==3) & ~mats.Soma(: , : , iden));
                % moving the scout agents
                ScoutAgents = (Dt & ~(Agents|AncientAgents) & conv2(full(ScoutAgents - SplitAgents),[0 1 0;1 0 1;0 1 0],'same'));

                if sum(SplitAgents(:)) > 0
                    SplitIDS = find(SplitAgents(:));
                    AfterSplit = false(size(SplitAgents));
                    for ss = 1:length(SplitIDS)
                        cSplitAgent = zeros(size(SplitAgents));
                        cSplitAgent(SplitIDS(ss)) = 1;
                        cSplitCandidates = (Dt & ~(Agents|AncientAgents) & conv2(full(cSplitAgent),[0 1 0;1 0 1;0 1 0],'same') & ~mats.Soma(: , : , iden));
                        
                        if prms.splitprob == 0
                        % % move in exaclty one random direction
                        cSplitCandidates(cSplitCandidates == 1) = custom_randomdraw(true(sum(cSplitCandidates(:)),1));
                        else
                        % % move using splitprob. this can lead to duplication or disappearence
                        cSplitCandidates(cSplitCandidates == 1) = rand(sum(cSplitCandidates(:)),1) <= prms.splitprob;
                        end
                        AfterSplit = AfterSplit + cSplitCandidates;
                    end
                    ScoutAgents = ScoutAgents | AfterSplit;
                end

                
                % % randomly killing scouts
                ScoutAgents(ScoutAgents) = rand(sum(ScoutAgents(:)),1) <= 1- prms.scoutdeathprob;
                
                % killing scouts that are adjacent to other scouts, to be
                % safe
                DefectScouts = ( conv2((ScoutAgents | GrowthAgents | RetractorAgents),[0 1 0;1 1 1;0 1 0],'same') > 1 ) & ScoutAgents;
                ScoutAgents(DefectScouts) = 0;
                
                
                % deleting values for synapses that the dendrite has retracted from
                Conlin = allConlin{iden};
                for lin = find(((ConSyn) & ~Dt))'
                    ConSyn(lin) = 0;
                    
                    linsyn = Conlin == lin; W = W(~linsyn); PRE = PRE(~linsyn); POST = POST(~linsyn);  POSTbap = POSTbap(~linsyn); Somadist = Somadist(~linsyn); dMat = dMat(~linsyn,:); dMat = dMat(:,~linsyn); SMat = SMat(~linsyn,:); SMat = SMat(:,~linsyn);
                    Conlin = Conlin(~linsyn);
                    allConlin{iden} = Conlin;
                end
                for lin = find(((DiscoSyn) & ~Dt))'
                    DiscoSyn(lin) = 0;
                end

                % rewritng values into the all stacks
                allAgents(:,:,iden) = ScoutAgents | GrowthAgents | RetractorAgents; allScoutAgents(:,:,iden) = ScoutAgents; allGrowthAgents(:,:,iden) = GrowthAgents; allRetractorAgents(:,:,iden) = RetractorAgents;
                allDt(:,:,iden) = Dt; allDiscoSyn(:,:,iden) = DiscoSyn; allConSyn(:,:,iden) = ConSyn;
                allW{iden} = W; allPRE{iden} = PRE; allPOST{iden} = POST; allPOSTbap{iden} = POSTbap; allSomadist{iden} = Somadist; alldMat{iden} = dMat; allSMat{iden} = SMat; allSens(:,:,iden) = Sens;
                
                % documenting the State of the Dendrite and the Weights
                SimVid(:,:,ceil((tt+1)/prms.agentspeed),iden) = Dt+ConSyn;
                
                % the weight-tracking requires adjustment to the moving
                % Synapses
%                 if sum(ConSyn(:))>0
%                 allWtrace(:,ceil((tt+1)/prms.agentspeed),iden) = weighttrace(W,Conlin,Syn);
%                 end
                
                end
        end
        
        % starting new wave of scout agents if it is time to do so
        if mod(tt,prms.agentfreq)==1; allScoutAgents(:,:,:) = allScoutAgents(:,:,:) | (logical(mats.Soma(:,:,:))); end
        
        alloldConSyn = sum(allConSyn,3) > 0;
        alldoublenewSyn = sum(allDt & repmat(Syn,[1 1 nDen]) & ~alloldConSyn & ~allDiscoSyn,3) > 1;
        
        FireImage = false(size(Syn));
        FireImage(SynPos) = mats.S(:,tt);
        for iden = 1:nDen
            % extracting the respective values from the "all"-stacks
            Dt = allDt(:,:,iden); ConSyn = allConSyn(:,:,iden);  StabSyn = allStabSyn(:,:,iden);  DiscoSyn = allDiscoSyn(:,:,iden);
            W = allW{iden}; PRE = allPRE{iden}; POST = allPOST{iden}; POSTbap = allPOSTbap{iden} ; dMat = alldMat{iden}; SMat = allSMat{iden}; Conlin = allConlin{iden}; Somadist = allSomadist{iden};
            
            % Connecting newly owergrown mats.Synapses
            newConSyn = (Syn & ~(alloldConSyn | alldoublenewSyn | DiscoSyn)) & Dt;
            
            if sum(newConSyn(:))>0 
            % calculate tree distances
            [dMat , SMat , ConSyn , Conlin , W , Somadist] = get_distances_2D_nomax(newConSyn , Conlin , Dt , ConSyn , dMat , mats.Soma(:,:,iden) , W , prms) ;
            end
            
            % calculating weight dynamics:
            [PRE , POST , POSTbap , W , allSomaFire(tt,iden) ] = get_weight_dynamics_morph( FireImage , W , PRE , POST , POSTbap , SMat , ConSyn , Conlin , Somadist , prms);
            
            % prune synapses
            [StabSyn , ConSyn , DiscoSyn , W , PRE, POST, dMat, SMat, Conlin, POSTbap, Somadist] = prune_synapses_morph(Dt , ConSyn , Conlin , W , StabSyn , DiscoSyn , PRE, POST, POSTbap, Somadist, dMat, SMat , prms);
            
%             % documenting weights
%             if mod(tt,prms.weighttrace_interval)==1
%                 if sum(ConSyn(:))>0
%                 allWtrace(:,ceil((tt+1)/prms.weighttrace_interval),iden) = weighttrace(W,Conlin,Syn);
%                 end
%             end
            
            % rewriting values into the all stacks
            allConSyn(:,:,iden) = ConSyn; allStabSyn(:,:,iden) = StabSyn; allDiscoSyn(:,:,iden) = DiscoSyn; allW{iden} = W; allPRE{iden} = PRE; allPOST{iden} = POST; allPOSTbap{iden} = POSTbap; alldMat{iden} = dMat; allSMat{iden} = SMat; allConlin{iden} = Conlin; allSomadist{iden} = Somadist;
        end
        
        % counting down lifetimes and moving synapses if necessary
        freeSyn = find(Syn & ~(sum(allConSyn,3)>0));
        for synlin = freeSyn'
            SynLife(SynPos == synlin) = SynLife(SynPos == synlin) - 1;
            if SynLife(SynPos == synlin) == 0
                SynLife(SynPos == synlin) = ceil(lognrnd((1 + prms.lifescale*tt/1000)*prms.lifetime_mu,prms.lifetime_sigma));
                Syn(synlin) = 0;    % Synapse gets removed
                
                % update groups
                syn_id_tmp = allGroupsMat(synlin);
                allGroupsMat(synlin) = 0;

                if rand < prms.syndeath % Check if the removed synapses is gonna die out
                    DeadSyn(synlin) = 1;
                else
                    movemask = false(size(Syn));
                    movemask(synlin) = 1;
                    movemask = conv2(movemask,mats.move,'same') & ~(Syn | DeadSyn) & mats.Area;
                    
                    if sum(movemask,'all') == 0 % if the synapse is stuck it doesnt move
                        movemask(synlin) = 1;
                    end
                    
                    postmove = custom_randomdraw(movemask);
                    Syn(postmove) = 1;
                    SynPos(SynPos == synlin) = find(postmove);

                    % update groups
                    allGroupsMat(postmove) = syn_id_tmp;
                end
                
                % removing the moved synapse from the DiscoSyn entries
                for iden = 1:nDen
                    DiscoSyn = allDiscoSyn(:,:,iden);
                    DiscoSyn(synlin) = 0;
                    allDiscoSyn(:,:,iden) = DiscoSyn;
                end
            end
        end
        
        % recording movement
        SynVid(:,:,tt) = Syn;
        GroupsVid(:,:,tt) = allGroupsMat;
 
    end
SimVid = SimVid(:,:,1:end-1,:); % cropping the data because the last step was might be empty
allWtrace = allWtrace(:,1:end-1,:);
end
