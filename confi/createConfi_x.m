%Variables
base_path = "Z:\Students\lslusny\datasets\Knie\v2\x";
pixel_size = 0.0000069; % in m;
img_size_x = 1024;
img_size_y = 1224;
step_size = 0.002000; % in m;
make_image = false;
count = 0

Cam_string = [];
%mkdir(base_path, "lumione_pc");
%mkdir(base_path + "\lumione_pc", "h");
%x

D = base_path + "\data";
S = dir(fullfile(D,'*'));
N1 = setdiff({S([S.isdir]).name},{'.','..'}); % list of subfolders of D.
N = {};
for i = 1:numel(N1) % remove dots
    dot_cam = size(regexp(N1{i},'.cam'));
    if dot_cam(2)>0
        continue
    end
    N{end+1} = N1{i};
end

Cam_ordering = cell(size(N));
middle = floor(length(N)/2)+1;
for i = 1:numel(N)
    sz_minus = size(regexp(N{i},'\-'));
    sz_plus = size(regexp(N{i},'\+'));
    displacement_amount = str2num(char(regexp(N{i},'\d+','match')));
    if displacement_amount == 0
        pos = middle;
        displacement = "0.0000000";
    elseif sz_minus(2)>0
        displacement = strcat("-",num2str(displacement_amount*step_size, '%.7f'));
        pos = middle - displacement_amount;
    elseif sz_plus(2)>0
        displacement = strcat(num2str(displacement_amount*step_size, '%.7f'));
        pos = middle + displacement_amount;
    else
        continue
    end
    cam_str = [
        "[Cam" + (pos - 1) + "]"
        "focus=0.025"
        "kappa=0"
        strcat("sx=",num2str(pixel_size, '%.7f'))
        strcat("sy=",num2str(pixel_size, '%.7f'))
        strcat("cy=",num2str(img_size_y/2))
        strcat("cx=",num2str(img_size_x/2))
        strcat("tx=",displacement)
        "ty=0"
        "tz=0"
        "a=0"
        "b=0"
        "g=0"
        ""
        ];
    Cam_ordering{pos} = cam_str;
    if make_image
        RGB = imread(strcat(base_path, "\data\", char(N{i}), "\pol\pol_0°.png"));
        I = rgb2gray(RGB);
        %I = imrotate(I,-90);
        mkdir(base_path+"\lumione_pc\h", "\cam" + (pos -1))
        imwrite(I',base_path + "\lumione_pc\h\cam" + (pos-1) + "\img_0.png")
    end
    count=count+1
        
end

for k=1:length(Cam_ordering)
   Cam_string = [Cam_string' Cam_ordering{k}']';
end

%y
%{
D = strcat(base_path, "\y");
S = dir(fullfile(D,'*'));
N = flip(setdiff({S([S.isdir]).name},{'.','..'})); % list of subfolders of D.
for i = 1:numel(N)
    sz_minus = size(regexp(N{i},'\-'));
    sz_plus = size(regexp(N{i},'\+'));
    displacement_amount = str2num(char(regexp(N{i},'\d+','match')));
    if sz_minus(2)>0
        displacement = strcat("-",num2str(displacement_amount*step_size, '%.7f'));
    elseif sz_plus(2)>0
        displacement = num2str(displacement_amount*step_size, '%.7f');
    elseif N{i}=="cam0"
        refCam = count;
    else
        continue
    end
    cam_str = [
        strcat("[Cam", num2str(count), "]")
        "focus=0.025"
        "kappa=0"
        strcat("sx=",num2str(pixel_size, '%.7f'))
        strcat("sy=",num2str(pixel_size, '%.7f'))
        strcat("cy=",num2str(img_size_y/2))
        strcat("cx=",num2str(img_size_x/2))
        "tx=0"
        strcat("ty=",displacement)
        "tz=0"
        "a=0"
        "b=0"
        "g=0"
        ""
        ];
    Cam_string = [Cam_string' cam_str']';
    if make_image
        RGB = imread(strcat(base_path, "\y\", char(N{i}), "\pol\pol_0°.png"));
        I = rgb2gray(RGB);
        mkdir(base_path+"\h", "\cam" + count)
        imwrite(I',base_path + "\h\cam" + count + "\img_0.png")
    end
    count=count+1
        
end
%}

% create confi.ini file
param_str = [
    "[Params]"
    strcat("output_path=", base_path, "\lumione_pc\data.h5")
    strcat("noOfCams=", num2str(count))
    "noOfImages=1"
    "refCamera=" + (middle-1)
    strcat("ImgWidth=",  num2str(img_size_x))
    strcat("ImgHeight=",  num2str(img_size_y))
    "imageDepth=0"
    "imgType=png"
    strcat("DataPath=", base_path, "\lumione_pc\h\")
    ""
    ];

whole_str = [param_str' Cam_string']';

fid = fopen(strcat(base_path,'\lumione_pc\confi.ini'),'wt');
fprintf(fid, '%s\n', whole_str);
fclose(fid);
%{
for n = 4:-1:0
    path = 'Z:\Students\lslusny\manuell\h\cam' + string(n) + '\img0.png';
    RGB = imread(path);
    I = rgb2gray(RGB);
    imwrite(I,path)
end
%}