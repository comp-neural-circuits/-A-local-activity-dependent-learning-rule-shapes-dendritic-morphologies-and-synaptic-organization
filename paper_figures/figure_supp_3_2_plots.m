%% setting up
clear
clc
% close all

addpath('../helpers')

dir_str = '../sims/';

save_dir_str = 'Videos and images/figure_supp_3_2/';
mkdir(save_dir_str)

% all the simulation folders that are getting visualized
folder_str = {
    'sims_2024-01-07-14-59-13 40000 baseline',...
    'sims_2024-01-07-17-30-03 40000 somata13',...
    'sims_2024-01-07-17-39-25 40000 somata16',...
    'sims_2024-01-07-19-07-44 40000 somata25',...
};

% initialize accumulators for multiple simulations
all_accLengths = [];
all_accSyns = [];
all_accDens = [];
all_tot_tree_length_time = [];
all_connect_syn_time = [];
all_dend_add_time = [];
all_dend_remove_time = [];
all_syn_add_time = [];
all_syn_remove_time = [];

% iterate over each folder
for k = 1:length(folder_str)
    f_str = folder_str{k};

    load_dir_str = [dir_str, f_str];
    % save_dir = [save_dir_str, f_str];

    % mkdir(save_dir)
    
    % number of different global iterations (in particular number of different sets of activity to be generated)
    data_classical = load([load_dir_str, '/data/data_classical.mat']);
    REPS = data_classical.REPS_global;

    % size of the simulation video
    T = data_classical.Tsim;
    N = data_classical.N;
    prms = load([load_dir_str, '/sim_1/prms.mat']).prms;

    tot_tree_length_time = zeros(REPS, N, T);
    dend_add_time = zeros(REPS, N, T);
    dend_remove_time = zeros(REPS, N, T);
    connect_syn_time = zeros(REPS, N, T);
    syn_add_time = zeros(REPS, N, T);
    syn_remove_time = zeros(REPS, N, T);

    accLengths = zeros(REPS, T);
    accSyns = zeros(REPS, T);
    accDens = zeros(REPS, T);

    % extracting data. one simulation at a time.
    for i = 1:REPS
        clc
        disp(f_str)
        disp([num2str(i), ' of ', num2str(REPS)])
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
    end
    % % applying movsum or movmean for the binned plot
    % tot_tree_length_time_bin = movmean(reshape(mean(tot_tree_length_time, [1,2]),1,[]),16,"Endpoints","discard");
    % connect_syn_time_bin = movmean(reshape(mean(connect_syn_time, [1,2]),1,[]),16,"Endpoints","discard");
    % dend_add_time_bin= movsum(reshape(mean(dend_add_time,[1,2]),1,[]),16,"Endpoints","discard");
    % dend_remove_time_bin = movsum(reshape(mean(dend_remove_time,[1,2]),1,[]),16,"Endpoints","discard");
    % syn_add_time_bin = movsum(reshape(mean(syn_add_time,[1,2]),1,[]),16,"Endpoints","discard");
    % syn_remove_time_bin = movsum(reshape(mean(syn_remove_time,[1,2]),1,[]),16,"Endpoints","discard");

    % accumulate data for all folders
    all_accLengths = [all_accLengths; mean(accLengths, 1)];
    all_accSyns = [all_accSyns; mean(accSyns, 1)];
    all_accDens = [all_accDens; mean(accDens, 1)];
    % all_accLengths = [all_accLengths; movmean(mean(accLengths, 1),16,"Endpoints","discard")];
    % all_accSyns = [all_accSyns; movmean(mean(accSyns, 1),16,"Endpoints","discard")];
    % all_accDens = [all_accDens; movmean(mean(accDens, 1),16,"Endpoints","discard")];
    all_tot_tree_length_time = [all_tot_tree_length_time; reshape(mean(tot_tree_length_time, [1,2]), 1, [])];
    all_connect_syn_time = [all_connect_syn_time; reshape(mean(connect_syn_time, [1,2]), 1, [])];
    all_dend_add_time = [all_dend_add_time; reshape(mean(dend_add_time, [1,2]), 1, [])];
    all_dend_remove_time = [all_dend_remove_time; reshape(mean(dend_remove_time, [1,2]), 1, [])];
    all_syn_add_time = [all_syn_add_time; reshape(mean(syn_add_time, [1,2]), 1, [])];
    all_syn_remove_time = [all_syn_remove_time; reshape(mean(syn_remove_time, [1,2]), 1, [])];
end

% Plotting

% Averages
figure
subplot(1,3,1);
hold on
for i = 1:length(folder_str)
    plot(all_accLengths(i,:))
end
axis square
% xlim([0 , 800])
ylim([0 , 1000])
% xticks([0 , 800])
yticks([0 , 1000])
xlabel('time')
ylabel('length')
legend(folder_str, 'Interpreter', 'none')

subplot(1,3,2);
hold on
for i = 1:length(folder_str)
    plot(all_accSyns(i,:))
end
axis square
% xlim([0 , 800])
ylim([0 , 120])
% xticks([0 , 800])
yticks([0 , 120])
xlabel('time')
ylabel('synapses')
legend(folder_str, 'Interpreter', 'none')

subplot(1,3,3); 
hold on
for i = 1:length(folder_str)
    plot(all_accDens(i,:))
end
axis square
% xlim([0 , 800])
ylim([0 , 0.3])
% xticks([0 , 800])
yticks([0 , 0.3])
xlabel('time')
ylabel('density')
legend(folder_str, 'Interpreter', 'none')

savefig([save_dir_str, 'combined_plots.fig'])

% Dendrite and Synapse Changes
figure
% tree length
subplot(2,2,1); hold on;
title('Dendritic tree length')
for i = 1:length(folder_str)
    plot(all_tot_tree_length_time(i,:), 'DisplayName', folder_str{i})
end
ylabel('dendritic tree length')
xlabel('time')
legend show

% dendrites added/removed
subplot(2,2,2); hold on;
title('Dendrites added/removed')
for i = 1:length(folder_str)
    plot(all_dend_add_time(i,:), 'Color' , [0 1 0])
    plot(all_dend_remove_time(i,:), 'Color' , [1 0 0])
end
ylabel('change of dendrites')
xlabel('time')

% total connections/synapses
subplot(2,2,3); hold on;
title('Total synapses')
for i = 1:length(folder_str)
    plot(all_connect_syn_time(i,:), 'DisplayName', folder_str{i})
end
ylabel('number of synapses')
xlabel('time')
legend show

% change in synapses
subplot(2,2,4); hold on;
title('Synapses added/removed')
for i = 1:length(folder_str)
    plot(all_syn_add_time(i,:), 'Color' , [0 1 0])
    plot(all_syn_remove_time(i,:), 'Color' , [1 0 0])
end
ylabel('change in number of synapses')
xlabel('time')

savefig([save_dir_str, 'combined_syn_dend_changes.fig'])