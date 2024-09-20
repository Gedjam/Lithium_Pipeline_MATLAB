%% Complete re-resampling Test method

% More of a complete registration method

% --- Load in
moving_Folder = "/Users/ngh92/Desktop/Bliss_Output/blissmr049/Lithium_LUT.nii"; 
moving = medicalVolume(moving_Folder);
moving.VoxelSpacing

fixed_Folder = "/Users/ngh92/Desktop/Bliss_Output/blissmr049/Registered_Orig_Lithium_T1.nii"; 
fixed = medicalVolume(fixed_Folder);
fixed.VoxelSpaing

% --- Get ratio difference between voxel sizes
ratios = fixed.VoxelSpaing ./ moving.VoxelSpacing;
% --- Calculate new size
origSize = size(moving.Voxels);
newSize = round(origSize ./ ratios);

% --- Get Geometry and map to world
origRef = medVol.VolumeGeometry;
origMapping = intrinsicToWorldMapping(origRef);
tform = origMapping.A;

% --- Get the new resolutions of each tform
newMapping4by4 = tform.* [ratios([2 1 3]) 1];
newMapping = affinetform3d(newMapping4by4);

% -- build the new image
newRef = medicalref3d(newSize,newMapping);

newRef = orient(newRef,origRef.PatientCoordinateSystem);
newVol = resample(medVol,newRef