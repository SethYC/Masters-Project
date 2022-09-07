%Semi-atuomate the daily process of generating sleep struct charts from
%cheetah recordings in my thesis experiment. 
% 
%Note that a specific file structure and naming scheme is required for all of 
%this to work. This largely relies on the bash script from the video camera 
%computer that records and saves videos in addition to creating the file structure 
%for the Cheetah recording data. Terminology-wise, here is an example folder
%structure from the top to a specific recording channel:
%   Z:\Seth\Thesis recordings\rat1_6380\2021-12-01-Training_day01\2021-12-01_12-41-21\hpc1.ncs
%   where:  rat_folder = rat1_6380 
%           day_folder = 2021-12-01-Training_day01
%           cheetah_folder = 2021-12-01_12-41-21 
%
% Seth Campbell
% Created: Dec. 6, 2021

%input: 
%   day_mode (optional) - a string, if "manual" then user can select recording
%   type and day to generate sleep structs for, else the current date is used
%   in respect to the cohort start date to compute what recording type and day
%   it is. 
function generate_sleep_structs(day_mode)

%hard code some basic info about the cohort
cohort_nums = {'1E' '2E' '3E' '4E' '1C' '2C'}; %rat numbers, should match number in rat_folders below
cohort_start = '13-July-2022'; %first day of experiment, starting with baseline day01
rat_folders = ["Y:\Seth_temp\Thesis recordings\rat1E_6939",...
               "Y:\Seth_temp\Thesis recordings\rat2E_6941",...
               "Y:\Seth_temp\Thesis recordings\rat3E_6940",...
               "Y:\Seth_temp\Thesis recordings\rat4E_6938",...
               "Y:\Seth_temp\Thesis recordings\rat1C_6387",...
               "Y:\Seth_temp\Thesis recordings\rat2C_6937"]; %just gonna hardcode these instead of all the commented out stuff below to automate this...


%display general info
fprintf("Rats in current cohort: %s\n", join(string(cohort_nums)))
fprintf("Cohort start: %s\n",cohort_start);

current_day = daysact(cohort_start,date); %get today's day number based on today's date minus cohort start date (note: requires financial toolbox)

