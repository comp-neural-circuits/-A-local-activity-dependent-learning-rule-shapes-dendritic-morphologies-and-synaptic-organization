%% setting up
clear
clc
close all

addpath('../helpers')

save_dir_str = 'Videos and images/figure_5/within_finalcheck2/';
% save_dir_str = 'Videos and images/figure_5/across_final/';
% save_dir_str = 'Videos and images/figure_5/within_across_combined_final/';
% save_dir_str = 'Videos and images/figure_supp_4_1/moving_synapses_combined4/';
% save_dir_str = 'Videos and images/figure_supp_4_1/moving_synapses_final/';

load([save_dir_str, 'all_data.mat']);

% all the simulation folders that are getting visualized
% isFolder = [folder_str.isdir]; % Extract only the folders
% folders = folder_str(isFolder);
% folders = folders(~ismember({folders.name}, {'.', '..'}));  % Remove the '.' and '..' folders
% folder_str = {folders.name};   % Get the names of the folders
numFolders = length(folder_str);
% Extract relevant parts from folder names and sort them
folder_str_parts = cellfun(@(s) strsplit(s, '_'), folder_str, 'UniformOutput', false);

% Convert the parts to character arrays for sorting
relevant_parts = cellfun(@(c) strjoin(c(end-3:end), '_'), folder_str_parts, 'UniformOutput', false);

% Sort the relevant parts and get the indices
[~, sorted_indices] = sort(relevant_parts);

% Reorder the data based on sorted indices
sorted_folder_str = relevant_parts(sorted_indices);
all_accLengths = all_accLengths(sorted_indices, :);
all_accSyns = all_accSyns(sorted_indices, :);
all_accDens = all_accDens(sorted_indices, :);
all_selectivity = all_selectivity(sorted_indices, :);
all_stability = all_stability(sorted_indices, :);
all_tot_tree_length_time = all_tot_tree_length_time(sorted_indices, :);
all_dend_add_time = all_dend_add_time(sorted_indices, :);
all_dend_remove_time = all_dend_remove_time(sorted_indices, :);
all_connect_syn_time = all_connect_syn_time(sorted_indices, :);
all_syn_add_time = all_syn_add_time(sorted_indices, :);
all_syn_remove_time = all_syn_remove_time(sorted_indices, :);

% Plotting
% Define the colormap
numColors = length(folder_str);
colors = winter(numColors); % or you can use any other colormap like 'jet', 'hsv', etc.
colors = flipud(colors);

% Averages
fig1 = figure;
subplot(1,5,1);
hold on
for i = 1:numFolders
    plot(all_accLengths(i,:), 'Color', colors(i,:))
end
axis square
% xlim([0 , 800])
ylim([0 , 1000])
% xticks([0 , 800])
yticks([0 , 1000])
xlabel('time')
ylabel('length')
legend(sorted_folder_str, 'Interpreter', 'none')

subplot(1,5,2);
hold on
for i = 1:numFolders
    plot(all_accSyns(i,:), 'Color', colors(i,:))
end
axis square
% xlim([0 , 800])
ylim([0 , 120])
% xticks([0 , 800])
yticks([0 , 120])
xlabel('time')
ylabel('synapses')
% legend(folder_str, 'Interpreter', 'none')

subplot(1,5,3); 
hold on
for i = 1:numFolders
    plot(all_accDens(i,:), 'Color', colors(i,:))
end
axis square
% xlim([0 , 800])
ylim([0 , 0.3])
% xticks([0 , 800])
yticks([0 , 0.3])
xlabel('time')
ylabel('density')
% legend(folder_str, 'Interpreter', 'none')

subplot(1,5,4); 
hold on
for i = 1:numFolders
    plot(all_selectivity(i,:), 'Color', colors(i,:))
end
yline(0.2, '--')
axis square
% xlim([0 , 800])
ylim([0 , 1])
% xticks([0 , 800])
yticks([0 , 1])
xlabel('time')
ylabel('selectivity')
% legend(sorted_folder_str, 'Interpreter', 'none')

subplot(1,5,5); 
hold on
for i = 1:numFolders
    plot(all_stability(i,:), 'Color', colors(i,:))
