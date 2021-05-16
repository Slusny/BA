% folder 0-x orderd from left to right or in originl from bottom to top

%Variables
base_path = "Z:\Students\lslusny\datasets\CombiTip";
direction = "\x";
pixel_size = 0.0000069; % in m;
img_size_x = 1024;
img_size_y = 1224;
step_size = 0.005000; % in m;
make_image = true;
count = 0

Cam_string = [];
mkdir(base_path, "h");

D = strcat(base_path, direction);
S = dir(fullfile(D,'*'));
N = setdiff({S([S.isdir]).name},{'.','..'}); % list of subfolders of D.

Cam_ordering = cell(size(N));
half = floor(length(N)/2);
for i = 1:numel(N)
    sz_minus = size(regexp(N{i},'\-'));
    sz_plus = size(regexp(N{i},'\+'));
    displacement_amount = str2num(char(regexp(N{i},'\d+','match')));
    displacement = (-1*half+displacement_amount) * step_size;
    if i == (half+1)
        refCam = count;
        displacement = "0.0000000";
    end
    cam_str = [
        strcat("[Cam", N{i}, "]")
        "focus=0.025"
        "kappa=0"
        strcat("sx=",num2str(pixel_size, '%.7f'))
        strcat("sy=",num2str(pixel_size, '%.7f'))
        strcat("cy=",num2str(img_size_y/2))
        strcat("cx=",num2str(img_size_x/2))
        strcat("tx=" + num2str(displacement, '%.7f'))
        "ty=0"
        "tz=0"
        "a=0"
        "b=0"
        "g=0"
        ""
        ];
    Cam_ordering{str2num(N{i})+1} = cam_str;
    if make_image
        RGB = imread(strcat(base_path, "\x\", char(N{i}), "\pol\pol_0°.png"));
        I = rgb2gray(RGB);
        mkdir(base_path+"\h", "\cam" + N{i})
        imwrite(I',base_path + "\h\cam" + N{i} + "\img_0.png")
    end
    count=count+1
        
end

for k=1:length(Cam_ordering)
   Cam_string = [Cam_string' Cam_ordering{k}']';
end

% create confi.ini file
param_str = [
    "[Params]"
    strcat("output_path=", base_path, "\data.h5")
    strcat("noOfCams=", num2str(count))
    "noOfImages=1"
    "refCamera=" + refCam
    strcat("ImgWidth=",  num2str(img_size_x))
    strcat("ImgHeight=",  num2str(img_size_y))
    "imageDepth=0"
    "imgType=png"
    strcat("DataPath=", base_path, "\h\")
    ""
    ];

whole_str = [param_str' Cam_string']';

fid = fopen(strcat(base_path,'\confi.ini'),'wt');
fprintf(fid, '%s\n', whole_str);
fclose(fid);
