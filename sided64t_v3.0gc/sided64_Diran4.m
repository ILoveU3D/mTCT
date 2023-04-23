clc;clear;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ��Ȼ 20230404 64���μ���У�������ؽ� �汾1.3 ��ʵ�����ؽ����� %%%%%%
% ��ʱ��Ϊ������ ˳ʱ��Ϊ������
load("Para.mat");

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
proj_num_total = 3240;%ͶӰͼ�Ƕȸ���
proj_num = 1080;
proj_num_single = proj_num/source_num;%��Դ�Ƕȸ���
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
sou_pos = getLosspos_sin2_Diran(Source);
det_pos = getLosspos_sin2_Diran(Det);
det_u = getLosspos_sin2_Diran(U);
det_v = getLosspos_sin2_Diran(V);
save("gc.mat","sou_pos","det_pos","det_u","det_v");

%2.2 ������������Proj_vec
%Proj_vec��Ҫ����( rayX, rayY, rayZ, dX, dY, dZ, uX, uY, uZ, vX, vY, vZ )
proj_vec = zeros(proj_num*detector_num , 12);
proj_interval = proj_num_total/proj_num;
for i = 1:proj_num_single
    for j = 1:source_num
        for k = 1:detector_num
             %����Դ����
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,1) = sou_pos(j,1+proj_interval*(i-1),1)/Binning/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,2) = sou_pos(j,1+proj_interval*(i-1),2)/Binning/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,3) = sou_pos(j,1+proj_interval*(i-1),3)/Binning/dSliceInterval;
             %̽�������ĵ�����
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,4) = det_pos(k,1+proj_interval*(i-1),1)/Binning/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,5) = det_pos(k,1+proj_interval*(i-1),2)/Binning/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,6) = det_pos(k,1+proj_interval*(i-1),3)/Binning/dSliceInterval;
             %̽��������(0,0)->(0,1)��������
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,7) = det_u(k,1+proj_interval*(i-1),1)/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,8) = det_u(k,1+proj_interval*(i-1),2)/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,9) = det_u(k,1+proj_interval*(i-1),3)/dSliceInterval;
             %̽��������(0,0)->(1,0)��������
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,10) = det_v(k,1+proj_interval*(i-1),1)/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,11) = det_v(k,1+proj_interval*(i-1),2)/dSampleInterval;
             proj_vec((j-1)*proj_num_single*detector_num + (i-1)*detector_num + k ,12) = det_v(k,1+proj_interval*(i-1),3)/dSliceInterval;
        end
    end
end

projection_matrix = proj_vec;
save( "projVecRealCo.mat", 'projection_matrix');
fprintf("%s\n","Finish!");


