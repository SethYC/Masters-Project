%Simply transfers all desired reaching videos from my NAS storage to a
%local drive under one folder to make some manual inspecting easier. 

root_dir = 'Y:\Seth_temp\Thesis recordings';
video_dir = dir([root_dir, '\*\*\*cam2.avi']); %only cam2 files for the reaching view

for i = 1:length(video_dir) %for all videos
    video_path = [video_dir(i).folder, '\', video_dir(i).name];
    copyfile (video_path, 'E:\Seth local\cohort 1 cam2 videos\')
    fprintf("progress: %i/%i\n", i , length(video_dir))
end
disp("~done copying files")
