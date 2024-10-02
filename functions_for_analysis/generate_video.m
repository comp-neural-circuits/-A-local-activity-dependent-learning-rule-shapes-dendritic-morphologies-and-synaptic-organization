% this script extracts the information that we want to plot and saves it as
% raw data. it is to be run in a tests_'serial date number' directory , wich are found in
% simulate\tests

%% setting up
clear
clc
close all

addpath('helpers')

dir_str = '../Lucas_version/faster/sims/';
% folder_str = {'sims_2024-01-07-19-38-43 40000 rare_large_steps_0'};

% all the simulation folders that are getting visualized
folder_str = {
    'sims_2024-01-07-14-59-13 40000 baseline',...   % no SynVid
    % 'sims_2024-01-07-15-51-32 80000 baseline_long',...  % no SynVid
    % 'sims_2024-01-07-17-08-09 40000 ingroup75',...  % no SynVid
    % 'sims_2024-01-08-17-47-44 40000 ingroup65',...  % no SynVid
    % 'sims_2024-01-08-18-15-40 40000 ingroup75_cross10',...  % no SynVid
    % 'sims_2024-01-09-12-54-42 40000 ingroup75_cross10_M2',...   % no SynVid
    % 'sims_2024-01-07-17-39-25 40000 somata16',...   % no SynVid
    % 'sims_2024-01-07-19-07-44 40000 somata25',...   % no SynVid
    % 'sims_2024-01-07-17-30-03 40000 somata13',...   % no SynVid
    % 'sims_2024-01-07-19-38-43 40000 rare_large_steps_0',...
    % 'sims_2024-01-07-19-54-15 40000 rare_small_steps_0',...
    % 'sims_2024-01-07-20-10-06 40000 often_large_steps_0',...
    % 'sims_2024-01-07-20-30-43 40000 often_small_steps_0',...
    % 'sims_2024-01-08-19-12-28 40000 rare_large_steps_01',...
    % 'sims_2024-01-08-19-25-44 40000 rare_small_steps_01',...
    % 'sims_2024-01-08-19-38-50 40000 often_large_steps_01',...
    % 'sims_2024-01-08-19-52-35 40000 often_small_steps_01',...
    % 'sims_2024-01-08-20-06-30 40000 rare_large_steps_001',...
    % 'sims_2024-01-08-20-20-33 40000 rare_small_steps_001',...
    % 'sims_2024-01-08-20-34-48 40000 often_large_steps_001',...
    % 'sims_2024-01-08-20-51-59 40000 often_small_steps_001',...
    };

% save_dir_str = ['Videos and images/', folder_str];
% mkdir(save_dir_str)
load_dir_str = [dir_str, 'sims_2024-01-07-15-51-32 80000 baseline_long'];

% REPS = load([load_dir_str, '/sim_1/REPS.mat']).REPS;
% T = load([load_dir_str, '/sim_1/T.mat']).T;
% N = load([load_dir_str, '/sim_1/N.mat']).N;
prms = load([load_dir_str, '/sim_1/prms.mat']).prms;
SimVid = load([load_dir_str, '/sim_1/SimVid.mat']).SimVid;

% implay(squeeze(sum(SimVid,4))==1)   % for dendrites
% implay(squeeze(sum(SimVid,4))==2)   % for connected synapses
implay(squeeze(SimVid(:,:,:,1))>0)   % for dendrites
implay(squeeze(SimVid(:,:,:,1))==2)   % for connected synapses

% for k = 1:length(folder_str)
%     f_str = folder_str{k};
% 
%     load_dir_str = [dir_str, f_str];
%     save_dir_str = ['Videos and images/', f_str];
% 
%     mkdir(save_dir_str)
% 
%     SimVid = load([load_dir_str, '/sim_1/SimVid.mat']).SimVid;

%%%%%%%%%%%
% Create video of all growth with connected synapses
    % % Create a VideoWriter object
    % videoFile = [save_dir_str, '/growth_neurons_and_connectors.mp4'];
    % writerObj = VideoWriter(videoFile, 'MPEG-4');
    % writerObj.FrameRate = 10;  % Set the frame rate as needed
    % open(writerObj);
    % 
    % % Plot and write frames to the video
    % figure;
    % for frameIdx = 1:size(SimVid, 3)
    %     % Create a binary mask for value 1 and 2
    %     mask1 = sum(SimVid(:,:,frameIdx,:), 4) == 1;
    %     mask2 = sum(SimVid(:,:,frameIdx,:), 4) == 2;
    % 
    %     % Create an RGB image where value 1 is mapped to red and value 2 to blue
    %     rgbImage = cat(3, mask1, mask2, zeros(size(mask1)));
    % 
    %     % Display the RGB image
    %     imagesc(rgbImage);
    %     title(['Frame: ' num2str(frameIdx)]);
    % 
    %     % Write the current frame to the video
    %     writeVideo(writerObj, getframe(gcf));
    % end
    % % Close the video writer
    % close(writerObj);
    % 
    % % Display a message
    % disp(['Video saved as: ' videoFile]);

