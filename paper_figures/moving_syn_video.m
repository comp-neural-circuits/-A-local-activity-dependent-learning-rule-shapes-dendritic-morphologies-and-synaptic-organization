% this script extracts the information that we want to plot and saves it as
% raw data. it is to be run in a tests_'serial date number' directory , wich are found in
% simulate\tests

%% setting up
clear
clc
close all

addpath('helpers')

% Specify which simulation to use
folder_str = ['sims_2024-06-28-11-55-58 40000 baseline'];

% save_str = 'figures/';

% Specify where the video should be stored
directory_str = ['../sims/4_2_moving_synapses_final/', folder_str];
% directory_str = ['sims/less_proBDNF/', folder_str];
% directory_str = ['sims/more_proBDNF/', folder_str];

save_str = directory_str;

% number of different global iterations (in particular number of different sets of activity to be generated)
% REPS = load([directory_str, '/sim_1/REPS.mat']).REPS;
% size of the simulation video
% T = load([directory_str, '/sim_1/T.mat']).T;
% N = load([directory_str, '/sim_1/N.mat']).N;
% prms = load([directory_str, '/sim_1/prms.mat']).prms;

% mats = load([directory_str, '/sim_1/mats.mat']).mats;

disp('Loading video ...');
% SimVid = load([directory_str, '/sim_1/SimVid.mat']).SimVid;
% SynVid = load([directory_str, '/sim_1/SynVid.mat']).SynVid;
TransVid = load([directory_str, '/sim_1/TransVid.mat']).TransVid;
disp('Video loaded!');

% implay(SynVid)

% implay(squeeze(sum(SimVid,3))==1)   % for dendrites
% implay(squeeze(sum(SimVid,3))==2)   % for connected synapses
%%
% Sens = load([directory_str, '/sim_1/Sens.mat']).Sens;
% implay(Sens)
% mats1 = double(mats.Groups(:,:,1))*255; % orange
% mats2 = double(mats.Groups(:,:,2))*200; % blau?
% mats3 = double(mats.Groups(:,:,3))*150; % türkis
% mats4 = double(mats.Groups(:,:,4))*100; % lila
% mats5 = double(mats.Groups(:,:,5))*50;  % gelb
% image(mats1 + mats2 + mats3 + mats4 + mats5)

% img = zeros(185,185,3);
% img(:,:,1) = double(mats.Groups(:,:,1))*255 + double(mats.Groups(:,:,4))*120 + double(mats.Groups(:,:,5))*255;
% img(:,:,2) = double(mats.Groups(:,:,1))*50 + double(mats.Groups(:,:,3))*255 + double(mats.Groups(:,:,5))*220;
% img(:,:,3) = double(mats.Groups(:,:,2))*255 + double(mats.Groups(:,:,4))*200;
% image(img)

% Create a VideoWriter object
videoFile = [save_str, '/output_video.avi'];
% writerObj = VideoWriter(videoFile, 'MPEG-4');
writerObj = VideoWriter(videoFile, 'Motion JPEG AVI');
% writerObj = VideoWriter(videoFile, 'Uncompressed AVI');
% writerObj = VideoWriter(videoFile, 'Archival');
writerObj.FrameRate = 10;  % Set the frame rate as needed
open(writerObj);

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

frames = size(TransVid, 3);
% frames = 10000;

for frameIdx = 1:100:frames
    if mod(frameIdx-1, 100) == 0; disp([num2str(frameIdx/frames*100),'%']); end
    imagesc(squeeze(TransVid(:,:,frameIdx)));
    title(['time: ' num2str(round(frameIdx/(40000/72))), 'h']);

    % Write the current frame to the video
    writeVideo(writerObj, getframe(gcf));
end

% Close the video writer
close(writerObj);

% Display a message
disp(['Video saved as ' videoFile]);