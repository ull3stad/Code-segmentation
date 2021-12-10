import torch
import torch.optim as optim
import os
import random
from datetime import datetime
from loader import DataLoad
from utils import *
from unet import *
from unet_dropout import *
from unet_parts import *
from unet_model import *
from dice_loss import *
from modules import *
from skopt.space import Real\

from skopt import gp_minimize


################# LOAD DATA ####################
### DATASET ###
image_train = '/nfs/student/ull3stad/Documents/Dataset_ferdig/Train/Images/'
mask_train = '/nfs/student/ull3stad/Documents/Dataset_ferdig/Train/Masks/'
#
image_val = '/nfs/student/ull3stad/Documents/Dataset_ferdig/Val/Images/'
mask_val = '/nfs/student/ull3stad/Documents/Dataset_ferdig/Val/Masks/'



############# PARAMETERS ##################
# learning_rate = [0.1, 0.01, 0.001, 0.0001, 1e-5]

### BAYESIAN ###
space = [Real(0.5, 1.5,
         name='lr'),
         Real(0.85, 0.99, name='scale')]

def objective(param):
    lr = param[0]
    scale = param[1]
    val = main(lr,1, scale) #run = main when doing bayesian optimization
    return val


def main(lr, i, drop):

    ### Initialize GPU ###
    def initialize_GPU():
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

        return GPU, device, numb_devices

    GPU, device, numb_devices = initialize_GPU()



    ###### CALCULATE WEIGHTS WHEN USING CROSS_ENTROPY######
    scale = [0, 0.5, 0.2, 0.8]
    if i == 0:
        weight = None
        scale = 0
    else:

        c1 = 0.97
        c2 = 0.03
        w1 = scale[i]/ c1
        w2 = (1 - scale[i]) / (c2)
        weights = [w1, w2]
        weight = torch.tensor(weights).to(device)
        scale = scale[i]






    ############# DIRECTORIES #################

    ### Without scaling ###
    Opt = "ADAM"
    model_dir_ver = './ADAM/binary_{}_{}'.format(Opt,lr)
    model_name = "/ADAM_{}_{}.pth".format(Opt, lr)
    val_name = '/ADAM_val{}_{}.csv'.format(Opt, lr)
    train_name = '/ADAM_train_{}_{}.csv'.format(Opt, lr)
    model_number = '/ADAM_model_{}_{}.csv'.format(Opt, lr)



    # ### With scaling ###
    # Opt = "ADAM"
    # model_dir_ver = '../Binary_ADAM_new/binary_{}_{}_{}'.format(Opt,lr, scale)
    # model_name = "/binary_model_{}_{}_{}.pth".format(Opt, lr, scale)
    # val_name = '/binary_val_{}_{}_{}.csv'.format(Opt, lr, scale)
    # train_name = '/binary_train_{}_{}_{}.csv'.format(Opt, lr, scale)
    # model_number = '/binary_model_{}_{}_{}.csv'.format(Opt, lr, scale)
    #
    # ### With dropout ###
    # Opt = "ADAM"
    # model_dir_ver = '../ADAM_dropout_smaller_lr/binary_{}_{}_{}'.format(Opt,lr, drop)
    # model_name = "/drop_{}_{}_{}.pth".format(Opt, lr, drop)
    # val_name = '/val_{}_{}_{}.csv'.format(Opt, lr, drop)
    # train_name = '/train_{}_{}_{}.csv'.format(Opt, lr, drop)
    # model_number = '/model_{}_{}_{}.csv'.format(Opt, lr, drop)
    #

    try:
        os.makedirs(model_dir_ver)
        print("Creation of directory succeeded")
    except OSError:
        print("Creation of directory failed")

    train_name = model_dir_ver + train_name
    val_name = model_dir_ver + val_name
    model_number = model_dir_ver + model_number
    model_dir = model_dir_ver

    weight = None



    ### LOAD DATA ###
    train_set = DataLoad(image_train, mask_train, train = True)
    val_set = DataLoad(image_val, mask_val)

    train_loader = torch.utils.data.DataLoader(dataset = train_set, batch_size = 2, shuffle = True, num_workers = 4)

    val_loader = torch.utils.data.DataLoader(dataset = val_set,
                                                     batch_size = 2, shuffle = True, num_workers = 2)

    ############### CHECK LOADERS ##################
    #
    # for i, (image, target) in enumerate(val_loader):
    #     image = image.cpu()
    #     npimg = npimg[0, 0, :, :]
    #     target = target.cpu()

    #     nptarget = target.numpy()
    #     nptarget = nptarget[0, 0, :, :]
    #     f, ax = plt.subplots(1,2)
    #     ax[0].imshow(npimg)
    #     ax[1].imshow(nptarget)
    #     plt.show()


    #############   MODEL - LOSS FUNCTION - OPTIMIZER   ##############
    n_class = 2 # Number of classes
    if weight == None:
        weight = weight
    else:
        weight = torch.tensor([weight]).to(device)

    #weight = torch.tensor([weight]).to(device)

    ############# CHOOSE THE MODEL YOU WANT TO USE ########## 
    model = UNet_MY(1, n_class).to(device)
    #model = UNet(1, n_class).to(device)

    optimizer = optim.Adam(model.parameters(), lr=lr)
    # optimizer = optim.SGD(model.parameters(), lr=lr, momentum=0.9, nesterov=True)

    #criterion = nn.CrossEntropyLoss(weight=weight)
    criterion = Dice()

    # ### DROP ###
    # model = UNet_drop(1, n_class, drop_rate=drop).to(device)
    # optimizer = optim.Adam(model.parameters(), lr=lr)
    # criterion = nn.CrossEntropyLoss()


    ### WITHOUT WEIGHTS ###
    # print("Start training, epochs: {}, lr: {}, dropout: {}".format(epochs, lr, drop))
    print("Start training, epochs: {}, lr: {}".format(epochs, lr))

    start_train = datetime.now()
    start_epoch = datetime.now()


    patience = 0
    val_loss_best = 100000000
    for epoch in range(epochs):
        model.train()

        train_loss, train_acc = train_model(model, train_loader, criterion, optimizer)

        end_epoch = datetime.now()
        total_epoch = end_epoch - start_epoch

        print('''Epoch {}, Train Loss {:.3f}, Train Acc {:.3f}, Elapsed time {}'''.format(epoch+1, train_loss,
                                                                                          train_acc, total_epoch))
        ##SAVE HISTORY##
        values_train = [epoch + 1, train_loss, train_acc, total_epoch]
        history(values_train, train_name)

        if (epoch + 1) % 1 == 0:
            val_loss, val_acc = val_model(model, val_loader, criterion)
            print('''Epoch {}, Val_loss: {:.3f}, Val_acc {:.3f}'''.format(epoch+1, val_loss, val_acc))
            if val_loss < val_loss_best:
                patience = 0
                val_loss_best = val_loss
                save_model(model, optimizer, model_dir, epoch, model_number, model_name)
            elif val_loss >= val_loss_best:
                patience += 1


            ##SAVE HISTORY##
            values = [epoch + 1, val_loss, val_acc, total_epoch]
            history(values, val_name)

        if patience == 10:
            print("\nTraining stopped due to early stopping")
            break

    end_train = datetime.now()
    total_train = end_train - start_train

    print("Finished training, elapsed time: {}".format(total_train))


if __name__ == "__main__":
    epochs = 100
    scale = [0.2, 0.5, 0.8]
    for i in range(0, 10):
        lr = random.randint(1, 1000)*1e-6
        dropout = round(random.randint(5, 50) * 1e-2, 2)
        main(lr,1, dropout)

    ### BAYESIAN ###
    ### PRIOR ###
    x = [[0.5, 0.85], [0.5, 0.90], [0.5, 0.95],
         [1, 0.85], [1, 0.90], [1, 0.95],
         [1.5, 0.85], [1.5, 0.90], [1.5, 0.95],
        ]

    y = [0.41, 0.399, 0.386,
         0.4312, 0.427, 0.367,
         0.43, 0.40, 0.37,
         ]

    objective(space)
    epochs = 100
    res_gp = gp_minimize(objective, space, n_calls=50, random_state=0, x0=x, y0=y)

