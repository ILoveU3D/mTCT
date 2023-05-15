import torch
import numpy as np
from tqdm import trange
from ConeBeamLayers.Beijing.BeijingGeometry import ForwardProjection,BackProjection

class Ista():
    def __init__(self, cascades:int=30, debug:bool=False):
        self.cascades = cascades
        self.debug = debug
        self.lamb = 0
        self.L = 1e-4
        self.t = 0

    def run(self, image, sino):
        t = 1
        I = Ip = image
        y = I
        for cascade in trange(self.cascades):
            d = y - self.L * BackProjection.apply(ForwardProjection.apply(y)-sino)
            I = torch.sign(d) * torch.nn.functional.relu(torch.abs(d) - self.lamb*self.L)
            y = I + self.t * (I-Ip)
            # tp = (1+np.sqrt(1+4*t**2))/2
            # y = I + (t-1)/tp * (I-Ip)
            # y = I
            Ip = I
            # t = tp
        return I