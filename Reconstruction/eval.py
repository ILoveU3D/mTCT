import os
import time
import tqdm
import torch
import numpy as np
from ConeBeamLayers.Beijing.BeijingGeometry import BeijingGeometry, BeijingGeometryWithFBP, ForwardProjection, BackProjection
from FISTA import Ista
from options import trainPath, validPath, outputPath

data = np.fromfile("/media/wyk/wyk/Data/raws/trainData/pa_348.raw", dtype="float32")
data = np.reshape(data, [1,1,64,256,256])
data = torch.from_numpy(data).cuda()
projection = ForwardProjection.apply(data)
projection.detach().cpu().numpy().tofile("/media/wyk/wyk/Data/raws/sino2.raw")
# projection = np.fromfile("/media/wyk/wyk/Data/wsr/projection.raw", dtype="float32")
# projection = np.reshape(projection, [1,1080*21, 144, 80])
# projection = projection[...,1:-1]
# projection = torch.from_numpy(projection).cuda()
print("projected")
net = BeijingGeometryWithFBP().cuda().eval()
volume = torch.zeros([1,1,64,256,256]).cuda()
tic = time.time()
# ista = Ista(200)
# print("time:{}".format(time.time()-tic))
# volume = ista.run(volume, projection)
volume = net(volume, projection)
volume.detach().cpu().numpy().tofile("/media/wyk/wyk/Data/raws/r.raw")