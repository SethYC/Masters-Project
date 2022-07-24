%%just changes directory to the found cheetah folder in the current
%%directoy, and includes an error check if provided name of current recording
%%folder such as "2022-07-13-Training_day02"
function cd_to_cheetah_folder(day_folder)
    
%     if ~exist(day_folder 

    %based on Cheetah Neuralynx file naming conventions, the folder of recording 
    %data for a given session starts with the year first, thus "20..." 
    cheetah_folder = dir("20*");    
   
    %handle not having one folder as errors
    if isempty(cheetah_folder) %make sure it's not missing
        error("No Cheetah recording folder found in current epoch's directory!")
    elseif length(cheetah_folder) > 1 %should only be one folder
        error("More than one Cheetah recording folder is in current epoch's directory!")
    end

    b = cheetah_folder.name(1:10); %get date in yyyy-mm-dd format
   
    %optional check to see cheetah recording folder's date matches day
    %folder's date (if not, means wrong cheetah folder was uploaded to the NAS)     
    if exist('day_folder','var') %day_folder is optional to have
        a = convertStringsToChars(day_folder);
        a = a(1:10); %get date in yyyy-mm-dd format
        if a ~= b %unlikely to be true, but good to check still (can only happen if i accidently moved a another days recording to the wrong location)
            error("Recording day and Cheetah recording folder dates don't match!!")
        end
    end

    cd(cheetah_folder.name) %go into cheetah folder
end