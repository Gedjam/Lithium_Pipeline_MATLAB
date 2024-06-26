%function Lithium_Mist_Registration(Lith,FS_Dir,Output_Dir)

Lith_Img="/Users/ngh92/Documents/Lithium_Analysis_Script/Lithuim_Data/bliss/temp_transfer/blissmr091/lithium/blissmr091_complex_avg_mag.nii";
FS_Dir="/Users/ngh92/Documents/Lithium_Analysis_Script/Lithuim_Data_FreeSurfer/blissmr091";
Output_Dir="/Users/ngh92/Documents/MATLAB/Lithium_APP_Script/Test_091";

%% Lithium Mist registration
%Load in Lith_Img
Lith_Img_Volume=medicalVolume(Lith_Img);
Lith_Img_Volume.PlaneMapping

%Load in images
MNI152=medicalVolume("/Users/ngh92/Documents/GitHub/Lithium_Pipeline_MATLAB/MNI152_T1_1mm.nii.gz"); 
MNI152_Mask_Comp=medicalVolume("/Users/ngh92/Documents/GitHub/Lithium_Pipeline_MATLAB/MNI152_T1_2mm_WM_w_eyes.nii.gz"); 
MNI152.PlaneMapping %Don't change all good
MNI152_Voxels=double(MNI152.Voxels); 

FS_Orig_Img = fullfile(FS_Dir,"/mri/orig.nii.gz"); 
FS_Orig_MRIVolume = medicalVolume(FS_Orig_Img); 
FS_Orig_MRIVolume.PlaneMapping

FS_Orig_MRIVoxels = double(permute(FS_Orig_MRIVolume.Voxels,[1 3 2])); 

%Register the images together get fixed voxels and moving voxels
fixedVoxelSpacing=FS_Orig_MRIVolume.VoxelSpacing;
movingVoxelSpacing=MNI152.VoxelSpacing; 

%Build up the destination info
Rfixed3d  = imref3d(size(FS_Orig_MRIVoxels),fixedVoxelSpacing(1), ...
    fixedVoxelSpacing(3),fixedVoxelSpacing(2)); %Swap here for orig
Rmoving3d = imref3d(size(MNI152.Voxels),movingVoxelSpacing(1), ...
    movingVoxelSpacing(2),movingVoxelSpacing(3)); 

%Time for registration, move MNI152 to orig
[optimizer,metric] = imregconfig('multimodal');
%optimizer.InitialRadius=4;


Fixed=FS_Orig_MRIVoxels; 
Moving=MNI152_Voxels;

%% initial registration 
HalfMNI152=size(MNI152_Voxels)/2;
centreMNI152=HalfMNI152(3);

HalfOrig=size(FS_Orig_MRIVoxels)/2;
centreMNI152=HalfOrig(3);


MNIwin = centerCropWindow3d(size(MNI152_Voxels),ceil(size(MNI152_Voxels)/2));
Origwin = centerCropWindow3d(size(FS_Orig_MRIVoxels),ceil(size(MNI152_Voxels)/2));

MNIcrop = imcrop3(MNI152_Voxels,MNIwin);
Origcrop = imcrop3(FS_Orig_MRIVoxels,Origwin);

sliceViewer(Origcrop)   

Rfixed3d_crop  = imref3d(size(Origcrop),fixedVoxelSpacing(1), ...
    fixedVoxelSpacing(3),fixedVoxelSpacing(2)); %Swap here for orig
Rmoving3d_crop = imref3d(size(MNIcrop),movingVoxelSpacing(1), ...
    movingVoxelSpacing(2),movingVoxelSpacing(3)); 

%MNI152_Voxels_rescale=rescale(Moving);
%Origcrop_rescale=rescale(Fixed);

%MNI152_Voxels_Hist = imhistmatchn(MNI152_Voxels_rescale,Origcrop_rescale);
%sliceViewer(MNI152_Voxels_Hist)

MNI152_Voxels_Hist=imgaussfilt3(Moving, 4);
Origcrop_rescale=imgaussfilt3(Fixed, 4);

figure
montage(MNI152_Voxels_Hist,'DisplayRange',[])
figure
montage(Origcrop_rescale,'DisplayRange',[])


sliceViewer(MNI152_Voxels_Hist)

tform = imregtform(MNI152_Voxels_Hist,Rmoving3d,Origcrop_rescale,Rfixed3d,"affine",optimizer,metric);
[movingRegisteredVoxels,ref]= imwarp(MNI152_Voxels,Rmoving3d,tform,"linear",OutputView=Rfixed3d);

movingRegisteredVoxels = double(permute(movingRegisteredVoxels,[1 3 2]));

movingRegisteredVolume = medicalVolume(movingRegisteredVoxels,FS_Orig_MRIVolume.VolumeGeometry);
write(movingRegisteredVolume,strcat(Output_Dir,"/Crop_Test.nii"))

%%Works... need to test retest the smoothing factors
%figure
%imshowpair(movingRegisteredVoxels(:,:,150),Fixed(:,:,150))
%title("Unregistered Transverse Slice")

%Resample the Lithium image to Orig

Resampled_Lith=resample(Lith_Img_Volume,FS_Orig_MRIVolume.VolumeGeometry,Method="linear");

Resampled_Lith_Smoothed=imgaussfilt3(Resampled_Lith.Voxels,4);

Resampled_Lith.PlaneMapping;
MNI152_Mask_Comp.PlaneMapping;

MNI152_Mask_Comp_Voxels=permute(MNI152_Mask_Comp.Voxels, [1 3 2]);

%montage(MNI152_Mask_Comp_Voxels(:,:,150),Resampled_Lith.Voxels(:,:,150))


Resampled_Lith_Smoothed_rescale=rescale(Resampled_Lith_Smoothed);
MNI152_Mask_Comp_Smoothed_rescale=rescale(MNI152_Mask_Comp_Voxels); 


%MNI152_Voxels_Hist = imhistmatchn(MNI152_Mask_Comp_Smoothed_rescale,Resampled_Lith_Smoothed_rescale);


%Create the 3d versions
Rmoving3d_Mist  = imref3d(size(MNI152_Mask_Comp_Voxels),MNI152_Mask_Comp.VoxelSpacing(1), ...
    MNI152_Mask_Comp.VoxelSpacing(3),MNI152_Mask_Comp.VoxelSpacing(2)); %Swap here for Lithium
Rfixed3d_Mist = imref3d(size(Resampled_Lith.Voxels),Resampled_Lith.VoxelSpacing(1), ...
    Resampled_Lith.VoxelSpacing(2),Resampled_Lith.VoxelSpacing(3)); 


%Register the mist
[optimizer,metric] = imregconfig('multimodal');


tform = imregtform(MNI152_Mask_Comp_Voxels,Rmoving3d_Mist,Resampled_Lith_Smoothed,Rfixed3d_Mist,"affine",optimizer,metric);

%figure
%imshowpair(MNI152_Voxels_Hist(:,:,200),Resampled_Lith_Smoothed_rescale(:,:,200))
%title("Unregistered Transverse Slice")


[movingRegisteredVoxels,ref]= imwarp(MNI152_Voxels,Rmoving3d,tform,"linear",OutputView=Rfixed3d);

movingRegisteredVoxels = double(permute(movingRegisteredVoxels,[1 3 2]));

movingRegisteredVolume = medicalVolume(movingRegisteredVoxels,Resampled_Lith.VolumeGeometry);
write(movingRegisteredVolume,strcat(Output_Dir,"/Test_Mist.nii"))



%% 
%end 