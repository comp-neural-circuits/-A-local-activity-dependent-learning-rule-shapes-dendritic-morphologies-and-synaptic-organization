%% setting up
clear
clc
close all

addpath('../helpers')

% save_dir_str = 'Videos and images/figure_supp_4_1/within2/';
% save_dir_str = 'Videos and images/figure_supp_4_1/across2/';
save_dir_str = 'Videos and images/figure_supp_4_1/within_across_combined4/';
% save_dir_str = 'Videos and images/figure_supp_4_2/moving_synapses_combined/';

load([save_dir_str, 'all_data.mat']);

% all the simulation folders that are getting visualized
% isFolder = [folder_str.isdir]; % Extract only the folders
% folders = folder_str(isFolder);
% folders = folders(~ismember({folders.name}, {'.', '..'}));  % Remove the '.' and '..' folders
% folder_str = {folders.name};   % Get the names of the folders
numFolders = length(folder_str);

% Plotting
% Define the colormap
numColors = length(folder_str);
colors = winter(7); % or you can use any other colormap like 'jet', 'hsv', etc.
% colors = flipud(colors);

% Averages
figure

for x = 0:10
    subplot(11,5,1+(x*5));
    hold on
    for i = 1:7
        plot(all_accLengths(i+x*7,:), 'Color', colors(i,:))
    end
    axis square
    % xlim([0 , 800])
    ylim([0 , 1000])
    % xticks([0 , 800])
    yticks([0 , 1000])
    xlabel('time')
    ylabel('length')
    legend(folder_str((1+x*7):(7+x*7)), 'Interpreter', 'none')
    
    subplot(11,5,2+(x*5));
    hold on
    for i = 1:7
        plot(all_accSyns(i+x*7,:), 'Color', colors(i,:))
    end
    axis square
    % xlim([0 , 800])
    ylim([0 , 120])
    % xticks([0 , 800])
    yticks([0 , 120])
    xlabel('time')
    ylabel('synapses')
    % legend(folder_str, 'Interpreter', 'none')
    
    subplot(11,5,3+(x*5)); 
    hold on
    for i = 1:7
        plot(all_accDens(i+x*7,:), 'Color', colors(i,:))
    end
    axis square
    % xlim([0 , 800])
    ylim([0 , 0.3])
    % xticks([0 , 800])
    yticks([0 , 0.3])
    xlabel('time')
    ylabel('density')
    % legend(folder_str, 'Interpreter', 'none')
    
    subplot(11,5,4+(x*5)); 
    hold on
    for i = 1:7
        plot(all_selectivity(i+x*7,:), 'Color', colors(i,:))
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
    
    subplot(11,5,5+(x*5)); 
    hold on
    for i = 1:7
        plot(all_stability(i+x*7,:), 'Color', colors(i,:))
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
for x = 0:10
    % Dendrite and Synapse Changes
    % tree length
    subplot(11,4,1+(x*4)); hold on;
    title('Dendritic tree length')
    for i = (1+x*7):(7+x*7)
        tot_tree_length_time_bin = movmean(reshape(all_tot_tree_length_time(i,:),1,[]),16,"Endpoints","discard");
        plot(tot_tree_length_time_bin, 'DisplayName', folder_str{i})
        % plot(all_tot_tree_length_time(i,:), 'DisplayName', folder_str{i})
    end
    axis square
    ylabel('dendritic tree length')
    xlabel('time')
    legend show
    
    % dendrites added/removed
    subplot(11,4,2+(x*4)); hold on;
    title('Dendrites added/removed')
    
    % for i = [1, numFolders]
    for i = (1+x*7):(7+x*7)
        dend_add_time_bin= movsum(reshape(all_dend_add_time(i,:),1,[]),16,"Endpoints","discard");
        dend_remove_time_bin = movsum(reshape(all_dend_remove_time(i,:),1,[]),16,"Endpoints","discard");
        plot(dend_add_time_bin, 'Color' , [0 1 0], 'DisplayName', folder_str{i})
        plot(dend_remove_time_bin, 'Color' , [1 0 0], 'DisplayName', folder_str{i})
        % plot(all_dend_add_time(i,:), 'Color' , [0 1 0])
        % plot(all_dend_remove_time(i,:), 'Color' , [1 0 0])
    end
    axis square
    ylabel('change of dendrites')
    xlabel('time')
    legend show
    
    % total connections/synapses
    subplot(11,4,3+(x*4)); hold on;
    title('Total synapses')
    for i = (1+x*7):(7+x*7)
        connect_syn_time_bin = movmean(reshape(all_connect_syn_time(i,:),1,[]),16,"Endpoints","discard");
        plot(connect_syn_time_bin, 'DisplayName', folder_str{i})
        % plot(all_connect_syn_time(i,:), 'DisplayName', folder_str{i})
    end
    axis square
    ylabel('number of synapses')
    xlabel('time')
    % legend show
    
    % change in synapses
    subplot(11,4,4+(x*4)); hold on;
    title('Synapses added/removed')
    
    % for i = [1, numFolders]
    for i = (1+x*7):(7+x*7)
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