clear all
close all

%% Load the captured image of four polarization angles
in_path = 'Z:\Students\lslusny\test\AdapterplatteBottom\h\cam0\img_0.png';
im = imread(in_path);

% to grayscale
%im = rgb2gray(im_color)

%% Stack the image of four polarization angles into an image of four channels
[nrows, ncols, channels] = size(im);

im0 = im(1 : nrows/2, 1 : ncols/2);
im45 = im(1 : nrows/2, ncols/2 + 1 : end);
im90 = im(nrows/2 + 1 : end, 1 : ncols/2);
im135 = im(nrows/2 + 1 : end, ncols/2 + 1 : end);
images = zeros(nrows/2, ncols/2, 4);
images(:, :, 1) = double(im0);
images(:, :, 2) = double(im45);
images(:, :, 3) = double(im90);
images(:, :, 4) = double(im135);

nskips = 4; % may work with a smaller image which runs faster
images = images(1 : nskips : end, 1 : nskips: end, :);

%% Assign polarizaton angles to corresponding channels
angles = [0, 45, 90, 135] * pi / 180;

%% May create a mask for a region of interest
use_fg_threshold = false;
mask = ones(size(images(:, :, 1)));
if ( use_fg_threshold )
  image_avg = mean(double(images), 3);
  fg_threshold = 10;
  mask(image_avg < fg_threshold)  = 0;
  mask(image_avg >=fg_threshold)  = 1; % foreground
end
mask = logical(mask);
if ( use_fg_threshold )
    figure('Name','Mask', 'NumberTitle', 'off'); imagesc(mask)
end

%% Calculate polarization attributes of the image: dolp, aolp and intensity
% credit: PlarizationImage can be found from https://github.com/waps101/depth-from-polarisation 
[ dolp_est,aolp_est,intensity_est ] = PolarisationImage( images,angles,mask,'linear' );
mask(dolp_est < 0.005) = 0; % filter out pixels with very small degree of polarization 
figure('Name','Polarisations Winkel', 'NumberTitle', 'off'); imagesc(aolp_est); colorbar; %colormap rainbow
figure('Name','Degree of Polarisation', 'NumberTitle', 'off'); imagesc(dolp_est); colorbar
figure('Name','Intensity Estimation', 'NumberTitle', 'off'); imagesc(intensity_est); colormap gray

%% Estimate surface normals of the object
% This can done with
% 1. a Lambertian model; OR
% 2. a boundary propagation method; OR 
% 3. a simple look up table approach given the lighting setup is invariant 
% The code of methods 1 and 2 can be found in https://github.com/waps101/depth-from-polarisation
N = lookup_aolp_cylinder(aolp_est);
%[N, height] = Propagation( rho_est,phi_est,mask,n );

% We found that a median filter could be usually to reduce the noise of the estimated normal vector but it is not a must
% N(:,:,1) = imsmooth(N(:,:,1), "Median", [5,5]);
% N(:,:,2) = imsmooth(N(:,:,2), "Median", [5,5]);
% N(:,:,3) = imsmooth(N(:,:,3), "Median", [5,5]);
N(:,:,1) = medfilt2(N(:,:,1), [5,5]);
N(:,:,2) = medfilt2(N(:,:,2), [5,5]);
N(:,:,3) = medfilt2(N(:,:,3), [5,5]);

%% Depth reconstruction from the derived surface normal 
% Various methods are described and their codes are include in https://github.com/yqueau/normal_integration 
temp = N(:, :, 3);
temp(abs(temp)<1e-5) = nan; % avoid dividing by zero or a very small number. otherwise it will screw up the depth map 
N(:, :, 3) = temp;
P = -N(:,:,1)./N(:,:,3);
Q = -N(:,:,2)./N(:,:,3);
P(isnan(P)) = 0;
Q(isnan(Q)) = 0;
height = DCT_Poisson(P,Q);
figure('Name','DepthMap', 'NumberTitle', 'off'); imagesc(height); colorbar
height(~mask) = nan;
save_point_cloud(height, 'point_cloud.txt', intensity_est);

figure('Name','PointCloud', 'NumberTitle', 'off'); 
surf(height,'EdgeColor','none','FaceColor',[0 0 1],'FaceLighting','gouraud','AmbientStrength',0,'DiffuseStrength',1); 
axis equal; light
xlabel('x')
ylabel('y')
zlabel('z')
