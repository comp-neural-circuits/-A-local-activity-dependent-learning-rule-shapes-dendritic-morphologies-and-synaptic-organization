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

parpool(32);

REPS = 32;

%% regular run
str_now = datetime('now', 'Format', 'yyyy-MM-dd-HH-mm-ss');
% Define the range of incor values
incor_values = 1:-0.4:0.2;
pairstrength_values = 0:0.1:0.2;

for incor = incor_values
    for pairstrength = pairstrength_values
        %% Create directory for current incor value
        directory_name = sprintf('sims/sims_%s_%i_ingroup_incor_%.2f_cross_paircorr_%.2f', str_now, T, incor, pairstrength);
    
        [~, ~, ~] = mkdir(directory_name);
    
        parfor xx = 1:REPS
            fprintf('Get all parameters for sim %i with incor %.2f_cross_paircorr_%.2f.\n', xx, incor, pairstrength)
            [prms , mats] = get_params_2D_fixed(T,N)
            
            sigDiss = 0.75; Dissum = 0.5;
            [XX  ,YY] = meshgrid(linspace(-3 , 3 , 20) , linspace(-3 , 3 , 20));
            DiffusionMat = reshape(mvnpdf([XX(:)  ,YY(:)],[0 , 0],sigDiss*eye(2)),[20,20]);
            mats.DiffusionMat = Dissum*DiffusionMat./sum(DiffusionMat(:));
                        
            synNum = 1500; ngroup = 5; mu = 0.0125;
            % npairs = 10; pairmax = 1;
            [mats.S,mats.GroupID] = correlated_discrete_input_noisy_final(synNum,ngroup,pairstrength,incor,T,mu);
            
            fprintf('Starting sim %i with incor %.2f_cross_paircorr_%.2f\n', xx, incor, pairstrength)
            SimVid = DenGrowth_2D_fixed(prms , mats);
            
            
            % NOTE: parsave is not a native function to matlab and it must be modified
            % each time you change the variables to be saved
            parsave(fullfile(directory_name, ['sim_', num2str(xx)]), SimVid, mats, prms)
        
            fprintf('Finished sim %i with incor %.2f_cross_paircorr_%.2f\n', xx, incor, pairstrength)
        end
    
        fprintf('Finished simulating batch for incor %.2f_cross_paircorr_%.2f\n', incor, pairstrength)
    
        %%
        fprintf('Now extracting data for incor %.2f_cross_paircorr_%.2f\n', incor, pairstrength)
    
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

