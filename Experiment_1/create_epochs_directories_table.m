%From directory table (made by create_recording_directory_table()), create a new sub-table for just every training day
%instead of divinding into the three epochs for each day. This gives easier
%access to epochs.mat file using the file_path column. This new table is
%used for create_SWS_charts() and spindle/SWR analysis. 

%load table var 't'
load('Y:\Seth_temp\Thesis recordings\directory_table.mat') %created by create_recording_directores()

%remove any file (row) from baseline phase
% t.phase = categorical(t.phase); %convert to categorical for next step
ix = t.phase == 'Baseline'; %index of rows with baseline
t(ix,:) = []; %delete the rows

%find unique groups of rat_num,group,phase & day (thus ignoring epoch)
[groups, epochs_t] = findgroups(t(:,1:4)); 

%add file_path column to table
file_path = cell(length(epochs_t.rat_num),1); %init empty cell array for paths
epochs_t = addvars(epochs_t,file_path);

%convoluted way to get one of the paths from a row in t that matches a
%group. i.e. in directoy table t (with baseline phase removed), for every unique group
%(such as rat 1, group E, Training phase) there are three rows that
%differ by the epoch column (i.e. post-task,pre-task and task). The last
%column is the file_path to these three epoch locations for this group, but i
%just want one of them as i will later be removing the last two files in
%the path to just have the path to the epochs.mat file two folders up. 
epochs_t.file_path = splitapply(@(x) x(1),t.path,groups);

%remove last two files in each file path (thus leading to epochs.mat)
epochs_t.file_path = cellfun(@remove_last_2_folders,epochs_t.file_path,'UniformOutput',false);

save("epochs_table.mat","epochs_t")