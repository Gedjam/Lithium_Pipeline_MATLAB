function Alignment(Lith_Img,Lith_T1w_Img,FS_Dir,Output_Dir)

%Lith_Img="/Users/ngh92/Documents/Lithium_Analysis_Script/Lithuim_Data/bliss/temp_transfer/blissmr077/lithium/blissmr077_complex_avg_mag.nii";
%Lith_T1w_Img="/Users/ngh92/Documents/Lithium_Analysis_Script/Lithuim_Data/bliss/temp_transfer/blissmr077/lithium/blissmr077_T1w_lithium_coil.nii.gz";
%FS_Dir="/Users/ngh92/Documents/Lithium_Analysis_Script/Lithuim_Data_FreeSurfer/blissmr077";
%Output_Dir="/Users/ngh92/Documents/MATLAB/Lithium_APP_Script/Test_077";

%Make the output directory, keeping these separate for now
mkdir(Output_Dir)
mkdir(strcat(Output_Dir,"/Image_Checks"));
mkdir(strcat(Output_Dir,"/Stats")); 

%FreeSurfer image lets get orig & brain
FS_Dir_orig=strcat(FS_Dir,"/mri/orig.mgz"); 
FS_Dir_brain=strcat(FS_Dir,"/mri/brain.mgz"); 
FS_Dir_Nii=strcat(FS_Dir,"/mri"); 
dicm2nii(FS_Dir_orig,FS_Dir_Nii,'nii.gz'); %Orig Conversion
dicm2nii(FS_Dir_brain,FS_Dir_Nii,'nii.gz'); %Brain Conversion
%Brain
FS_Brain_Img=fullfile(FS_Dir,"/mri/brain.nii.gz"); 
Brain_IMG_Volume = medicalVolume(FS_Brain_Img); 

%% -------- Now filepaths are setup load in

Lith_T1w_Img = fullfile(Lith_T1w_Img);
Lith_T1w_MRIVolume = medicalVolume(Lith_T1w_Img);
%Fixed seems to be Sag Trans Cor
Lith_T1w_orientation=Lith_T1w_MRIVolume.PlaneMapping 

%Orig
FS_Orig_Img = fullfile(FS_Dir,"/mri/orig.nii.gz"); 
FS_Orig_MRIVolume = medicalVolume(FS_Orig_Img); 

%moving seems to be Sag Trans Cor
FS_Orig_orientation=FS_Orig_MRIVolume.PlaneMapping


% Lets view each of the images
Lith_T1w_MRIVoxels = Lith_T1w_MRIVolume.Voxels;
FS_Orig_MRIVoxels = FS_Orig_MRIVolume.Voxels;

Lith_T1w_VolumeSize=size(Lith_T1w_MRIVoxels);
FS_Orig_VolumeSize=size(FS_Orig_MRIVoxels);

center_Lith_T1w = Lith_T1w_VolumeSize/2;
center_FS_Orig = FS_Orig_VolumeSize/2;

fixedVoxelSpacing = Lith_T1w_MRIVolume.VoxelSpacing;
movingVoxelSpacing = FS_Orig_MRIVolume.VoxelSpacing;

% Lets view the offset of orientation
Orientation=figure;
imshowpair(Lith_T1w_MRIVoxels(:,:,center_Lith_T1w(3)),FS_Orig_MRIVoxels(:,:,center_FS_Orig(3)));
Orientation.Position=[100 100 540 400];
title("Orientation Offset Original")
saveas(Orientation,strcat(Output_Dir,"/Image_Checks/Orientation_Ofset.png"))
close(Orientation)

%Since the orientations are off, lets swap them back
FS_Orig_MRIVoxels = permute(FS_Orig_MRIVoxels,[1 3 2]); % swapped matrix
%Repeat this for the Brain image
BrainMRIVoxels = permute(Brain_IMG_Volume.Voxels,[1 3 2]); 

