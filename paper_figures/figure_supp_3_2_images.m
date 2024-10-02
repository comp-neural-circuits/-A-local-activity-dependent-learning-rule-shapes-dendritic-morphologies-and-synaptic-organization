%% setting up
clear
clc
close all

addpath('../helpers')

dir_str = '../sims/';

save_dir_str = 'Videos and images/figure_supp_3_2/';
mkdir(save_dir_str)

% all the simulation folders that are getting visualized
folder_str = {
    'sims_2024-01-07-14-59-13 40000 baseline',...   % no SynVid
    'sims_2024-01-07-17-39-25 40000 somata16',...   % no SynVid
    'sims_2024-01-07-19-07-44 40000 somata25',...   % no SynVid
    'sims_2024-01-07-17-30-03 40000 somata13',...   % no SynVid
    };

% REPS = load([load_dir_str, '/sim_1/REPS.mat']).REPS;
% T = load([load_dir_str, '/sim_1/T.mat']).T;
% N = load([load_dir_str, '/sim_1/N.mat']).N;
% prms = load([load_dir_str, '/sim_1/prms.mat']).prms;
% SimVid = load([load_dir_str, '/sim_1/SimVid.mat']).SimVid;

for k = 1:length(folder_str)
    f_str = folder_str{k};

    load_dir_str = [dir_str, f_str];
    save_dir = [save_dir_str, f_str];

    mkdir(save_dir)

    SimVid = load([load_dir_str, '/sim_1/SimVid.mat']).SimVid;

% %%%%%%%%%%
% % Create video of all growth with connected synapses
%     % Create a VideoWriter object
%     videoFile = [save_dir, '/growth_neurons_and_connectors.mp4'];
%     writerObj = VideoWriter(videoFile, 'MPEG-4');
%     writerObj.FrameRate = 10;  % Set the frame rate as needed
%     open(writerObj);
% 
%     % Plot and write frames to the video
%     figure;
%     for frameIdx = 1:size(SimVid, 3)
%         % Create a binary mask for value 1 and 2
%         mask1 = sum(SimVid(:,:,frameIdx,:), 4) == 1;
%         mask2 = sum(SimVid(:,:,frameIdx,:), 4) == 2;
% 
%         % Create an RGB image where value 1 is mapped to red and value 2 to blue
%         rgbImage = cat(3, mask1, mask2, zeros(size(mask1)));
% 
%         % Display the RGB image
%         imagesc(rgbImage);
%         title(['Frame: ' num2str(frameIdx)]);
% 
%         % Write the current frame to the video
%         writeVideo(writerObj, getframe(gcf));
%     end
%     % Close the video writer
%     close(writerObj);
% 
%     % Display a message
%     disp(['Video saved as: ' videoFile]);
% 
% %%%%%%%%%%%
% Create image of all neurons final dendritic tree with connections
    imageFile = [save_dir, '/final_dend_image.png'];
    last_image_dend = sum(SimVid(:,:,end,:),4)==1;
    last_image_syn = sum(SimVid(:,:,end,:),4)==2;

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
    svgFile = fullfile(save_dir, 'final_dend_image.svg');
    saveas(gcf, svgFile, 'svg');

    % Save the figure as PDF
    pdfFile = fullfile(save_dir, 'final_dend_image.pdf');
    saveas(gcf, pdfFile, 'pdf');

    disp(['Images saved as: ' imageFile]);

    % image of dendrites and connectors after 1/24 of time
    imageFile = [save_dir, '/early_dend_image.png'];
    early_image_dend = sum(SimVid(:,:,round(end/24),:),4)==1;
    early_image_syn = sum(SimVid(:,:,round(end/24),:),4)==2;

    % rgbImage = cat(3, last_image_dend, last_image_syn, zeros(size(last_image_dend)));

    % Set the background pixels to white
    % background_pixels = ~any(rgbImage, 3);  % Find pixels with no signal
    % rgbImage(repmat(background_pixels, [1, 1, 3])) = 1;  % Set those pixels to white
    background_pixels = ~any(early_image_dend | early_image_syn, 3);
    rgbImage = cat(3, ones(size(early_image_dend))-early_image_dend, ones(size(early_image_dend))-early_image_syn-early_image_dend, background_pixels);

    % Saving the matrix as an image (change 'output_image.png' to your desired filename)
    imwrite(rgbImage, imageFile);

    % Display the image in the figure
    imshow(rgbImage);

    % Save the figure as SVG
    svgFile = fullfile(save_dir, 'early_dend_image.svg');
    saveas(gcf, svgFile, 'svg');

    % Save the figure as PDF
    pdfFile = fullfile(save_dir, 'early_dend_image.pdf');
    saveas(gcf, pdfFile, 'pdf');

    disp(['Images saved as: ' imageFile]);
end