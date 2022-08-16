%create slow wave sleep duration comparison charts for cohort 1.

%%
%%create table of epoch files and their information

%load table var 't'
load('Y:\Seth_temp\Thesis recordings\directory_table.mat') %created by create_recording_directores()

%remove any file (row) from baseline phase
t.phase = categorical(t.phase); %convert to categorical for next step
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

%note: make the above code its own script later for better modularization

%%
%%collect data


%init empty duration arrays for columns
R1_SWS_total = duration(nan(length(epochs_t.rat_num),3)); %(based on https://www.mathworks.com/matlabcentral/answers/368435-create-an-array-of-empty-durations)
% R1_SWS_total.Format = "s"; %to specify as just seconds instead of default hh:mm:ss
R2_SWS_total = R1_SWS_total;
R1_SWS_pre45 = R1_SWS_total; %SWS duration before 45 min
R2_SWS_pre75 = R1_SWS_total; %SWS duration before 75 min

%add pre-task sleep and post-task SWS SWS duration columns
epochs_t = addvars(epochs_t,R1_SWS_pre45,R1_SWS_total,R2_SWS_pre75,R2_SWS_total,'After','file_path');

%fill duration values
for i = 1:length(epochs_t.rat_num) %for each epochs.mat file
    epoch_path = epochs_t.file_path{i};
    load([epoch_path, '\epochs.mat']) %import struct 'epochs'

    %note: for readability, i should split this into multiple lines later(?)
    epochs_t.R1_SWS_total(i) = seconds(sum(diff(epochs.tssws1'))/1e4);
    epochs_t.R2_SWS_total(i) = seconds(sum(diff(epochs.tssws2'))/1e4);

    %note: rename these vars or just make the conversion to seconds a function
    R1_ts_new = trim_to_duration(epochs.sleep1(1),epochs.tssws1,45);
    R2_ts_new = trim_to_duration(epochs.sleep2(1),epochs.tssws2,75);

    epochs_t.R1_SWS_pre45(i) = seconds(sum(diff(R1_ts_new'))/1e4);
    epochs_t.R2_SWS_pre75(i) = seconds(sum(diff(R2_ts_new'))/1e4);

end

%%
%%create chart



%%
%%functions

%Removes the last two folders in a given file path
function out = remove_last_2_folders(in) 
    intermediate = split(in, '\'); %seperate file path into individual file names as a cell array
    intermediate(end-1:end) = []; %delete last two files 
    out = cell2mat(join(intermediate,'\')); %rejoin parts 
end

%trims a matrix of event start and end times so that no event occurs past a
%certain duration from the start time.
%
%input: 
%   start_time - start time of the epoch in nsma, e.g. epochs.sleep1(1)
%   ts - matrix where 1st column is start times, 2nd column is end times,
%   in nsma units, of events (i.e. spindles or sharp wave ripples). e.g.
%   epochs.tssws1
%   dur - duration limit from start time (in minutes). e.g. 45 to remove
%   any events past 45 minutes.
%
%output:
%   ts - same format as input ts
function ts = trim_to_duration(start_time,ts,dur)
    nsma_dur = dur*60*1e4; %convert min to nsma units
    end_time = start_time + nsma_dur;

    ts(ts>end_time) = NaN; %any timestamps past the end_time set to NaN
    ts(all(isnan(ts),2),:) = []; %any row with all NaN's is removed (inspired by https://www.mathworks.com/matlabcentral/answers/68510-remove-rows-or-cols-whose-elements-are-all-nan)
    
    %handle case when ts is empty or just the end time of a sws period is past the
    %end time by setting it to the end time
    if isempty(ts) %if nothing left, return an empty ts
        ts = [];
    elseif isnan(ts(end,2))
        ts(end,2) = end_time;
    end
end