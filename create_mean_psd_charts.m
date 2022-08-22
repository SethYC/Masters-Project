%~*NOT FUNCTIONAL YET*~
%Compute power spectral density and create plots for all four hippocampal
%recording channels averaged across all training and probe recordings in
%the post-task epoch for a rat. Script is largely based on
%create_psd_charts(), but generalized to averaging results across multiple
%recordings.
%
%Note: must be in directory of recording epoch with the hippocampal .ncs 
%files.

%four hippocampal channel names
hpc_names = ["hpc1.ncs", "hpc2.ncs", "hpc3.ncs", "hpc4.ncs"];

%load directory table and keep only post-task sleep epoch entries during training phase
load("Y:\Seth_temp\Thesis recordings\directory_table.mat") %load table 't'
t(t.phase == 'Baseline',:) = []; %delete rows based on index of rows with baseline
t(t.epoch ~= 'post-task_sleep',:) = [];

%init new hpc result columns in a n x 4 cell array (4 columns for 4 hpc channels)
% hpc1_norm_power = cell(length(t.rat_num),1); %cell array so each cell can hold results of an array of power values
% hpc2_norm_power = cell(length(t.rat_num),1);
% hpc3_norm_power = cell(length(t.rat_num),1);
% hpc4_norm_power = cell(length(t.rat_num),1);
hpc_norm_powers = cell(length(t.rat_num),4); %each cell will hold an array of power values

for j = 1:length(t.rat_num)
    
    %load epochs struct
    epochs_path = remove_last_2_folders(t.path{j});
    load([epochs_path, '\epochs.mat']) %import struct 'epochs'
    
    %loop through hpc channels
    for i = 1:4
        
        %current channel
        hpc_ch = convertStringsToChars(hpc_names(i)); 
        
        %load eeg data
        x = split(t.path{j},'\');
        if x{end-1} == "post-task_sleep"
            eeg_tsd = csc2tsd_badclock([t.path{j},'\',hpc_ch],epochs.sleep2);
        else %pre-task_sleep
            eeg_tsd = csc2tsd_badclock([t.path{j},'\',hpc_ch],epochs.sleep1);
        end  
        eeg = Data(eeg_tsd);
        s_rate = 1 / mode(diff(Range(eeg_tsd)))*1e4; %sample rate in Hz %note: maybe make this more effecient later
    
        %calc fft and power, based on https://www.mathworks.com/help/matlab/math/basic-spectral-analysis.html
        y = fft(eeg);
        n = length(eeg);
        y0 = fftshift(y);         
        f0 = (-n/2:n/2-1)*(s_rate/n);
        power0 = abs(y0).^2/n;  
        norm_power0 = power0/max(power0);
        
        %prepare plot data snippets (plotting full data is redundent) 
        l = length(f0);
        f0_snippet = f0(floor(l/2):end-floor(l/3)); %only take halfway point to 5/6 point, corresponding to 0hz-1333Hz (arbitrarly choosen snippet size)
        norm_power0_snippet = norm_power0(floor(l/2):end-floor(l/3));
    
%         %plot
%         ax(i) = nexttile;
%         plot(f0_snippet,norm_power0_snippet)
%         str = sprintf('hpc%i', i); %subplot title
%         title(str)
%         patch([5,5,8,8],[0,1,1,0],'red','FaceAlpha',.1,'edgecolor','none') %theta patch
%         patch([100,100,300,300],[0,1,1,0],'green','FaceAlpha',.1,'edgecolor','none') %SWR 100Hz-300Hz patch
    
        %save results to (to-be) column vars
        hpc_norm_powers{j,i} = norm_power0_snippet;

        %note: current issue is that for each new recording day, the length
        %of norm_power0_snippet is different. The step size of what the nth
        %value in that array is what freq is also different from recording
        %to recording slightly, so averaging across days will be inaccurate
        %to a degree. The solution could use histc to bin related values
        %from f0 (the xaxis) and applying this binning to the averaging of
        %results in norm_power0_snippet. 

    end

end

%
%init chart layout
figure;
charts = tiledlayout('flow');

%general chart formatting
linkaxes(ax,'xy')
xlim([0 300])
xlabel(charts,'Frequency (Hz)')
ylabel(charts,'Normalized Power')
title(charts,"Normalized power of all hippocampal channels for a given recording epoch","red = theta, green = SWR 100-300Hz")