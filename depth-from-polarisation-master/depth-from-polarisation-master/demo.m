clear cam1

dataset = "Adapterplatte_point";

names = ["0_deg.png","45_deg.png","90_deg.png","135_deg.png"];
p.Knie.base_path = "Z:\Students\lslusny\datasets\Knie\v2\x";
p.Knie.path = "\data\cam0\grey\";
p.Kugel.base_path = "Z:\Students\lslusny\datasets\Kugel\v2_point\x";
p.Kugel.path = "\data\cam0\mono0\";
p.Defect1.base_path = "Z:\Students\lslusny\datasets\Defect1\v7\x";
p.Defect1.path = "\data\cam10\mono\";
p.Defect2.base_path = "Z:\Students\lslusny\datasets\Defect2\v6\x";
p.Defect2.path = "\data\cam15\mono\";
p.Glaskaraffe.base_path = "Z:\Students\lslusny\datasets\Glaskaraffe\v1\x";
p.Glaskaraffe.path = "\data\cam15\mono\";
p.CombiTip_point.base_path = "Z:\Students\lslusny\datasets\CombiTip\v2_point\x";
p.CombiTip_point.path = "\data\cam0\mono0\";
p.Kobel_point.base_path = "Z:\Students\lslusny\datasets\Kobel\v2_point\x";
p.Kobel_point.path = "\data\cam0\mono\";
p.Adapterplatte_point.base_path = "Z:\Students\lslusny\datasets\Adapterplatte\v2_point_dunkel\x";
p.Adapterplatte_point.path = "\data\cam0\mono0\";

base_path = p.(dataset).base_path;
path = base_path + p.(dataset).path;


example_data = false;
threshold_mask = false;
drawing_mask = true;
drawing_spec = false;
nonlinear = false;
Do_N_guide = false;

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
figure('Name','Iun', 'NumberTitle', 'off'); imshow(Iun_est, []); colorbar

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
theta_est_spec = rho_spec(rho_est(spec),n); %rho_spec(rho_est.*spec)
theta_est_combined = theta_est_diffuse;
theta_est_combined(spec)=theta_est_spec;
phi_est_combined = phi_est;
phi_est_combined(spec)=mod(phi_est(spec)+pi/2,pi);
figure('Name','Theta', 'NumberTitle', 'off'); imshow(theta_est_combined); colorbar
%
temp = theta_est_spec;
theta_est_spec = zeros(size(L));
theta_est_spec(spec) = temp;
%
if(~drawing_spec)
    theta_est_spec = zeros(size(L));
end

% Estimate light source direction from diffuse pixels (note that you might
[ s,T,B ] = findLight( theta_est_combined,phi_est,Iun_est,mask&~spec,3 );
%s = [0,0.866,0.5];
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

if Do_N_guide
    % dings
    N_guide_x_in = readmatrix(base_path + "\lumione_pc\N_guide_x.csv");
    N_guide_y_in = readmatrix(base_path + "\lumione_pc\N_guide_y.csv");
    N_guide_z_in = readmatrix(base_path + "\lumione_pc\N_guide_z.csv");

    N_guide_x_in(isnan(N_guide_x_in)) = 0;
    N_guide_y_in(isnan(N_guide_y_in)) = 0;
    N_guide_z_in(isnan(N_guide_z_in)) = 0;

    N_test(:,:,1) = N_guide_x_in;
    N_test(:,:,2) = N_guide_x_in;
    N_test(:,:,3) = N_guide_x_in;

    N_guide_x(:,:,1) = make_dense(N_guide_x_in,mask);
    N_guide = N_guide_x;
    N_guide(:,:,2) = make_dense(N_guide_y_in,mask);
    N_guide(:,:,3) = make_dense(N_guide_z_in,mask);

    % make N_guide dense

    example = load("../../CVPR2019-master/CVPR2019-master/data/horse_disparity_median.mat");
    N = example.N_guide;

    test = zeros(size(N_guide,1),size(N_guide,2));
    figure;
    for i=1:size(N_test,1)
        for j=1:size(N_test,2)
            if(N_test(i,j,1) ~= 0 || N_test(i,j,2) ~= 0 || N_test(i,j,3) ~= 0)
                test(i,j) = 255;
            end
        end
    end
    imshow(test);
    %{%}
    save(base_path + "\lumione_pc\data", 'polAng','cam1', 'N_guide')
else 
    save(base_path + "\lumione_pc\data_noNguide", 'polAng','cam1')
end
disp("wrote data");

% Run linear height from polarisation
[ height ] = HfPol( theta_est_combined,min(1,Iun_est),phi_est_combined,s,mask,true,spec );

% Visualise
%{
mask = height < 20;
mask2 = height > -20;
mask = mask2+mask.*(mask2==0);
dispHeight = zeros(size(L));
dispHeight(mask) = height(mask);
figure;
%}
surf(height,'EdgeColor','none','FaceColor',[0 0 1],'FaceLighting','gouraud','AmbientStrength',0,'DiffuseStrength',1); axis equal; light

function [point_sum,total_sum,count] = search_inside(in,k,l,radius, point_sum, total_sum,count)
    row_t = k-radius;
    row_b = k+radius;
    col_l = l-radius;
    col_r = l+radius;
    % left and right col
    for i=row_t:row_b
        if i<1 || i>size(in,1)
            continue
        end
        %distance as weight
        dist = sqrt(i^2 + radius^2);
        %left
        if col_l > 0
            if in(i,col_l)
                point_sum = point_sum + in(i,col_l)/dist;
                total_sum = total_sum + 1/dist;
                count = count + 1;
            end
        end
        %right
        if col_r <= size(in,1)
            if in(i,col_r)
                point_sum = point_sum + in(i,col_r)/dist;
                total_sum = total_sum + 1/dist;
                count = count + 1;
            end
        end
    end
    % top and bottom row
    for j=col_l +1 :col_r - 1
        if j<1 || j>size(in,2)
            continue
        end
        %distance as weight
        dist = sqrt(radius^2 + j^2);
        %top
        if row_t > 0
            if in(row_t,j)
                point_sum = point_sum + in(row_t,j)/dist;
                total_sum = total_sum + 1/dist;
                count = count + 1;
            end
        end
        %bottom
        if row_b <= size(in,2)
            if in(row_b,j)
                point_sum = point_sum + in(row_b,j)/dist;
                total_sum = total_sum + 1/dist;
                count = count + 1;
            end
        end
    end

end
function [out] = make_dense(in,mask)
    out = zeros(size(in));
    out(mask) = in(mask);
    value_mask = logical(in);
    value_mask = (~value_mask) & mask; % leerstellen in maske
    
    for i=1:size(in,1)
        for j=1:size(in,2)
            if value_mask(i,j)
                radius = 1;
                count = 0;
                total_sum = 0;
                point_sum = 0;
                while count < 6
                    [point_sum,total_sum,count] = search_inside(in,i,j,radius, point_sum, total_sum,count);
                    radius = radius + 1;
                end
                out(i,j) = point_sum/total_sum;
            end
        end
    end
end
