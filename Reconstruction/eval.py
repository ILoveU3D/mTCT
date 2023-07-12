import os
import time
import tqdm
import torch
import numpy as np
from ConeBeamLayers.BeijingGeometry import BeijingGeometry, BeijingGeometryWithFBP, ForwardProjection, BackProjection
from FISTA import Ista
from options import trainPath, validPath, outputPath

data = np.fromfile("/media/wyk/wyk/Data/result/AAPM/origin/pa_56.raw", dtype="float32")
data = np.reshape(data, [1,1,64,256,256])
data = torch.from_numpy(data).cuda()
projection = ForwardProjection.apply(data)
# projection.detach().cpu().numpy().tofile("/media/wyk/wyk/Data/raws/sino2.raw")
# projection = np.fromfile("/media/wyk/wyk/Data/wsr/projection.raw", dtype="float32")
# projection = np.reshape(projection, [1,1080*21, 144, 80])
# projection = torch.from_numpy(projection).cuda()
print("projected")
net = BeijingGeometryWithFBP().cuda().eval()
volume = torch.zeros([1,1,64,256,256]).cuda()
volume = net(volume, projection)
volume.detach().cpu().numpy().tofile("/media/wyk/wyk/Data/raws/r.raw")

# fdk = BeijingGeometryWithFBP().cuda().eval()
# for i in os.listdir("/media/wyk/wyk/Data/result/AAPM/origin"):
#     data = np.fromfile(os.path.join("/media/wyk/wyk/Data/result/AAPM/origin",i), dtype="float32")
#     data = np.reshape(data, [1, 1, 64, 256, 256])
#     data = torch.from_numpy(data).cuda()
#     projection = ForwardProjection.apply(data)
#     volume = torch.zeros_like(data).cuda()
#     f = fdk(volume, projection)
#     f.detach().cpu().numpy().tofile(os.path.join("/media/wyk/wyk/Data/result/AAPM/FDK_f", i))
#     del f, projection, data, volume
#     print("infered {}".format(i))
