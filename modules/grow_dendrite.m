function [GrowthAgents , ScoutAgents , Dt] = grow_dendrite(iden ,Dt , DI , GrowthAgents , OutI , ScoutAgents , StabSyn , mats, prms)
    % documenting maximum outside Transmitter density a each growth agent:
    Gmax = zeros(size(Dt));

    for lin = find(GrowthAgents==1)'
        [j,k]=ind2sub(size(Dt),lin);
        Gmax(j,k)= max(OutI((j-1):(j+1),(k-1):(k+1)).*([0 1 0; 1 0 1; 0 1 0]),[],'all');
    end

    % marking locations for intended growth
    Gintent = false(size(Dt));

    for lin = find(Gmax>0)'
        [j,k]=ind2sub(size(Dt),lin);

        if OutI(j+1,k)==Gmax(j,k) && mats.Area(j+1,k)==1 && max(Dt((j):(j+2),(k-1):(k+1)).*([0 0 0; 1 0 1; 1 1 1]),[],'all')==0
            Gintent(j+1,k) = 1;
        end

        if OutI(j,k+1)==Gmax(j,k) && mats.Area(j,k+1)==1 && max(Dt((j-1):(j+1),(k):(k+2)).*([0 1 1; 0 0 1; 0 1 1]),[],'all')==0
            Gintent(j,k+1) = 1;
        end

        if OutI(j-1,k)==Gmax(j,k) && mats.Area(j-1,k)==1 && max(Dt((j-2):(j),(k-1):(k+1)).*([1 1 1; 1 0 1; 0 0 0]),[],'all')==0
            Gintent(j-1,k) = 1;
        end

        if OutI(j,k-1)==Gmax(j,k) && mats.Area(j,k-1)==1 && max(Dt((j-1):(j+1),(k-2):(k)).*([1 1 0; 1 0 0; 1 1 0]),[],'all')==0
            Gintent(j,k-1) = 1;
        end

    end
   
    % tranforming scout agents to growth agents if possible and marking
    % locations for intended growth or flipping a corner
    GIT = Gintent.*(OutI);
    newScouts=full(ScoutAgents);
    
    for lin = find(ScoutAgents==1)'
        [j,k]=ind2sub(size(Dt),lin);
        if DI(j,k) > max((DI((j-1):(j+1),(k-1):(k+1)).*[0 1 0; 1 0 1; 0 1 0]),[],'all') || mats.Soma(j,k,iden) == 1 % The important function of this line is that it makes it so that a new branch is only grown at the point which is nearest to the synapse on the existing dendrite. This can cause problems on the soma.
            om = max(OutI((j-1):(j+1),(k-1):(k+1)).*([0 1 0; 1 0 1; 0 1 0]),[],'all');
            if om > DI(j,k)
                if (OutI(j+1,k)==om && mats.Area(j+1,k)==1 && om > max(GIT((j):(j+2),(k-1):(k+1)).*([0 0 0; 1 0 1; 1 1 1]),[],'all'))
                    if sum(Dt((j):(j+2),(k-1):(k+1))&([0 0 0; 1 0 1; 1 1 1]),'all')==0 %if this happens the agent becomes a growth agent
                        newScouts(j,k)=0;
                        Gintent(j+1,k) = 1;
                    elseif sum(Dt((j):(j+2),(k-1):(k+1))&([0 0 0; 1 0 1;1 1 1]),'all')==1 %if this happens a corner might be flipped

                        if sum(Dt((j):(j+2),(k-1):(k+1))&([0 0 0; 0 0 1; 0 0 0]),'all')==1 && StabSyn(j,k+1) == 0 && sum(Dt((j-1):(j+1),(k):(k+2)).*([0 1 0; 1 0 1; 0 1 0]),'all')<3
                            Dt(j+1,k) = 1;
                            Dt(j,k+1) = 0;
                        elseif sum(Dt((j):(j+2),(k-1):(k+1))&([0 0 0; 1 0 0; 0 0 0]),'all')==1 && StabSyn(j,k-1) == 0 && sum(Dt((j-1):(j+1),(k-2):(k)).*([0 1 0; 1 0 1; 0 1 0]),'all')<3
                            Dt(j+1,k) = 1;
                            Dt(j,k-1) = 0;
                        end
                    end      
                end
                if (OutI(j,k+1)==om && mats.Area(j,k+1)==1 && om > max(GIT((j-1):(j+1),(k):(k+2)).*([0 1 1; 0 0 1; 0 1 1]),[],'all'))
                    if sum(Dt((j-1):(j+1),(k):(k+2)).*([0 1 1; 0 0 1; 0 1 1]),'all')==0
                    newScouts(j,k)=0;
                    Gintent(j,k+1) = 1;
                    elseif sum(Dt((j-1):(j+1),(k):(k+2)).*([0 1 1; 0 0 1; 0 1 1]),'all')==1
                        if sum(Dt((j-1):(j+1),(k):(k+2)).*([0 0 0; 0 0 0; 0 1 0]),'all')==1 && StabSyn(j+1,k) == 0 && sum(Dt((j):(j+2),(k-1):(k+1))&([0 1 0; 1 0 1; 0 1 0]),'all')<3
                            Dt(j,k+1)=1;
                            Dt(j+1,k)=0;
                        elseif sum(Dt((j-1):(j+1),(k):(k+2)).*([0 1 0; 0 0 0; 0 0 0]),'all')==1 && StabSyn(j-1,k) == 0 && sum(Dt((j-2):(j),(k-1):(k+1)).*([0 1 0; 1 0 1; 0 1 0]),'all')<3
                            Dt(j,k+1)=1;
                            Dt(j-1,k)=0;
                        end
                    end
                end
                if (OutI(j-1,k)==om && mats.Area(j-1,k)==1 && om > max(GIT((j-2):(j),(k-1):(k+1)).*([1 1 1; 1 0 1; 0 0 0]),[],'all'))
                    if sum(Dt((j-2):(j),(k-1):(k+1)).*([1 1 1; 1 0 1; 0 0 0]),'all')==0
                    newScouts(j,k)=0;
                    Gintent(j-1,k) = 1;
                    elseif sum(Dt((j-2):(j),(k-1):(k+1)).*([1 1 1; 1 0 1; 0 0 0]),'all')==1
                        if sum(Dt((j-2):(j),(k-1):(k+1)).*([0 0 0; 0 0 1; 0 0 0]),'all')==1 && StabSyn(j,k+1)==0 && sum(Dt((j-1):(j+1),(k):(k+2)).*([0 1 0; 1 0 1; 0 1 0]),'all')<3
                            Dt(j-1,k) = 1;
                            Dt(j,k+1) = 0;
                        elseif sum(Dt((j-2):(j),(k-1):(k+1)).*([0 0 0; 1 0 0; 0 0 0]),'all')==1 && StabSyn(j,k-1)==0 && sum(Dt((j-1):(j+1),(k-2):(k)).*([0 1 0; 1 0 1; 0 1 0]),'all')<3
                            Dt(j-1,k) = 1;
                            Dt(j,k-1) = 0;
                        end
                    end
                end
                if (OutI(j,k-1)==om && mats.Area(j,k-1)==1 && om > max(GIT((j-1):(j+1),(k-2):(k)).*([1 1 0; 1 0 0; 1 1 0]),[],'all'))
                    if sum(Dt((j-1):(j+1),(k-2):(k)).*([1 1 0; 1 0 0; 1 1 0]),'all')==0
                    newScouts(j,k)=0;
                    Gintent(j,k-1) = 1;
                    elseif sum(Dt((j-1):(j+1),(k-2):(k)).*([1 1 0; 1 0 0; 1 1 0]),'all')==1
                        if sum(Dt((j-1):(j+1),(k-2):(k)).*([0 1 0; 0 0 0; 0 0 0]),'all')==1 && StabSyn(j-1,k)==0 && sum(Dt((j-2):(j),(k-1):(k+1)).*([0 1 0; 1 0 1; 0 1 0]),'all')<3
                            Dt(j,k-1) = 1;
                            Dt(j-1,k) = 0;
                        elseif sum(Dt((j-1):(j+1),(k-2):(k)).*([0 0 0; 0 0 0; 0 1 0]),'all')==1 && StabSyn(j+1,k)==0 && sum(Dt((j):(j+2),(k-1):(k+1))&([0 1 0; 1 0 1; 0 1 0]),'all')<3
                            Dt(j,k-1) = 1;
                            Dt(j+1,k) = 0;
                        end
                    end
                end
            end
        end
        
    end
    
    Dt = Dt | logical(mats.Soma(:,:,iden));
    ScoutAgents = (newScouts);
    
    % only keeping intended growth locations if they are not adjacent
    % to another intended growth location with higher transmitter
    % density
    
    GIT = Gintent.*(OutI);
    newGintent = Gintent;

    for lin = find(Gintent==1)'
        [j,k]=ind2sub(size(Dt),lin);
        if GIT(j,k) > max(GIT((j-1):(j+1),(k-1):(k+1)).*([1 1 1; 1 0 1; 1 1 1]),[],'all')
            newGintent((j-1):(j+1),(k-1):(k+1)) = [0 0 0; 0 1 0; 0 0 0];
        end     
    end

    Gintent = newGintent;

    % completely removing growth locations that are still adjacent
    Del = false(size(Dt));

    for lin = find(Gintent==1)'
        [j,k]=ind2sub(size(Dt),lin);
        if max(Gintent((j-1):(j+1),(k-1):(k+1)).*([1 1 1; 1 0 1; 1 1 1]),[],'all') >= 1
            Del(j,k)=1;
        end
    end

    GrowthAgents = (Gintent & ~Del); % moving the growthagents to the intended locations
    
    % randomly killing growth agents
    GrowthAgents(GrowthAgents) = rand(sum(GrowthAgents(:)),1) <= 1 - prms.growthdeathprob;
    
    % growing the mats.Dendrite
    Dt = Dt | full(GrowthAgents);
end