% %%%%%%%%%%%
% % Create video of moving synapses
%     SynVid = load([load_dir_str, '/sim_1/SynVid.mat']).SynVid;
% 
%     % Create a VideoWriter object
%     videoFile = [save_dir_str, '/moving_synapses.mp4'];
%     writerObj = VideoWriter(videoFile, 'MPEG-4');
%     writerObj.FrameRate = 10;  % Set the frame rate as needed
%     open(writerObj);
% 
%     % Plot and write frames to the video
%     figure;
%     for frameIdx = 1:size(SynVid, 3)/50
%         % Create a binary mask for value 1 and 2
%         mask1 = sum(SimVid(:,:,frameIdx,:), 4) == 2;
%         mask2 = sum(SynVid(:,:,frameIdx*50,:), 4) == 1;
% 
%         % Create an RGB image where value 1 is mapped to red and value 2 to blue
%         rgbImage = cat(3, mask2-mask1, mask1, zeros(size(mask2)));
% 
%         % Display the RGB image
%         imagesc(rgbImage);
%         % imagesc(sum(SynVid(:,:,frameIdx*50,:), 4) == 1);
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
% %%%%%%%%%%%
% % Create image of single neurons final dendritic tree with connections
%     % for n = 1:size(SimVid,4)
%     %     imageFile = [save_dir_str, '/', num2str(n), '_dend_image.png'];
%     %     last_image_dend = SimVid(:,:,end,n)==1;
%     %     last_image_syn = SimVid(:,:,end,n)==2;
%     % 
%     %     % rgbImage = cat(3, last_image_dend, last_image_syn, zeros(size(last_image_dend)));
%     % 
%     %     % Set the background pixels to white
%     %     % background_pixels = ~any(rgbImage, 3);  % Find pixels with no signal
%     %     % rgbImage(repmat(background_pixels, [1, 1, 3])) = 1;  % Set those pixels to white
%     %     background_pixels = ~any(last_image_dend | last_image_syn, 3);
%     %     rgbImage = cat(3, ones(size(last_image_dend))-last_image_dend, ones(size(last_image_dend))-last_image_syn-last_image_dend, background_pixels);
%     % 
%     %     % Saving the matrix as an image (change 'output_image.png' to your desired filename)
%     %     imwrite(rgbImage, imageFile);
%     % 
%     %     % Display the image in the figure
%     %     imshow(rgbImage);
%     % 
%     %     % Save the figure as SVG
%     %     svgFile = fullfile(save_dir_str, [num2str(n), '_dend_image.svg']);
%     %     saveas(gcf, svgFile, 'svg');
%     % 
%     %     % Save the figure as PDF
%     %     pdfFile = fullfile(save_dir_str, [num2str(n), '_dend_image.pdf']);
%     %     saveas(gcf, pdfFile, 'pdf');
%     % 
%     %     disp(['Images saved as: ' imageFile]);
%     % end
% end
%% Tested how to visualize all the different activity patterns of the synapses (not in use)

% mats = load([load_dir_str, '/sim_1/mats.mat']).mats;
% 
% mats1 = double(mats.Groups(:,:,1))*255; % orange
% mats2 = double(mats.Groups(:,:,2))*200; % blau?
% mats3 = double(mats.Groups(:,:,3))*150; % türkis
% mats4 = double(mats.Groups(:,:,4))*100; % lila
% mats5 = double(mats.Groups(:,:,5))*50;  % gelb
% image(mats1 + mats2 + mats3 + mats4 + mats5)
% 
% img = zeros(185,185,3);
% img(:,:,1) = double(mats.Groups(:,:,1))*255 + double(mats.Groups(:,:,4))*120 + double(mats.Groups(:,:,5))*255;
% img(:,:,2) = double(mats.Groups(:,:,1))*50 + double(mats.Groups(:,:,3))*255 + double(mats.Groups(:,:,5))*220;
% img(:,:,3) = double(mats.Groups(:,:,2))*255 + double(mats.Groups(:,:,4))*200;
% image(img)
% 
% % Create a VideoWriter object
% videoFile = save_dir_str + folder_str + 'output_video.mp4';
% writerObj = VideoWriter(videoFile, 'MPEG-4');
% writerObj.FrameRate = 10;  % Set the frame rate as needed
% open(writerObj);
% 
% % Plot and write frames to the video
% figure;
% for frameIdx = 1:size(SimVid, 4)
%     % imagesc(squeeze(sum(SimVid(:,:,:,frameIdx), 3)) == 1);
%     % title(['Frame: ' num2str(frameIdx)]);
%     % 
%     % % Write the current frame to the video
%     % writeVideo(writerObj, getframe(gcf));
% 
%     % Create a binary mask for value 1 and 2
%     mask1 = sum(SimVid(:,:,:,frameIdx), 3) == 1;
%     mask2 = sum(SimVid(:,:,:,frameIdx), 3) == 2;
% 
%     % Create an RGB image where value 1 is mapped to red and value 2 to blue
%     rgbImage = cat(3, mask1, mask2, ones(size(mask1)));
% 
%     % Display the RGB image
%     imagesc(rgbImage);
%     title(['Frame: ' num2str(frameIdx)]);
% 
%     % Write the current frame to the video
%     writeVideo(writerObj, getframe(gcf));
% end
% % for frameIdx = 1:size(mats.Vid, 3)
% %     imagesc(squeeze(mats.Vid(:,:,frameIdx)));
% %     title(['Frame: ' num2str(frameIdx)]);
% % 
% %     % Write the current frame to the video
% %     writeVideo(writerObj, getframe(gcf));
% % end
% % Close the video writer
% close(writerObj);
% 
% % Display a message
% disp(['Video saved as ' videoFile]);