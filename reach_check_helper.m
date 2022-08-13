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

%get cheetah folder name (which changes based on when recording was made)
cheetah_folder = dir("task\20*"); %always starts with the year, so 20* will suffice
if size(cheetah_folder,1) > 1
    error("More than one potential cheetah recording folder was found in the task folder!")
end

%load event data
[ts,s,~] = events_read(['task\', cheetah_folder.name, '\events.nev']);

%get door open timestamps


%find 1st beam break timestamps after door open events


%ask user for 1st door open video timestamp


%calc video timestamps


%display to user

