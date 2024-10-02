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

P = 185; N = 25; T = 40000;

rng(1)

%% regular run
str_now = datetime('now', 'Format', 'yyyy-MM-dd-HH-mm-ss');
directory_name = sprintf('sims/sims_%s %i somata25', str_now, T);

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
    
    mats.Soma = false([185,185,25]);
    
    mats.Soma(18:20,18:20,1) = 1;
    mats.Soma(18:20,55:57,2) = 1;
    mats.Soma(18:20,92:94,3) = 1;
    mats.Soma(18:20,129:131,4) = 1;
    mats.Soma(18:20,166:168,5) = 1;
    
    mats.Soma(55:57,18:20,6) = 1;
    mats.Soma(55:57,55:57,7) = 1;
    mats.Soma(55:57,92:94,8) = 1;
    mats.Soma(55:57,129:131,9) = 1;
    mats.Soma(55:57,166:168,10) = 1;
    
    mats.Soma(92:94,18:20,11) = 1;
    mats.Soma(92:94,55:57,12) = 1;
    mats.Soma(92:94,92:94,13) = 1;
    mats.Soma(92:94,129:131,14) = 1;
    mats.Soma(92:94,166:168,15) = 1;
    
    mats.Soma(129:131,18:20,16) = 1;
    mats.Soma(129:131,55:57,17) = 1;
    mats.Soma(129:131,92:94,18) = 1;
    mats.Soma(129:131,129:131,19) = 1;
    mats.Soma(129:131,166:168,20) = 1;
    
    mats.Soma(166:168,18:20,21) = 1;
    mats.Soma(166:168,55:57,22) = 1;
    mats.Soma(166:168,92:94,23) = 1;
    mats.Soma(166:168,129:131,24) = 1;
    mats.Soma(166:168,166:168,25) = 1;

    mats.Dend = mats.Soma;
    
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




