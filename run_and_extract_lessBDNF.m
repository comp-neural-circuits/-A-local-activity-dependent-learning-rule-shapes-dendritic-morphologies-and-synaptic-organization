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

%% regular run
str_now = datetime('now', 'Format', 'yyyy-MM-dd-HH-mm-ss');
directory_name = sprintf('sims/sims_%s %i lessBDNF', str_now, T);

[~, ~, ~] = mkdir(directory_name);

parpool(32);
REPS = 32;
parfor xx = 1:REPS
    fprintf('Get all parameters for sim %i.\n', xx)
    [prms , mats] = get_params_2D_fixed(T,N)
    
    sigDiss = 0.75; Dissum = 0.5;
    [XX  ,YY] = meshgrid(linspace(-3 , 3 , 20) , linspace(-3 , 3 , 20));
    DiffusionMat = reshape(mvnpdf([XX(:)  ,YY(:)],[0 , 0],sigDiss*eye(2)),[20,20]);
    mats.DiffusionMat = Dissum*DiffusionMat./sum(DiffusionMat(:));
    
    eta = 0.4286; prms.offset = (2*eta-1)/(2*(1-eta));
    
    fprintf('Starting %i\n', xx)
    SimVid = DenGrowth_2D_fixed(prms , mats);
    
    
    % NOTE: parsave is not a native function to matlab and it must be modified
    % each time you change the variables to be saved
    parsave(fullfile(directory_name, ['sim_', num2str(xx)]), SimVid, mats, prms)

    fprintf('Finished %i\n', xx)
end

fprintf('Finished simulating batch')

%%
fprintf('Now extracting data')

cd(directory_name)

% you have to tell this next script what the meta parameters are:

REPS_global = REPS; % number of different global iterations (in particular number of different sets of activity to be generated)
Tsim = T/50; % size of the simulation video
% N = number of neurons

extract_data_classical;

delete(gcp('nocreate'));

cd ..
cd ..

fprintf('Done')




