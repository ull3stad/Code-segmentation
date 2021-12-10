import numpy as np
from PIL import Image
import os

target_folder = '../Dataset'

class1_tot = 0
class2_tot = 0
class3_tot = 0
total_pix = 0
for element in os.listdir(target_folder):
    im = Image.open(target_folder + element)
    np_mask = np.asarray(im)
    np_mask = np.asarray(np_mask).copy()

    class1 = np.sum(np_mask == 0)
    class2 = np.sum(np_mask == 1)
    class3 = np.sum(np_mask == 2)

    class1_tot += class1
    class2_tot += class2
    class3_tot += class3

    total = 512 * 512
    total_pix += total

class1_y = class1_tot / total_pix
class2_y = class2_tot / total_pix
class3_y = class3_tot / total_pix

print(class1_y)
print(class2_y)
print(class3_y)
