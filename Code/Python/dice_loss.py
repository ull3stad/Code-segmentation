import torch
import torch.nn as nn
import numpy as np
#
class Dice(nn.Module):
    def __init__(self):
        super(Dice, self).__init__()

    def forward(self, output, target):

        #assert output.size() == target.size(), "input sizes must be equal" 
        #assert output.dim() == 4, "input must be a 4D tensor"
        #print(output.size(),target.size())
        smooth = 1

        num = output * target
        num = torch.sum(num, dim=3) #b,c,h
        num = torch.sum(num, dim=2) #b,c


        den1 = output * output
        den1 = torch.sum(den1, dim=3) #b,c,h
        den1 = torch.sum(den1, dim=2) #b,c

        den2 = target * target
        den2 = torch.sum(den2, dim=2) #b,c,h
        den2 = torch.sum(den2, dim=1) #b,c

        dice = (2*num + smooth) / (den1 + den2 + smooth)

        dice_loss = 1 - dice.mean()

        return dice_loss

# https://github.com/rogertrullo/pytorch/blob/rogertrullo-dice_loss/torch/nn/functional.py#L708
