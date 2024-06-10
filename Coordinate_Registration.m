function Coordinate_Registration(T1w_Image,Lith_Img)

Lith_Img="/Users/ngh92/Documents/Lithium_Analysis_Script/Lithuim_Data/bliss/temp_transfer/blissmr091/lithium/blissmr091_complex_avg_mag.nii";
FS_Dir="/Users/ngh92/Documents/Lithium_Analysis_Script/Lithuim_Data_FreeSurfer/blissmr091";
Output_Dir="/Users/ngh92/Documents/MATLAB/Lithium_APP_Script/Test_091";

%% Co-ordinate registration
%Load in Lith_Img
Lith_Img_Volume=medicalVolume(Lith_Img);
Lith_Img_Volume.PlaneMapping

%Load in images
MNI152=medicalVolume("/Users/ngh92/Documents/GitHub/Lithium_Pipeline_MATLAB/MNI152_T1_1mm.nii.gz"); 
MNI152_Reye=medicalVolume("/Users/ngh92/Documents/GitHub/Lithium_Pipeline_MATLAB/MNI152_T1_1mm_Left_Eye_mask.nii.gz"); 
MNI152_Leye=medicalVolume("/Users/ngh92/Documents/GitHub/Lithium_Pipeline_MATLAB/MNI152_T1_1mm_Right_Eye_mask.nii.gz");

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
sliceViewer(MNI152_Voxels_Hist)

figure
montage(MNI152_Voxels_Hist,'DisplayRange',[])
figure
montage(Origcrop_rescale,'DisplayRange',[])

MNI152_Voxels_Hist=imgaussfilt3(Moving, 4);
Origcrop_rescale=imgaussfilt3(Fixed, 4);

sliceViewer(MNI152_Voxels_Hist)

tform = imregtform(MNI152_Voxels_Hist,Rmoving3d,Origcrop_rescale,Rfixed3d,"affine",optimizer,metric);
[movingRegisteredVoxels,ref]= imwarp(MNI152_Voxels,Rmoving3d,tform,"linear",OutputView=Rfixed3d);

movingRegisteredVoxels = double(permute(movingRegisteredVoxels,[1 3 2]));

movingRegisteredVolume = medicalVolume(movingRegisteredVoxels,FS_Orig_MRIVolume.VolumeGeometry);
write(movingRegisteredVolume,strcat(Output_Dir,"/Crop_Test.nii"))

%%Works... need to test retest the smoothing factors
figure
imshowpair(movingRegisteredVoxels(:,:,150),Fixed(:,:,150))
title("Unregistered Transverse Slice")


%Move the eyeball masks into Orig space

Reg_Reye = imwarp(MNI152_Reye.Voxels,Rmoving3d,tform,"nearest",OutputView=Rfixed3d);
Reg_Leye = imwarp(MNI152_Leye.Voxels,Rmoving3d,tform,"nearest",OutputView=Rfixed3d);

sliceViewer(Reg_Reye)

%Get the centroids of each eyeball
Reg_Reye_Cent = regionprops3(Reg_Reye,"Centroid");
Reg_Leye_Cent = regionprops3(Reg_Leye,"Centroid");

%Resample the Lithium image to Orig

Resampled_Lith=resample(Lith_Img_Volume,FS_Orig_MRIVolume.VolumeGeometry,Method="linear");

%Max_Val=max(Resampled_Lith.Voxels(:),[],'all');
%[r1,c1,v1] = ind2sub(size(Resampled_Lith.Voxels),find(Resampled_Lith.Voxels == Max_Val))


%write(Resampled_Lith,strcat(Output_Dir,"/Max.nii"))
%% Ended here for now 

%Get the two highest peaks & get coordinates


%Move the Orig image into the Lithium coordinates

%BAM, got a T1w image in Lithium space (not in resolution though)

end