clc;clear;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 弟然 20230404 64边形几何校正参数重建 版本1.3 真实数据重建几何 %%%%%%
% 逆时针为正方向 顺时针为负方向
load("Para.mat");

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
proj_num_total = 3240;%投影图角度个数
proj_num = 1080;
proj_num_single = proj_num/source_num;%单源角度个数
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
sou_pos = getLosspos_sin2_Diran(Source);
det_pos = getLosspos_sin2_Diran(Det);
det_u = getLosspos_sin2_Diran(U);
det_v = getLosspos_sin2_Diran(V);
save("gc.mat","sou_pos","det_pos","det_u","det_v");

%2.2 构建向量矩阵Proj_vec
%Proj_vec需要参数( rayX, rayY, rayZ, dX, dY, dZ, uX, uY, uZ, vX, vY, vZ )
proj_vec = zeros(proj_num*detector_num , 12);
proj_interval = proj_num_total/proj_num;
for i = 1:proj_num_single
    for j = 1:source_num
        for k = 1:detector_num
             %射线源坐标
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,1) = sou_pos(j,1+proj_interval*(i-1),1)/Binning/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,2) = sou_pos(j,1+proj_interval*(i-1),2)/Binning/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,3) = sou_pos(j,1+proj_interval*(i-1),3)/Binning/dSliceInterval;
             %探测器中心点坐标
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,4) = det_pos(k,1+proj_interval*(i-1),1)/Binning/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,5) = det_pos(k,1+proj_interval*(i-1),2)/Binning/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,6) = det_pos(k,1+proj_interval*(i-1),3)/Binning/dSliceInterval;
             %探测器像素(0,0)->(0,1)方向向量
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,7) = det_u(k,1+proj_interval*(i-1),1)/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,8) = det_u(k,1+proj_interval*(i-1),2)/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,9) = det_u(k,1+proj_interval*(i-1),3)/dSliceInterval;
             %探测器像素(0,0)->(1,0)方向向量
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,10) = det_v(k,1+proj_interval*(i-1),1)/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,11) = det_v(k,1+proj_interval*(i-1),2)/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,12) = det_v(k,1+proj_interval*(i-1),3)/dSliceInterval;
        end
    end
end

projection_matrix = proj_vec;
save( "projVecRealCo.mat", 'projection_matrix');
fprintf("%s\n","Finish!");