%Double check the corrected orientations
Orientation_Fix=figure; 
imshowpair(Lith_T1w_MRIVoxels(:,:,center_Lith_T1w(3)),FS_Orig_MRIVoxels(:,:,center_FS_Orig(3)))
Orientation_Fix.Position=[100 100 540 400];
title("Unregistered Transverse Slice with fixed Orientation")
saveas(Orientation_Fix,strcat(Output_Dir,"/Image_Checks/Orientation_Fix.png"));
close(Orientation_Fix)


%Build up header information for the registration process
Rfixed3d  = imref3d(Lith_T1w_VolumeSize,fixedVoxelSpacing(1), ...
    fixedVoxelSpacing(2),fixedVoxelSpacing(3));
Rmoving3d = imref3d(size(FS_Orig_MRIVoxels),movingVoxelSpacing(1), ...
    movingVoxelSpacing(3),movingVoxelSpacing(2)); %Remember to swap here due to orientation

%Time for registration, selecting monomodal reg
[optimizer,metric] = imregconfig('monomodal');

tform = imregtform(FS_Orig_MRIVoxels,Rmoving3d,Lith_T1w_MRIVoxels,Rfixed3d,"rigid",optimizer,metric);
[movingRegisteredVoxels,ref]= imwarp(FS_Orig_MRIVoxels,Rmoving3d,tform,"linear",OutputView=Rfixed3d);

%Lets also register the brain 
[BrainRegisteredVoxels,ref2]= imwarp(BrainMRIVoxels,Rmoving3d,tform,"linear",OutputView=Rfixed3d);
%Lets create a simple brain mask too
BrainRegisteredVoxels_Mask=(BrainRegisteredVoxels>0); 

%Check sizes of voxels, should be all the same
whos movingRegisteredVoxels Lith_T1w_MRIVoxels BrainRegisteredVoxels

%Check again for registration
Reg_T1=figure;
imshowpair(movingRegisteredVoxels(:,:,center_Lith_T1w(3)),Lith_T1w_MRIVoxels(:,:,center_Lith_T1w(3)))
Reg_T1.Position=[100 100 540 400];
title("Registered Transverse Slice")
saveas(Reg_T1,strcat(Output_Dir,"/Image_Checks/Registered_Slice_T1w_2_T1wLith.png"))
close(Reg_T1)

Reg_Brain=figure; 
imshowpair(BrainRegisteredVoxels(:,:,center_Lith_T1w(3)),Lith_T1w_MRIVoxels(:,:,center_Lith_T1w(3)))
Reg_Brain.Position=[100 100 540 400];
title("Registered Transverse Slice of Brain, Check if fit is correct")
saveas(Reg_Brain,strcat(Output_Dir,"/Image_Checks/Registered_Slice_T1wBrain_2_T1wLith.png"))
close(Reg_Brain)

%Build image & assoicated header ready for saving
R = Lith_T1w_MRIVolume.VolumeGeometry;
movingRegisteredVolume = medicalVolume(movingRegisteredVoxels,R);

write(movingRegisteredVolume,strcat(Output_Dir,"/Registered_Orig_Lithium_T1.nii"))


%% ---- Lets load in the atlas
%FreeSurfer image lets get Atlas
FS_Dir_Atlas=strcat(FS_Dir,"/mri/aparc+aseg.mgz"); 
FS_Dir_Nii=strcat(FS_Dir,"/mri"); 
dicm2nii(FS_Dir_Atlas,FS_Dir_Nii,'nii.gz'); 

FS_Atlas_Img = fullfile(FS_Dir,"/mri/aparc_aseg.nii.gz"); 
FS_AtlasVolume = medicalVolume(FS_Atlas_Img); 

%Attempt to run the same swap done before
FS_AtlasVolume.PlaneMapping 
FS_AtlasVoxels=FS_AtlasVolume.Voxels;
%Run swap
FS_AtlasVoxels = permute(FS_AtlasVoxels,[1 3 2]);

sliceViewer(FS_AtlasVoxels)

%Get unique atlas regions
FS_Atlas_Regions = unique(FS_AtlasVoxels);
FS_Atlas_Size = size(FS_AtlasVoxels); 
FS_Atlas_Regions(FS_Atlas_Regions == 0) = [];

