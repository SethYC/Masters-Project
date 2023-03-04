%Calculates cross correlation results between spindles and SWRs for each 
%pre and post-task epoch from all recording data stored in directory_table.mat
%Output is cross_corr_table.mat, containing the table of results and the
%lag vector from xcorr(). Calculates both default cross correlation and
%normalized version. 
% 
%Note: modify window size of cross correlation with xcorr_window. 
%
%Seth Campbell, Mar. 3, 2023

%init window size for cross correlation, noting that eeg was sampled at
%8kHz, e.g. 40,000 unit window = 5sec to the left and right of lag 0 = total
%10sec window
XCORR_WINDOW = 40000; 

%load table var 't' (with all epochs of all recordings as rows)
load('Y:\Seth_temp\Thesis recordings\directory_table.mat') %created by create_recording_directories_table()

%remove any file (row) from baseline phase or task epoch
t(t.phase == 'Baseline',:) = []; %delete rows based on index of rows with baseline
t(t.epoch == 'task',:) = [];

%init two new table columns for results 
cross_corr = cell(length(t.rat_num),1); %non-normalized xcorr results
cross_corr_norm = cell(length(t.rat_num),1); %normalized xcorr results
t = addvars(t,cross_corr, cross_corr_norm,'After','path');

%loop through every pre-task and post-task epoch
for i = 1:length(t.rat_num) 
    epochs_path = remove_last_2_folders(t.path{i});
    load([epochs_path, '\epochs.mat']) %import struct 'epochs'

    if t.epoch(i) == 'pre-task_sleep'
        %load raw eeg file (which is arbitrary as all are the same length)
        eeg_tsd = csc2tsd_badclock([t.path{i}, '\ctx1.ncs'],epochs.sleep1); 

        %get pre-task rest epoch start times of spindles and swr's
        spin_ts = epochs.tsspin1(:,1);
        swr_ts = epochs.tsswr1(:,1);
    else %post-task_sleep
        eeg_tsd = csc2tsd_badclock([t.path{i}, '\ctx1.ncs'],epochs.sleep2);

        spin_ts = epochs.tsspin2(:,1);
        swr_ts = epochs.tsswr2(:,1);
    end

    %get eeg timestamps
    eeg_ts = Range(eeg_tsd);
    
    %find index of eeg_ts that matches spindle and SWR timestamps
    [is_spin_found,spin_idx] = ismember(spin_ts,eeg_ts);
    [is_swr_found,swr_idx] = ismember(swr_ts,eeg_ts);

    %need to find nearest recording timestamp to SWR and spindle events not exactly
    %aligned to eeg_ts. This is not often an issue for spindles due to the nature
    %of the functions for finding the spindle timestamps. The SWR finding
    %function changed units during  calculation, likely leading to this
    %issue of often not matching. 
    swr_idx = get_missing_event_indexes(is_swr_found,swr_idx,swr_ts,eeg_ts);    
    spin_idx = get_missing_event_indexes(is_spin_found,spin_idx,spin_ts,eeg_ts);    

    %init 2nd and 3rd column with zeroes, such that 2nd col = spindles, 3rd col = SWRs 
    eeg_ts(:,[2,3]) = 0;  

    %convert spindle and SWR indexes to binary occurence vector (1 =
    %occured, 0 = did not occur)
    eeg_ts(spin_idx,2) = 1;
    eeg_ts(swr_idx,3) = 1;

    %cross correlation
    [r,~] = xcorr(eeg_ts(:,2),eeg_ts(:,3),XCORR_WINDOW); 
    [r2,lags] = xcorr(eeg_ts(:,2),eeg_ts(:,3),XCORR_WINDOW,'coeff'); %normalized cross correlation
    
    %write to table
    t.cross_corr{i} = r; 
    t.cross_corr_norm{i} = r2;

    fprintf("progress: %i/%i\n", i, length(t.rat_num))
end

%save resulting table and xcorr lags vector
save('Y:\Seth_temp\Thesis recordings\cross_corr_table.mat','t','lags')


%%
%find and fill missing SWR or spindle index values in event_idx. Input parameters are
%the same as their analogous counterparts in the main script body. Perhaps 
%not necessary as a function but oh well. 
function event_idx = get_missing_event_indexes(is_event_found,event_idx,event_ts,eeg_ts)

    event_ts(is_event_found) = []; %keep only missing SWR or spindle timestamps
    missing_indexes = find(~is_event_found==1); %indexes of missing SWRs or spindles within event_idx

    for i = 1:numel(event_ts) %for each missing SWR or spindle timestamp 
        current_event_ts = event_ts(i);     
        nearest_idx = find(current_event_ts < eeg_ts, 1, 'first'); %get closest timestamp, thus maximum error of 1/8000s 
        event_idx(missing_indexes(i)) = nearest_idx; %replace missing value in event_idx with found approximation
    end

end


