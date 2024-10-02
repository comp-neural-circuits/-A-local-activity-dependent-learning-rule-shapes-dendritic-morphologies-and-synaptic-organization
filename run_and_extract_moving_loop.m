clear
close all
clc

% this script runs simulations and extracts data so one can recreate panels
% 2bc and 3bc (aka the baseline) from the paper, using the script "plot_data_single"

addpath(pwd)
addpath('functions_for_analysis')
addpath('helpers')
addpath('modules')
addpath('modules/gaimc')

P = 185; N = 9; T = 40000;

rng(1)

parpool(14);

REPS = 32;

%% regular run
str_now = datetime('now', 'Format', 'yyyy-MM-dd-HH-mm-ss');
% Range of timescales under which synapses move
lifetime_steps = [20, 50, 200].*50;
% Sets the dimensions of the distance matrix, e.g. 9 -> 9x9, where synapses
% would move 4 tiles away (so tiles = (d-1)/2
moving_distance = [3, 25, 101];
% moving_distance = [3, 5, 9, 25, 51, 101, 201];

for distance = moving_distance
    for lifetime = lifetime_steps
        directory_name = sprintf('sims/sims_%s_%i_moving_LT_%05i_D_%03i', str_now, T, lifetime, distance);
    
        [~, ~, ~] = mkdir(directory_name);
    
        % creating inputs for the movement
        lifetime_sigma = 1;
        
        % the mean/median of the lognormal distribution used for synapse lifetimes
        mu_lognorm = log(lifetime);
        % mu_lognorm = log(lifetime)-(lifetime_sigma^2)/2;
        % long = log(1000)-(lifetime_sigma^2)/2;
        
        % these next entries govern synapse movement, they should be 2 by 2 double
        % of uneven dimension so that conv2 and customrandomdraw can be applied
        % easily
        % small = [0 1 0; 1 0 1; 0 1 0]; % this will make the synapse move only one step each time
        
        large_l = distance;
        large = zeros(large_l); % this will end up being a ring around the synapse forcing it to move somewhat far
        
        for j = 1:large_l
            for k = 1:large_l
                if large_l/4 < sqrt(((j-1/2) - large_l/2)^2 + ((k-1/2) - large_l/2)^2) && sqrt(((j-1/2) - large_l/2)^2 + ((k-1/2) - large_l/2)^2) < large_l/2
                    large(j,k) = 1;
                end
            end
        end
    
        parfor xx = 1:REPS
            fprintf('Get all parameters for sim %i with lifetime %i and distance %i.\n', xx, lifetime, distance)
            [prms , mats] = get_params_2D_fixed(T,N)
            
            sigDiss = 0.75; Dissum = 0.5;
            [XX  ,YY] = meshgrid(linspace(-3 , 3 , 20) , linspace(-3 , 3 , 20));
            DiffusionMat = reshape(mvnpdf([XX(:)  ,YY(:)],[0 , 0],sigDiss*eye(2)),[20,20]);
            mats.DiffusionMat = Dissum*DiffusionMat./sum(DiffusionMat(:));
            
            prms.lifetime_sigma = lifetime_sigma;
            % prms.lifescale = lifescale;
            prms.lifescale = 0;
            prms.syndeath = 0;
            
            prms.lifetime_mu = mu_lognorm;
            mats.move = large;
            
            fprintf('Starting sim %i with lifetime %i and distance %i.\n', xx, lifetime, distance)
            % [SimVid, SynVid, TransVid, GroupsVid] = DenGrowth_2D_moving_syns_fixed(prms , mats);
            [SimVid, SynVid, GroupsVid] = DenGrowth_2D_moving_syns_fixed(prms , mats);
            
            % NOTE: parsave is not a native function to matlab and it must be modified
            % each time you change the variables to be saved
            % parsave_moving_syns(fullfile(directory_name, ['sim_', num2str(xx)]), SimVid, SynVid, TransVid, GroupsVid, mats, prms)
            parsave_moving_syns(fullfile(directory_name, ['sim_', num2str(xx)]), SimVid, SynVid, GroupsVid, mats, prms)
        
            fprintf('Finished sim %i with lifetime %i and distance %i.\n', xx, lifetime, distance)
        end
    
        fprintf('Finished simulating batch for lifetime %i and distance %i.\n', lifetime, distance)
    
        %%
        fprintf('Now extracting data for lifetime %i and distance %i.\n', lifetime, distance)
    
        cd(directory_name)
    
        % you have to tell this next script what the meta parameters are:
        REPS_global = REPS; % number of different global iterations (in particular number of different sets of activity to be generated)
        Tsim = T / 50; % size of the simulation video
        % N = number of neurons
    
        extract_data_classical;
    
        cd ../..
    end
end

delete(gcp('nocreate'));

fprintf('Done with all simulations and data extraction\n')