%Look first
Cor_Align=figure; 
imshowpair(FS_AtlasVoxels(:,:,center_FS_Orig(3)),FS_Orig_MRIVoxels(:,:,center_FS_Orig(3)))
Cor_Align.Position=[100 100 540 400];
title("Check alignment of Cortical ribbon (Transverse View)")
close(Cor_Align)

Atlas_4D=zeros([FS_Atlas_Size length(FS_Atlas_Regions)]);
Atlas_4D_Reg=zeros([size(movingRegisteredVoxels) length(FS_Atlas_Regions)]);
Atlas_4D_Reg_Smoothed=zeros([size(movingRegisteredVoxels) length(FS_Atlas_Regions)]);

%Apply Registration in here
for i = 1:length(FS_Atlas_Regions)   
    Atlas_4D(:,:,:,i)=(FS_AtlasVoxels == FS_Atlas_Regions(i)); 
    [Atlas_4D_Reg(:,:,:,i),ref_2]= imwarp(Atlas_4D(:,:,:,i),Rmoving3d,tform,"nearest",OutputView=Rfixed3d);
    Atlas_4D_Reg_Smoothed(:,:,:,i) = imgaussfilt3(Atlas_4D_Reg(:,:,:,i),4); %4mm smoothing
end 

%Now to find the maximum value
[Max_Vals,Index] = max(Atlas_4D_Reg_Smoothed,[],4,'linear');

whos I M

[~,~,~,Int_Pos] = ind2sub(size(Index),Index);

sliceViewer(Int_Pos)

%To save on memory
clear Atlas_4D Atlas_4D_Reg Atlas_4D_Reg_Smoothed

%Now to change interger positions into their respective values

FS_AtlasVoxels_Reg = FS_Atlas_Regions(Int_Pos); 

%Now trim the non-brain regions

FS_AtlasVoxels_Reg_Brain=double(FS_AtlasVoxels_Reg).*double(BrainRegisteredVoxels_Mask);

Atlas_Reg = medicalVolume(FS_AtlasVoxels_Reg_Brain,R);
write(Atlas_Reg,strcat(Output_Dir,"/Atlas_Registered_Lithium.nii"))

%% --------- Resample Mask to Lithium resolution

Lithium_Image = medicalVolume(Lith_Img);
Lithium_ImageVoxels = Lithium_Image.Voxels;

sliceViewer(Lithium_ImageVoxels)

Lithium_ImageVoxels_Sz=size(Lithium_ImageVoxels);
Lithium_R=imref3d(Lithium_ImageVoxels_Sz,Lithium_Image.VoxelSpacing(1),Lithium_Image.VoxelSpacing(2),Lithium_Image.VoxelSpacing(3)); 

%Setup for resample 
Brain_Mask_Volume=medicalVolume(double(BrainRegisteredVoxels_Mask),R);

%% When ever a resample
Brain_Mask_Volume_Resampled=resample(Brain_Mask_Volume,Lithium_Image.VolumeGeometry,method="nearest");
%% Run a -1 shift due to matlab counting from one
Brain_Mask_Shift=circshift(Brain_Mask_Volume_Resampled.Voxels, [-1, -1, -1]); % One Voxel shift seems to exist
Brain_Mask_Lith = medicalVolume(double(Brain_Mask_Shift),Lithium_Image.VolumeGeometry);
write(Brain_Mask_Lith,strcat(Output_Dir,"/Lithium_Mask.nii"))

%Leave this for now, no need Line above is fine
%write(Brain_Mask_Volume_Resampled,strcat(Output_Dir,"/Registered_Lithium_Mask.nii"))
%write(Brain_Mask_Shift,strcat(Output_Dir,"/Registered_Lithium_Mask.nii"))


%% Save workspace

save(strcat(Output_Dir,"/Alignment_Workspace.mat"),'Brain_Mask_Lith','Output_Dir','Lith_T1w_MRIVolume','Atlas_Reg','Lithium_Image'); %%Add the main images to workspace for easy loading

end 