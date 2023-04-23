clc;clear;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ��Ȼ 20230403 64���η����ؽ� �汾1.1 ��ʵ�����ؽ����� %%%%%%
% �ؽ���ά�����ʵ��С�̶��������޸��ؽ�ͼ����������ؽ����ظ���
% addpath(genpath('astra-2.1.0'));
% addpath(genpath('func'));
% addpath(genpath('data'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% �������� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1.1 ���漸��
SID = 1143;
SOD = 708;
source_num = 24;
detector_num = 64;
Binning = 4;
dPixelSpacing = 0.265*Binning;%̽�������ش�С
R1 = SOD/dPixelSpacing;
R2 = (SID-SOD)/dPixelSpacing;
Z_offset = 100;
proj_width_total = 10240/Binning;%ͶӰͼ��
proj_width_single = proj_width_total/detector_num;%����̽������
proj_height = 288/Binning;%ͶӰͼ��
proj_num_total = 1080;%ͶӰͼ�Ƕȸ���
proj_num_single = proj_num_total/source_num;%��Դ�Ƕȸ���
nReconWid = 256;%�ؽ�ͼ��С
nReconSlices = 72;%�ؽ�ͼ����,���ۼ�����Ϊ418��

% 1.2 ���ݼ��ηŴ��ϵ�޸�XY�������
origin_width = 3072/Binning;
theta_dec = origin_width/(2*(SID-SOD)/dPixelSpacing);
BG = (SID-SOD)/dPixelSpacing*sin(theta_dec);
AG = (SID-SOD)/dPixelSpacing*cos(theta_dec) + SOD/dPixelSpacing;
AB = (BG*BG + AG*AG)^0.5;
dRadiusTemp = BG/AB*SOD/dPixelSpacing*2;
dSampleInterval = dRadiusTemp/nReconWid;

% 1.3 ���ݼ��ηŴ��ϵ�޸�Z�������
z0 = Z_offset/dPixelSpacing*SOD/SID;
z1 = (SOD/dPixelSpacing - dRadiusTemp/2)*(Z_offset/dPixelSpacing - proj_height/2)/(SID/dPixelSpacing);
z2 = (SOD/dPixelSpacing + dRadiusTemp/2)*(Z_offset/dPixelSpacing + proj_height/2)/(SID/dPixelSpacing);
tempz = (z1+z2)/2 - z0;
Z_offset_Sou = - Z_offset/dPixelSpacing*SOD/SID - tempz;%����ԴZ��ƫ����
Z_offset_Dec = Z_offset/dPixelSpacing*(1 - SOD/SID) - tempz;%̽����Z��ƫ����
TablePosition = zeros(proj_num_single,1);%���TablePosition��ֵ��Ϊ0 ���ͱ����ɨ
dSliceInterval = (z2 - z1)/nReconSlices;

dSampleInterval = 0.25;
dSliceInterval = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ����geometry %%%%%%%%%%%%%%%%%%%%%%%%%
%2.1 ����1������Դ��y��������(0,708)�ϣ������������Ե�1��̽������y�Ḻ����Ľ���
% �Ӷ��õ�����-ԭ����̽�������ĵ�-ԭ�����ߵļн�
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
%2.2 ������������Proj_vec
%Proj_vec��Ҫ����( rayX, rayY, rayZ, dX, dY, dZ, uX, uY, uZ, vX, vY, vZ )
proj_vec = zeros(proj_num_total*detector_num , 12);
for i = 1:proj_num_single
    detAngle = detAngleInit + Angle(i);
    souAngle = souAngleInit + Angle(i);
    for j = 1:source_num
        for k = 1:detector_num
             %����Դ����
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,1) = R1*cos(souAngle(j))/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,2) = R1*sin(souAngle(j))/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,3) = Z_offset_Sou/dSliceInterval + TablePosition(i);
             %̽�������ĵ�����
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,4) = R2*cos(detAngle(k))/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,5) = R2*sin(detAngle(k))/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,6) = Z_offset_Dec/dSliceInterval + TablePosition(i);
             %̽��������(0,0)->(0,1)��������
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,7) = 0;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,8) = 0;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,9) = 1/dSliceInterval;
             %̽��������(0,0)->(1,0)��������
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,10) = cos(detAngle(k) - pi/2)/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,11) = sin(detAngle(k) - pi/2)/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,12) = 0;
        end
    end
end

projection_matrix = proj_vec;
save( "projVecReal.mat", 'projection_matrix');
fprintf("%s\n","Finish!");


