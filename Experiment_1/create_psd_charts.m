%Compute power spectral density and create plots for all four hippocampal
%recording channels for a given recording epoch. 
%
%note: must be in directory of recording epoch with the hippocampal .ncs 
%files.

%four hippocampal channel names
hpc_names = ["hpc1.ncs", "hpc2.ncs", "hpc3.ncs", "hpc4.ncs"];

%init chart layout
figure;
charts = tiledlayout('flow');

%load epochs struct
epochs_path = remove_last_2_folders(pwd);
load([epochs_path, '\epochs.mat']) %import struct 'epochs'

%loop through hpc channels
for i = 1:4
    
    %current channel
    hpc_ch = convertStringsToChars(hpc_names(i)); 
    
    %load eeg data
    x = split(pwd,'\');
    if x{end-1} == "post-task_sleep"
        eeg_tsd = csc2tsd_badclock(hpc_ch,epochs.sleep2);
    else %pre-task_sleep
        eeg_tsd = csc2tsd_badclock(hpc_ch,epochs.sleep1);
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

    %plot
    ax(i) = nexttile;
    plot(f0_snippet,norm_power0_snippet)
    str = sprintf('hpc%i', i); %subplot title
    title(str,'FontSize',15)
    patch([6,6,10,10],[0,1,1,0],'red','FaceAlpha',.2,'edgecolor','none') %theta patch
    patch([100,100,300,300],[0,1,1,0],'green','FaceAlpha',.1,'edgecolor','none') %SWR 100Hz-300Hz patch
end

%general chart formatting
linkaxes(ax,'xy')
xlim([0 300])
xlabel(charts,'Frequency (Hz)','FontSize',14)
ylabel(charts,'Normalized Power','FontSize',14)
title(charts,"Normalized power of all hippocampal channels for a given recording epoch","red = theta 6-10Hz, green = SWR 100-300Hz")