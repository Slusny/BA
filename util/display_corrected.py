import matplotlib.pyplot as plt
import scipy.io as sio
import sys

data = sio.loadmat(sys.argv[1])

plt.subplot(1, 2, 2)
plt.imshow((data["normal1"] + 1) / 2)
plt.title('corrected normal')

plt.subplot(2, 2, 3)
plt.imshow(data["specmask"])
plt.title('Original specular mask')
plt.show()