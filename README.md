### mTCT
mTCT is the best way to config any geometry into CT projection operator of nerual network, such as CNN-based network, Tranformer-based network or NeRF. 

#### How to use?
##### An example
Firstly, run the [*geometry editing script*](./sided64t/side64_Diran2.m) with `MATLAB`, where you can get *projection data file*(etc. *projVecReal.m*) containing a **matrix of N*12**. Then you can use pytorch CUDA extension to compile our [operators](Reconstruction/ConeBeamLayers/plug/setup.py).  finally, Link the location of geometric files in the `YAML` script and use compiled operators to project the embedded network, as shown in [*this script*](Reconstruction/eval.py).