%determine whether recording today was baseline, training or probe type
if current_day > 5
    if current_day < 19
        recording_type = 'T'; %training
        current_day = current_day-5; %training days start from 1, even if it is the 6th day of the experiment for example
        str_to_find = strcat('Training_day', sprintf('%02d', current_day)); %used to search day folder names, sprintf allows days under 10 to be padded with a leading zero (based on https://www.mathworks.com/matlabcentral/answers/359926-how-can-i-include-leading-zeros-in-a-number)
    else
        recording_type = 'P'; %probe
        current_day = 1; %there is only one probe trial, so day is always 1
        str_to_find = strcat('Probe_day', sprintf('%02d', current_day));
    end
else
    recording_type = 'B'; %baseline
    str_to_find = strcat('Baseline_day', sprintf('%02d', current_day));
end

%if this script/function was called with this set, then manually provide 
%the recording type and day to make sleep structs for, overriding the
%previous str_to_find var
while day_mode == "manual" 
    type = input("Select type: 1 = baseline, 2 = training, 3 = probe: ",'s');
    day = input("Enter day: ");
    if ismember(type,['123']) && day > 0
        switch type
            case '1'
                recording_type = 'B'; %baseline
                str_to_find = strcat('Baseline_day', sprintf('%02d', day));
            case '2'
                recording_type = 'T'; %training
                str_to_find = strcat('Training_day', sprintf('%02d', day));
            case '3'
                recording_type = 'P'; %probe
                str_to_find = strcat('Probe_day', sprintf('%02d', day));
        end
        break
    else
        warning("Invalid entry, try again")
    end  
end

fprintf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");

%for each rat in cohort, make a sleep struct
for i = 1:length(rat_folders)
    [~, n, ~] = fileparts(rat_folders(i)); %get just rat folder name from directory (e.g. "rat1_6380")
    fprintf("\nrat folder: %s\n",n); 
    
    %allow user to skip a rat, useful when going back after finding a
    %mistake in a later file for a given day
    x = input("Press 0 to skip rat, else press any key to continue: ");
    if x == 0
        disp("skipping rat...")
        continue
    end

    rat_num = cohort_nums{i}; %get rat number for input to sleep_struct() later
    cd(rat_folders(i)); %go to the rat folder announced above
    directories = dir('*_day*'); %find all folders/files that contain "_day" in it, i.e. recording folders
    directories_names = struct2table(directories); %convert to table
    directories_names = convertCharsToStrings(directories_names.name); %convert names column of table to string array
    
    %get recording day number from folder names (e.g. "day05" and not yyyy-mm-dd)
    expr = '((Baseline)|(Training)|(Probe))_day([0-9])[0-9]?'; %regular expression to find day numbers
    nums = regexp(directories_names,expr,'match'); 
    nums = string(nums); %convert from cell array to string array for easier searching
    
    %determine recording day: find the position of a 1 in nums, corresponding to where str_to_find was
    nums = strfind(nums,str_to_find);
    pos = [];
    for i = 1:length(nums)
        if nums{i} == [1] %day we want will show up as a nonempty entry with a [1] in it
            pos = i;
            break
        end    
    end
    
    %make sure recording day is found
    if isempty(pos)  
        error("Could not find '%s' in recording day folders", str_to_find)
    end
    
    day_folder = directories_names(pos);
    fprintf("Recording day: %s\n", day_folder)
    cd(day_folder) %go into epoch-day folder (e.g. "2021-12-01-Training_day01")
    day_path = pwd; %use this to return to right directory if an error occurs mid-run later

    %create sleep struct chart the usual method for each rat
    count = 0; %this and next two lines based on: https://www.mathworks.com/matlabcentral/answers/82806-repeat-try-catch-loop
    err_count = 0;
    while count == err_count %keep trying to make a sleep_struct till no errors occur (useful so you don't have to restart the script if a mistake or bug occurs)
        count = count + 1;
        try
            switch recording_type
                case 'B' %for baseline
                    %pipeline of scripts to create a sleep struct now that prep is done
                    
                    %find motionless for all two epochs (s1, s2)
                    epoch_names = ["pre-task_sleep", "post-task_sleep"];
                    for i = 1:2
                        cd(epoch_names(i))
                        cd_to_cheetah_folder(day_folder)
                        set_motion_thresh('yyy.ncs',i) %determine accelerometer threshold for motion vs motionlessness
                        cd ..\.. %go back to original recording day folder (two directies up) 
                    end
                    
                    epochs_from_motionless %break recording into motion & motionless epochs
                    tone2epochs_2_room_ver("post-task_sleep") %add in tone timestamps to epochs struct
                    
                    fprintf('Creating sleep1 (reaching cage) sleep struct\n')
                    fprintf('Creating sleep1 sleep struct\n')
                    cd 'pre-task_sleep'
                    cd_to_cheetah_folder()
                    epochs = sleep_struct(rat_num,1,1); %meat of the pipeline, finds REM and SWS during motionless periods
                    cd ..\..;
                    save('epochs.mat','epochs'); %save results so that next epoch can load it in sleep_struct() and add to it

                    fprintf('Creating sleep2 (sleeping cage) sleep struct\n')
                    cd 'post-task_sleep'
                    cd_to_cheetah_folder()
                    epochs = sleep_struct(rat_num,2,1); 
                    cd ..\..;
                    save('epochs.mat','epochs');
                    

                    commandwindow %place cursor back to command window so you don't have to click it
                    input("Press any key to continue") %moves on when user presses a key (giving them time to see results before moving on)
                case {'T','P'} %for both training and probe
                    %find motionless for all three epochs (s1, t, s2)
                    epoch_names = ["pre-task_sleep", "task", "post-task_sleep"];
                    sess_nums = [1, 1.5, 2]; %this is needed because set_motion_thresh() requires a input of 1.5 after the .ncs file to specify a task epoch
                    for i = 1:3
                        cd(epoch_names(i))
                        cd_to_cheetah_folder(day_folder)
                        set_motion_thresh('yyy.ncs',sess_nums(i)) 
                        cd ..\.. %go back to original recording day folder (two directies up)
                    end
                    
                    epochs_from_motionless
                    tone2epochs_2_room_ver("pre-task_sleep")
                    tone2epochs_2_room_ver("post-task_sleep")

                    fprintf('Creating sleep1 sleep struct\n')
                    cd 'pre-task_sleep'
                    cd_to_cheetah_folder()
                    epochs = sleep_struct(rat_num,1,1);
                    cd ..\..;
                    save('epochs.mat','epochs')

                    fprintf('Creating task sleep struct\n')
                    cd 'task'
                    cd_to_cheetah_folder()
                    try 
                        epochs = sleep_struct(rat_num,1.5,1);
                    catch error  %in case where task had no motionless periods, can't look for sleep stages, sp just mov on
                        %disp( getReport( error, 'extended', 'hyperlinks', 'on' ) ) %based on https://www.mathworks.com/matlabcentral/answers/225796-rethrow-a-whole-error-as-warning
                        warning("task not examined for sleep stages")
                    end
                    save('epochs.mat','epochs')

                    fprintf('Creating sleep2 sleep struct\n')
                    cd ..\..; cd 'post-task_sleep'
                    cd_to_cheetah_folder()
                    epochs = sleep_struct(rat_num,2,1);
                    cd ..\..;
                    save('epochs.mat','epochs');             

                    commandwindow %place cursor back to command window so you don't have to click it
                    input("Press any key to continue") %moves on when user presses a key (giving them time to see results before moving on) 
            end %switch end
        catch me
            err_count = err_count + 1;
            disp( getReport( me, 'extended', 'hyperlinks', 'on' ) ) %based on https://www.mathworks.com/matlabcentral/answers/225796-rethrow-a-whole-error-as-warning
            warning("An error occured during sleep struct creation, press any key to try again...")
            cd(day_path)
            input("")
        end %try end
    end %while end
    close all %close figures, so you start fresh for the next rat
end %rat_folders for-loop end

fprintf("\n~~終わり/finished~~\n") %finished 
end 
