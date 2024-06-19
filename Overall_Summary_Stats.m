function Overall_Summary_Stats(VC_Workspace)

%VC_Workspace="/Users/ngh92/Documents/MATLAB/Lithium_APP_Script/Test_091/VC_Workspace.mat";
load(VC_Workspace); 

%% Get subject table and calculate mean weighted average for regions
Regions=Table_Head_Names(3:end);

%Create new table for regions per Subject
Weighted_Mean_Region=nan(1,length(Regions));
%Subject_Table=array2table(Table_Layout);
%Subject_Table.Properties.VariableNames = Table_Head; 


for i = 1:length(Regions)

    Column=i+2; %Since the first two columns: Voxel number, Lithium
    %Extract Region + Lithium
    Individual_Region=Subject_Table(:,Column); 
    Lithium=Subject_Table(:,2);
    %Get idx that finds nans
    [row, ~] = find(isnan(Individual_Region.(1)));
    %Get rid of those
    Lithium(row,:)=[];
    Individual_Region(row,:)=[];

    Weighted_Mean_Region(1,i) = mean(table2array(Lithium),Weights=table2array(Individual_Region));
   
end

%Write out regional information to table
Weighted_Mean_Region_Table=array2table(Weighted_Mean_Region);
Weighted_Mean_Region_Table.Properties.VariableNames = Regions; 
writetable(Weighted_Mean_Region_Table,strcat(Output_Dir,"/Stats/Regional_Values_MWA.csv"))

end 