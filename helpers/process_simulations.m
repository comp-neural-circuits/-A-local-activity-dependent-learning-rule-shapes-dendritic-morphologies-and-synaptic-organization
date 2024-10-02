function [accLengths, accSyns, accDens, tot_tree_length_time, dend_add_time, dend_remove_time, connect_syn_time, syn_add_time, syn_remove_time, sel, stab, sel_groups] = process_simulations(load_dir_str, REPS, N, T)
    tot_tree_length_time = zeros(REPS, N, T);
    dend_add_time = zeros(REPS, N, T);
    dend_remove_time = zeros(REPS, N, T);
    connect_syn_time = zeros(REPS, N, T);
    syn_add_time = zeros(REPS, N, T);
    syn_remove_time = zeros(REPS, N, T);

    accLengths = zeros(REPS, T);
    accSyns = zeros(REPS, T);
    accDens = zeros(REPS, T);
    sel = zeros(REPS, T);
    sel_groups = zeros(REPS, T, 5);
    
    interval = 50;    % 4.5h
    stab = zeros(REPS, T-interval);

    % extracting data. one simulation at a time.
    parfor i = 1:REPS
        % SimVid dimensions: PxPxNxT
        SimVid = load([load_dir_str, '/sim_', num2str(i), '/SimVid.mat']).SimVid;

        SimVid = permute(SimVid, [1, 2, 4, 3]);

        % total tree length as a function of time
        tree_length = squeeze(sum(SimVid==1,[1 2]));
        tot_tree_length_time(i,:,:) = tree_length(:,1:end);

        % amount of dendrite added/removed as a function of time
        [addvstime_new, remvstime_new] = addremvstime(SimVid);
        dend_add_time(i,:,:) = addvstime_new(:,1:end);
        dend_remove_time(i,:,:) = remvstime_new(:,1:end);

        % number of connected synapses as a function of time
        connect_syn = squeeze(sum(SimVid==2,[1 2]));
        connect_syn_time(i,:,:) = connect_syn(:,1:end);

        % number of synapses added/removed as a function of time
        [formedvstime_new, prunedvstime_new] = formprunvstime(SimVid);
        syn_add_time(i,:,:) = formedvstime_new(:,1:end);
        syn_remove_time(i,:,:) = prunedvstime_new(:,1:end);

        accLengths(i,:) = squeeze(sum(sum(mean(SimVid(: , : , : , 1:end) > 0 , 3) , 1) , 2)); % get the length of a dendrite (sum over all the entries bigger than 0)
        accSyns(i,:) = squeeze(sum(sum(mean(SimVid(: , : , : , 1:end) > 1 , 3) , 1) , 2)); % get the number of connected synapses (sum over all the entries bigger than 1)
        accDens(i,:) = squeeze(sum(sum(mean(SimVid(: , : , : , 1:end) > 1 , 3) , 1) , 2))./squeeze(sum(sum(mean(SimVid(: , : , : , 1:end) > 0 , 3) , 1) , 2)); % get the density (quotient of the previous two)

        % Selectivity
        mats = load([load_dir_str, '/sim_', num2str(i), '/mats.mat']).mats;
        Syn = mats.Syn;
        GroupID = mats.GroupID;
        % sel(i,:) = selectivityvstime_trad(SimVid, Syn, GroupID);
        sel(i,:) = selectivityvstime_new(SimVid, Syn, GroupID);
        sel_groups(i,:,:) = selectivityvstime_groups(SimVid, Syn, GroupID);

        % Stability
        stab(i,:) = stabilityvstime(SimVid,interval);

        fprintf('rep %i out of %i done.', i, REPS)
    end
end
