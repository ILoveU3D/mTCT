clc;clear;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 弟然 20230403 64边形仿真重建 版本1.1 真实数据重建几何 %%%%%%
% 重建三维体块真实大小固定，但可修改重建图三个方向的重建体素个数
% addpath(genpath('astra-2.1.0'));
% addpath(genpath('func'));
% addpath(genpath('data'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 基本参数 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1.1 常规几何
SID = 1143;
SOD = 708;
source_num = 24;
detector_num = 64;
Binning = 4;
dPixelSpacing = 0.265*Binning;%探测器像素大小
R1 = SOD/dPixelSpacing;
R2 = (SID-SOD)/dPixelSpacing;
Z_offset = 100;
proj_width_total = 10240/Binning;%投影图宽
proj_width_single = proj_width_total/detector_num;%单个探测器宽
proj_height = 288/Binning;%投影图高
proj_num_total = 1080;%投影图角度个数
proj_num_single = proj_num_total/source_num;%单源角度个数
nReconWid = 256;%重建图大小
nReconSlices = 72;%重建图层数,理论计算结果为418层

% 1.2 根据几何放大关系修改XY方向参数
origin_width = 3072/Binning;
theta_dec = origin_width/(2*(SID-SOD)/dPixelSpacing);
BG = (SID-SOD)/dPixelSpacing*sin(theta_dec);
AG = (SID-SOD)/dPixelSpacing*cos(theta_dec) + SOD/dPixelSpacing;
AB = (BG*BG + AG*AG)^0.5;
dRadiusTemp = BG/AB*SOD/dPixelSpacing*2;
dSampleInterval = dRadiusTemp/nReconWid;

% 1.3 根据几何放大关系修改Z方向参数
z0 = Z_offset/dPixelSpacing*SOD/SID;
z1 = (SOD/dPixelSpacing - dRadiusTemp/2)*(Z_offset/dPixelSpacing - proj_height/2)/(SID/dPixelSpacing);
z2 = (SOD/dPixelSpacing + dRadiusTemp/2)*(Z_offset/dPixelSpacing + proj_height/2)/(SID/dPixelSpacing);
tempz = (z1+z2)/2 - z0;
Z_offset_Sou = - Z_offset/dPixelSpacing*SOD/SID - tempz;%射线源Z向偏移量
Z_offset_Dec = Z_offset/dPixelSpacing*(1 - SOD/SID) - tempz;%探测器Z向偏移量
TablePosition = zeros(proj_num_single,1);%如果TablePosition的值均为0 ，就变成轴扫
dSliceInterval = (z2 - z1)/nReconSlices;

dSampleInterval = 0.25;
dSliceInterval = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 构建geometry %%%%%%%%%%%%%%%%%%%%%%%%%
%2.1 假设1号射线源在y轴正半轴(0,708)上，计算与其正对的1号探测器与y轴负半轴的交点
% 从而得到焦点-原点与探测器中心点-原点连线的夹角
det_offset = 21.0049 - (proj_width_single-2)*dPixelSpacing/2;
SouDec_offset = pi + atan(det_offset/(R2*dPixelSpacing));
souAngle_interval = 2*pi/source_num;
detAngle_interval = -2*pi/detector_num;
% projAngle_interval = 2*pi/proj_num_total;
souAngleInit = zeros(source_num,1);
detAngleInit = zeros(detector_num,1);
for i = 1:source_num
    souAngleInit(i) = (i-1)*souAngle_interval;
end
for k = 1:detector_num
    detAngleInit(k) = SouDec_offset + (k-32)*detAngle_interval;
end
load("angles.mat", "Angle");
%2.2 构建向量矩阵Proj_vec
%Proj_vec需要参数( rayX, rayY, rayZ, dX, dY, dZ, uX, uY, uZ, vX, vY, vZ )
proj_vec = zeros(proj_num_total*detector_num , 12);
for i = 1:proj_num_single
    detAngle = detAngleInit + Angle(i);
    souAngle = souAngleInit + Angle(i);
    for j = 1:source_num
        for k = 1:detector_num
             %射线源坐标
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,1) = R1*cos(souAngle(j))/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,2) = R1*sin(souAngle(j))/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,3) = Z_offset_Sou/dSliceInterval + TablePosition(i);
             %探测器中心点坐标
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,4) = R2*cos(detAngle(k))/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,5) = R2*sin(detAngle(k))/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,6) = Z_offset_Dec/dSliceInterval + TablePosition(i);
             %探测器像素(0,0)->(0,1)方向向量
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,7) = 0;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,8) = 0;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,9) = 1/dSliceInterval;
             %探测器像素(0,0)->(1,0)方向向量
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,10) = cos(detAngle(k) - pi/2)/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,11) = sin(detAngle(k) - pi/2)/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,12) = 0;
        end
    end
end

projection_matrix = proj_vec;
save( "projVecReal.mat", 'projection_matrix');
fprintf("%s\n","Finish!");


