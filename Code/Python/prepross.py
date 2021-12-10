import numpy as np

def flip(image, num):
    '''
    :param image: image or mask to be augmented
    :param num: random number between 0 and 9
    :return: augmented image/mask
    '''

    if num == 0:
        #vertical
        image = np.flip(image, axis=0).copy()

    elif num == 1:
        #horizontal
        image = np.flip(image, axis=1).copy()

    elif num == 2:
        #vertical & horizontal
        image = np.flip(image, axis=0).copy()
        image = np.flip(image, axis=1).copy()

    else:
        #no change
        image = image

    return image
