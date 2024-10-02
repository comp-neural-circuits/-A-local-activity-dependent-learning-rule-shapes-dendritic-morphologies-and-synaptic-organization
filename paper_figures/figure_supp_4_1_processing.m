%% setting up
clear
clc
close all

addpath('../helpers')

% Here load and save directory are the same. If needed this can be changed.
% % save_dir_str = 'Videos and images/figure_supp_4_1/within/';
% save_dir_str = 'Videos and images/figure_supp_4_1/across/';
% save_dir_str = 'Videos and images/figure_supp_4_1/within_across_combined/';
save_dir_str = 'Videos and images/figure_supp_4_2/moving_synapses_final/';

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

n_LT = 6-1;
n_D = 3;

% Plotting
% Define the colormap
numColors = length(folder_str);
colors = winter(n_D); % or you can use any other colormap like 'jet', 'hsv', etc.
% colors = flipud(colors);

% Averages
figure

for x = 0:n_LT
    subplot(7,5,1+(x*5));
    hold on
    for i = 1:n_D
        plot(all_accLengths(i+x*n_D,:), 'Color', colors(i,:))
    end
    axis square
    % xlim([0 , 800])
    ylim([0 , 1000])
    % xticks([0 , 800])
    yticks([0 , 1000])
    xlabel('time')
    ylabel('length')
    legend(sorted_folder_str((1+x*n_D):(n_D+x*n_D)), 'Interpreter', 'none')
    
    subplot(7,5,2+(x*5));
    hold on
    for i = 1:n_D
        plot(all_accSyns(i+x*n_D,:), 'Color', colors(i,:))
    end
    axis square
    % xlim([0 , 800])
    ylim([0 , 120])
    % xticks([0 , 800])
    yticks([0 , 120])
    xlabel('time')
    ylabel('synapses')
    % legend(folder_str, 'Interpreter', 'none')
    
    subplot(7,5,3+(x*5)); 
    hold on
    for i = 1:n_D
        plot(all_accDens(i+x*n_D,:), 'Color', colors(i,:))
    end
    axis square
    % xlim([0 , 800])
    ylim([0 , 0.3])
    % xticks([0 , 800])
    yticks([0 , 0.3])
    xlabel('time')
    ylabel('density')
    % legend(folder_str, 'Interpreter', 'none')
    
    subplot(7,5,4+(x*5)); 
    hold on
    for i = 1:n_D
        plot(all_selectivity(i+x*n_D,:), 'Color', colors(i,:))
    end
    yline(0.2, '--')
    axis square
    % xlim([0 , 800])
    ylim([0 , 1])
    % xticks([0 , 800])
    yticks([0 , 1])
    xlabel('time')
    ylabel('selectivity')
    % legend(folder_str, 'Interpreter', 'none')
    
    subplot(7,5,5+(x*5)); 
    hold on
    for i = 1:n_D
        plot(all_stability(i+x*n_D,:), 'Color', colors(i,:))
    end
    axis square
    % xlim([0 , 800])
    ylim([0 , 1])
    % xticks([0 , 800])
    yticks([0 , 1])
    xlabel('time')
    ylabel('stability')
    % legend(folder_str, 'Interpreter', 'none')
    
    savefig([save_dir_str, 'pp_combined_plots.fig'])
end

figure
for x = 0:n_LT
    % Dendrite and Synapse Changes
    % tree length
    subplot(7,4,1+(x*4)); hold on;
    title('Dendritic tree length')
    for i = (1+x*n_D):(n_D+x*n_D)
        tot_tree_length_time_bin = movmean(reshape(all_tot_tree_length_time(i,:),1,[]),16,"Endpoints","discard");
        plot(tot_tree_length_time_bin, 'DisplayName', sorted_folder_str{i})
        % plot(all_tot_tree_length_time(i,:), 'DisplayName', folder_str{i})
    end
    axis square
    ylabel('dendritic tree length')
    xlabel('time')
    legend show
    
    % dendrites added/removed
    subplot(7,4,2+(x*4)); hold on;
    title('Dendrites added/removed')
    
    % for i = [1, numFolders]
    for i = (1+x*n_D):(n_D+x*n_D)
        dend_add_time_bin= movsum(reshape(all_dend_add_time(i,:),1,[]),16,"Endpoints","discard");
        dend_remove_time_bin = movsum(reshape(all_dend_remove_time(i,:),1,[]),16,"Endpoints","discard");
        plot(dend_add_time_bin, 'Color' , [0 1 0], 'DisplayName', sorted_folder_str{i})
        plot(dend_remove_time_bin, 'Color' , [1 0 0], 'DisplayName', sorted_folder_str{i})
        % plot(all_dend_add_time(i,:), 'Color' , [0 1 0])
        % plot(all_dend_remove_time(i,:), 'Color' , [1 0 0])
    end
    axis square
    ylabel('change of dendrites')
    xlabel('time')
    legend show
    
    % total connections/synapses
    subplot(7,4,3+(x*4)); hold on;
    title('Total synapses')
    for i = (1+x*n_D):(n_D+x*n_D)
        connect_syn_time_bin = movmean(reshape(all_connect_syn_time(i,:),1,[]),16,"Endpoints","discard");
        plot(connect_syn_time_bin, 'DisplayName', sorted_folder_str{i})
        % plot(all_connect_syn_time(i,:), 'DisplayName', folder_str{i})
    end
    axis square
    ylabel('number of synapses')
    xlabel('time')
    % legend show
    ylim([0,120])
    
    % change in synapses
    subplot(7,4,4+(x*4)); hold on;
    title('Synapses added/removed')
    
    % for i = [1, numFolders]
    for i = (1+x*n_D):(n_D+x*n_D)
        syn_add_time_bin = movsum(reshape(all_syn_add_time(i,:),1,[]),16,"Endpoints","discard");
        syn_remove_time_bin = movsum(reshape(all_syn_remove_time(i,:),1,[]),16,"Endpoints","discard");
        plot(syn_add_time_bin, 'Color' , [0 1 0])
        plot(syn_remove_time_bin, 'Color' , [1 0 0])
        % plot(all_syn_add_time(i,:), 'Color' , [0 1 0])
        % plot(all_syn_remove_time(i,:), 'Color' , [1 0 0])
    end
    axis square
    ylabel('change in number of synapses')
    xlabel('time')
    ylim([0,15])
    
    savefig([save_dir_str, 'pp_combined_syn_dend_changes.fig'])
end