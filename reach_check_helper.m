%Help with the manual checking of a single reach video by asking the user
%for the video timestamp of the first reach, then showing the
%video timestamps for all door open events and the first beam break that
%occurs after the door opens. This information lets the user quickly watch
%just the reaches of a video.
%
%Note: requires you to be in the directory where the videos are (although
%it does not use the videos)
% 
% Seth Campbell - Aug. 13, 2022

% %init constants
% F_RATE = 100.020008; %frames per second for current video camera setup

%get cheetah folder name (which changes based on when recording was made)
cheetah_folder = dir("task\20*"); %always starts with the year, so 20* will suffice
if size(cheetah_folder,1) > 1
    error("More than one potential cheetah recording folder was found in the task folder!")
end

%load event data
[ts,s,~] = events_read(['task\', cheetah_folder.name, '\events.nev']); 

%get door open timestamps
open_ix = find(contains(s,"0x0001")); %index of door opens
open_ts = ts(open_ix); %timestamp of door opens

%find 1st beam break timestamp after each door open event
reach_ix = find(contains(s,"0x0008"));
reach_ts = ts(reach_ix);

first_reach_ts = zeros(1,length(open_ts));
for i = 1:length(open_ts)
    
    if i == length(open_ts) %final comparison, so there isn't a subsequent door open event to be before
        x = find(reach_ix > open_ix(i));
    else %find reach events that happen after the current open event, but before the next one
        x = find(reach_ix > open_ix(i) & reach_ix < open_ix(i+1));
    end
        
    if isempty(x) %if no reach events occured, then leave it as zero
        continue
    else
        first_reach_ts(i) = reach_ts(x(1)); %only want first reach event (if multiple)
    end
end

%ask user for 1st door open video timestamp
user_ts = input("Enter timestamp of 1st door open (sec): ");

%calc video timestamps
%note: formula to convert to video timestamp: (cheetah time - first door open)/10e5 + 1st door open time in sec.
video_door_ts = (open_ts-open_ts(1))/10e5 + user_ts;
video_reach_ts = (first_reach_ts-open_ts(1))/10e5 + user_ts;

%create first column of results table
num = 1:length(video_door_ts);

%convert times to min:sec format
video_door_ts = seconds(video_door_ts);
video_door_ts.Format = "mm:ss";
video_reach_ts = seconds(video_reach_ts);
video_reach_ts.Format = "mm:ss";

%combine results
a = array2table(num');
a.Properties.VariableNames = "#";
b = array2table([video_door_ts;video_reach_ts]');
b.Properties.VariableNames = {'door open' 'beam break'};
results_table = [a b];

% results_matrix = [num; video_door_ts; video_reach_ts]'; %this accidently converts nums to a duration type array as well
% results_table = array2table(results_matrix);
% results_table.Properties.VariableNames = {'#' 'door open' 'beam break'};

%display to user
disp(results_table)
