%Variables
base_path = "Z:\Students\lslusny\datasets\Knie\v2\x\data\cam0";

mkdir(base_path, "\grey");

D = base_path + "\pol\";
S = dir(fullfile(D,'*.png'));
for i = 1:numel(S) % remove dots
    RGB = imread(D + S(i).name);
    I = rgb2gray(RGB);
    imwrite(I',base_path + "\grey\" +S(i).name)
end
