%%% Smooth, crop, find heart center, scale
close all
clear all
clc


filepath='/nfs/prosjekt/EKG/data/wmri/';
filepathDel='/nfs/prosjekt/EKG/data/wmri/erlend/';


folderImg = 'Save images';
folderMinf = 'Save minf masks';
folderMmyo = 'Save mmyo masks';

[Pt,drecs,bytes]=dbread(filepath);

for i = 226:255 %number of IDs
    ID = string(Pt(i))
    inD = organizeimage_KE(filepath,filepathDel,Pt(i));

    if inD.Exists==1
    %Crop files
    [cpD]=crop_heart_v2016(inD);

    %Find Epicardium and Endocardium - masks
    %out=Segment_prob_2016(hcD);
    
    % IMAGES
    LX = size(cpD.X);
    for j = 1:LX(3)
            img = cpD.X(:,:,j);
            
            %Smooth and scale
            Ig = imgaussfilt(img,1.5);
            Res = imresize(Ig, [512 512]);
            %Save images
            baseFileName = sprintf(ID + '_000' + j + '.png', j); 
            fullFileName = fullfile(folderImg, baseFileName);
            pic8 = uint8(Res);
            imwrite(pic8, fullFileName, 'png');
    end
   
    %Get minf
    LMinf = size(cpD.Minf);
    for k = 1:LMinf(3)     
        minf = cpD.Minf(:,:,k);
        Res_minf = imresize(minf, [512 512]);
        baseFileNameMinf = sprintf(ID + '_minf_000' + k + '.png', k);
        fullFileNameMinf = fullfile(folderMinf, baseFileNameMinf);
        imwrite(Res_minf, fullFileNameMinf, 'png');
    end

    %Get Mmyo
    LMmyo = size(cpD.Mmyo);
    for l = 1:LMmyo(3)
        mmyo = cpD.Mmyo(:,:,l);
        Res_mmyo = imresize(mmyo, [512 512]);
        baseFileNameMmyo = sprintf(ID + '_mmyo_000' + l + '.png', l); 
        fullFileNameMmyo = fullfile(folderMmyo, baseFileNameMmyo);
        imwrite(Res_mmyo, fullFileNameMmyo, 'png');
    end
    
    %{
         %Get epicardium
            LEpic = size(out.EpiMFD);
            for m = 1:LEpic(3)
                epic = out.EpiMFD(:,:,m);
                baseFileNameEpic = sprintf(ID + '_epic_000' + m + '.png', m);
                fullFileNameEpic = fullfile(folderEpic, baseFileNameEpic);
               imwrite(epic, fullFileNameEpic, 'png');
            end

            %Get Endocardium
            LEndo = size(out.EndoMFD);
            for n = 1:LEndo(3)
                endo = out.EndoMFD(:,:,n);
                baseFileNameEndo = sprintf(ID + '_endo_000' + n + '.png', n);
                fullFileNameEndo = fullfile(folderEndo, baseFileNameEndo);
                imwrite(endo, fullFileNameEndo, 'png'); 
            end
    %}
    end
    
    
end
