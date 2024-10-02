%% setting up
clear
clc
close all

addpath('../helpers')

numD = 4;

% Here load and save directory are the same. If needed this can be changed.
% save_dir_str = 'Videos and images/figure_supp_4_1/within2/';
% save_dir_str = 'Videos and images/figure_supp_4_1/across2/';
% save_dir_str = 'Videos and images/figure_supp_4_1/within_across_combined4/';
% save_dir_str = 'Videos and images/figure_supp_4_2/moving_synapses_combined/';
save_dir_str = 'Videos and images/figure_supp_4_2/moving_synapses_gamma_100/';
load([save_dir_str, 'all_data.mat']);

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
colors = winter(7); % or you can use any other colormap like 'jet', 'hsv', etc.
% colors = flipud(colors);

% Averages
figure

for x = 0:4
    subplot(7,5,1+(x*5));
    hold on
    for i = 1:numD
        plot(all_accLengths(i+x*numD,:), 'Color', colors(i,:))
    end
    axis square
    % xlim([0 , 800])
    ylim([0 , 1000])
    % xticks([0 , 800])
    yticks([0 , 1000])
    xlabel('time')
    ylabel('length')
    if x < 2
        legend(sorted_folder_str((1+x*numD):(numD+x*numD)), 'Interpreter', 'none')
    end
    subplot(7,5,2+(x*5));
    hold on
    for i = 1:numD
        plot(all_accSyns(i+x*numD,:), 'Color', colors(i,:))
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
    for i = 1:numD
        plot(all_accDens(i+x*numD,:), 'Color', colors(i,:))
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
    for i = 1:numD
        plot(all_selectivity(i+x*numD,:), 'Color', colors(i,:))
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
    for i = 1:numD
        plot(all_stability(i+x*numD,:), 'Color', colors(i,:))
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
for x = 0:4
    % Dendrite and Synapse Changes
    % tree length
    subplot(7,4,1+(x*4)); hold on;
    title('Dendritic tree length')
    for i = (1+x*numD):(numD+x*numD)
        tot_tree_length_time_bin = movmean(reshape(all_tot_tree_length_time(i,:),1,[]),16,"Endpoints","discard");
        plot(tot_tree_length_time_bin)
        % plot(all_tot_tree_length_time(i,:), 'DisplayName', folder_str{i})
    end
    axis square
    ylabel('dendritic tree length')
    xlabel('time')
    if x < 2
        legend(sorted_folder_str((1+x*numD):(numD+x*numD)), 'Interpreter', 'none')
    end
    % dendrites added/removed
    subplot(7,4,2+(x*4)); hold on;
    title('Dendrites added/removed')
    
    legend_entries = [];
    % for i = [1, numFolders]
    for i = (1+x*numD):(numD+x*numD)
        dend_add_time_bin= movsum(reshape(all_dend_add_time(i,:),1,[]),16,"Endpoints","discard");
        dend_remove_time_bin = movsum(reshape(all_dend_remove_time(i,:),1,[]),16,"Endpoints","discard");
        plot(dend_add_time_bin, 'Color' , [0 1 0], 'DisplayName', sorted_folder_str{i})
        plot(dend_remove_time_bin, 'Color' , [1 0 0], 'DisplayName', sorted_folder_str{i})
        
        % Append the legend entry twice
        legend_entries = [legend_entries, {sorted_folder_str{i}, sorted_folder_str{i}}];
    end
    axis square
    ylabel('change of dendrites')
    xlabel('time')
    if x < 2
        legend(legend_entries, 'Interpreter', 'none')
    end
    % total connections/synapses
    subplot(7,4,3+(x*4)); hold on;
    title('Total synapses')
    for i = (1+x*numD):(numD+x*numD)
        connect_syn_time_bin = movmean(reshape(all_connect_syn_time(i,:),1,[]),16,"Endpoints","discard");
        plot(connect_syn_time_bin, 'DisplayName', sorted_folder_str{i})
        % plot(all_connect_syn_time(i,:), 'DisplayName', folder_str{i})
    end
    axis square
    ylabel('number of synapses')
    xlabel('time')
    % legend show
    
    % change in synapses
    subplot(7,4,4+(x*4)); hold on;
    title('Synapses added/removed')
    
    % for i = [1, numFolders]
    for i = (1+x*numD):(numD+x*numD)
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
    
    savefig([save_dir_str, 'pp_combined_syn_dend_changes.fig'])
end
