%Goes through directory table and finds either spindles or Sharp Wave Rippless in pre-task and post-task
%epochs and saves the timestamps to epochs.mat

%load table var 't' (with all epochs of all recordings as rows)
load('Y:\Seth_temp\Thesis recordings\directory_table.mat') %created by create_recording_directories_table()

%remove any file (row) from baseline phase or task epoch
% t.phase = categorical(t.phase); %convert to categorical for next step
t(t.phase == 'Baseline',:) = []; %delete rows based on index of rows with baseline
t(t.epoch == 'task',:) = [];

% fprintf("find and save spindles or SWRs? 1 = spindles, 2 = SWRs: ")
response = input("find and save spindles or SWRs? 1 = spindles, 2 = SWRs: ","s"); 
if ~ismember(response,'12')
    error("Inappropriate input, try again.")
end

for i = 1:length(t.rat_num) %for each epoch file in all rats & days    
    %load epochs.mat from two folders up
    epochs_path = remove_last_2_folders(t.path{i});
    load([epochs_path, '\epochs.mat']) %import struct 'epochs'

    %find spindles (or later SWR's)
%     recording_path = t.path{i};

    if response == 1 %spindles
        ts = get_spindles(t.path{i},t.epoch(i),epochs,'ctx1.ncs');

        %save timestamps to epochs.mat
        if t.epoch(i) == 'pre-task_sleep'
            epochs.tsspin1 = ts;
        else %post-task_sleep
            epochs.tsspin2 = ts;
        end
    else %response == 2 %SWRs
%         continue %placeholder
        hpc_ch = get_hpc_ch(t.group(i),t.rat_num(i));
        ts = get_swrs(t.path{i},t.epoch(i),epochs,hpc_ch);

        %save timestamps to epochs.mat
        if t.epoch(i) == 'pre-task_sleep'
            epochs.tsswr1 = ts;
        else %post-task_sleep
            epochs.tsswr2 = ts;
        end
    end

    %save epochs.mat
    save([epochs_path,'\epochs.mat'],'epochs')
    
    fprintf("progress: %i/%i\n", i , length(t.rat_num))
end

%%
%%functions

%finds spindles in the specified path and cortex channel. 
function ts = get_spindles(path,epoch_name,epochs,ctx_ch)
    
    if epoch_name == 'pre-task_sleep'
        eeg_tsd = csc2tsd_badclock([path, '\', ctx_ch],epochs.sleep1);
    else % 'post-task_sleep'
        eeg_tsd = csc2tsd_badclock([path, '\', ctx_ch],epochs.sleep2);
    end

    %find spindles with Mike's function
    ts = find_lvs(eeg_tsd,1.5);
    
    %try to remove artifacts from stim in post-task sleep
    if epoch_name == 'post-task_sleep' %note: technically should check if experiment too because its redundant to run on controls with no stim anyways
        peak_ts = find_stim_peaks(epochs, path);
        ts = remove_overlap(ts,peak_ts,160); %note: think this is working yet because it is being undone by tsgaps in its current form/settings
    end
    
    %remove spindles outside of motionlessness
    if epoch_name == 'post-task_sleep'
        ts = rm_ts_overlap(ts,epochs.tswake2);
    else %pre-task_sleep
        ts = rm_ts_overlap(ts,epochs.tswake1);
    end

    %remove spindles or gaps between spindles that are too small
    ts = tsgaps(ts,.075,.200);

    %quick removal of any spindles longer than 2 sec (should verify this
    %threshold later)
    diffs = ts(:,2)-ts(:,1); %difference between end and start times
    ts(diffs>2e4,:) = []; %1e4 nsma units = 1 sec

end

function ts = get_swrs(path,epoch_name,epochs,hpc_ch)

    if epoch_name == 'pre-task_sleep'
        eeg_tsd = csc2tsd_badclock([path, '\', hpc_ch],epochs.sleep1);
    else % 'post-task_sleep'
        eeg_tsd = csc2tsd_badclock([path, '\', hpc_ch],epochs.sleep2);
    end

    %preprocessing
    eeg_tsd = downsamp(eeg_tsd,2000); %downsample to 2kHz
    ts_range = Range(eeg_tsd,'sec'); %get timestamps, but in seconds
    data = Data(eeg_tsd);

    %bandstop filter between 178-182Hz to remove 180Hz (based on 60Hz harmonic)
    %noise in SWR freq. range (1-3kHz). Power spectral density plots in
    %testing did not show any other noticable spikes in noise due to 60Hz
    %harmonics. 
    data = bandstop(data,[178 182],2000); 

    %find SWRs with Mike and Karim's function
    if epoch_name == 'pre-task_sleep'
        [ts, ~] = ripple_detect(ts_range, data, (epochs.tssleep1 ./ 1e4), 7, 1);
    else
        [ts, ~] = ripple_detect(ts_range, data, (epochs.tssleep2 ./ 1e4), 7, 1);
    end
    
%     %remove swrs outside of motionlessness
%     if epoch_name == 'post-task_sleep'
%         ts = rm_ts_overlap(ts,epochs.tswake2);
%     else %pre-task_sleep
%         ts = rm_ts_overlap(ts,epochs.tswake1);
%     end

    %remove SWRs longer than 100ms
    swr_durations = ts(:,2)-ts(:,1);
    ts(swr_durations>0.1,:) = [];

    %convert sec to nsma 
    ts = ts*1e4;

end

function hpc_ch = get_hpc_ch(group,rat_num)

    if group == 'C'
        if rat_num == 1
            hpc_ch = 'hpc4.ncs';
        else % rat_num == 2
            hpc_ch = 'hpc1.ncs';
        end
    else %group == 'E'
        if rat_num == 1
            hpc_ch = 'hpc4.ncs';
        elseif rat_num == 2
            hpc_ch = 'hpc2.ncs';   
        elseif rat_num == 3
            hpc_ch = 'hpc2.ncs';
        else %rat_num == 4
            hpc_ch = 'hpc1.ncs';
        end
    end

end