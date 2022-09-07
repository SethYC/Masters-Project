%trims a matrix of event start and end times so that no event occurs past a
%certain duration from the start time.
%
%input: 
%   start_time - start time of the epoch in nsma, e.g. epochs.sleep1(1)
%   ts - matrix where 1st column is start times, 2nd column is end times,
%   in nsma units, of events (i.e. spindles or sharp wave ripples). e.g.
%   epochs.tssws1
%   dur - duration limit from start time (in minutes). e.g. 45 to remove
%   any events past 45 minutes.
%
%output:
%   ts - same format as input ts
function ts = trim_to_duration(start_time,ts,dur)
    nsma_dur = dur*60*1e4; %convert min to nsma units
    end_time = start_time + nsma_dur;

    ts(ts>end_time) = NaN; %any timestamps past the end_time set to NaN
    ts(all(isnan(ts),2),:) = []; %any row with all NaN's is removed (inspired by https://www.mathworks.com/matlabcentral/answers/68510-remove-rows-or-cols-whose-elements-are-all-nan)
    
    %handle case when ts is empty or just the end time of a sws period is past the
    %end time by setting it to the end time
    if isempty(ts) %if nothing left, return an empty ts
        ts = [];
    elseif isnan(ts(end,2))
        ts(end,2) = end_time;
    end
end