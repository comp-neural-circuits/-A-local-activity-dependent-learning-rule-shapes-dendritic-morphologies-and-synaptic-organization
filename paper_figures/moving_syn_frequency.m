clc
clear
close all

% % Parameters
% % mean_value = 50; % mean of the distribution
% median_value = 10000/(40000/72); % median of the distribution
% num_synapses = 1500; % number of synapses
% total_time = 72; % total simulation time
dt = 40000 / 72; % time interval for checking (1h)

% % Calculate mu and sigma for lognormal distribution
% mu = log(median_value);
% sigma = 1;

% % Generate lifetimes from lognormal distribution
% lifetimes = lognrnd(mu, sigma, num_synapses, 1);

dir_str = '../sims/4_2_moving_synapses_final/';
save_dir_str = 'Videos and images/figure_supp_4_2/moving_synapses_final/';
mkdir(save_dir_str)

% all the simulation folders that are getting visualized
folder_str = dir(dir_str);
isFolder = [folder_str.isdir]; % Extract only the folders
folders = folder_str(isFolder);
folders = folders(~ismember({folders.name}, {'.', '..'}));  % Remove the '.' and '..' folders
folder_str = {folders.name};   % Get the names of the folders

% Extract relevant parts from folder names and sort them
folder_str_parts = cellfun(@(s) strsplit(s, '_'), folder_str, 'UniformOutput', false);
% Convert the parts to character arrays for sorting
relevant_parts = cellfun(@(c) strjoin(c(end-3:end), '_'), folder_str_parts, 'UniformOutput', false);
% Sort the relevant parts and get the indices
[relevant_parts, sorted_indices] = sort(relevant_parts);
folder_str = folder_str(sorted_indices);

% Only every third folder (since rate of moving synapses should be the same
% for different distances)
n_D = 3;    % e.g. distances 3, 25 and 101
folder_str = folder_str(1:n_D:end);
% folder_str = folder_str(1+6:n_D:end-3);
relevant_parts = relevant_parts(1:n_D:end);
% relevant_parts = relevant_parts(1+6:n_D:end-3);

% Open parallel pool
parpool('local', 32);

% Preallocate results to avoid issues with parfor
numFolders = length(folder_str);
all_syn_moving_count = cell(1, numFolders);

% iterate over each folder in parallel
for k = 1:numFolders
    f_str = folder_str{k};
    load_dir_str = [dir_str, f_str];
    
    % % number of different global iterations (in particular number of different sets of activity to be generated)
    data_classical = load([load_dir_str, '/data/data_classical.mat']);
    REPS = data_classical.REPS_global;
    % 
    % % size of the simulation video
    T = data_classical.Tsim;
    % N = data_classical.N;
        
    SynVid = load([load_dir_str, '/sim_1/SynVid.mat']).SynVid;

    mean_syn_moving_counts = zeros(REPS, size(SynVid,3)-1);
    parfor i = 1:REPS
        SynVid = load([load_dir_str, '/sim_', num2str(i), '/SynVid.mat']).SynVid;
        
        % Initialize arrays to store results
        syn_moving_counts = zeros(size(SynVid,3)-1, 1);
        
        % Simulate the disappearance and reappearance
        for t = 2:1:size(SynVid,3)
            syn_moving_counts(t-1) = sum(SynVid(:,:,t) ~= SynVid(:,:,t-1), "all") / 2;
        end
        mean_syn_moving_counts(i,:) = syn_moving_counts;
    end
    mean_syn_moving_counts = mean(mean_syn_moving_counts,1);
    all_syn_moving_count{k} = movsum(mean_syn_moving_counts,dt,"Endpoints","discard");

    fprintf('\nfolder %i out of %i done.', k, numFolders)
end

% Plot the results
figure;
hold on;
for k = 1:numFolders
    plot(all_syn_moving_count{k}, 'DisplayName', relevant_parts{k});
end
axis square
legend(relevant_parts, 'Interpreter', 'none')
xlabel('Time');
ylabel('# of moving Synapses (per hour)');
legend show;
hold off;

savefig([save_dir_str, 'syn_move_rate.fig'])

fprintf('Succesfully plotted and saved results.')