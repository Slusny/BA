
import open3d
import numpy as np
#import glob

#list = glob.glob('./*.pcd')
#for i in range(len(list)):
    #print(list[i])
    #cloud=list[i]
PATH = 'Z:/Students/lslusny/datasets/Defect1/v7/x/lumione_pc/'
cloud = PATH + "pol_normals.pcd"
point_cloud = open3d.read_point_cloud(cloud)
pc_array = np.asarray(point_cloud.points)
np.save(PATH + "pol_normals.npy", pc_array)