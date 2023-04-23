import os
import time
import tqdm
import torch
import numpy as np
# from model.ConeBeamLayers.Shenzhen.ShenzhenGeometry import ShenzhenGeometryWithFBP, ForwardProjection, BackProjection
from model.ConeBeamLayers.Beijing.BeijingGeometry import BeijingGeometry, BeijingGeometryWithFBP, ForwardProjection, BackProjection
from model.FISTA.DTVFISTA import DTVFista
from options import trainPath, validPath, outputPath

data = np.fromfile("/media/wyk/wyk/Data/raws/ShepLogan_256x256x64.raw", dtype="float32")
# data = np.fromfile("/media/wyk/wyk/Data/raws/volume.raw", dtype="float32")
data = np.reshape(data, [1,1,64,256,256])
data = torch.from_numpy(data).cuda()
data = torch.ones_like(data)
projection = ForwardProjection.apply(data)
projection.detach().cpu().numpy().tofile("/media/wyk/wyk/Data/raws/sino2.raw")
projection = np.fromfile("/media/wyk/wyk/Data/wsr/projection.raw", dtype="float32")
projection = np.reshape(projection, [1,1080*21, 72, 40])
projection = torch.from_numpy(projection).cuda()
print("projected")
# net = ShenzhenGeometryWithFBP().cuda().eval()
net = BeijingGeometry().cuda().eval()
# volume = torch.zeros_like(data).cuda()
volume = torch.zeros([1,1,64,256,256]).cuda()
tic = time.time()
volume = net(volume, projection)
print("time:{}".format(time.time()-tic))
# for j in tqdm.trange(50):
#     volume = volume + 1e-1 * net(volume, projection)
volume.detach().cpu().numpy().tofile("/media/wyk/wyk/Data/raws/r.raw")