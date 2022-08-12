%from found spindle timestamps, remove any region that overlaps with a stim
%timestamp with a given width. 

function ts = remove_overlap(spindle_ts,stim_ts,width)

%init loop vars
search_pos = 1; %what row from s[indle_ts
i = 1; %what stim value from stim_ts

while 1
    if i > length(stim_ts) || search_pos > size(spindle_ts,1) %reached the end 
        break
    end

    curr_stim = stim_ts(i);    
    if curr_stim < spindle_ts(search_pos,1) %because spindle_ts is sorted in ascending order, move onto next stim timestamp
        i = i + 1;
        continue
    elseif curr_stim > spindle_ts(search_pos,2) %thus stim does not occur within the current spindle, so move onto next spindle
        search_pos = search_pos + 1;
        continue
    end
    
    %calc removal edges
    left_pos = curr_stim - width;
    right_pos = curr_stim + width;

    %determine how to remove overlap into one of 4 cases
    if left_pos <= spindle_ts(search_pos,1)
        if right_pos >= spindle_ts(search_pos,2)
            %case 1 - removal region overlaps both sides
            spindle_ts(search_pos,:) = []; %delete row
        else
            %case 2 - removal region overlaps on the left side only
            spindle_ts(search_pos,1) = right_pos;
            search_pos = search_pos + 1;
        end
    else
        if right_pos >= spindle_ts(search_pos,2)
            %case 3 - removal region overlaps on the right side only
            spindle_ts(search_pos,2) = left_pos;
            search_pos = search_pos + 1;
        else 
            %case 4 - removal region is within a spindle event from both sides

            %insert new row at search_pos and fill with [right_pos,spindle_ts(search_pos,2)], then update current row
            %with left_pos in position 2. e.g. if the row was [10 17], then it'll become [10 left_pos; right_pos, 17]
            spindle_ts = [spindle_ts(1:search_pos,:); [right_pos,spindle_ts(search_pos,2)] ; spindle_ts(search_pos+1:end,:)]; %based on https://www.mathworks.com/matlabcentral/answers/172699-how-can-i-insert-row-into-matrix-without-deleting-its-values
            spindle_ts(search_pos,2) = left_pos;
            search_pos = search_pos + 1;
        end
    end

end %while end

ts = spindle_ts;
end %function end