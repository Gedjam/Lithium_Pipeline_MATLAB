%% Simple reg test

MNI_152_Eye_Ancor_FP = "/Users/ngh92/Documents/GitHub/Lithium_Pipeline_MATLAB/MNI152_T1_1mm_VentricleMask_eyes_s10.nii.gz";
MNI_152_Brain_FP = "/Users/ngh92/Documents/GitHub/Lithium_Pipeline_MATLAB/MNI152_T1_1mm.nii.gz"; 

MNI152_Eye_Anc_Vol = medicalVolume(MNI_152_Eye_Ancor_FP); 
MNI152_Brain_Vol = medicalVolume(MNI_152_Brain_FP); 

FS_Brain_Img=fullfile(FS_Dir,"/mri/brain.nii.gz"); 
Brain_IMG_Volume = medicalVolume(FS_Brain_Img); 


MNI152_Vox_Spacing=MNI152_Eye_Anc_Vol.VoxelSpacing; 
RMNI152_eye_Anc_3d  = imref3d(size(MNI152_Eye_Anc_Vol.Voxels),MNI152_Vox_Spacing(1), ...
    MNI152_Vox_Spacing(2),MNI152_Vox_Spacing(3));


%Time for registration, selecting monomodal reg
[optimizer,metric] = imregconfig('multimodal');

%optimizer.MaximumIterations = 6000000000000000000; 
optimizer.InitialRadius = 0.000000001; 
%optimizer.GrowthFactor = 1.000001;
tform = imregtform(rescale(MNI152_Eye_Anc_Vol.Voxels),RMNI152_eye_Anc_3d,rescale(newVol.Voxels),Rfixed3d,"translation",optimizer,metric);

[movingRegisteredVoxels,ref]= imwarp(MNI152_Eye_Anc_Vol.Voxels,RMNI152_eye_Anc_3d,tform,"linear",OutputView=Rfixed3d);




movingRegisteredVolume = medicalVolume(movingRegisteredVoxels,newRef); % New ref coming from the resampled Lithium space

write(movingRegisteredVolume,strcat(Output_Dir,"/Registered_Orig_Lithium_T1_MNI152.nii"))
