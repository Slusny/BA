v = load("C:\Users\lennart\Desktop\BA\BA\normal_integration-master\Datasets\vase.mat");

X = [];
Z = [];
Y = [];
%{
X1 = 1:size(v.p,1);
for i=1:size(v.p,1)
    X= cat(2,X,X1);
end

for i=1:size(v.p,1)
    Y2 = ones(1,size(v.p,1));
    Y = cat(2,Y,Y2*i);
    Z = cat(2,Z,Y2);
end

U = reshape(v.p,[1,numel(v.p)]);
V = reshape(v.q,[1,numel(v.q)]);
W = reshape(v.u,[1,numel(v.u)]);
figure
quiver3(X,Y,Z,U,V,W,3);
axis equal
%}
% Try this example
[X,Y] = meshgrid(1:.1:100,1:.1:100); 
R = sin(Y/1) + eps;
Z = R;
[nx,ny,nz] = surfnorm(X,Y,Z);
b = reshape([nx ny nz], size(nx,1), size(nx,2),3);
b = ((b+1)./2).*255;
figure
imshow(uint8(b));