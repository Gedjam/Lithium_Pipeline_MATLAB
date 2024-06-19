function Voxel_Consistency(Alignment_Workspace)

%Alignment_Workspace="/Users/ngh92/Documents/MATLAB/Lithium_APP_Script/Test_077/Alignment_Workspace.mat";
load(Alignment_Workspace);
load("LUT_INDEX.mat")

%Upsample each individual Voxel in the lith mask, give it an LUT 

Mask_Size = size(Brain_Mask_Lith.Voxels);

uni_count=1;
Mask_LUT=Brain_Mask_Lith.Voxels; 

for i = 1:Mask_Size(1)
    for j = 1:Mask_Size(2)
        for k = 1:Mask_Size(3)
        
            Val=Brain_Mask_Lith.Voxels(i,j,k);
                
                if Val==1
                    Mask_LUT(i,j,k)=Mask_LUT(i,j,k)*uni_count; 
                    uni_count=uni_count+1;                                    
                end 
        end 
    end
end     

%Now to resample the LUT

%sliceViewer(Mask_LUT)

Mask_R=Brain_Mask_Lith.VolumeGeometry;

Lith_Mask_LUT=medicalVolume(Mask_LUT,Mask_R); 
%Save out
write(Lith_Mask_LUT,strcat(Output_Dir,"/Lithium_LUT.nii"))

%% Resample time

LUT_List=unique(Lith_Mask_LUT.Voxels);
LUT_List(LUT_List == 0)=[]; 

%% ---- Slight problem here LUT slighty cutting out over top, seems a problem with resample step
% Potential Fix another day
%Lith_Mask_LUT_Pad=padarray(Lith_Mask_LUT.Voxels,[1 1],0,'both');
%fixedVoxelSpacing=Lith_Mask_LUT.VoxelSpacing;
%Mask_R_Pad  = medicalref3d(size(Lith_Mask_LUT_Pad), Lith_Mask_LUT. ,fixedVoxelSpacing);
%Lith_Mask_LUT=medicalVolume(Lith_Mask_LUT_Pad,Mask_R_Pad); 
%% ------
%% Attempt 2 resample

%Lithium_T1w_Res=Lith_T1w_MRIVolume.VolumeGeometry.VolumeSize;
%Lithium_Img_Res=Brain_Mask_Lith.VolumeGeometry.VolumeSize;


%% Work in progress

% Shift before resampling because will have to find underlying voxel size
% from Lithium to T1w space
Lith_Mask_LUT_Resample=resample(Lith_Mask_LUT,Lith_T1w_MRIVolume.VolumeGeometry,method="nearest");
write(Lith_Mask_LUT_Resample,strcat(Output_Dir,"/Lithium_LUT_T1w_Res_Unshifted.nii")); %So far resample gives shift

%% Run a 1 (lithium space) shift due to matlab counting from one, 
%Brain_Mask_Lith = medicalVolume(Lith_Mask_LUT_Resample);
Lithium_T1w_Res=Lith_T1w_MRIVolume.VoxelSpacing;
Lithium_Img_Res=Brain_Mask_Lith.VoxelSpacing;
ratios =  Lithium_Img_Res./Lithium_T1w_Res;

new_ratios=ceil(ratios-1); 

Lith_Mask_LUT_Resample_Shift=circshift(Lith_Mask_LUT_Resample.Voxels, new_ratios); % One Voxel shift seems to exist
Lith_Mask_LUT=medicalVolume(double(Lith_Mask_LUT_Resample_Shift),Lith_T1w_MRIVolume.VolumeGeometry); 
write(Lith_Mask_LUT,strcat(Output_Dir,"/Lithium_LUT_T1w_Res.nii"))

%sliceViewer(Brain_Mask_Lith)

%Get tissue maps of FS (no need to resample)
All_Atlas_Values = unique(Atlas_Reg.Voxels); 

%Get values of atlas and build whats required for the tables
Table_Head = ['Voxel','Lithium_Value',string(All_Atlas_Values')];
[is_there,name_idx]=ismember(LUT_Index.LUT,All_Atlas_Values);
Names=LUT_Index.Name(is_there,:); %Maybe sort order out too if required keep idx here for now
Table_Head_Names = ['Voxel','Lithium_Value',string(Names')];
Table_Layout=nan([length(LUT_List),length(Table_Head)]);
Subject_Table=array2table(Table_Layout);
Subject_Table.Properties.VariableNames = Table_Head; 

%Add a cheeky Voxel size table to QC resampling
Resample_Vox_QC=nan([length(LUT_List),1]);


%% Build basic table first  

for i = 1:length(LUT_List)

    ROI=(Lith_Mask_LUT_Resample.Voxels==LUT_List(i)); %Per each Lith voxel T1 reso
    ROI_Lith_Space=(Mask_LUT==LUT_List(i)); %Per each Lith vox, Lith resolution
    %Get makeup
    Values_ROI=Atlas_Reg.Voxels(ROI);
    %Get Lithium
    Lithium_ImageVoxels = Lithium_Image.Voxels;
    Lithium=Lithium_ImageVoxels(ROI_Lith_Space);

    ROI_Tab=tabulate(categorical(Values_ROI));
    ROI_Tab=cell2table(ROI_Tab);
    
    %Adding this in to check size of each voxel
    Size_of_ROI=sum(ROI_Tab.ROI_Tab2);
    Resample_Vox_QC(i,1)=Size_of_ROI;

    %Add into the table
    Subject_Table.Voxel(i)=LUT_List(i);
    Subject_Table.Lithium_Value(i)=Lithium; 
    
        %for each voxel
        for j = 1:length(ROI_Tab.ROI_Tab1)
            Current_Value=ROI_Tab.ROI_Tab1(j); 
            Subject_Table.(string(Current_Value))(i)=ROI_Tab.ROI_Tab3(j);
        end 
end 

%Change to actual names
Subject_Table.Properties.VariableNames = Table_Head_Names; 
writetable(Subject_Table,strcat(Output_Dir,"/Stats/Table_Values.csv"))

%Also save size of Lith voxels for resample QC
Resample_Vox_QC_fig=figure;
Resample_Vox_QC_fig=piechart(Resample_Vox_QC); 
Resample_Vox_QC_fig.Labels=[];
Resample_Vox_QC_fig.EdgeColor="none"; 
title("QC: Do all values in piechart look to be (somewhat) equal?")
saveas(Resample_Vox_QC_fig,strcat(Output_Dir,"/Stats/Resampled_Vox_Sizes.png")); 
close all 

%Now save workspace
save(strcat(Output_Dir,"/VC_Workspace.mat")); %%Save of workspace for next step

end 