from scipy.io import savemat
import numpy as np
import sys

d = np.load(sys.argv[1] + ".npy")
savemat(sys.argv[1] + ".mat", {"data":d})
print('generated ', sys.argv[1] + ".mat", 'from')