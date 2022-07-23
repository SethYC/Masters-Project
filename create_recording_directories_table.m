% Create a table containing information about the location of every Cheetah
% recording folder for my thesis experiment whilst including grouping
% information such as day, control or experimental, epoch, etc.
%
% example directory: Y:\Seth_temp\Thesis recordings\rat1E_6939\
% 2022-07-16-Training_day01\post-task_sleep\2022-07-16_15-47-02, after
% which contains the recording channel data like ctx1.ncs
%
% Seth Campbell - July 21, 2022

root_dir = 'Y:\Seth_temp\Thesis recordings'; %root directory for data

%helper functions
get_ratnum = @(x) str2num(regexp(x{end-3},'(?<=rat)[0-9]{1,2}(?=C|E)','match','once'));
get_group = @(x) x{end-3}(regexp(x{end-3},'E|C'));
get_phase = @(x) regexp(x{end-2},'Baseline|Training|Probe','match','once');
get_day = @(x) str2num(x{end-2}(end-1:end));
get_epoch = @(x) x{end-1};
% get_channel

%find all Chettah folders and their path
directories = dir([root_dir '\rat*\20*\*\20*']); %get struct array with info on cheetah folders only
directories = struct2table(directories); %convert to table for next step
folder_paths = strcat(directories.folder,'\',directories.name); %get full path together

%seperate parts of each file path
wrapper = @(x) split(x, '\'); %create function handle for split() with '\' specified a priori
split_paths = cellfun(wrapper,folder_paths,'UniformOutput',false); %for each file path, split it at each '\'

%get info from file path text
ratnums = cellfun(get_ratnum,split_paths);
groups = cellfun(get_group,split_paths);
phases = cellfun(get_phase,split_paths,'UniformOutput',false);
days = cellfun(get_day,split_paths);
epochs = cellfun(get_epoch,split_paths,'UniformOutput',false);

%init table
t = table('Size',[length(folder_paths),6],...
          'VariableTypes',["double","string","cell","double","string","cell"],...
          'VariableNames', ["rat_num","group","phase","day","epoch","path"]);

%fill table
t.rat_num = ratnums;
t.group = groups;
t.phase = phases;
t.day = days;
t.epoch = epochs;
t.path = folder_paths;

%save table
save("directory_table.mat","t")