clc;clear;
exposureOrder = [1,9,17,2,10,18,3,11,19,4,12,20,5,13,21,6,14,22,7,15,23,8,16,24]; %24Դ���ع�˳��
sourceNum = 24;
p = 1.0;
view = 1080;
root = "E:\\����\\����\\����\\";
sid = 708;%Դ����ת���ľ���
sod = 1143;%Դ��̽��������
dPixelSpacing = 0.265;%���ص���
if p>=1%p>=1ʱ����ת1Ȧ
    rotateNum = 1.0;
else%p<1ʱ��Ҫ��ת����Ȧ
    rotateNum = 1/p;
end
views = view * ceil(rotateNum) *1;%��Ȧ������ȡ��������ȡ��ͶӰ�Ƕ���
pixelCut = 32;%��̽�����߶�288�����ϣ�����ȥ�����ٸ�����
if sourceNum <= 3
    zbias = 0;%̽����С�ڵ���3ʱ��Դ��̽����������ͬһƽ��
else
    zbias = 100 - pixelCut/2*dPixelSpacing;%Դ��̽�����ڲ�ͬƽ��ʱ����ƽ����z�����ƫ��
end
proHeight = (288 - pixelCut)*dPixelSpacing; %̽�����߶�
dAngle = pi / 180 * 360/view;%Դ��С����ת�����������
%%%%%%%%%%%%%%%%%%%%%%%%% ������ؽ�����ʼ %%%%%%%%%%%%%%%%%%%%%%%%%
Rz=0.0;
z1s=(sid - Rz)*(zbias - proHeight/2)/sod;
z1e=(sid - Rz)*(zbias + proHeight/2)/sod;
z2s=(sid + Rz)*(zbias - proHeight/2)/sod;
z2e=(sid + Rz)*(zbias + proHeight/2)/sod;
zs = max(z1s, z2s);
ze = min(z1e, z2e);
zSlice = ze-zs;
%%%%%%%%%%%%%%%%%%%%%%%%% ������ؽ�������� %%%%%%%%%%%%%%%%%%%%%%%%%
AngleTableSource = zeros(views,3);
tableInit = -1/2*(views - 1) * zSlice * p / view;
for exposureIndex = 0:views-1
%     rotateAngle = ceil((exposureIndex+1)/sourceNum) * dAngle;%�ô��ع⣬����ʵ����ת�Ƕ�
    rotateAngle = exposureIndex / view * 2*pi/sourceNum;
    sourceIndex = exposureOrder(mod(exposureIndex,sourceNum) + 1);%�ô��ع⣬���ĸ�Դ
    angleReal = rotateAngle + 2 * pi / sourceNum * sourceIndex; %������ת�Ƕȼ��ϸ�Դ����ĳ�ʼ�Ƕȣ��õ���������ϵ�µĽǶ�
    table = exposureIndex * zSlice * p / view + tableInit;%��ǰ���ľ���
    AngleTableSource(exposureIndex+1, 1) = angleReal;
    AngleTableSource(exposureIndex+1, 2) = table;
    AngleTableSource(exposureIndex+1, 3) = sourceIndex;
end
save( char( strcat(root,"AngleTableSource.mat") ), 'AngleTableSource');