function Voxel_Consistency(Alignment_Workspace)

Alignment_Workspace="/Users/ngh92/Documents/MATLAB/Lithium_APP_Script/Test_091/Alignment_Workspace.mat";
load("/Users/ngh92/Documents/MATLAB/Lithium_APP_Script/Test_091/Alignment_Workspace.mat");
load("LUT_INDEX.mat")

%Upsample each individual Voxel in the lith mask, give it an LUT 

Mask_Size = size(Brain_Mask_Volume_Resampled.Voxels);

uni_count=1;
Mask_LUT=Brain_Mask_Volume_Resampled.Voxels; 

for i = 1:Mask_Size(1)
    for j = 1:Mask_Size(2)
        for k = 1:Mask_Size(3)
        
            Val=Brain_Mask_Volume_Resampled.Voxels(i,j,k);
                
                if Val==1
                    Mask_LUT(i,j,k)=Mask_LUT(i,j,k)*uni_count; 
                    uni_count=uni_count+1;                                    
                end 
        end 
    end
end     

%Now to resample the LUT

sliceViewer(Mask_LUT)

Mask_R=Brain_Mask_Volume_Resampled.VolumeGeometry;

Lith_Mask_LUT=medicalVolume(Mask_LUT,Mask_R); 
%Save out
write(Lith_Mask_LUT,strcat(Output_Dir,"/Lithium_LUT.nii"))

%% Resample time

LUT_List=unique(Lith_Mask_LUT.Voxels);
LUT_List(LUT_List == 0)=[]; 

%Upsample
Lith_Mask_LUT_Resample=resample(Lith_Mask_LUT,Lith_T1w_MRIVolume.VolumeGeometry,method="nearest");

sliceViewer(Lith_Mask_LUT_Resample)

write(Lith_Mask_LUT_Resample,strcat(Output_Dir,"/Lithium_LUT_T1w_Res.nii"))

%Get tissue maps of FS (no need to resample)
All_Atlas_Values = unique(Atlas_Reg.Voxels); 

%Get values of atlas
Table_Head = ['Voxel','Lithium_Value',string(All_Atlas_Values')];

[is_there,name_idx]=ismember(LUT_Index.LUT,All_Atlas_Values);
Names=LUT_Index.Name(is_there,:); %Maybe sort order out too if required keep idx here for now

Table_Head_Names = ['Voxel','Lithium_Value',string(Names')];


Table_Layout=nan([length(LUT_List),length(Table_Head)]);

Subject_Table=array2table(Table_Layout);
Subject_Table.Properties.VariableNames = Table_Head; 

%% Build basic table first  

for i = 1:length(LUT_List)

    ROI=(Lith_Mask_LUT_Resample.Voxels==LUT_List(i)); %Per each Lith voxel T1 reso
    ROI_Lith_Space=(Mask_LUT==LUT_List(i)); %Per each Lith vox, Lith resolution
    %Get makeup
    Values_ROI=Atlas_Reg.Voxels(ROI);
    %Get Lithium
    Lithium=Lithium_ImageVoxels(ROI_Lith_Space);

    ROI_Tab=tabulate(categorical(Values_ROI));
    ROI_Tab=cell2table(ROI_Tab);

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
writetable(Subject_Table,strcat(Output_Dir,"/Table_Values.csv"))

%Build table per subject
h=figure; 
scatter(Subject_Table.("Outside-Brain"),Subject_Table.Lithium_Value,'fill');
xlabel("Percentage (%) of Lithium Voxel Outside of Brain")
ylabel("Lithium Concentration")
title("Scatter Plot of Partial Volume effects (each dot represents a Lithium voxel)") 
h=lsline;
h.LineWidth=3; 
h.LineStyle="--";

saveas(h,strcat(Output_Dir,"/Scatter.pdf"))
close all




end 