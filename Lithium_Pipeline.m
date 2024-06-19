%function Lithium_Pipeline(List,Lithium_Img_List,Lithium_T1_List,FS_Folder_List,Overall_Output_Dir)

%% For test purposes
List="/Users/ngh92/Documents/GitHub/Lithium_Pipeline_MATLAB/Subject_List_Test.txt";
Lithium_Img_List="/Users/ngh92/Documents/GitHub/Lithium_Pipeline_MATLAB/Avg_Mag_List.txt";
Lithium_T1_List="/Users/ngh92/Documents/GitHub/Lithium_Pipeline_MATLAB/Bliss_T1w_Lithium_List.txt";
FS_Folder_List="/Users/ngh92/Documents/Lithium_Analysis_Script/FreeSurfer_List.txt";
Overall_Output_Dir="/Users/ngh92/Desktop/Bliss_Output";

List_Import=readlines(List,"EmptyLineRule","skip");
Lithium_Img_List=readlines(Lithium_Img_List,"EmptyLineRule","skip");
Lithium_T1_List=readlines(Lithium_T1_List,"EmptyLineRule","skip"); 
FS_Folder_List=readlines(FS_Folder_List,"EmptyLineRule","skip"); 

mkdir(strcat(Overall_Output_Dir,"/Overall_Stats")); 

%% Run the pipeline calculate stats per individual
%Keeping the for loop separate to allow for parfor later on
for i=1:length(List_Import)

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
    
    %catch
    %    disp(strcat("Check ",List_Import(i))); 
    %end

end

%% Get all subjects and create a total table, WORK ON THIS TOMORROW
%Need to repad the table, with all names, 
%How many subjects? 
Subj_Size=length(List_Import);

%Now get the names for all the header names
load("LUT_INDEX.mat")
Total_Names=(LUT_Index.Name');



for i=1:length(List_Import)
    %% Step 4: Build the cohort database from the two current .csv's    
    Subject_Table=readtable(strcat(Overall_Output_Dir,"/",List_Import(i),"/Stats/Table_Values.csv"));
    Voxels=height(Subject_Table); 
    Current_Subj=array2table(repmat(List_Import(i),[Voxels,1]));
    Current_Subj.Properties.VariableNames="ID";
    Combined_Table=horzcat(Current_Subj,Subject_Table);
    Tbl_Head=Combined_Table.Properties.VariableNames; 
    %Run same on Mean weighted volume (MWV)
    Subject_MWV_Table=readtable(strcat(Overall_Output_Dir,"/",List_Import(i),"/Stats/Regional_Values_MWA.csv"));
    ID=array2table(List_Import(i));
    ID.Properties.VariableNames="ID"; 
    Subject_MWV_Table=horzcat(ID,Subject_MWV_Table); %Add subject label
    Head_MWV_Table=Subject_MWV_Table.Properties.VariableNames; 
    %% Problem here is subjects have differing table sizes
    %If the first subject, else add to whats already there
    if i == 1
        Total_Table=Combined_Table;
        Total_Table.Properties.VariableNames=Tbl_Head;

        Total_MWV_Table=Subject_MWV_Table;
        Total_MWV_Table.Properties.VariableNames=Head_MWV_Table;
    
    else 
        Combined_Table.Properties.VariableNames=Tbl_Head;
        Total_Table=[Total_Table;Combined_Table];

        Total_MWV_Table.Properties.VariableNames=Head_MWV_Table;
        Total_MWV_Table=[Total_MWV_Table;Subject_MWV_Table];

    end 
end 

writetable(Total_Table,(strcat(Overall_Output_Dir,"/Overall_Stats/Overall_Table_Values.csv")));
writetable(Total_MWV_Table,(strcat(Overall_Output_Dir,"/Overall_Stats/Overall_Regional_Values_MWA.csv")));

%Now combine rows to create Inside/Outisde brain, Tissue and Lobe based measures



%end
