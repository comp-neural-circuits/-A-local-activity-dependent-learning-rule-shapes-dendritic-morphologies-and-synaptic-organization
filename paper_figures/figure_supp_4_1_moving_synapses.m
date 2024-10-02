%% setting up
clear
clc
% close all

addpath('../helpers')

dir_str = '../sims/4_2_moving_synapses_final/';
save_dir_str = 'Videos and images/figure_supp_4_2/moving_synapses_final/';
mkdir(save_dir_str)

% all the simulation folders that are getting visualized
folder_str = dir(dir_str);
isFolder = [folder_str.isdir]; % Extract only the folders
folders = folder_str(isFolder);
folders = folders(~ismember({folders.name}, {'.', '..'}));  % Remove the '.' and '..' folders
folder_str = {folders.name};   % Get the names of the folders

% Open parallel pool
parpool('local', 32);

% Preallocate results to avoid issues with parfor
numFolders = length(folder_str);
all_accLengths = cell(1, numFolders);
all_accSyns = cell(1, numFolders);
all_accDens = cell(1, numFolders);
all_tot_tree_length_time = cell(1, numFolders);
all_connect_syn_time = cell(1, numFolders);
all_dend_add_time = cell(1, numFolders);
all_dend_remove_time = cell(1, numFolders);
all_syn_add_time = cell(1, numFolders);
all_syn_remove_time = cell(1, numFolders);
all_selectivity = cell(1, numFolders);
all_stability = cell(1, numFolders);

% iterate over each folder in parallel
for k = 1:numFolders
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

    [accLengths, accSyns, accDens, tot_tree_length_time, dend_add_time, dend_remove_time, connect_syn_time, syn_add_time, syn_remove_time, sel, stab] = process_simulations_moving_syn(load_dir_str, REPS, N, T);

    % Store the results in the cell arrays
    all_accLengths{k} = mean(accLengths, 1);
    all_accSyns{k} = mean(accSyns, 1);
    all_accDens{k} = mean(accDens, 1);
    all_selectivity{k} = mean(sel, 1);
    all_stability{k} = mean(stab, 1);
    all_tot_tree_length_time{k} = reshape(mean(tot_tree_length_time, [1,2]), 1, []);
    all_connect_syn_time{k} = reshape(mean(connect_syn_time, [1,2]), 1, []);
    all_dend_add_time{k} = reshape(mean(dend_add_time, [1,2]), 1, []);
    all_dend_remove_time{k} = reshape(mean(dend_remove_time, [1,2]), 1, []);
    all_syn_add_time{k} = reshape(mean(syn_add_time, [1,2]), 1, []);
    all_syn_remove_time{k} = reshape(mean(syn_remove_time, [1,2]), 1, []);

    fprintf('folder %i out of %i done.', k, numFolders)
end

% Close parallel pool
delete(gcp('nocreate'));

% Convert cell arrays to matrices
all_accLengths = cell2mat(all_accLengths');
all_accSyns = cell2mat(all_accSyns');
all_accDens = cell2mat(all_accDens');
all_selectivity = cell2mat(all_selectivity');
all_stability = cell2mat(all_stability');
all_tot_tree_length_time = cell2mat(all_tot_tree_length_time');
all_connect_syn_time = cell2mat(all_connect_syn_time');
all_dend_add_time = cell2mat(all_dend_add_time');
all_dend_remove_time = cell2mat(all_dend_remove_time');
all_syn_add_time = cell2mat(all_syn_add_time');
all_syn_remove_time = cell2mat(all_syn_remove_time');

save([save_dir_str, 'all_data.mat'], 'folder_str', 'all_accLengths', 'all_accSyns', 'all_accDens', 'all_selectivity', 'all_stability', 'all_tot_tree_length_time', 'all_connect_syn_time', 'all_dend_add_time', 'all_dend_remove_time', 'all_syn_add_time', 'all_syn_remove_time');

% % Plotting
% % Define the colormap
% numColors = length(folder_str);
% colors = winter(numColors); % or you can use any other colormap like 'jet', 'hsv', etc.
% 
% % Averages
% figure
% subplot(1,5,1);
% hold on
% for i = 1:numFolders
%     plot(all_accLengths(i,:), 'Color', colors(i,:))
% end
% axis square
% % xlim([0 , 800])
% ylim([0 , 1000])
% % xticks([0 , 800])
% yticks([0 , 1000])
% xlabel('time')
% ylabel('length')
% legend(folder_str, 'Interpreter', 'none')
% 
% subplot(1,5,2);
% hold on
% for i = 1:numFolders
%     plot(all_accSyns(i,:), 'Color', colors(i,:))
% end
% axis square
% % xlim([0 , 800])
% ylim([0 , 120])
% % xticks([0 , 800])
% yticks([0 , 120])
% xlabel('time')
% ylabel('synapses')
% legend(folder_str, 'Interpreter', 'none')
% 
% subplot(1,5,3); 
% hold on
% for i = 1:numFolders
%     plot(all_accDens(i,:), 'Color', colors(i,:))
% end
% axis square
% % xlim([0 , 800])
% ylim([0 , 0.3])
% % xticks([0 , 800])
% yticks([0 , 0.3])
% xlabel('time')
% ylabel('density')
% legend(folder_str, 'Interpreter', 'none')
% 
% subplot(1,5,4); 
% hold on
% for i = 1:numFolders
%     plot(all_selectivity(i,:), 'Color', colors(i,:))
% end
% yline(0.2, '--')
% axis square
% % xlim([0 , 800])
% ylim([0 , 1])
% % xticks([0 , 800])
% yticks([0 , 1])
% xlabel('time')
% ylabel('selectivity')
% legend(folder_str, 'Interpreter', 'none')
% 
% subplot(1,5,5); 
% hold on
% for i = 1:numFolders
%     plot(all_stability(i,:), 'Color', colors(i,:))
% end
% axis square
% % xlim([0 , 800])
% ylim([0 , 1])
% % xticks([0 , 800])
% yticks([0 , 1])
% xlabel('time')
% ylabel('stability')
% legend(folder_str, 'Interpreter', 'none')
% 
% savefig([save_dir_str, 'combined_plots.fig'])
% 
% % Dendrite and Synapse Changes
% figure
% % tree length
% subplot(2,2,1); hold on;
% title('Dendritic tree length')
% for i = 1:numFolders
%     plot(all_tot_tree_length_time(i,:), 'DisplayName', folder_str{i})
% end
% ylabel('dendritic tree length')
% xlabel('time')
% legend show
% 
% % dendrites added/removed
% subplot(2,2,2); hold on;
% title('Dendrites added/removed')
% for i = 1:numFolders
%     plot(all_dend_add_time(i,:), 'Color' , [0 1 0])
%     plot(all_dend_remove_time(i,:), 'Color' , [1 0 0])
% end
% ylabel('change of dendrites')
% xlabel('time')
% 
% % total connections/synapses
% subplot(2,2,3); hold on;
% title('Total synapses')
% for i = 1:numFolders
%     plot(all_connect_syn_time(i,:), 'DisplayName', folder_str{i})
% end
% ylabel('number of synapses')
% xlabel('time')
% legend show
% 
% % change in synapses
% subplot(2,2,4); hold on;
% title('Synapses added/removed')
% for i = 1:numFolders
%     plot(all_syn_add_time(i,:), 'Color' , [0 1 0])
%     plot(all_syn_remove_time(i,:), 'Color' , [1 0 0])
% end
% ylabel('change in number of synapses')
% xlabel('time')
% 
% savefig([save_dir_str, 'combined_syn_dend_changes.fig'])
