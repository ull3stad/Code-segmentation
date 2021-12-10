function out = organizeimage_KE(filepath,filepathDel,Pt, Exists)
%%% detecting the capture position of the images to select the columnar
%%% ones, sort the images based on the time that they have been taken
%%% according to SOPInstanceUID, which is a worldwide unique ID consist of
%%% date, time and other numberings to make it unique for each image.

%   Inputs: 
%     filepath - file path for the images
%     filepathDel - file path for the doctor's delineation files
%     PatientN - list of all patient name and number of corresponding images
%     PtNumber - Number of the patient to organise the images for


%   Output:  structure (out) with different fields:
%     out.X - Image slices
%     out.Mmyo - Image slices, myocardium mask
%     out.Minf - Image slices, infarct mask
%     out.Mask - Image slices, endocardium, epicardium, and infarct mask
%     out.intersectpoint - Position of intersection point between endocardium and epicardium [xi, yi]
%     out.patient - Pt
% %%% ----- created by Mahdieh Khanmohammadi and modified, January 2016. ------
%
% -----------
%  --  Modified by K. Engan jan 2016, 
%                           feb 2016
%                           mars 2016 -     out.PixSize=PixSize(:,ind2);
%                           15 mars 2016 -  bugfix
% --------


% Some of the DICOM headers don't include the creation date in the
% SOPInstanceUID, for them Start and End is used:
Start = 40; % start of the time of acqusition in the string MediaStorageSOPInstanceUID
End = 49; % end of the time of acqusition in the string MediaStorageSOPInstanceUID
filename = dir(filepath);

Pnames = {filename.name};
%Pt = cell2mat(PatientN(1,PtNumber));
if iscell(Pt)
  Pt=cell2mat(Pt);
end
[indl]=strmatch([Pt,'_'],Pnames);
imList = Pnames(indl);
filename = Pt;
imageposition = [];
infoAll=[];
time=[];
number=[];
repeated = [];
filenameDel = dir(fullfile(filepathDel,'*.mat'));
filenameDel = {filenameDel.name};
if ~isempty(strfind(Pt,'_'))
    index = strfind(Pt,'_');
    Pt = Pt(1:index-1);
end
[inddel]=strmatch([Pt,'.'],filenameDel);
if ~isempty(inddel)
    load([filepathDel,Pt,'.mat']);
end
for i= 1:length(imList)
    tmp = [filepath,cell2mat(imList(i))];
    Y = dicomread(tmp);
    info = dicominfo(tmp);
    imageposition = [imageposition;info.InPlanePhaseEncodingDirection];
    t = info.MediaStorageSOPInstanceUID;  % SOPInstanceUID is a worldwide unique ID consist of date, time and other numberings to make it unique for each image.
    if length(t)>=63
        str = info.InstanceCreationDate;
        indtime = strfind(t,str);
        t = str2num(t(indtime+8:end));
    elseif length(t)<63
        t = str2num(t(Start:End));
    end
    time= [time;t];
    number = [number;info.InstanceNumber];
    repeated = [repeated; info.LowRRValue];
end
indp = strmatch('COL', imageposition);% checking for the direction of the images to discard columnar images  
time(indp) = [];
repeated(indp) = [];
mr = mode(repeated);% finding the repeated images to be discarded 
indr = find(repeated ~= mr);
time(indr) = [];
[s,ind]= sort(time);% sorting the images based on their SOP Instance UID
i = 1:length(imList);
i(indp)= [];
%i(indr)= [];
out.Exists = 0;
for j = 1:length(ind)
    tmp = [filepath,cell2mat(imList(i(ind(j))))];
    if ~isempty(inddel)
        list=who;
        [inddelname]=strmatch(imList(i(ind(j))),list);
        if ~isempty(inddelname)
            display('delineation Exists!')
            eval(['bn=',list{inddelname},';']);
            [Mmyokard{j},Minf{j},Mask{j}]=mask_data(bn.imS,bn.xy,bn.xys);% adding the doctor's delineation if they exist.
            X{j}=dicomread(tmp);
            info= dicominfo(tmp);
            PixSize(:,j)=info.PixelSpacing;
            xi = bn.xi;
            yi = bn.yi;
            intersectpoint{j} = [xi,yi];
            xcc{j}=bn.xcc;  %  added by KE
%         elseif isempty(inddelname)
%             Mask=[];
%             X=[];
%             Mmyokard=[];
%             Minf=[];
%             intersectpoint=[];
        end
        out.Exists = 1;
        
    elseif isempty(inddel)
        display('delineation is Empty!')
        X{j}=dicomread(tmp);              % changed march 2016 --
        [nr,nc]=size(X{j});
        if nr==256
             X{j}= imresize(X{j}, [512 512]);
             out.resize=1;
        end
        info= dicominfo(tmp);
        PixSize(:,j)=info.PixelSpacing;    % changed march 2016 --
    end
end

if ~isempty(inddel) %&& ~isempty(inddelname)
    indicator=zeros(1,length(Mask));
    for i=1:length(Mask)
        indicator(i)=isempty(Mask{i});
    end
    
    ind2=find(indicator==0);
    
    out.X = X(ind2);
    out.Mask = Mask(ind2);
    
    % ------  added feb 2016 -----
    %  because for some data the 256x256 images are upsampled to 512 x 512 prior to manual deliniation.
    %if ~isempty(Mask) && ~isempty(X)
    [nr,nc]=size(out.X{1});
    [nrm, ncm]=size(out.Mask{1}{1});
    if nr ~= nrm
        for i = 1:length(ind2)
            out.X{i}= imresize(out.X{i}, [nrm ncm]);
            out.resize=1;
        end
    end
    %end
    % -----------
    
    out.Mmyo = Mmyokard(ind2);
    out.Minf = Minf(ind2);
    out.intersectpoint = intersectpoint(ind2);
    out.cent=xcc(ind2);
    out.PixSize=PixSize(:,ind2);    % changed march 2016 --
    
elseif isempty(inddel)
    if ~isempty(ind)
    ind=2:1:(length(X)-1);
    out.X=X(ind);
    out.PixSize=PixSize(:,ind);
    end
elseif isempty(inddelname)
    out.Exists=0;
end





%out.X = X(2:end); %If the doctor's delineation does not exist only the image will be saved in the output
%if ~isempty(inddel)% If the doctor's delineation exists image, Myokard mask and scar mask will be saved in the output
%    out.Mask = Mask(2:end);
%    out.Mmyo = Mmyokard(2:end);
%    out.Minf = Minf(2:end);
%    out.intersectpoint = intersectpoint(2:end);
%    out.cent=xcc(2:end);
%end


out.patient=Pt;

