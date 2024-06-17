function Lithium_Pipeline(List,Lithium_Img_List,Lithium_T1_List,FS_Folder_List,Overall_Output_Dir)

List_Import=readlines(List,"EmptyLineRule","skip");
Lithium_Img_List=readlines(Lithium_Img_List,"EmptyLineRule","skip");
Lithium_T1_List=readlines(Lithium_T1_List,"EmptyLineRule","skip"); 
FS_Folder_List=readlines(FS_Folder_List,"EmptyLineRule","skip"); 

mkdir(strcat(Overall_Output_Dir,"/Overall_Stats")); 


for i=1:length(List_Import)
    try 
    disp(strcat("Running ",List_Import(i)))
    
    %% Main per-subject script that runs Lithium Image, Lithium T1, FS folder, and Output_Folder 
    %% Step 1: Pre-processing 
    mkdir(strcat(Overall_Output_Dir,"/",List_Import(i)));
    Alignment(Lithium_Img_List(i),Lithium_T1_List(i),FS_Folder_List(i),strcat(Overall_Output_Dir,"/",List_Import(i)))
    
    %% Step 2: Get attributes of the underlying voxel
    %Get the underlying properties of each lithium voxel and get lithium
    %value
    Alignment_Workspace=strcat(Overall_Output_Dir,"/",List_Import(i),"/Alignment_Workspace.mat"); 
    Voxel_Consistency(Alignment_Workspace)

    %% Step 3: Add this to an overall table, also get summary stats on it
    %Create a script that collects the tables an creates one whole table
    VC_Workspace=strcat(Overall_Output_Dir,"/",List_Import(i),"/VC_Workspace.mat");
    Overall_Summary_Stats(VC_Workspace);
    
    catch
        disp(strcat("Check ",List_Import(i))); 
    end

end

for i=1:length(List_Import)
    %% Step 4: Build the cohort database from the two current .csv's    
    Subject_Table=readtable(strcat(Overall_Output_Dir,"/",List_Import(i),"/Stats/Table_Values.csv"));
    Subj_Size=length(Subject_Table); 
    disp(Subj_Size)
    

end
