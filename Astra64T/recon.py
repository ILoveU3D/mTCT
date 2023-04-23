import os
import scipy.io
import astra
import h5py
import numpy as np
import AstraConvertion

# System matrix
anglesNum = 1080
# parameters = h5py.File("./projVec.mat", 'r')
parameters = scipy.io.loadmat("./projVec.mat")
projectVector = np.array(parameters['projection_matrix'])
detectorSize = [160,288]
volumeSize = [256,256,72]
projectorGeometry = astra.create_proj_geom('cone_vec', detectorSize[0],detectorSize[1], projectVector)
volumeGeometry = astra.create_vol_geom(volumeSize[0],volumeSize[1],volumeSize[2])
projector = astra.create_projector('cuda3d',projectorGeometry,volumeGeometry)
H = astra.OpTomo(projector)

# Reconstruction
lung = np.fromfile("/media/seu/wyk/Data/raws/sample.raw","float32")
sino = H * lung.flatten()
AstraConvertion.astra2Projection(sino).tofile("/media/seu/wyk/Data/raws/sino.raw")