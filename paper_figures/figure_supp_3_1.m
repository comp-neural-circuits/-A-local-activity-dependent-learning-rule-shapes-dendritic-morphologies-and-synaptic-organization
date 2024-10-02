%% setting up
clear
clc
close all

addpath('../helpers')

dir_str = '../sims/';

save_dir_str = 'Videos and images/figure_supp_3_1/';
mkdir(save_dir_str)
load_dir_str = [dir_str, 'sims_2024-01-07-15-51-32 80000 baseline_long'];

% REPS = load([load_dir_str, '/sim_1/REPS.mat']).REPS;
% T = load([load_dir_str, '/sim_1/T.mat']).T;
% N = load([load_dir_str, '/sim_1/N.mat']).N;
% prms = load([load_dir_str, '/sim_1/prms.mat']).prms;
SimVid = load([load_dir_str, '/sim_1/SimVid.mat']).SimVid;

% implay(squeeze(sum(SimVid,4))==1)   % for dendrites
% implay(squeeze(sum(SimVid,4))==2)   % for connected synapses
% implay(squeeze(SimVid(:,:,:,1))>0)   % for dendrites
% implay(squeeze(SimVid(:,:,:,1))==2)   % for connected synapses

%%%%%%%%%%%
% Create image of single neurons final dendritic tree with connections
for n = 1:size(SimVid,4)    % last frame (144h)
    % middle frame (72h)
    imageFile = [save_dir_str, '/', num2str(n), '_dend_image_half.png'];
    last_image_dend = SimVid(:,:,end/2,n)==1;
    last_image_syn = SimVid(:,:,end/2,n)==2;

    % rgbImage = cat(3, last_image_dend, last_image_syn, zeros(size(last_image_dend)));

    % Set the background pixels to white
    % background_pixels = ~any(rgbImage, 3);  % Find pixels with no signal
    % rgbImage(repmat(background_pixels, [1, 1, 3])) = 1;  % Set those pixels to white
    background_pixels = ~any(last_image_dend | last_image_syn, 3);
    rgbImage = cat(3, ones(size(last_image_dend))-last_image_dend, ones(size(last_image_dend))-last_image_syn-last_image_dend, background_pixels);

    % Saving the matrix as an image (change 'output_image.png' to your desired filename)
    imwrite(rgbImage, imageFile);

    % Display the image in the figure
    imshow(rgbImage);

    % Save the figure as SVG
    svgFile = fullfile(save_dir_str, [num2str(n), '_dend_image_half.svg']);
    saveas(gcf, svgFile, 'svg');

    % Save the figure as PDF
    pdfFile = fullfile(save_dir_str, [num2str(n), '_dend_image_half.pdf']);
    saveas(gcf, pdfFile, 'pdf');

    disp(['Images saved as: ' imageFile]);

    % last frame (144h)
    imageFile = [save_dir_str, '/', num2str(n), '_dend_image.png'];
    last_image_dend = SimVid(:,:,end,n)==1;
    last_image_syn = SimVid(:,:,end,n)==2;

    % rgbImage = cat(3, last_image_dend, last_image_syn, zeros(size(last_image_dend)));

    % Set the background pixels to white
    % background_pixels = ~any(rgbImage, 3);  % Find pixels with no signal
    % rgbImage(repmat(background_pixels, [1, 1, 3])) = 1;  % Set those pixels to white
    background_pixels = ~any(last_image_dend | last_image_syn, 3);
    rgbImage = cat(3, ones(size(last_image_dend))-last_image_dend, ones(size(last_image_dend))-last_image_syn-last_image_dend, background_pixels);

    % Saving the matrix as an image (change 'output_image.png' to your desired filename)
    imwrite(rgbImage, imageFile);

    % Display the image in the figure
    imshow(rgbImage);

    % Save the figure as SVG
    svgFile = fullfile(save_dir_str, [num2str(n), '_dend_image.svg']);
    saveas(gcf, svgFile, 'svg');

    % Save the figure as PDF
    pdfFile = fullfile(save_dir_str, [num2str(n), '_dend_image.pdf']);
    saveas(gcf, pdfFile, 'pdf');

    disp(['Images saved as: ' imageFile]);
end