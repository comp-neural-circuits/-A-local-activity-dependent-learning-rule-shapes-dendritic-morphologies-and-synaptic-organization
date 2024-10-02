function [newdMat , newSMat , ConSyn , newfullConlin , newW , newSomadist] = get_distances_2D_nomax(newConSyn , Conlin , Dt , ConSyn , dMat , Soma , W , prms) 
    %% compute pairwise distances between all synapses on a dendrite
    % comverts binary image of dendrite to graph and uses the Dijkstra 
    % algorithm to compute all (new) pairwise distances
    % Input:
    %   - "newConSyn" is a binary matrix with 1 in the location of newly
    %   connected synapses
    %   - "SynPositions" are the linear indices of all the potential synapses
    %   - "Dt" logical image of the current state of the dendrite
    %   - "ConSyn" logical image of all connected synapses
    %   - "dMat" previously computed distance matrix, will be updated
    %   - "SMat" matrix of proximity values
    %   - "W" array of all current weights
    %   - "prms" and "mats" are structures containing the parameters and
    %   matrices particular to the simulation
    % Output:
    %   - "dMat" updated matrix of distances
    %   - "SMat" updated matrix of proximity values
    %   - "ConSyn" updated matrix of connected synapses
    %   - "W" updated array of weights
    
    star = [0 1 0; 1 1 1; 0 1 0];
    
    newConlin = find(newConSyn)';
    newfullConlin = [Conlin newConlin];
    
    newdMat = Inf(size(Conlin,2) + size(newConlin,2));
    newdMat(1:size(Conlin,2),1:size(Conlin,2)) = dMat;
    newdMat(logical(eye(size(newdMat)))) = 0;
        
    newW = zeros(1 , size(Conlin,2) + size(newConlin,2));
    newW(1 , 1:size(Conlin,2)) = W;
            
    for lin = newConlin % find all newly connected synapses
        tempConSyn = ConSyn;
        flower = false(size(Dt),'logical');
        flower(lin) = 1;
        linsyn = newfullConlin==lin;
        
        dist = 0;
        while max(logical(Dt) - logical(flower),[],'all') == 1
            flower = conv2(flower,star,'same') & Dt;
            dist = dist + 1;
            for lin2 = find(flower & tempConSyn)'
                linsyn2 = newfullConlin==lin2;
                newdMat(linsyn , linsyn2) = dist;
                newdMat(linsyn2 , linsyn) = dist;
            end
            tempConSyn = tempConSyn & ~flower;
        end
        
        ConSyn(lin) = 1;
        newW(linsyn)=prms.initialweight; % and initialize their weight appropriately
    end
    
    newSMat = normpdf(newdMat, 0 , prms.normSTD)*(sqrt(2*pi)*prms.strSTD);%prms.normSTD);
    
    % calculating soma distance
    flower = Soma;
    rose = double(flower);
    while flower ~= Dt
        flower = logical(conv2(flower,star,'same')) & Dt;
        rose = rose + flower;
    end
    rose = max(rose(:)) - rose;
    
    newSomadist = rose(newfullConlin);
    
    
    
end