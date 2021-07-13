load("Z:\Students\lslusny\datasets\Kugel\v2_point\x\lumione_pc\lin\big_spec\data_half.mat")
base_path = "Z:\Students\lslusny\datasets\Defect1\v7\x";
addpath("utils")
% Compute angles, taking into account different model for specular pixels
mask =cam1.mask  ;
Iun_est  = cam1.Iun_est ;
%spec = logical(zeros(size(Iun_est))); 
spec = cam1.specmask ;
%theta_est_spec = zeros(size(Iun_est)); 
theta_est_spec = cam1.theta_est_spec;
theta_est_combined = cam1.theta_est_diffuse;
theta_est_combined(spec)=theta_est_spec(spec);
phi_est = cam1.phi_est;
phi_est_combined = cam1.phi_est;
phi_est_combined(spec)=mod(cam1.phi_est(spec)+pi/2,pi);
figure('Name','Theta', 'NumberTitle', 'off'); imshow(theta_est_combined); colorbar

% Estimate light source direction from diffuse pixels (note that you might
[ s,T,B ] = findLight( theta_est_combined,phi_est,Iun_est,mask&~spec,3 );

% Compute boundary prior azimuth angles and weight
[ azi,Bdist ] = boundaryPrior( mask );

specmask = spec;
cam1.Iun_est = Iun_est;
cam1.rho_est=cam1.rho_est;
cam1.phi_est=phi_est;
cam1.theta_est_diffuse=cam1.theta_est_diffuse;
cam1.theta_est_spec=theta_est_spec;
cam1.mask = mask;
cam1.specmask = specmask;

% dings
%{
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

% show dense vs original
if true 
    N_g_img(:,:,1) = floor((N_guide(:,:,1)+1)*128);
    N_g_img(:,:,2) = floor((N_guide(:,:,2)+1)*128);
    N_g_img(:,:,3) = floor((N_guide(:,:,3)+1)*128);
    figure; imshow(N_test); figure; imshow(N_guide);
end

%example = load("../../CVPR2019-master/CVPR2019-master/data/horse_disparity_median.mat");
%N = example.N_guide;

% Show Pointcloud coverage 
%{
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
%}
%{%}
save(base_path + "\lumione_pc\nonlin_r0.01_th0.9\data_nospec", 'polAng','cam1', 'N_guide')
disp("wrote data");
%}
% Run linear height from polarisation
[ height ] = HfPol( theta_est_combined,min(1,Iun_est),phi_est_combined,s,mask,false,spec );

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
