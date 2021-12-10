import numpy as np
from sklearn.metrics import confusion_matrix
from sklearn.metrics import f1_score
from Confusion_matrix import *



def dice(output, target):
    output, target = output.data.cpu(), target.data.cpu()
    npoutput, nptarget = output.numpy(), target.numpy()

    npoutput = npoutput.flatten()
    nptarget = nptarget.flatten()

    intersection = np.logical_and(nptarget, npoutput)
    A = np.sum(npoutput)
    B = np.sum(nptarget)

    dice = 2 * (intersection.sum() + 1) / (A + B + 1)

    return dice

def jaccard(output, target):
    output, target = output.data.cpu(), target.data.cpu()
    npoutput, nptarget = output.numpy().astype(np.bool), target.numpy().astype(np.bool)

    intersection = np.logical_and(npoutput, nptarget)
    union = np.logical_or(npoutput, nptarget)
    jacc = intersection.sum() / float(union.sum())
    return jacc


def F1(output, target):
    output, target = output.data.cpu(), target.data.cpu()
    npoutput, nptarget = output.numpy().astype(np.bool), target.numpy().astype(np.bool)
    nptarget = nptarget.flatten()
    npoutput = npoutput.flatten()

    f1 = f1_score(nptarget, npoutput, average=None)
    return f1


def Conf(output, target):
    output, target = output.data.cpu(), target.data.cpu()
    npoutput, nptarget = output.numpy().astype(np.bool), target.numpy().astype(np.bool)
    nptarget = nptarget.flatten()
    npoutput = npoutput.flatten()
    conf = confusion_matrix(nptarget, npoutput)
    # print(conf)

    return conf



