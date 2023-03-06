

load('Y:\Seth_temp\Thesis recordings\cross_corr_table_overlap_removed.mat')
t(t.epoch == 'pre-task_sleep',:) = [];
t(t.group == 'C',:) = []; %remove controls beause they had no DBS stim
t_temp = t;

%%
% mean_hpc_snippets = zeros(length(t.rat_num),100001);

for i = 58:length(t.rat_num) 

    epochs_path = remove_last_2_folders(t.path{i});
    load([epochs_path, '\epochs.mat']) %import struct 'epochs'

    %load events file
    [event_ts,s,~] = events_read([t.path{i},'\Events.nev']);
    
    %find pulse event timestamps
    pos = matches(s,'pulse');
    stim_ts = event_ts(pos);
    stim_ts = stim_ts/100; %convert from Cheetah to NSMA units

    %load hpc channel and filter for SWRs
    hpc_ch = get_hpc_ch(t.group(i),t.rat_num(i));
    eeg_tsd = csc2tsd_badclock([t.path{i}, '\', hpc_ch],epochs.sleep2);
    eeg_tsd = downsamp(eeg_tsd,2000); %downsample to 2kHz
    ts_range = Range(eeg_tsd);
    data = Data(eeg_tsd);
    data = bandstop(data,[178 182],2000); %remove harmonic of 60Hz noise at 180Hz
    data = bandpass(data, [100 300],2000);

    %init empty array to store 10sec window snippets of filtered hpc 
    %recordings centered around stim events
    hpc_snippets = zeros(length(stim_ts),100001);
    for j = 1:length(stim_ts)
        stim_idx = find(ts_range > stim_ts(j),1,'first'); %find essentially nearest timestamp in hpc trace to stim event
        start_idx = stim_idx - 50000; %50,000 NSMA units = 5 sec
        end_idx = stim_idx + 50000;

        %extract 10sec window from filtered hpc recording centered around stim event    
        hpc_snippets(j,:) = data(start_idx:end_idx);
    end

    mean_hpc_snippets(i,:) = mean(hpc_snippets);
    fprintf('%d/60\n', i)
end

grand_mean = mean(mean_hpc_snippets);

%%
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