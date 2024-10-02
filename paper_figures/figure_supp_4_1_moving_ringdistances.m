%% setting up
clear
clc
close all

addpath('../helpers')

dir_str = '../sims/4_2_moving_synapses_final/';
save_dir = 'Videos and images/figure_supp_4_2/';
mkdir(save_dir)

% all the simulation folders that are getting visualized
folder_str = 'sims_2024-01-07-14-59-13 40000 baseline';

load_dir_str = [dir_str, folder_str];

SimVid = load([load_dir_str, '/sim_1/SimVid.mat']).SimVid;
Syn = load([load_dir_str, '/sim_1/mats.mat']).mats.Syn;

% Image of dendrites and connectors after 1/24 of time
imageFile = [save_dir, '/early_dend_image.png'];
early_image_dend = sum(SimVid(:,:,round(end/24),:),4)==1;
% early_image_syn = sum(SimVid(:,:,round(end/24),:),4)==2;
early_image_syn = Syn;

background_pixels = ~any(early_image_dend | early_image_syn, 3);
rgbImage = cat(3, ones(size(early_image_dend))-early_image_dend, ...
                  ones(size(early_image_dend))-early_image_syn-early_image_dend, ...
                  background_pixels);

% Define the center of the matrix
matrix_size = size(rgbImage, 1); % Assuming it's a square matrix
center = ceil(matrix_size / 3);

% Define the distances for the rings
moving_distance = [3, 25, 101];

% Create an empty RGB image for the rings
ring_image = zeros(matrix_size, matrix_size, 3);
ring_image(center, center, :) = [1, 0, 0];

% Define colors for each ring in RGB format
% Define colors for each ring in RGB format
ring_colors = [34, 139, 34;  % Green
               255, 165, 0;  % Orange
               30, 144, 255]/255; % Blue

for idx = 1:length(moving_distance)
    distance = moving_distance(idx);
    
    % Generate the ring for the given distance
    for j = 1:matrix_size
        for k = 1:matrix_size
            if distance / 4 < sqrt((j - center)^2 + (k - center)^2) && sqrt((j - center)^2 + (k - center)^2) < distance / 2
                % Check if the current pixel in rgbImage is not already colored
                if all(rgbImage(j, k, :) == 1)  % Background pixel is white
                    ring_image(j, k, :) = ring_colors(idx, :);
                end
            end
        end
    end
end

% Combine the rings with the original image
combinedImage = rgbImage;
ring_mask = sum(ring_image, 3) > 0;

for c = 1:3
    combinedImage(:,:,c) = combinedImage(:,:,c) .* ~ring_mask + ring_image(:,:,c) .* ring_mask;
end

% Display the combined image
figure;
imshow(combinedImage);
hold on;

% Create legend items
hOrange = plot(NaN, NaN, 's', 'MarkerFaceColor', ring_colors(1, :), 'MarkerEdgeColor', 'k');
hGreen = plot(NaN, NaN, 's', 'MarkerFaceColor', ring_colors(2, :), 'MarkerEdgeColor', 'k');
hBlue = plot(NaN, NaN, 's', 'MarkerFaceColor', ring_colors(3, :), 'MarkerEdgeColor', 'k');

% Add the legend
legend([hOrange, hGreen, hBlue], {'3x3 pixel ring', '25x25 pixel ring', '101x101 pixel ring'}, 'Location', 'northeast');

% Save the combined image
imwrite(combinedImage, imageFile);

% Save the figure as SVG
svgFile = fullfile(save_dir, 'early_dend_image.svg');
saveas(gcf, svgFile, 'svg');

% Save the figure as PDF
pdfFile = fullfile(save_dir, 'early_dend_image.pdf');
saveas(gcf, pdfFile, 'pdf');

disp(['Images saved as: ' imageFile]);
