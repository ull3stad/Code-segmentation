import torch
import numpy as np
from torch.autograd import Variable
import matplotlib.pyplot as plt
import matplotlib
import csv
from PIL import Image
import matplotlib.cm as cm


def train_model(model, train_loader, criterion, optimizer):
    '''

    :param model: DNN
    :param train_loader: Training-samples
    :param criterion: Loss-function
    :param optimizer: Optimizer
    :return: train loss and train accuracy
    '''
    train_loss = 0.0
    acc = 0.0
    tot = 0.0
    for batch, (image, target) in enumerate(train_loader):
        tot += 1

        image, target = Variable(image.cuda()), Variable(target.cuda())
        optimizer.zero_grad() # Reset gradients
        output = model(image)# Predicted mask made by model
        loss = criterion(output, target) # Get loss, arguments: predicted mask and ground truth

        loss.backward() # Backward propagation, update weights
        optimizer.step()
        train_loss += loss.item() # Add loss for each sample in batch

        ######### ACCURACY ###########
        #target_acc = target[:,0,:,:] #DICE
        target_acc = target #CROSS

        _, preds = torch.max(output, 1)
        total = target.nelement()
        correct = torch.sum(preds == target_acc.data.long()).item()
        acc += 100 * (correct / total)

    train_acc = acc / tot # Get accuracy for the batch
    train_loss = train_loss / tot  #Get train loss for the batch

    return train_loss, train_acc


def val_model(model, val_loader, criterion):
    '''
    :param model: DNN
    :param val_loader: Validation-samples
    :param criterion: Loss-function
    :return: val loss and val accuracy
    '''
    model.eval()
    val_loss = 0.0
    acc = 0.0
    tot = 0.0
    for batch, (image, target) in enumerate(val_loader):
        tot += 1
        image, target = Variable(image.cuda()), Variable(target.cuda())
        output = model(image)
        loss = criterion(output, target)
        # print(loss.item())
        val_loss += loss.item()


        ######### ACCURACY AND LOSS ###########
        #target_acc = target[:,0,:,:]
        target_acc = target
        _, preds = torch.max(output, 1)
        total = target.nelement()
        correct = torch.sum(preds == target_acc.data.long()).item()
        acc += 100 * (correct / total)

    epoch_acc = acc / tot
    epoch_loss = val_loss / tot

    return epoch_loss, epoch_acc


def history(values, file_name):
    with open(file_name, mode='a') as f:
        writer = csv.writer(
            f,
            delimiter=',',
            quotechar='"',
            quoting=csv.QUOTE_MINIMAL)
        writer.writerow(values)

def save_model(model, optimizer, model_save_dir, epoch, model_number, save_name):
    state = {'epoch': epoch+1,
             'model_dict': model.state_dict(),
             'optim_dict': optimizer.state_dict()}
    save_path = model_save_dir


    with open(model_number, mode='a') as file:
        writer = csv.writer(
            file,
            quotechar='"',
            quoting=csv.QUOTE_MINIMAL)
        writer.writerow(str(epoch+1))

    torch.save(state, save_path + save_name)

def save_images(img, target, pred, max, img_save, batch):

    img, target, pred, max = img.cpu(), target.cpu(), pred.cpu(), max.cpu()

    npimg = img.numpy()
    npimg = npimg[0, 0, :, :]


    nptarget = np.transpose(target.numpy(), (1,2,0))
    nptarget = nptarget[:, :, 0]
    
    #nptarget = target.numpy()
    #nptarget = nptarget[0, 0, :, :]
    #nptarget = np.transpose(target.numpy(), (2,3,1,0))
    #nptarget = nptarget[:, :, 0, 0]


    nppred = pred.detach().numpy()
    nppred = nppred[0, 0, :, :]

    npmax = max.detach().numpy()
    npmax = npmax[0, :, :]

    f, ax = plt.subplots(1,4)
    ax[0].imshow(npimg)
    ax[0].set_title('Image')

    ax[1].imshow(nptarget)
    ax[1].set_title('Ground truth')

    ax[2].imshow(nppred)
    ax[2].set_title('Predicted')

    ax[3].imshow(npmax)
    ax[3].set_title('Max')

    f.savefig(img_save + '''/Image_{}.png'''.format(batch))
    plt.clf()


def visualize(img, target, pred, max = None):

    img, target, pred, max = img.cpu(), target.cpu(), pred.cpu(), max.cpu()

    npimg = img.numpy()
    npimg = npimg[0, 0, :, :]


    nptarget = np.transpose(target.numpy(), (1,2,0))
    nptarget = nptarget[:, :, 0]
    #
    # nptarget = target.numpy()
    # nptarget = nptarget[0, 0, :, :]



    #nptarget = np.transpose(target.numpy(), (2,3,1,0))
    #nptarget = nptarget[:, :, 0, 0]


    nppred = pred.detach().numpy()
    nppred = nppred[0, 0, :, :]

    npmax = max.detach().numpy()
    npmax = npmax[0, :, :]

    f, ax = plt.subplots(1,4)
    ax[0].imshow(npimg)
    ax[0].set_title('Image')

    ax[1].imshow(nptarget)
    ax[1].set_title('Ground truth')

    ax[2].imshow(nppred)
    ax[2].set_title('Predicted')

    ax[3].imshow(npmax)
    ax[3].set_title('Max')

    f.suptitle('RESULTS')
    plt.show()


def save_image(image, target, predicted, max, img_save=None, epoch=None, batch=None):
    predicted, target_data = predicted.data, target.data
    img, target, pred, max = image.cpu(), target.cpu(), predicted.cpu(), max.cpu()

    npimg = img.numpy()
    npimg = npimg[0, 0, :, :]

    nptarget = np.transpose(target.numpy(), (1,2,0))
    nptarget = nptarget[:, :, 0]

    nppred = np.transpose(pred.detach().numpy(), (2,3,1,0))
    nppred = nppred[:, :, 0, 0]

    npmax = max.detach().numpy()
    npmax = npmax[0, :, :]

    matplotlib.image.imsave(img_save + "mask_{}.png".format(batch), npmax)


    #img = Image.open('image.png').convert('LA')
    img = Image.open(img_save+'mask_{}.png'.format(batch)).convert('LA')
    img.save('greyscale.png')



