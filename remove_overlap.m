%from found spindle timestamps, remove any region that overlaps with a stim
%timestamp with a given width. 

function ts = remove_overlap(spindle_ts,stim_ts,width)

search_pos = 1; %init 

for i = 1:length(stim_ts) %per stim timestamp
    curr_stim = stim_ts(i);
    
    while curr_stim < spindle_ts(search_pos,1) || curr_stim > spindle_ts(search_pos,2)
        search_pos = search_pos + 1;
    end    

    %determine how to remove overlap into one of 4 cases
    left_pos = curr_stim - width;
    right_pos = curr_stim + width;

    if left_pos <= spindle_ts(search_pos,1)
        if right_pos >= spindle_ts(search_pos,2)
            %case 1 - removal region is within a spindle event from both sides
        else
            %case 2 - removal region overlaps on the left side only
        end
    elseif right_pos >= spindle_ts(search_pos,2)
        %case 3 - removal region overlaps on the right side only
    else 
        %case 4 - removal region overlaps both sides
    end
end

end