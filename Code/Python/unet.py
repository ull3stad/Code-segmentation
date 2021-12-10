import torch.nn as nn
import torch



class UNet(nn.Module):
    def __init__(self, num_ch=1, num_classes=None):
        '''
        :param num_ch: Number of channels in image
        :param num_classes: Number of classes to predict
        '''

        super(UNet, self).__init__()

        ### ENCODER ###
        self.down1 = nn.Sequential(Conv(num_ch, 64))
        self.down2 = nn.Sequential(nn.MaxPool2d(kernel_size=2),
                                   Conv(64, 128))
        self.down3 = nn.Sequential(nn.MaxPool2d(kernel_size=2),
                                   Conv(128, 256))
        self.down4 = nn.Sequential(nn.MaxPool2d(kernel_size=2),
                                   Conv(256,512))
        self.down5 = nn.Sequential(nn.MaxPool2d(kernel_size=2),
                                   Conv(512, 1024))

        ### DECODER ###
        self.up1 = Upconv(1024, 512)
        self.upconv1 = Conv(1024, 512)
        self.up2 = Upconv(512, 256)
        self.upconv2 = Conv(512, 256)
        self.up3 = Upconv(256, 128)
        self.upconv3 = Conv(256, 128)
        self.up4 = Upconv(128, 64)
        self.upconv4 = Conv(128, 64)

        ### OUTPUT LAYER ###
        self.final = nn.Sequential(nn.Conv2d(64,
                                             num_classes,
                                             kernel_size=1))#,
                                   #nn.Softmax2d()) # When using dice loss


    def forward(self, input):
        down1 = self.down1(input)
        down2 = self.down2(down1)
        down3 = self.down3(down2)
        down4 = self.down4(down3)
        down5 = self.down5(down4)

        up1 = self.up1(down5, down4)
        up1 = self.upconv1(up1)
        up2 = self.up2(up1, down3)
        up2 = self.upconv2(up2)
        up3 = self.up3(up2, down2)
        up3 = self.upconv3(up3)
        up4 = self.up4(up3, down1)
        up4 = self.upconv4(up4)

        output = self.final(up4)
        return output



class Conv(nn.Module):
    def __init__(self, in_feat, out_feat):
        super(Conv, self).__init__()

        self.conv1 = nn.Sequential(nn.Conv2d(in_feat, out_feat,
                                             kernel_size=3,
                                             stride=1,
                                             padding=1),
                                   nn.BatchNorm2d(out_feat),
                                   nn.ReLU())
        self.conv2 = nn.Sequential(nn.Conv2d(out_feat, out_feat,
                                             kernel_size=3,
                                             stride=1,
                                             padding=1),
                                   nn.BatchNorm2d(out_feat),
                                   nn.ReLU())

    def forward(self, input):
        output = self.conv1(input)
        output = self.conv2(output)
        return output

class Upconv(nn.Module):
    def __init__(self, in_feat, out_feat):
        super(Upconv, self).__init__()

        self.up = nn.UpsamplingBilinear2d(scale_factor=2)
        self.deconv = nn.ConvTranspose2d(in_feat, out_feat,
                                         kernel_size=2, stride=2)

    def forward(self, input, output_down):
        output = self.deconv(input)
        out = torch.cat([output_down, output], 1)
        return out
