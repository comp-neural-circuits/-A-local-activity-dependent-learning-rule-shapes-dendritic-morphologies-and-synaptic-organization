function [prms , mats , cells] = get_params_2D_fixed(T,N)
    % this is just normal get_params_2D but it generates the randomized
    % parameters N times and stores them in cells.
    
    P = 185;
    
    % set up structures
    prms = struct;
    mats = struct;
    cells = struct;

    initSomPos = load('data_Jan/initialSomaPos.mat');
    mats.Soma = initSomPos.initialSomaPos;
    mats.Area = (ones(P , P)); 
    mats.Area(1,:) = 0; mats.Area(end,:) = 0; mats.Area(:,1) = 0; mats.Area(:,end) = 0;
    % mats.Dend = false(size(mats.Soma)); % this might have caused a
    % freezing issue in the while loop of get_distance_nomax
    mats.Dend = mats.Soma; 
    
    groupsmat = load('data_Jan/Groupsmat.mat');
    mats.Syn = logical(sum(groupsmat.Groupsmat , 3));
    mats.Groups = groupsmat.Groupsmat;

    % now assign activity traces to all the potential synapses
    
    groupsmat = load('data_Jan/Groupsmat.mat');
    mats.Syn = logical(sum(groupsmat.Groupsmat , 3));
    mats.Groups = groupsmat.Groupsmat;
    
    numSyns = sum(mats.Syn,'all');
    Synlin = find(mats.Syn);
    S = zeros(numSyns,T);
    GroupID = zeros(size(Synlin));
    mu = 0.0125;
    numGroups = size(mats.Groups,3);
    S_groups = zeros(numGroups,T);
    for ii = 1:numGroups
        S_groups(ii,:) = rand(1,T) < mu;
    end
    for isyn = 1:numSyns
        lin = Synlin(isyn);
        [j,k] = ind2sub(size(mats.Syn),lin);
        cgroup = find(mats.Groups(j,k,:)>0);
        S(isyn,:) = S_groups(mats.Groups(j,k,:)>0,:);
        GroupID(isyn) = cgroup;
    end
    
    mats.S = S;
    mats.GroupID = GroupID;
    
    % set the speed of the growth agents as well as the frequency at which
    % they are released
    prms.agentfreq = 100;
    prms.agentspeed = 50;
    prms.weighttrace_interval = prms.agentspeed;
    
        
    % and now set up the diffusion matrix (dimension must be odd!)
     
%     Small Diamond Diffusion:
    ratio = 0.25; Dissum = 0.95;
    mats.DiffusionMat = Dissum*(1/(4*ratio + 1))*[ 0 ratio 0; ratio 1 ratio; 0 ratio 0];
    
    prms.noisedown = 500;
    
    prms.desens = 0.0; prms.signalint = 1;
    
    prms.splitprob = 0.5; % this is the probability for a scout to continue in any direction at a branch point
    % setting this to 0 activates movement in exactly one random direction
    
    prms.scoutdeathprob = 0; % this the probability for a scout to disappear every time it moves. Low values lead to smaller dendrites.
    prms.growthdeathprob = 0; % same for growth agents. Setting this to be higher than the above work against "unlikely" long branches which dont retract.
    
    % and add a bit of noise to the growth field
    mats.Noise = randn(P,P,400)/(prms.signalint*prms.noisedown);
    
    % and now the parameters for the plasticity rule
    prms.initialweight = 0.5;
    tf = 1;
    prms.tauPOST = tf*6; prms.tauPRE = tf*12; prms.tauW = tf*60; %prms.tauPOST = 6; prms.tauPRE = 12; prms.tauW = 60;
    eta = 0.4655; prms.offset = (2*eta-1)/(2*(1-eta));
    prms.phi = 3; prms.normSTD = 200; prms.strSTD = 200;
    prms.stabthr = 0.02; prms.conthr = 0.02;
    prms.lowerbound = 0; prms.upperbound = 1;
    
    relevance = 0.95; % this is the percentage of the part of the normal distribution in which synapse distances are supposed to be calculated
    prms.maxdist = round(norminv(relevance + (1-relevance)/2,0,prms.normSTD));
    
    prms.bAP_contr_thr = 0.6; % 0.8; % the minimal weight a synapse needs to have before contributing to bAP
    prms.bAP_thr = 25;
    prms.bAPstrength = 0;
    prms.sigma_s = 75;
    prms.bAPprob = 0.25;
    
    % stir and done!
    
    % for bAP: 
    % prms.normSTD = 100; % which affects maxdist!
    % prms.bAPstrength = 5;
    % prms.scoutdeathprob = 4*0.01;
    % prms.growthdeathprob = 4*0.05;
    
    % for no bAP: 
    % prms.normSTD = 200; % which affects maxdist!
    % prms.bAPstrength = 0;
    % prms.scoutdeathprob = 1*0.01;
    % prms.growthdeathprob = 1*0.05;
end