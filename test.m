%in = load("C:\Users\lennart\Desktop\BA\BA\Discrete-normal-integration\data\bunny\pol_normals.mat");
%in = load("C:\Users\lennart\Desktop\BA\BA\Discrete-normal-integration\data\bunny\bunny_normal.mat");
%v = load("C:\Users\lennart\Desktop\BA\BA\normal_integration-master\Datasets\vase.mat");

v.p = in.data(:,:,1);
v.q = in.data(:,:,2);
v.u = in.data(:,:,3);

X = [];
Z = [];
Y = [];

X1 = 1:size(v.p,2);
for i=1:size(v.p,1)
    X= cat(2,X,X1);
end

for i=1:size(v.p,2)
    Y2 = ones(1,size(v.p,1));
    Y = cat(2,Y,Y2*i);
    Z = cat(2,Z,Y2*1);
end

U = reshape(v.p,[1,numel(v.p)]);
V = reshape(v.q,[1,numel(v.q)]);
W = reshape(v.u,[1,numel(v.u)]);
figure
i=50
quiver3(X(1:i:end),Y(1:i:end),Z(1:i:end),U(1:i:end),V(1:i:end),W(1:i:end));
%axis equal

% Try this example
%{
[X,Y] = meshgrid(1:.1:100,1:.1:100); 
R = sin(Y/1) + eps;
Z = R;
[nx,ny,nz] = surfnorm(X,Y,Z);
b = reshape([nx ny nz], size(nx,1), size(nx,2),3);
b = ((b+1)./2).*255;
figure
imshow(uint8(b));
%}