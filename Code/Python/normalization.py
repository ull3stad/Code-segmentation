import numpy as np
from PIL import Image
import glob

def normalization(path):
    img_dir = sorted(glob.glob(path + str("/*png")))
    mean = 0
    std = 0
    print(len(img_dir))
    for images in enumerate(img_dir):
        img = Image.open(images[1])
        np_image = np.asarray(img) / 255
        mean += np.mean(np_image, axis=(0,1))
        std += np.std(np_image)

    mean = mean / len(img_dir)
    std = std / len(img_dir)
    return mean, std


if __name__ == "__main__":
    path =  '/zfs1/home/kregnes/Dataset_ferdig/Train/Images'
    mean, std = normalization(path)
    print(mean, std)
