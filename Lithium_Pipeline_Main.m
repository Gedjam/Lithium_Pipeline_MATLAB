function Lithium_Pipeline_Main(List,Lithium_Img_List,Lithium_T1_List,FS_Folder_List,Overall_Output_Dir)

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

%% Now sum rows to create a hierarchical region wise breakdown (Added 07.2024 on request)
%Lobes
Lobe_List = unique(LUT_Index.Lobe); 
Total_Table_Lobe=Total_Table(:,[1:3]); %Get the basic columns for table
for i = 1:length(Lobe_List) %for each lobe
    Spec_Table=LUT_Index(LUT_Index.Lobe == Lobe_List(i), :);
    Total_Spec=sum(Total_Table(:,[Spec_Table.Name]),2,"omitnan"); %Get the sum colmn for that specific type
    Total_Table_Lobe=horzcat(Total_Table_Lobe,Total_Spec);
    Lobe=Lobe_LUT(Lobe_LUT.Lobe_Idx==Lobe_List(i),:);
    Total_Table_Lobe=renamevars(Total_Table_Lobe,"sum",Lobe.Lobe_Name); %Rename the new column
end 

%Tissue Compartments
Tissue_List = unique(LUT_Index.Tissue); 
Total_Table_Tissue=Total_Table(:,[1:3]); %Get the basic columns for table
for i = 1:length(Tissue_List) %for each lobe
    Spec_Table=LUT_Index(LUT_Index.Tissue == Tissue_List(i), :);
    Total_Spec=sum(Total_Table(:,[Spec_Table.Name]),2,"omitnan"); %Get the sum colmn for that specific type
    Total_Table_Tissue=horzcat(Total_Table_Tissue,Total_Spec);
    Tissue=Tissue_LUT(Tissue_LUT.Tissue_Idx==Tissue_List(i),:);
    Total_Table_Tissue=renamevars(Total_Table_Tissue,"sum",Tissue.Tissue_Names);
end 

%Brain vs nonbrain
Brain_List = unique(LUT_Index.Brain); 
Total_Table_Brain=Total_Table(:,[1:3]); %Get the basic columns for table
for i = 1:length(Brain_List) %for each lobe
    Spec_Table=LUT_Index(LUT_Index.Brain == Brain_List(i), :);
    Total_Spec=sum(Total_Table(:,[Spec_Table.Name]),2,"omitnan"); %Get the sum colmn for that specific type
    Total_Table_Brain=horzcat(Total_Table_Brain,Total_Spec);
    Brain=Brain_LUT(Brain_LUT.Brain_Idx==Brain_List(i),:);
    Total_Table_Brain=renamevars(Total_Table_Brain,"sum",Brain.Brain_Names);
end 

% Save into new workspace

writetable(Total_Table_Lobe,strcat(Overall_Output_Dir,"/Overall_Stats/Total_Table_Lobe.csv"))
writetable(Total_Table_Tissue,strcat(Overall_Output_Dir,"/Overall_Stats/Total_Table_Tissue.csv"))
writetable(Total_Table_Brain,strcat(Overall_Output_Dir,"/Overall_Stats/Total_Table_Brain.csv"))


%% Now calculate the MWA for the new Columns

Name_List=unique(Total_MWV_Table.ID);

%For Lobe
Lobe_Regions=Total_Table_Lobe(:,4:end);
Total_Table_Lobe_MWA=nan(length(Name_List),width(Lobe_Regions)); 
Total_Table_Lobe_MWA=array2table(Total_Table_Lobe_MWA);
Total_Table_Lobe_MWA.Properties.VariableNames=Lobe_Regions.Properties.VariableNames; 

for i = 1:length(Name_List) %Per individual
    Subj_MWA=Total_Table_Lobe(Total_Table_Lobe.ID==(Name_List(i)),:);
    Lobe_Regions=Subj_MWA(:,4:end);

    for j = 1:width(Lobe_Regions) %Per Lobe
        jn=j+3;%Correct position on the Atlas     
        [row, ~] = find(Subj_MWA(:,jn).(1));
        Lobe_Rows = Subj_MWA(row,:); 
        MWA_Lobe=mean(Lobe_Rows.Lithium_Value,Weights=(Lobe_Rows(:,jn).(1))); %MWA
        Total_Table_Lobe_MWA{i,j}=MWA_Lobe;      
    end
end 

ID=Name_List;
ID_Table=table(ID);
Total_Table_Lobe_MWA=horzcat(ID_Table,Total_Table_Lobe_MWA); 
writetable(Total_Table_Lobe_MWA,strcat(Overall_Output_Dir,"/Overall_Stats/Total_Table_Lobe_MWA.csv"))


%For Tissue
Tissue_Types=Total_Table_Tissue(:,4:end);
Total_Table_Tissue_MWA=nan(length(Name_List),width(Tissue_Types)); 
Total_Table_Tissue_MWA=array2table(Total_Table_Tissue_MWA);
Total_Table_Tissue_MWA.Properties.VariableNames=Tissue_Types.Properties.VariableNames; 

for i = 1:length(Name_List) %Per individual
    Subj_MWA=Total_Table_Tissue(Total_Table_Tissue.ID==(Name_List(i)),:);
    Tissue_Types=Subj_MWA(:,[4:end]);

    for j = 1:width(Tissue_Types) %Per Tissue Type
        jn=j+3;%Correct position on the Atlas     
        [row, ~] = find(Subj_MWA(:,jn).(1));
        Tissue_Rows = Subj_MWA(row,:); 
        MWA_Tissue=mean(Tissue_Rows.Lithium_Value,Weights=(Tissue_Rows(:,jn).(1))); %MWA
        Total_Table_Tissue_MWA{i,j}=MWA_Tissue;      
    end
end 

Total_Table_Tissue_MWA=horzcat(ID_Table,Total_Table_Tissue_MWA); 
writetable(Total_Table_Tissue_MWA,strcat(Overall_Output_Dir,"/Overall_Stats/Total_Table_Tissue_MWA.csv"))


%For Brain
Brain_Types=Total_Table_Tissue(:,4:end);
Total_Table_Brain_MWA=nan(length(Name_List),width(Brain_Types)); 
Total_Table_Brain_MWA=array2table(Total_Table_Brain_MWA);
Total_Table_Brain_MWA.Properties.VariableNames=Brain_Types.Properties.VariableNames; 

for i = 1:length(Name_List) %Per individual
    Subj_MWA=Total_Table_Tissue(Total_Table_Brain.ID==(Name_List(i)),:);
    Brain_Types=Subj_MWA(:,[4:end]);

    for j = 1:width(Brain_Types) %Per Tissue Type
        jn=j+3;%Correct position on the Atlas     
        [row, ~] = find(Subj_MWA(:,jn).(1));
        Brain_Rows = Subj_MWA(row,:); 
        MWA_Brain=mean(Brain_Rows.Lithium_Value,Weights=(Brain_Rows(:,jn).(1))); %MWA
        Total_Table_Brain_MWA{i,j}=MWA_Brain;      
    end
end 

Total_Table_Brain_MWA=horzcat(ID_Table,Total_Table_Brain_MWA); 
writetable(Total_Table_Brain_MWA,strcat(Overall_Output_Dir,"/Overall_Stats/Total_Table_Brain_MWA.csv"))

end
