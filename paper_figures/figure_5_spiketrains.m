clc;
close all;

% % within
dir_str = '../sims/5_within_group_correlation_finalcheck/';
folder_str = 'sims_2024-09-16-11-52-47_40000_ingroup_incor_0.60/';
% % across
% dir_str = '../../Lucas_version/faster/sims/5_across_group_correlation_final/';
% folder_str = 'sims_2024-06-14-09-25-44_40000_cross_paircorr_0.20/';
% % combined
% dir_str = '../../Lucas_version/faster/sims/5_within_across_correlation_combined_final/';
% folder_str = 'sims_2024-06-17-12-44-09_40000_ingroup_incor_0.20_cross_paircorr_0.20/';
mats = load([dir_str, folder_str, 'sim_1/mats.mat']).mats;

spiketrains = mats.S;

group_IDs = mats.GroupID;

% Sort synapses by group IDs
[sorted_group_IDs, sort_idx] = sort(group_IDs);
% Reorder the spiketrains according to sorted group IDs
x = 35000;
spiketrains = spiketrains(sort_idx, 1+x:500+x);
% spiketrains = spiketrains(1:600,40:120);

% Synapses to highlight
% selected_synapses = [5, 10, 15, 20, 35, 40];
selected_synapses = [];
% selected_synapses = ceil(linspace(10,500,10));

% spiketrains is a logical matrix of size [num_synapses x num_timesteps]
% selected_synapses is a vector containing the indices of synapses to highlight

[num_synapses, num_timesteps] = size(spiketrains);

% Create a matrix to store the spiketrain image
spiketrain_image = zeros(num_synapses, num_timesteps, 3); % RGB image

% % Fill the matrix with the spiketrain data
% % Plot all spiketrains in black
% spiketrain_image(:,:,1) = spiketrains * 255; % Red channel
% spiketrain_image(:,:,2) = spiketrains * 255; % Green channel
% spiketrain_image(:,:,3) = spiketrains * 255; % Blue channel

% Highlight selected spiketrains with different colors
% group_colors = lines(10); % Use MATLAB's lines colormap for distinct colors
% group_colors = {'#ceb969', '#7396ce', '#ce8373', '#8fcea5', '#a477b4'};
group_colors = {'#314696', '#8c6931', '#317c8c', '#70315a', '#5b884b'}; % inverted
% Count the number of spikes at each time point (for all the groups)
global_spike_count = sum(spiketrains, 1);

% Fill the matrix with the spiketrain data
for syn = 1:num_synapses
    group_id = sorted_group_IDs(syn); % Get the group ID of the current synapse
    color = hex2rgb(group_colors(group_id)); % Get the color corresponding to the group ID

    % Count the number of spikes at each time point (for the same group)
    local_spike_count = sum(spiketrains(sorted_group_IDs == group_id,:), 1);

    spike_times = find(spiketrains(syn, :)); % Find the spike times for the current synapse
    for t = spike_times(spike_times > 2 & spike_times < 498)

        if global_spike_count(t) >= 1000
            spiketrain_image(syn, t-2:t+2, :) = repmat([0, 255, 255], 5,1); % Assign red color to the spike
        elseif local_spike_count(t) >= 200
            spiketrain_image(syn, t-2:t+2, :) = repmat(color * 255, 5,1); % Assign the group color to the spike
        else
            spiketrain_image(syn, t-2:t+2, :) = repmat([255, 255, 255], 5,1); % Assign black color to the spike
        end
    end
end

% % Highlight differences and similarities
% for ii = 1:length(selected_synapses)
%     syn1 = selected_synapses(ii);
%     % Logical matrix for selected spiketrains
%     selected_spikes = spiketrains(syn1, :);
% 
%     % Plot different spikes in red
%     for i = 1:length(selected_synapses)
%         if i ~= ii
%             syn2 = selected_synapses(i);
%             other_spikes = spiketrains(syn2,:);
%             different_spikes = (selected_spikes ~= other_spikes) & selected_spikes > 0;
%             spiketrain_image(syn1, find(different_spikes), :) = repmat(reshape([0, 255, 255], 1, 1, 3), sum(different_spikes), 1); % Red
%         end
%     end
% 
%     % Plot same spikes in green
%     for i = 1:length(selected_synapses)
%         if i ~= ii
%             syn2 = selected_synapses(i);
%             other_spikes = spiketrains(syn2,:);
%             same_spikes = (selected_spikes == other_spikes) & (selected_spikes + other_spikes) ~= 0;
%             spiketrain_image(syn2, find(same_spikes), :) = repmat(reshape([255, 0, 255], 1, 1, 3), sum(same_spikes), 1); % Green
%         end
%     end
% end

% Display the spiketrain image
figure;
image(uint8(255 - spiketrain_image));
xlabel('Time');
ylabel('Synapse');
title('Spiketrain Image with Differences Highlighted');
axis xy;
