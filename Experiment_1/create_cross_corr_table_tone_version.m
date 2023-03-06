%just like create_cross_corr_table.m, but computes cross correlation of SWRs
%and spindles with tones. See original script for more detailed comments. 
% 
%Note: modify window size of cross correlation with xcorr_window. 
%
%Seth Campbell, Mar. 3, 2023

XCORR_WINDOW = 40000; 

load('Y:\Seth_temp\Thesis recordings\directory_table.mat') %created by create_recording_directories_table()

%keep only post-task epoch recordings
t(t.phase == 'Baseline',:) = []; 
t(t.epoch == 'task',:) = [];
t(t.epoch == 'pre-task_sleep',:) = [];

swr_cross_corr = cell(length(t.rat_num),1); %non-normalized xcorr results
swr_cross_corr_norm = cell(length(t.rat_num),1); %normalized xcorr results
spin_cross_corr = cell(length(t.rat_num),1); %non-normalized xcorr results
spin_cross_corr_norm = cell(length(t.rat_num),1); %normalized xcorr results
shuffle_cross_corr = cell(length(t.rat_num),1);
shuffle_cross_corr_norm = cell(length(t.rat_num),1);    
t = addvars(t,swr_cross_corr, swr_cross_corr_norm, spin_cross_corr, spin_cross_corr_norm, shuffle_cross_corr, shuffle_cross_corr_norm, 'After','path');

for i = 1:length(t.rat_num) 
    epochs_path = remove_last_2_folders(t.path{i});
    load([epochs_path, '\epochs.mat']) %import struct 'epochs'

    %post-task_sleep
    eeg_tsd = csc2tsd_badclock([t.path{i}, '\ctx1.ncs'],epochs.sleep2);

    spin_ts = epochs.tsspin2(:,1);
    swr_ts = epochs.tsswr2(:,1);
    tone_ts = epochs.tone2(:,1);

    %get eeg timestamps
    eeg_ts = Range(eeg_tsd);
    
    %find index of eeg_ts that matches spindle and SWR timestamps
    [is_spin_found,spin_idx] = ismember(spin_ts,eeg_ts);
    [is_swr_found,swr_idx] = ismember(swr_ts,eeg_ts);
    [is_tone_found,tone_idx] = ismember(tone_ts,eeg_ts);

    %need to find nearest recording timestamp to SWR and spindle events not exactly
    %aligned to eeg_ts. This is not often an issue for spindles due to the nature
    %of the functions for finding the spindle timestamps. The SWR finding
    %function changed units during  calculation, likely leading to this
    %issue of often not matching. 
    swr_idx = get_missing_event_indexes(is_swr_found,swr_idx,swr_ts,eeg_ts);    
    spin_idx = get_missing_event_indexes(is_spin_found,spin_idx,spin_ts,eeg_ts);  
    tone_idx = get_missing_event_indexes(is_tone_found,tone_idx,tone_ts,eeg_ts);    


    %init new columns with zeroes, such that:
    %   2nd col = spindles
    %   3rd col = SWRs 
    %   4th col = tones
    %   5th col = shuffled spindles %not incorporated yet
    eeg_ts(:,2:5) = 0;  

    %convert spindle and SWR indexes to binary occurence vector (1 =
    %occured, 0 = did not occur)
    eeg_ts(spin_idx,2) = 1;
    eeg_ts(swr_idx,3) = 1;
    eeg_ts(tone_idx,4) = 1;

    %cross correlation
    [r1,~] = xcorr(eeg_ts(:,3),eeg_ts(:,4),XCORR_WINDOW); 
    [r2,~] = xcorr(eeg_ts(:,3),eeg_ts(:,4),XCORR_WINDOW,'coeff'); %normalized cross correlation
    [r3,~] = xcorr(eeg_ts(:,2),eeg_ts(:,4),XCORR_WINDOW); 
    [r4,lags] = xcorr(eeg_ts(:,2),eeg_ts(:,4),XCORR_WINDOW,'coeff');

    %write to table
    t.swr_cross_corr{i} = r1; 
    t.swr_cross_corr_norm{i} = r2;
    t.spin_cross_corr{i} = r3; 
    t.spin_cross_corr_norm{i} = r4;

    fprintf("progress: %i/%i\n", i, length(t.rat_num))
end

%save resulting table and xcorr lags vector
% save('Y:\Seth_temp\Thesis recordings\cross_corr_table_tones_ver.mat','t','lags')

%%
function event_idx = get_missing_event_indexes(is_event_found,event_idx,event_ts,eeg_ts)

    event_ts(is_event_found) = []; %keep only missing SWR or spindle timestamps
    missing_indexes = find(~is_event_found==1); %indexes of missing SWRs or spindles within event_idx

    for i = 1:numel(event_ts) %for each missing SWR or spindle timestamp 
        current_event_ts = event_ts(i);     
        nearest_idx = find(current_event_ts < eeg_ts, 1, 'first'); %get closest timestamp, thus maximum error of 1/8000s 
        event_idx(missing_indexes(i)) = nearest_idx; %replace missing value in event_idx with found approximation
    end

end


