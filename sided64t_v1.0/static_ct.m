clear all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% �������� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1.1 ���漸��
SID = 1143;
SOD = 708;
Binning = 1;
dPixelSpacing = 0.265*Binning;%̽�������ش�С
R1 = SOD/dPixelSpacing;
R2 = (SID-SOD)/dPixelSpacing;
Z_offset = 100;
ProjWidth = 3072/Binning;%ͶӰͼ��
ProjHeight = 288/Binning;%ͶӰͼ��
ProjWidth_cut = 3072;
ProjHeight_cut = 288;
Angle_num = 1080;%ͶӰͼ�Ƕȸ���
nReconWid = 256;%�ؽ�ͼ��С
nReconSlices = 72;%�ؽ�ͼ����,���ۼ�����Ϊ418��
%1.2 ���ݼ��ηŴ��ϵ�޸�XY�������
theta_dec = ProjWidth_cut/(2*(SID-SOD)/dPixelSpacing);
BG = (SID-SOD)/dPixelSpacing*sin(theta_dec);
AG = (SID-SOD)/dPixelSpacing*cos(theta_dec) + SOD/dPixelSpacing;
AB = (BG*BG + AG*AG)^0.5;
dRadiusTemp = BG/AB*SOD/dPixelSpacing*2;
dSampleInterval = dRadiusTemp/nReconWid;
%1.3 ���ݼ��ηŴ��ϵ�޸�Z�������
z0 = Z_offset/dPixelSpacing*SOD/SID;
z1 = (SOD/dPixelSpacing - dRadiusTemp/2)*(Z_offset/dPixelSpacing - ProjHeight_cut/2)/(SID/dPixelSpacing);
z2 = (SOD/dPixelSpacing + dRadiusTemp/2)*(Z_offset/dPixelSpacing + ProjHeight_cut/2)/(SID/dPixelSpacing);
tempz = (z1+z2)/2 - z0;
Z_offset_Sou = - Z_offset/dPixelSpacing*SOD/SID - tempz;%����ԴZ��ƫ����
Z_offset_Dec = Z_offset/dPixelSpacing*(1 - SOD/SID) - tempz;%̽����Z��ƫ����
TablePosition = zeros(Angle_num,1);%���TablePosition��ֵ��Ϊ0 ���ͱ����ɨ
dSliceInterval = (z2 - z1)/nReconSlices;

% dSampleInterval = 3.6744;
% dSliceInterval = 3.5863;
Binning = 1;
dPixelSpacing = 0.265*Binning;%̽�������ش�С
d = 869.5 / dPixelSpacing; %̽������תֱ��
D = 1418 / dPixelSpacing; %Դ��תֱ��
z_bias = 100 / dPixelSpacing; %z��ƫ��
angle_yiquan = 360;
angle_all = 1080;
src_num = 24;
det_num = 64;
rotation_num = angle_all / src_num;
rotation_interval = angle_yiquan / angle_all;
projection_matrix = zeros(rotation_num, src_num, det_num, 12);
for rotation_index=1:rotation_num
    rotation_angle = rotation_index * rotation_interval * pi/180;
    rotation_matrix = [cos(rotation_angle) -sin(rotation_angle) 0; sin(rotation_angle) cos(rotation_angle) 0; 0 0 1];
    for src_index=1:src_num
        src_angle = src_index / src_num * pi*2;
        src_place_init = [-D/2*sin(src_angle) D/2*cos(src_angle) 0];
        src_place = (rotation_matrix * src_place_init')';
        for det_index=1:det_num
            det_angle = det_index / det_num * pi*2;
            det_place_init = [-d/2*sin(det_angle) d/2*cos(det_angle) z_bias];
            det_place = (rotation_matrix * det_place_init')';
            det_dir_init = [-cos(det_angle) -sin(det_angle) 0];
            det_dir = (rotation_matrix * det_dir_init')';
            projection_matrix(rotation_index, src_index, det_index, 1) = src_place(1) / dSampleInterval;
            projection_matrix(rotation_index, src_index, det_index, 2) = src_place(2) / dSampleInterval;
            projection_matrix(rotation_index, src_index, det_index, 3) = src_place(3) / dSliceInterval;
            projection_matrix(rotation_index, src_index, det_index, 4) = det_place(1) / dSampleInterval;
            projection_matrix(rotation_index, src_index, det_index, 5) = det_place(2) / dSampleInterval;
            projection_matrix(rotation_index, src_index, det_index, 6) = det_place(3) / dSliceInterval;
            projection_matrix(rotation_index, src_index, det_index, 7) = 0;
            projection_matrix(rotation_index, src_index, det_index, 8) = 0;
            projection_matrix(rotation_index, src_index, det_index, 9) = 1 / dSliceInterval;
            projection_matrix(rotation_index, src_index, det_index, 10) = det_dir(1) / dSampleInterval;
            projection_matrix(rotation_index, src_index, det_index, 11) = det_dir(2) / dSampleInterval;
            projection_matrix(rotation_index, src_index, det_index, 12) = 0;
        end
    end
end
projection_matrix = reshape(projection_matrix, [rotation_index * src_index * det_index, 12]);
fprintf("%s","Finish!");
