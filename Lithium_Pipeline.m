function Lithium_Pipeline(List.txt,Lithium_Img,Lithium_T1,FS_Folder,Output_Dir);


for i=1:length(List.txt)

%% Main per-subject script that runs Lithium Image, Lithium T1, FS folder, and Output_Folder 
    
    %% Step 1: Pre-processing 
    Alignment(Lithium_Img,Lithium_T1,FS_Folder,Output_Dir)
    
    %% Step 2: Get attributes of the underlying voxel
    %Get the underlying properties of each lithium voxel and get lithium
    %value
    Alignment_Workspace=(strcat(Output_Dir,"/Alignment_Workspace.mat")); 
    Voxel_Consistency(Alignment_Workspace)

    %% Step 3: Add this to an overall table, also get summary stats on it
    %Create a script that collects the tables an creates one whole table
    Overall_Summary_Stats()
 
end