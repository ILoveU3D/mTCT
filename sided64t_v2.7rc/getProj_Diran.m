% 1.4 读取投影数据
%投影图路径
proj_path ='/media/wyk/wyk/Data/wsr/proj/';
proj_PathList = dir(strcat(proj_path,'*.raw'));
proj_angles = length(proj_PathList);
proj_num = 1080;
proj_Interval = floor(proj_angles/proj_num);
proj_width = 2560;proj_height = 72;proj_width_cut = 840;
proj_data = zeros(proj_width_cut,proj_height,proj_num);
proj_angle = zeros(proj_angles,2);%第一行存角度，第二行存索引
Angle = zeros(proj_num,1);
for i = 1:proj_angles
    projName = proj_PathList(i).name;% Proj name
    c = regexp(projName,'-?\d*\.?\d*','match');
    proj_angle(i,1) = str2double(c{1,2});%读取所有的投影数据
    proj_angle(i,2) = i;
end

proj_angle = sortrows(proj_angle,1);
i_angle = 1;
for i = 1:proj_Interval:proj_angles
    %从一张投影图中读出投影角度
    Angle(i_angle) = proj_angle(i,1)*pi/180;
    
    %从一张投影图中读出投影数据
    projName = proj_PathList(proj_angle(i,2)).name;% Proj name
    currFileName = fullfile(proj_path,projName); % Proj name including of path
    fileID = fopen(currFileName); % Open the current proj file
    currProjData = fread(fileID,[proj_width proj_height],'float'); 
    fclose(fileID);
     
    proj_data(:,:,i_angle) = cut(currProjData, floor(proj_angle(i,1)/15)+1);
    i_angle = i_angle + 1;
end

save_file("/media/wyk/wyk/Data/wsr//projection.raw", proj_data);
save("angles.mat", "Angle");

function save_file(path, img)
fileID = fopen(path, 'wb+'); % Save the new proj data
fwrite(fileID, img, 'float');
fclose(fileID);
end

function cut_proj = cut(proj, source)
source_num = 24;detector_num = 64;detector_num_cut = 21;proj_width = 2560;
proj_width_single = floor(proj_width / detector_num);
get_detector = @(s) mod(round((source_num/2-s+1)*detector_num/source_num), detector_num);
center_detector = get_detector(source);
if center_detector == 0
    center_detector = detector_num;
end
radius = floor(detector_num_cut/2);
if center_detector - radius - 1 <= 0
    cut_proj = [proj((detector_num-radius+center_detector-1)*proj_width_single:detector_num*proj_width_single,:);proj(1:(center_detector+radius)*proj_width_single-1,:)];
elseif center_detector + radius >= detector_num
    cut_proj = [proj((center_detector-radius-1)*proj_width_single:detector_num*proj_width_single,:);proj(1:(center_detector + radius - detector_num)*proj_width_single-1,:)];
else
    cut_proj = proj((center_detector-radius-1)*proj_width_single:(center_detector+radius)*proj_width_single-1,:);
end
end