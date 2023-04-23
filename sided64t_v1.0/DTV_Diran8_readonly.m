clc;clear;
SID = 1143;
SOD = 708;
Binning = 1;
dPixelSpacing = 0.265*Binning;%̽�������ش�С
R1 = SOD/dPixelSpacing;
R2 = (SID-SOD)/dPixelSpacing;
Z_offset = 100;
% ProjWidth = 3072/Binning;%ͶӰͼ��
% ProjHeight = 288/Binning;%ͶӰͼ��
ProjWidth = 3072;
ProjHeight = 288;
Angle_num = 1080;%ͶӰͼ�Ƕȸ���
nReconWid = 256;%�ؽ�ͼ��С
nReconSlices = 72;%�ؽ�ͼ����,���ۼ�����Ϊ418��

%1.2 ���ݼ��ηŴ��ϵ�޸�XY�������
theta_dec = ProjWidth/(2*(SID-SOD)/dPixelSpacing);
BG = (SID-SOD)/dPixelSpacing*sin(theta_dec);
AG = (SID-SOD)/dPixelSpacing*cos(theta_dec) + SOD/dPixelSpacing;
AB = (BG*BG + AG*AG)^0.5;
dRadiusTemp = BG/AB*SOD/dPixelSpacing*2;
dSampleInterval = dRadiusTemp/nReconWid;

%1.3 ���ݼ��ηŴ��ϵ�޸�Z�������
z0 = Z_offset/dPixelSpacing*SOD/SID;
z1 = (SOD/dPixelSpacing - dRadiusTemp/2)*(Z_offset/dPixelSpacing - ProjHeight/2)/(SID/dPixelSpacing);
z2 = (SOD/dPixelSpacing + dRadiusTemp/2)*(Z_offset/dPixelSpacing + ProjHeight/2)/(SID/dPixelSpacing);
tempz = (z1+z2)/2 - z0;
Z_offset_Sou = - Z_offset/dPixelSpacing*SOD/SID - tempz;%����ԴZ��ƫ����
Z_offset_Dec = Z_offset/dPixelSpacing*(1 - SOD/SID) - tempz;%̽����Z��ƫ����
TablePosition = zeros(Angle_num,1);%���TablePosition��ֵ��Ϊ0 ���ͱ����ɨ
dSliceInterval = (z2 - z1)/nReconSlices;

Angle = linspace(0,360,Angle_num) * pi / 180;
proj_vec = zeros(Angle_num*ProjWidth , 12);
for i = 1:Angle_num
    for j = 1:ProjWidth
         %����Դ����
         proj_vec((j-1)*Angle_num + i ,1) = R1*cos(Angle(i) + pi)/dSampleInterval;
         proj_vec((j-1)*Angle_num + i ,2) = R1*sin(Angle(i) + pi)/dSampleInterval;
         proj_vec((j-1)*Angle_num + i ,3) = Z_offset_Sou/dSliceInterval + TablePosition(i);
         %̽�������ĵ�����
         proj_vec((j-1)*Angle_num + i ,4) = R2*cos(Angle(i)-(j-ProjWidth/2-0.5)/R2)/dSampleInterval;
         proj_vec((j-1)*Angle_num + i ,5) = R2*sin(Angle(i)-(j-ProjWidth/2-0.5)/R2)/dSampleInterval;
         proj_vec((j-1)*Angle_num + i ,6) = Z_offset_Dec/dSliceInterval + TablePosition(i);
         %̽��������(0,0)->(0,1)��������
         proj_vec((j-1)*Angle_num + i ,7) = 0;
         proj_vec((j-1)*Angle_num + i ,8) = 0;
         proj_vec((j-1)*Angle_num + i ,9) = 1/dSliceInterval;
         %̽��������(0,0)->(1,0)��������
         proj_vec((j-1)*Angle_num + i ,10) = cos(Angle(i)-(j-ProjWidth/2-0.5)/R2 - pi/2)/dSampleInterval;
         proj_vec((j-1)*Angle_num + i ,11) = sin(Angle(i)-(j-ProjWidth/2-0.5)/R2 - pi/2)/dSampleInterval;
         proj_vec((j-1)*Angle_num + i ,12) = 0;
    end
end