end
axis square
% xlim([0 , 800])
ylim([0 , 1])
% xticks([0 , 800])
yticks([0 , 1])
xlabel('time')
ylabel('stability')
% legend(folder_str, 'Interpreter', 'none')

savefig([save_dir_str, 'pp_combined_plots2.fig'])
% saveas(fig1, [save_dir_str, 'pp_combined_plots.svg'])

%
% Dendrite and Synapse Changes
fig2 = figure;
% tree length
subplot(2,2,1); hold on;
title('Dendritic tree length')
for i = 1:numFolders
    tot_tree_length_time_bin = movmean(reshape(all_tot_tree_length_time(i,:),1,[]),800/72,"Endpoints","discard");
    plot(tot_tree_length_time_bin)
    % plot(all_tot_tree_length_time(i,:), 'DisplayName', folder_str{i})
end
legend(sorted_folder_str, 'Interpreter', 'none')
axis square
ylabel('dendritic tree length')
xlabel('time')
legend show

% dendrites added/removed
subplot(2,2,2); hold on;
title('Dendrites added/removed')

% for i = [1, numFolders]
for i = 1:numFolders
    dend_add_time_bin= movsum(reshape(all_dend_add_time(i,:),1,[]),800/72,"Endpoints","discard");
    dend_remove_time_bin = movsum(reshape(all_dend_remove_time(i,:),1,[]),800/72,"Endpoints","discard");
    plot(dend_add_time_bin, 'Color' , [0 1 0], 'DisplayName', sorted_folder_str{i})
    plot(dend_remove_time_bin, 'Color' , [1 0 0], 'DisplayName', sorted_folder_str{i})
    % plot(all_dend_add_time(i,:), 'Color' , [0 1 0])
    % plot(all_dend_remove_time(i,:), 'Color' , [1 0 0])
end
axis square
ylabel('change of dendrites')
xlabel('time')
ylim([0,100])
legend show

% total connections/synapses
subplot(2,2,3); hold on;
title('Total synapses')
for i = 1:numFolders
    connect_syn_time_bin = movmean(reshape(all_connect_syn_time(i,:),1,[]),800/72,"Endpoints","discard");
    plot(connect_syn_time_bin)
    % plot(all_connect_syn_time(i,:), 'DisplayName', folder_str{i})
end
legend(sorted_folder_str, 'Interpreter', 'none')
axis square
ylabel('number of synapses')
xlabel('time')
% legend show

% change in synapses
subplot(2,2,4); hold on;
title('Synapses added/removed')

% for i = [1, numFolders]
for i = 1:numFolders
    syn_add_time_bin = movsum(reshape(all_syn_add_time(i,:),1,[]),800/72,"Endpoints","discard");
    syn_remove_time_bin = movsum(reshape(all_syn_remove_time(i,:),1,[]),800/72,"Endpoints","discard");
    plot(syn_add_time_bin, 'Color' , [0 1 0])
    plot(syn_remove_time_bin, 'Color' , [1 0 0])
    % plot(all_syn_add_time(i,:), 'Color' , [0 1 0])
    % plot(all_syn_remove_time(i,:), 'Color' , [1 0 0])
end
axis square
ylabel('change in number of synapses')
xlabel('time')
ylim([0,10])

savefig([save_dir_str, 'pp_combined_syn_dend_changes2.fig'])
% saveas(fig2, [save_dir_str, 'pp_combined_syn_dend_changes.svg'])

% Selectivity groups
fig3 = figure;

hold on
% for i = 1:numFolders
for i = 3
    disp(sorted_folder_str(i))
    for gid = 1:5
        plot(all_selectivity_groups(i,:,gid))
    end
end
yline(0.2, '--')
axis square
% xlim([0 , 800])
ylim([0 , 1])
% xticks([0 , 800])
yticks([0 , 1])
xlabel('time')
ylabel('selectivity')
% legend

savefig([save_dir_str, 'pp_selectivity_plots.fig'])
% % saveas(fig1, [save_dir_str, 'pp_combined_plots.svg'])
