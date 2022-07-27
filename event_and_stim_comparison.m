% find average delay between cheetah stim event timestamp and actual
% depolarization event (measurets_spind from lowest voltage point during a
% stimulation event). 
%
% This is just a quick script to test one recording file to help
% understanding the typical delay between the above two events to inform my
% later spindle detection scripts.
% 
% Seth Campbell, June 14, 2022

%load cortex recording, pwd needs to have the data 
load('epochs.mat')
eeg_tsd = csc2tsd_badclock('ctx2.ncs',epochs.sleep2); %can also just use csc2tsd()
eeg = Data(eeg_tsd);
ts = Range(eeg_tsd);

%load events file
[event_ts,s,~] = events_read('Events.nev');

%find pulse event timestamps
pos = matches(s,'pulse');
stim_ts = event_ts(pos);
stim_ts = stim_ts/100; %convert from Cheetah to NSMA units

%limit timestamps to epochs.sleep2 (i.e. post task sleep) for testing
stim_ts(stim_ts<epochs.sleep2(1)) = [];

%init array for storing differences between stim events and pulses for all
%stim events
diffs = zeros(1,numel(stim_ts));

%for each pulse timestamp, find the lowest subsquent voltage value within 20ms
for i = 1:numel(stim_ts)
    %get start and end timestamps of the 20ms window for the current stim pulse
    ts_start = find(ts >= stim_ts(i),1,'first'); %find the first timestamp in the eeg 
    ts_end = ts_start + 40; %note: we are using this to index by position, so 40 positions units = 20ms based on 2000hz sampling freq.

    %find position of minimum voltage point within the 200ms window
    [valley_min,valley_pos] = min(eeg(ts_start:ts_end));
    valley_pos = valley_pos + ts_start; %convert to true position and not just the relative position within ts_start:ts_end

    %compare valley pos and stim pulse timestamp
    diffs(i) = ts(valley_pos) - stim_ts(i); 
end

%%
% optional: summary stats and visualize results
diffs_ms = diffs/10; %convert to ms (1 NSMA unit = 10ms)

fprintf("Mean: %.3f ms\n", mean(diffs_ms))
fprintf("Median: %.3f ms\n", median(diffs_ms))
figure;
h = histogram(diffs_ms);
xlabel('delay (ms)')
ylabel('counts')