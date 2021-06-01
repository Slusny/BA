clear cam1
path = "C:\Users\lennart\Desktop\BA\BA\results\Basler\led\";
names = ["0_deg.png","45_deg.png","90_deg.png","135_deg.png"];

example_data = false;
threshold_mask = false;
drawing_mask = false;
drawing_spec = false;
nonlinear = false;

addpath("utils")
if(example_data)
    % Load raw images, mask and specular mask
    load sampleData.mat
else
    %% Stack the image of four polarization angles into an image of four channels
    for i = [1, 2, 3, 4]
        images(:, :, i) = imread(path + names(i));
    end
    images = im2double(images);
    %% Assign polarizaton angles to corresponding channels
    angles = [0, 45, 90, 135] * pi / 180;

    %% May create a mask for a region of interest
    L = imread(path + names(1));
    if ( threshold_mask )
        mask = ones(size(images(:, :, 1)));
        image_avg = mean(double(images), 3);
        fg_threshold = 10;
        mask(image_avg < fg_threshold)  = 0;
        mask(image_avg >=fg_threshold)  = 1; % foreground
        mask = logical(mask);
        figure('Name','Threshold Mask', 'NumberTitle', 'off'); imagesc(mask)
        
    elseif  (drawing_mask)
        figure('Name','Drawing Mask', 'NumberTitle', 'off');imshow(L)
        h1 = drawpolygon();
        roiPoints = h1.Position;
        mask = poly2mask(roiPoints(:,1),roiPoints(:,2),size(L,1),size(L,2));
        %figure('Name','Drawing Mask', 'NumberTitle', 'off'); imshow(mask)
    else
        mask = logical(ones(size(L)));
    end
        
    if  (drawing_spec)
        figure('Name','Specular Mask', 'NumberTitle', 'off');imshow(L)
        h1 = drawpolygon();
        roiPoints = h1.Position;
        spec = poly2mask(roiPoints(:,1),roiPoints(:,2),size(L,1),size(L,2));
        %figure('Name','Specular Mask', 'NumberTitle', 'off'); imshow(mask)
        
    else
        spec = logical(zeros(size(L)));
    end

end

% Estimate polarisation image from captured images
if (threshold_mask || drawing_mask)
    if(nonlinear)
        [ rho_est,phi_est,Iun_est ] = PolarisationImage( images,angles,mask,'nonlinear' );
    else
        [ rho_est,phi_est,Iun_est ] = PolarisationImage( images,angles,mask,'linear' );
    end
else 
    [ rho_est,phi_est,Iun_est ] = PolarisationImage( images,angles );
end
figure('Name','Rho', 'NumberTitle', 'off'); imshow(rho_est); c = colorbar;c. Label.String = 'percent'; % < 2 // für nonlinear max 0.8138
figure('Name','Phi', 'NumberTitle', 'off'); imshow(phi_est/3.1416); %colorbar('Ticks',[0,0.25,0.5,0.75,1],'TickLabels',{'0°','45°','90°','135°','180°'}) % < 4 // für nonlinear max 3.1416
figure('Name','Iun', 'NumberTitle', 'off'); imshow(Iun_est); colorbar

hsv_img = zeros(size(phi_est,1),size(phi_est,2),3);
for i=1:size(phi_est,1)
    for j=1:size(phi_est,2)
        hsv_img(i,j,1) = phi_est(i,j)/3.1416;
    end
end
hsv_img(:,:,2) = 1;
hsv_img(:,:,3) = 1;
disp_img = hsv2rgb(hsv_img);
if(threshold_mask || drawing_mask)
    disp_img2 = zeros(size(disp_img,1),size(disp_img,2),3);
    mask3d = repmat(mask, 1, 1, 3);
    disp_img2(mask3d) = disp_img(mask3d);
    disp_img = disp_img2;
end
figure('Name','Phi HSV', 'NumberTitle', 'off');imshow(disp_img,[]);myColorMap = hsv(256);colormap(myColorMap);colorbar('Ticks',[0,0.25,0.5,0.75,1],'TickLabels',{'0°','45°','90°','135°','180°'});

%{
[x1,x2]=meshgrid(linspace(0,1,256),linspace(0,1,256));
img(:,:,1)=x1;
img(:,:,2)=1;  %fully saturated colors
img(:,:,3)=x2;

imgRGB=hsv2rgb(img); %for display purposes
imshow(imgRGB,[])
%}

%prozent = Iun_est .\ imread(path + names(1)) * 100;
%figure('Name','Iun  pro', 'NumberTitle', 'off'); imshow(prozent); colorbar

% Assume refractive index = 1.5
n = 1.5;

% Estimate light source direction from diffuse pixels (note that you might
% get a convex/concave flip)
%[ s,T,B ] = findLight( theta_est,phi_est,Iun_est,mask&~spec,3 );
% Or use known direction and estimate albedo
%s = [2 0 7]';
%[ s,T,B ] = findLight( theta_est,phi_est,Iun_est,mask&~spec,3,s );

% Compute angles, taking into account different model for specular pixels
theta_est_diffuse = rho_diffuse(rho_est,n);
theta_est_spec = rho_spec(rho_est(spec),n);
theta_est_combined = theta_est_diffuse;
theta_est_combined(spec)=theta_est_spec;
phi_est_combined = phi_est;
phi_est_combined(spec)=mod(phi_est(spec)+pi/2,pi);
figure('Name','Theta', 'NumberTitle', 'off'); imshow(theta_est_combined); colorbar

% Estimate light source direction from diffuse pixels (note that you might
[ s,T,B ] = findLight( theta_est_combined,phi_est,Iun_est,mask&~spec,3 );

% Compute boundary prior azimuth angles and weight
[ azi,Bdist ] = boundaryPrior( mask );

specmask = spec;
polAng = angles;
cam1.Iun_est = Iun_est;
cam1.rho_est=rho_est;
cam1.phi_est=phi_est;
cam1.theta_est_diffuse=theta_est_diffuse;
cam1.theta_est_spec=theta_est_spec;
cam1.mask = mask;
cam1.specmask = specmask;

% dings
N_guide_x = readmatrix("Z:\Students\lslusny\datasets\Basler\v5\x\lumione_pc\N_guide_x.csv");
N_guide_x(:,:,3) = N_guide_x;
N_guide = N_guide_x;
N_guide_y = readmatrix("Z:\Students\lslusny\datasets\Basler\v5\x\lumione_pc\N_guide_y.csv");
N_guide(:,:,2) = N_guide_y;
N_guide_z = readmatrix("Z:\Students\lslusny\datasets\Basler\v5\x\lumione_pc\N_guide_z.csv");
N_guide(:,:,3) = N_guide_z;

example = load("../../CVPR2019-master/CVPR2019-master/data/horse_disparity_median.mat");
N = example.N_guide;

test = zeros(size(N_guide,1),size(N_guide,2));
figure;
for i=1:size(N_guide,1)
    for j=1:size(N_guide,2)
        if(N_guide(i,j,1) ~= 0 || N_guide(i,j,2) ~= 0 || N_guide(i,j,3) ~= 0)
            test(i,j) = 255;
        end
    end
end
imshow(test);

save('data', 'polAng','cam1', 'N_guide')

% Run linear height from polarisation
[ height ] = HfPol( theta_est_combined,min(1,Iun_est),phi_est_combined,s,mask,false,spec );

% Visualise
figure;
surf(height,'EdgeColor','none','FaceColor',[0 0 1],'FaceLighting','gouraud','AmbientStrength',0,'DiffuseStrength',1); axis equal; light