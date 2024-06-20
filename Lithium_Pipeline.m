function Lithium_Pipeline(List,Lithium_Img_List,Lithium_T1_List,FS_Folder_List,Overall_Output_Dir)

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

%Now get the names for all the header names, create a table
load("LUT_INDEX.mat")
Total_Names=["ID",string(LUT_Index.Name')];
Table_Head_Names = ["ID","Voxel","Lithium_Value",string(LUT_Index.Name')];

Total_Table = array2table(nan(1,length(Table_Head_Names)),'VariableNames',Table_Head_Names); 
Total_MWV_Table = array2table(nan(1,length(Total_Names)),'VariableNames',Total_Names);

for i=1:length(List_Import)

    %% Step 4: Build the cohort database from the two current .csv's    
    %Voxel Consistency
    Subject_Table=readtable(strcat(Overall_Output_Dir,"/",List_Import(i),"/Stats/Table_Values.csv"),'PreserveVariableNames',true); %Make sure to preserve names
    Voxels=height(Subject_Table); 
    Current_Subj=array2table(repmat(List_Import(i),[Voxels,1]));
    Current_Subj.Properties.VariableNames="ID";
    Combined_Table=horzcat(Current_Subj,Subject_Table);
    
    %Run same on Mean weighted volume (MWV)
    Subject_MWV_Table=readtable(strcat(Overall_Output_Dir,"/",List_Import(i),"/Stats/Regional_Values_MWA.csv"),'PreserveVariableNames',true);
    ID=array2table(List_Import(i));
    ID.Properties.VariableNames="ID"; 
    Combined_MWV_Table=horzcat(ID,Subject_MWV_Table); %Add subject label
    
    
    %% Problem here is subjects have differing table sizes
    %If the first subject, else add to whats already there
    if i == 1
    
        %Table sizes are different therefore, combine into one complete
        %table
        Current_Missing = setdiff(string(Total_Table.Properties.VariableNames),string(Combined_Table.Properties.VariableNames));
        %Now combine the additional variables from other tables
        Combined_Table = [Combined_Table array2table(nan(height(Combined_Table), numel(Current_Missing)), 'VariableNames', Current_Missing)]; 
        %If first instead of concat, make the first
        Total_Table=Combined_Table;

        %---- Same for the MWV    
        Current_Missing_MWV = setdiff(string(Total_MWV_Table.Properties.VariableNames),string(Combined_MWV_Table.Properties.VariableNames)); 
        Combined_MWV_Table = [Combined_MWV_Table array2table(nan(height(Combined_MWV_Table), numel(Current_Missing_MWV)), 'VariableNames', Current_Missing_MWV)]; 
        Total_MWV_Table=Combined_MWV_Table;

    else 
        
        %Get whats missing and then create a mini total ready for concat
        Current_Missing = setdiff(string(Total_Table.Properties.VariableNames),string(Combined_Table.Properties.VariableNames));
        %Now combine the additional variables from other tables
        Combined_Table = [Combined_Table array2table(nan(height(Combined_Table), numel(Current_Missing)), 'VariableNames', Current_Missing)];  
        Total_Table=[Total_Table;Combined_Table]; 

        
        Current_Missing_MWV = setdiff(string(Total_MWV_Table.Properties.VariableNames),string(Combined_MWV_Table.Properties.VariableNames));
        %Now combine the additional variables from other tables
        Combined_MWV_Table = [Combined_MWV_Table array2table(nan(height(Combined_MWV_Table), numel(Current_Missing_MWV)), 'VariableNames', Current_Missing_MWV)];  
        Total_MWV_Table=[Total_MWV_Table;Combined_MWV_Table]; 

    end 
end 

writetable(Total_Table,(strcat(Overall_Output_Dir,"/Overall_Stats/Overall_Table_Values.csv")));
writetable(Total_MWV_Table,(strcat(Overall_Output_Dir,"/Overall_Stats/Overall_Regional_Values_MWA.csv")));

%Now combine rows to create Inside/Outisde brain, Tissue and Lobe based measures

end
