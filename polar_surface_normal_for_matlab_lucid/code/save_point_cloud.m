function save_point_cloud(depth_image, out_file, intensity_map)

[X,Y] = meshgrid(1 : size(depth_image, 2), 1 : size(depth_image, 1));
ncols = size(depth_image, 2);
nrows = size(depth_image, 1);
width = 1000; % mm
height = width * nrows / ncols;
X = X * width / ncols;
Y = -Y * height / nrows;
Z = depth_image * 1; % should vary depending on the scene
intensity_vect = intensity_map(:);
valid_locations = find(depth_image > 0);
X = X(valid_locations);
Y = Y(valid_locations);
Z = Z(valid_locations);
intensity_valid = intensity_vect(valid_locations);
pc_data_depth = [X(:), Y(:), Z(:)];
if nargin<3
    pc_data_rgb = ones(size(pc_data_depth)) * 128;
else
    pc_data_rgb = repmat(intensity_valid, [1, 3]);
end
pc_data = [pc_data_depth, pc_data_rgb];
fid = fopen(out_file, 'w');
dlmwrite(out_file, pc_data, '-append', 'delimiter', '\t', 'precision', 5);
fclose(fid);