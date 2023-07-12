clc;clear;
exposureOrder = [1,9,17,2,10,18,3,11,19,4,12,20,5,13,21,6,14,22,7,15,23,8,16,24]; %24源的曝光顺序
sourceNum = 24;
p = 1.0;
view = 1080;
root = "E:\\北京\\交接\\仿真\\";
sid = 708;%源到旋转中心距离
sod = 1143;%源到探测器距离
dPixelSpacing = 0.265;%像素点间隔
if p>=1%p>=1时，旋转1圈
    rotateNum = 1.0;
else%p<1时，要旋转更多圈
    rotateNum = 1/p;
end
views = view * ceil(rotateNum) *1;%对圈数向上取整，并获取总投影角度数
pixelCut = 32;%在探测器高度288基础上，上面去掉多少个像素
if sourceNum <= 3
    zbias = 0;%探测器小于等于3时，源和探测器阵列在同一平面
else
    zbias = 100 - pixelCut/2*dPixelSpacing;%源和探测器在不同平面时，两平面在z方向的偏移
end
proHeight = (288 - pixelCut)*dPixelSpacing; %探测器高度
dAngle = pi / 180 * 360/view;%源最小的旋转间隔，弧度制
%%%%%%%%%%%%%%%%%%%%%%%%% 计算可重建区域开始 %%%%%%%%%%%%%%%%%%%%%%%%%
Rz=0.0;
z1s=(sid - Rz)*(zbias - proHeight/2)/sod;
z1e=(sid - Rz)*(zbias + proHeight/2)/sod;
z2s=(sid + Rz)*(zbias - proHeight/2)/sod;
z2e=(sid + Rz)*(zbias + proHeight/2)/sod;
zs = max(z1s, z2s);
ze = min(z1e, z2e);
zSlice = ze-zs;
%%%%%%%%%%%%%%%%%%%%%%%%% 计算可重建区域结束 %%%%%%%%%%%%%%%%%%%%%%%%%
AngleTableSource = zeros(views,3);
tableInit = -1/2*(views - 1) * zSlice * p / view;
for exposureIndex = 0:views-1
%     rotateAngle = ceil((exposureIndex+1)/sourceNum) * dAngle;%该次曝光，机架实际旋转角度
    rotateAngle = exposureIndex / view * 2*pi/sourceNum;
    sourceIndex = exposureOrder(mod(exposureIndex,sourceNum) + 1);%该次曝光，是哪个源
    angleReal = rotateAngle + 2 * pi / sourceNum * sourceIndex; %机架旋转角度加上该源本身的初始角度，得到世界坐标系下的角度
    table = exposureIndex * zSlice * p / view + tableInit;%床前进的距离
    AngleTableSource(exposureIndex+1, 1) = angleReal;
    AngleTableSource(exposureIndex+1, 2) = table;
    AngleTableSource(exposureIndex+1, 3) = sourceIndex;
end
save( char( strcat(root,"AngleTableSource.mat") ), 'AngleTableSource');