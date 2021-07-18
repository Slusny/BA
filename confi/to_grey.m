%Variables
base_path = "Z:\Students\lslusny\datasets\Adapterplatte\v2_point_dunkel\x\data\cam0";
%{
S1 = dir(fullfile(base_path,'*'));
N = setdiff({S1([S1.isdir]).name},{'.','..'});
for j = 1:numel(N)
    disp(N(j))
    cam_path = base_path + N(j);
    mkdir(cam_path, "\mono");
    mkdir(cam_path, "\color");
    D = cam_path + "\pol\";
    S = dir(fullfile(D,'*.png'));
    for i = 1:numel(S) % remove dots
        RGB = imread(D + S(i).name);
        I = flip(rgb2gray(RGB)', 1);
        RGB = flip(permute(RGB,[2 1 3]),1);
        file = regexp(S(i).name,'\d+','match') + "_deg.png";
        imwrite(I,cam_path + "\mono\" +file)
        imwrite(RGB, cam_path + "\color\" +file)
        delpath = cam_path + "\mono\" + S(i).name;
        delete(delpath)
    end
    dpath = cam_path + "\pol";
    rmdir(dpath, 's')
end
%}
D = base_path + "\pol0\";
mkdir(base_path, "\mono0");
    S = dir(fullfile(D,'*.png'));
    for i = 1:numel(S) % remove dots
        RGB = imread(D + S(i).name);
        I = flip(rgb2gray(RGB)', 1);
        RGB = flip(permute(RGB,[2 1 3]),1);
        file = regexp(S(i).name,'\d+','match') + "_deg.png";
        imwrite(I,base_path + "\mono0\" +file)
        %imwrite(RGB, cam_path + "\color\" +file)
        %delpath = cam_path + "\mono\" + S(i).name;
        %delete(delpath)
    end