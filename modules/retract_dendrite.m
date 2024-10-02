function [Dt , RetractorAgents , ScoutAgents , Sens] = retract_dendrite(ScoutAgents , RetractorAgents , StabSyn , Dt , Sens , prms)
    % transforming scouts to retractors if they have reached the end of
    % a branch without finding a location to grow
    newScouts = full(ScoutAgents);
    newRetractors = full(RetractorAgents);

    for lin = find((ScoutAgents & ~StabSyn)==1)'
        [j,k]=ind2sub(size(Dt),lin);
        if sum([Dt(j-1,k) Dt(j+1,k) Dt(j,k-1) Dt(j,k+1)])==1
            newScouts(j,k)=0;
            newRetractors(j,k)=1;
        end
    end

    ScoutAgents = (newScouts);
    RetractorAgents = (newRetractors);

    % retracting branches on current dendrite and moving retractors
    newRetractors = false(size(Dt));

    for lin = find(RetractorAgents == 1)'

        Dt(lin)=0;

        [j,k]=ind2sub(size(Dt),lin);

        if Dt(j+1,k)==1 && StabSyn(j+1,k)==0 && sum(Dt((j):(j+2),(k-1):(k+1)).*([0 1 0; 1 0 1; 0 1 0]),'all')==1
            newRetractors(j+1,k) = 1;

        elseif Dt(j-1,k)==1 && StabSyn(j-1,k)==0 && sum(Dt((j-2):(j),(k-1):(k+1)).*([0 1 0; 1 0 1; 0 1 0]),'all')==1
            newRetractors(j-1,k) = 1;

        elseif Dt(j,k+1)==1 && StabSyn(j,k+1)==0 && sum(Dt((j-1):(j+1),(k):(k+2)).*([0 1 0; 1 0 1; 0 1 0]),'all')==1
            newRetractors(j,k+1) = 1;

        elseif Dt(j,k-1)==1 && StabSyn(j,k-1)==0 && sum(Dt((j-1):(j+1),(k-2):(k)).*([0 1 0; 1 0 1; 0 1 0]),'all')==1
            newRetractors(j,k-1) = 1;

        else
            Sens(j,k) = Sens(j,k)*prms.desens;
        end
    end

    Sens(conv2(Dt,[0 1 0;1 1 1;0 1 0],'same')==0) = 1;

    RetractorAgents = (newRetractors);

end