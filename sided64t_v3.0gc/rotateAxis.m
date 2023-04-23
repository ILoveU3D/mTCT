function y = rotateAxis(x)
% make ratation for world axis
r = atan((285+33.48)/(2691.3+2612.33));
p = atan((-68+197.5)/(-2671.89-2655.77));
m = 0;
Rx = [1,0,0;0,cos(r),-sin(r);0,sin(r),cos(r)];
Ry = [cos(p),0,sin(p);0,1,0;-sin(p),0,cos(p)];
Rz = [cos(m),-sin(m),0;sin(m),cos(m),0;0,0,1];
s = size(x);
z = reshape(x,[],3);
[k,~] = size(z);
y = zeros(size(z));
for i = 1:k
    y(i,:) = Rx*Ry*Rz*z(i,:)';
end
y = reshape(y, s);
end

