clc
clear all
close all 

%%%%%%%%%%%%% SEGMENTED HEART %%%%%%%%%%%%%%%%%%%%%%
%{
mask_epic = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Cropped/v3/Masks/Epicard/AEA063v3_epic_0004.png');
mask_endo = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Cropped/v3/Masks/Endocard/AEA063v3_endo_0004.png');
mask_mmyo = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Cropped/v3/Masks/Mmyo/AEA063v3_mmyo_0004.png');
mask_minf = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Cropped/v3/Masks/Minf/AEA063v3_minf_0004.png');
%}
%%
%{
pic2 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Images/8bit/AEA063v3_8bit_0004.png');
mask_epic = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/v3/Epicard/AEA063v3_epic_0004.png');
mask_endo = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/v3/Endocard/AEA063v3_end_0004.png');
mask_mmyo = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/v3/Mmyokard/AEA063v3_mmyo_0004.png');
mask_minf =
imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/v3/Minf/AEA063v3_minf_0004.png');
%}
clc 
close all
image = imread( '/nfs/prosjekt/EKG/users/kregnes/Master/Matlab/Merged/Image_140.png');
pred = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Matlab/Merged/mask_140.png');
gt = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Matlab/Merged/GT_140.png');
%{
image = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Results/TAGv3/TAG009v3_00010.png');
gt = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Results/TAGv3/TAG009v3_minf_00010.png');
pred = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Results/TAGv3/mask_243.png');
%}
pred = rgb2gray(pred);
pred_tresh= pred;
pred_tresh(pred>100) = 1;
pred_tresh(pred<100) = 0;
pred = pred_tresh; 


io = image;
iob_gt = bwperim(gt, 8); 
iob_pred = bwperim(pred,8);


green = zeros(size(io, 1),size(io,2),3);
green(:,:,2) = 2;
red = zeros(size(io, 1), size(io,2),3);
red(:,:,1) = 2; 
%blue = zeros(size(io, 1), size(io, 2), 3);
%blue(:,:,3) = 2;

figure, imshow(io); 
hold all
h = imshow(green); 
k = imshow(red);
%l = imshow(blue);
set(h,'AlphaData',iob_gt);
set(k,'AlphaData',iob_pred);
%set(l,'AlphaData',iob_pred);

%%%%%%%%%%%%%%%%%% IMAGES OF PATIENT %%%%%%%%%%%%%%%%%%%%%%%
%%

img1 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Binary_TAG009/S1.png');
img2 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Binary_TAG009/S2.png');
img3 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Binary_TAG009/S3.png');
img4 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Binary_TAG009/S4.png');
img5 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Binary_TAG009/S5.png');
img6 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Binary_TAG009/S6.png');
img7 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Binary_TAG009/S7.png');
img8 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Binary_TAG009/S8.png');
img9 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Binary_TAG009/S9.png');
img10 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Binary_TAG009/S10.png');

%figure, imshow(img3);

%{
img1 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Images/8bit/AEA063_8bit_0001.png');
img2 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Images/8bit/AEA063_8bit_0002.png');
img3 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Images/8bit/AEA063_8bit_0003.png');
img4 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Images/8bit/AEA063_8bit_0004.png');
img5 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Images/8bit/AEA063_8bit_0005.png');
img6 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Images/8bit/AEA063_8bit_0006.png');
img7 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Images/8bit/AEA063_8bit_0007.png');
img8 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Images/8bit/AEA063_8bit_0008.png');
%}
%{
img1 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Cropped/Images/8bit/HL064v3_0001.png');
img2 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Cropped/Images/8bit/HL064v3_0002.png');
img3 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Cropped/Images/8bit/HL064v3_0003.png');
img4 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Cropped/Images/8bit/HL064v3_0004.png');
img5 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Cropped/Images/8bit/HL064v3_0005.png');
img6 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Cropped/Images/8bit/HL064v3_0006.png');
img7 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Cropped/Images/8bit/HL064v3_0007.png');
img8 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Cropped/Images/8bit/HL064v3_0008.png');
img9 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Cropped/Images/8bit/HL064v3_0009.png');
img10 = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Cropped/Images/8bit/HL064v3_00010.png');
%}
%multi = cat(3,img1,img2,img3,img4, img5, img6, img7, img8);
%montage(multi, 'Size', [2,4]);
figure, montage({img1, img2, img3, img5, img5, img6, img7, img8, img9, img10}, 'Size', [2,5]);


%% 
%%%%%%%%%% GET SINGLE IMAGE %%%%%%%%%%%%%
%{
mmyo = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Cropped/Dataset_v3andv4/Dataset_v3_v4/Trainv3_v4/Masks/AEA063v3_minf_0005.png');
minf = imread('/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/PM/dataset/Train/Masks_grey_8/PM016_minf_0004.png');
mmyo = '/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Cropped/v3/Masks/Mmyo/'
minf = '/nfs/prosjekt/EKG/users/kregnes/Master/Data/Filer/Cropped/v3/Masks/Minf
figure, imshow(img, []);
%}