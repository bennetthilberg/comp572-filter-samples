%%AI Usage Report
%{
1.  Which AI tool(s) you used:

2.  One or two example prompts:

3.  What parts of the MATLAB code were AI-generated:

4.  What changes, debugging, or refinements you performed yourself:

%}

close all;

filenames = ["alcapone2.jpeg", "iwojima.png", "che.png", "hubble.jpg", "bluemarble.jpg", "babyginny.jpg"];

% Approximate number of dots along the shorter dimension.
% Tweak these per image if needed.
Sizes = [53, 72, 60, 65, 55, 45];

for i = 1:6

    filename = filenames(i);
    Size = Sizes(i);

    if i <= 3
        % Grayscale dot mosaic for images 1-3
        im = im2double(imread(filename));

        if size(im, 3) == 3
            im = rgb2gray(im);
        end

        mosaic = dot_mosaic_gray(im, Size);

        figure;
        tiledlayout(1, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

        nexttile;
        imshow(im);
        title("img" + i + " original grayscale");

        nexttile;
        imshow(mosaic);
        title("img" + i + " grayscale dot mosaic, Size = " + Size);

    else
        % Color dot mosaic for images 4-6
        im = im2double(imread(filename));

        mosaic = dot_mosaic_color(im, Size);

        figure;
        tiledlayout(1, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

        nexttile;
        imshow(im);
        title("img" + i + " original color");

        nexttile;
        imshow(mosaic);
        title("img" + i + " color dot mosaic, Size = " + Size);
    end

end


function result = dot_mosaic_gray(im, Size)

    if size(im, 3) == 3
        im = rgb2gray(im);
    end

    im = im2double(im);
    im = min(max(im, 0), 1);

    height = size(im, 1);
    width = size(im, 2);

    k = round(min(height, width) / Size);
    k = max(k, 1);

    if mod(k, 2) == 0
        k = k + 1;
    end

    small_height = max(1, round(height / k));
    small_width = max(1, round(width / k));
    im_small = imresize(im, [small_height, small_width]);

    mosaic_cells = cell(small_height, small_width);

    max_radius = (k - 1) / 2;
    center = (k + 1) / 2;

    for row = 1:small_height
        for col = 1:small_width

            p = im_small(row, col);
            grid_square = ones(k, k);

            radius = round(max_radius * sqrt(1 - p));

            if radius > 0
                disk = fspecial('disk', radius);
                disk = disk ./ max(disk(:));
                disk = 1 - disk;

                row_range = (center - radius):(center + radius);
                col_range = (center - radius):(center + radius);

                grid_square(row_range, col_range) = disk;
            end

            mosaic_cells{row, col} = grid_square;

        end
    end

    result = cell2mat(mosaic_cells);

end


function result = dot_mosaic_color(im, Size)

    im = im2double(im);
    im = min(max(im, 0), 1);

    if size(im, 3) == 1
        result = dot_mosaic_gray(im, Size);
        return;
    end

    result_red = dot_mosaic_gray(im(:, :, 1), Size);
    result_green = dot_mosaic_gray(im(:, :, 2), Size);
    result_blue = dot_mosaic_gray(im(:, :, 3), Size);

    result = cat(3, result_red, result_green, result_blue);

end