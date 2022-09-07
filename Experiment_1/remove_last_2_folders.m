%Removes the last two folders in a given file path. Used on full Cheetah
%file paths to move up 2 folders where epochs.mat is stored.
function out = remove_last_2_folders(in) 
    intermediate = split(in, '\'); %seperate file path into individual file names as a cell array
    intermediate(end-1:end) = []; %delete last two files 
    out = cell2mat(join(intermediate,'\')); %rejoin parts 
end