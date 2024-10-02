function [prms , mats] = get_params_ver_22_02_12(P , N , T , K , cVal)
    prms = struct;
    mats = struct;
    
    prms.seed = randi(10000 , 1);
    
    initSomPos = load('data/initialSomaPos.mat');
    mats.Soma = initSomPos.initialSomaPos;
    mats.Area = (ones(P , P)); 
    mats.Area(1,:) = 0; mats.Area(end,:) = 0; mats.Area(:,1) = 0; mats.Area(:,end) = 0;
    mats.Dend = int8(zeros(P , P , N));

    groupsmat = load('data/Groupsmat.mat');
    mats.Syn = logical(sum(groupsmat.Groupsmat , 3));
    [Groupsmat , fGroupsmat] = generate_random_Groupsmat(mats.Syn , K);
    mats.Groups = Groupsmat;

    CF = get_CF(P , T , mats , cVal);
    mats.Vid = CF;


%     prms.agentfreq = 100; 
    prms.agentfreq = ones(T,1)*100;%linspace(10 , 200 , T); 

    prms.agentspeed = 50;

    sigDiss = 0.75; Dissum = 0.5;
    [XX  ,YY] = meshgrid(linspace(-3 , 3 , 20) , linspace(-3 , 3 , 20));
    DiffusionMat = reshape(mvnpdf([XX(:)  ,YY(:)],[0 , 0],sigDiss*eye(2)),[20,20]);
    mats.DiffusionMat = Dissum*DiffusionMat./sum(DiffusionMat(:));
    prms.desens = 0.0; prms.signalint = 1;

    mats.Noise = randn(P,P,floor(T/100))/(prms.signalint*500);%int8(zeros(P , P));

    prms.initialweight = 0.5;
%     prms.tauPOST = 6; prms.tauPRE = 12; prms.tauW = 20;%60;
    prms.tauPOST = 6; prms.tauPRE = 12; prms.tauW = 60;%60;

    eta = 0.45;
    prms.offset = (2*eta-1)/(2*1-eta); 
    
    prms.phi = 3; prms.normSTD = 200;
    prms.calDiffSigma = 200;
    prms.stabthr = 0.02; prms.conthr = 0.02;

    prms.lowerbound = 0; prms.upperbound = 1;

end

function [Groupsmat , fGroupsmat] = generate_random_Groupsmat(Syn , K)
    [xPos , yPos] = find(Syn);
    fGroupsmat = double(Syn);
    idx=shuffle(sub2ind(size(Syn),xPos , yPos));
    nGroup = floor(length(idx)/K);
    for xx = 1:K
        for xx2 = 1:nGroup
            fGroupsmat(idx((xx-1)*nGroup + xx2)) = xx;
        end
    end
    Groupsmat = zeros(size(Syn,1) , size(Syn,2) , K);
    for xx = 1:K
        Groupsmat(: , : , xx) = fGroupsmat == xx;
    end
end

function v=shuffle(v)
     v=v(randperm(length(v)));
end

function CF = get_CF(P , T , mats , cVal)
    CF = zeros(P , P , T);
    muTot = 0.0125;
    muShared = muTot*cVal;
    muIndiv = muTot*(1-cVal);
    numGroups = size(mats.Groups,3);
    for ii = 1:numGroups
        [groupIDX , groupIDY] = find(mats.Groups(: , : , ii));
        Sshared = rand(T,1) < muShared;
        for jj = 1:length(groupIDX)
            Sindiv = rand(T,1) < muIndiv;
            CF(groupIDX(jj) , groupIDY(jj) , :) = (Sshared + Sindiv)>0;
        end
    end
end

