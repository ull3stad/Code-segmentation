import torch
import numpy as np
import glob
from random import randint
from PIL import Image
import torch.utils.data as utils_data
from prepross import *


class DataLoad(utils_data.Dataset):

    def __init__(self, img_dir, mask_dir, train=False):

        # File Names
        self.img_dir = sorted(glob.glob(img_dir + str("/*png")))
        self.mask_dir = sorted(glob.glob(mask_dir + str("/*png")))
        self.train = train
    def __getitem__(self, index):
        ### Normalize ###
        mean = 0.199
        std = 0.144

        image = Image.open(self.img_dir[index])
        mask = Image.open(self.mask_dir[index])

        np_image = np.asarray(image) / 255
        np_image = np.subtract(np_image, mean)
        np_image = np.true_divide(np_image, std)

        np_mask = np.asarray(mask).copy()
        np_mask[np_mask == 1] = 1
        np_mask[np_mask == 2] = 1

        ####### AUGMENTATION TRAINING########
        if self.train == True:
            # Flip and rotate
            num = randint(0, 8)
            np_image = flip(np_image, num)
            np_mask = flip(np_mask, num)

        np_image = np.expand_dims(np_image, axis=0)

        ### DICE ###
        # np_mask = np.expand_dims(np_mask, axis=0)

        t_image = torch.from_numpy(np_image).float()
        t_mask = torch.from_numpy(np_mask).long()

        ### DICE ###
        t_mask = torch.from_numpy(np_mask).float()

        return t_image, t_mask

    def __len__(self):
        return len(self.img_dir)





