% this script extracts the information that we want to plot and saves it as
% raw data.

%% setting up
mkdir('data')

% I want to create a loop so that fList is not so huge all the time
 
        fList = cell(REPS_global,1);
        for xxx = 1:REPS_global
            fList{xxx} = append(pwd,'/sim_',num2str(xxx),'/SimVid.mat');
        end
        
    nSim = size(fList,1);
    
    datasize = [Tsim,N,REPS_global];
    lengthvstime_d = zeros(datasize);
    totalsynvstime_d = zeros(datasize);
    addvstime_d = zeros(datasize);
    remvstime_d = zeros(datasize);
    formedvstime_d = zeros(datasize);
    prunedvstime_d = zeros(datasize);
    lengthvstime_b =  zeros(datasize);
    totalsynvstime_b =  zeros(datasize);
    addvstime_b = zeros(datasize);
    remvstime_b =  zeros(datasize);
    formedvstime_b =  zeros(datasize);
    prunedvstime_b =  zeros(datasize);

    %% extracting data. one simulation at a time.
    parfor ff = 1:size(fList,1)
        fprintf('extracting data from sim %i.\n', ff)
        
        dat = load(fList{ff});

        %% extracting data

        % total tree length as a function of time
        lengthvstime_new = squeeze(sum(dat.SimVid>0,[1 2]));
        lengthvstime_d(:,:,ff) = lengthvstime_new;

        % amount of dendrite added/removed as a function of time        
        [addvstime_new,remvstime_new] = addremvstime(dat.SimVid);
        addvstime_d(:,:,ff) = addvstime_new;
        remvstime_d(:,:,ff) = remvstime_new;

        % number of connected synapses as a function of time
        totalsynvstime_new = squeeze(sum(dat.SimVid>1,[1 2]));
        totalsynvstime_d(:,:,ff) = totalsynvstime_new;
        
        % number of synapses added/removed as a function of time
        [formedvstime_new, prunedvstime_new] = formprunvstime(dat.SimVid);
        formedvstime_d(:,:,ff) = formedvstime_new;
        prunedvstime_d(:,:,ff) = prunedvstime_new;
        
        
        % applying movsum for the binned plot
        for ibin = 1:N
            lengthvstime_b(:,ibin,ff) = movsum(lengthvstime_new(:,ibin),16);
            totalsynvstime_b(:,ibin,ff) = movsum(totalsynvstime_new(:,ibin),16);
            addvstime_b(:,ibin,ff) = movsum(addvstime_new(:,ibin),16);
            remvstime_b(:,ibin,ff) = movsum(remvstime_new(:,ibin),16);
            formedvstime_b(:,ibin,ff) = movsum(formedvstime_new(:,ibin),16);
            prunedvstime_b(:,ibin,ff) = movsum(prunedvstime_new(:,ibin),16);
        end
        
        
        fprintf('finished extracting data from sim %i.\n', ff)
    end

        save('data/data_classical.mat','-v7.3');

        
    

    

