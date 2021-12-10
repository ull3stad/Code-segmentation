import torch
import os
import csv
import numpy as np
import matplotlib.pyplot as plt
from loader import DataLoad
#from loader_dice import DataLoad_dice
from utils import *
from torch.autograd import Variable
from unet import *
#from unet_dice import *
from unet_dropout import *
from performance import *
from modules import *
from unet_model import *
from unet_parts import *

### Initialize GPU ###
GPU = '1'
os.environ['CUDA_VISIBLE_DEVICES'] = GPU

if torch.cuda.is_available():
    device = torch.device("cuda")
    numb_devices = torch.cuda.device_count()
    print("\nNetwork will be run on cuda: {}".format(GPU))
    print("Network will be run on {} devices".format(numb_devices))
else:
    device = torch.device("cpu")
    print("\nNetwork will be run on CPU")



####### DIRECTORIES ##########
images_test = '/nfs/student/ull3stad/Documents/Dataset_ferdig/Test/Images/' # Directory for test images
masks_test = '/nfs/student/ull3stad/Documents/Dataset_ferdig/Test/Masks/' # Directory for test masks

images_val = '/nfs/student/ull3stad/Documents/Dataset_ferdig/Val/Images/' # Directory for val images
masks_val = '/nfs/student/ull3stad/Documents/Dataset_ferdig/Train/Mask/' # Directory for val masks

#dir = './ADAM_dice/' # Directory for folders with models
dir='/home/stud/ull3stad/Documents/ADAM_dice/'

img_save = dir + 'masks_test'

files = []
for element in os.listdir(dir):
    files.append(element)
files_s = sorted(files)

def main(i):

    folder = files_s[i]
    name = folder[7:]
    lr = name.split('_')
    lr = lr[1] # learning rate
    drop = float(name[-3:])*10**(-1)*(-1) #Drop rate
    print(lr)


    #model_path = folder + '/dice_model_' + name +'.pth' #Path for model
    model_path = folder + '/ADAM_' + name +'.pth'
    model_dir = dir + model_path
    perf_scores = '/validation_model.csv'

    file_name = dir + perf_scores

    test_set = DataLoad(images_test, masks_test)
    test_loader = torch.utils.data.DataLoader(dataset = test_set,
                                                batch_size = 1, shuffle = False, num_workers = 2)



    n_class = 2
    
    ########### CHOOSE THE MODEL ###########
    #model = UNet_drop(1, n_class,drop_rate=drop).to(device)
    model = UNet_MY(1, n_class).to(device)
    #model = UNet(1, n_class).to(device)

    checkpoint = torch.load(model_dir)
    model.load_state_dict(checkpoint["model_dict"])
    model.eval()

    acc = []
    tot = 0.0
    dice_sum = []
    jaccard_sum = []
    Conf_sum = 0.0
    F1_c1 = []
    F1_c2 = []

    for batch, (image, target) in enumerate(test_loader):
        tot = tot+1
        image, target = Variable(image.cuda()), Variable(target.cuda())
        output = model(image)

        ## PIXEL ACCURACY ##
        _, preds = torch.max(output, 1)
        total = target.nelement()
        correct  = torch.sum(preds == target.data.long()).item()
        acc.append(100 *(correct/total))

        ## DICE SCORE ###
        dice_score = dice(preds, target)
        dice_sum.append(dice_score)

        ## JACCARD ##
        jacc_score = jaccard(preds, target)
        jaccard_sum.append(jacc_score)

        ## F1 SCORE ##
        F1_score = F1(preds, target)
        F1_c1.append(F1_score[0])


        if len(F1_score) == 1:
            F1_c2.append(0)
        else:
            F1_c2.append(F1_score[1])

        ## CONFUSION MATRIX ##
        Conf_score = Conf(preds, target)
        Conf_sum += Conf_score

        #visualize(image, target, output, preds)
        save_images(image, target,output, preds, img_save=img_save, batch=batch)
        save_image(image, target, output, preds, img_save=img_save, batch=batch)

    acc_mean = np.mean(acc)
    acc_std = np.std(acc)
    dice_mean = np.mean(dice_sum)
    print(dice_mean)
    dice_std = np.std(dice_sum)
    jaccard_mean = np.mean(jaccard_sum)
    jaccard_std = np.std(jaccard_sum)
    F1_mean_c1 = np.mean(F1_c1)
    F1_mean_c2 = np.mean(F1_c2)
    F1_std_c1 = np.std(F1_c1)
    F1_std_c2 = np.std(F1_c2)
    Conf_sum = Conf_sum / tot

    values = [name, acc_mean, acc_std, dice_mean, dice_std, jaccard_mean, jaccard_std, F1_mean_c1, F1_std_c1, F1_mean_c2, F1_std_c2, Conf_sum]


    with open(file_name, mode='a') as f:
        writer = csv.writer(
            f,
            delimiter=',',
            quotechar='"',
            quoting=csv.QUOTE_MINIMAL)
        writer.writerow(values)

if __name__ == "__main__":
    N = 1 #number of models in folder
    for i in range(0, N):
        main(i)
