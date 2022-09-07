%Goes through directory table and finds spindles in pre-task and post-task
%epochs and saves the timestamps to epochs.mat

%load table var 't'
load('Y:\Seth_temp\Thesis recordings\directory_table.mat') %created by create_recording_directories_table()

%remove any file (row) from baseline phase or task epoch
% t.phase = categorical(t.phase); %convert to categorical for next step
t(t.phase == 'Baseline',:) = []; %delete rows based on index of rows with baseline
t(t.epoch == 'task',:) = [];

for i = 1:length(t.rat_num) %for each epoch file in all rats & days    
    %load epochs.mat from two folders up
    epochs_path = remove_last_2_folders(t.path{i});
    load([epochs_path, '\epochs.mat']) %import struct 'epochs'

    %find spindles (or later SWR's)
%     recording_path = t.path{i};

    ts = get_spindles(t.path{i},t.epoch(i),epochs,'ctx1.ncs');

    %save timestamps to epochs.mat
    if t.epoch(i) == 'pre-task_sleep'
        epochs.tsspin1 = ts;
    else %post-task_sleep
        epochs.tsspin2 = ts;
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