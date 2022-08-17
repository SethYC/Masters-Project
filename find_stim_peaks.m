%fings timestamp of stim events in a given stimulation channel and returns
%it. Must be in directorty with the recording data.
%
%Input: epochs - epochs struct for the current day and rat 
%       path - file path to where stim.ncs & events.nev are stored (should
%       be the same)
%
%output: timestamps of stim peaks (in NSMA units)
%
%note: stim.ncs is the stimulation pulse channel. This is not to be
%confused with the cortex channel that RECEIVES stimulation, this is the
%channel that records when stimulation is delivered, showing the same biphasic
%pulse that is delivered to the rat's motor cortex.

function peak_ts = find_stim_peaks(epochs, path)

sample_rate = 8000; %data was collected at 8khz
window_ms = 40; %window in ms to search for a stim peak after each pulse event

%load stim channel
eeg_tsd = csc2tsd_badclock([path,'\stim.ncs'],epochs.sleep2); %sleep2 is the only epoch with stimulation
eeg = Data(eeg_tsd);
ts = Range(eeg_tsd);

%load events file
[event_ts,s,~] = events_read([path,'\Events.nev']);

%find pulse event timestamps
pos = matches(s,'pulse');
stim_ts = event_ts(pos);
stim_ts = stim_ts/100; %convert from Cheetah to NSMA units

%init loop var
peak_pos = zeros(numel(stim_ts),1); 
relative_pos = zeros(numel(stim_ts),1);

%for every pulse event, find its corresponding max voltage point in the stim channel 
for i = 1:numel(stim_ts)
    %get start and end timestamps of the searching area (window_ms) for the current stim pulse
    start_pos = find(ts >= stim_ts(i),1,'first'); %find the first timestamp in the eeg 
    window_units = window_ms/(1/sample_rate*1000); %calc number of time stamp units corresponds to window_ms based on sampling freq. 
    ts_end = start_pos + window_units; %note: we are using this to index by position, not time
    
    %find position of max voltage within the window
    [peak_height,relative_pos(i)] = max(eeg(start_pos:ts_end));
    
    if peak_height > 4 %any real peak will be above 4 units in height
        peak_pos(i) = relative_pos(i) + start_pos; %convert to true position and not just the relative position to start_pos
    else
        warning("A normal stim peak could not be found within search window. Estimating location instead.")
        peak_pos(i) = start_pos + floor(mean(relative_pos)); %if i can't find a normal peak, estimate where the stim event should be based on the average of past results (and floor it so its an integer)
    end
end

peak_ts = ts(peak_pos); %convert from position to timestamps 

end