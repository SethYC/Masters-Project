%create cross correlation charts using output table from
%create_cross_corr_table.m
%
%Seth Campbell, Mar. 4, 2023

%load table 't' and 'lags' vector from xcorr() (~200mb file!)
load('Y:\Seth_temp\Thesis recordings\cross_corr_table.mat')
t_temp = t;

%%
% post-task results
t = t_temp;
%filter out non-post-task epochs
t(t.epoch == 'pre-task_sleep',:) = [];

%transform data from cell array into 90x80,001 matrix (90 epochs by 80,001 1/8000Hz units) 
mean_xcorr_data = arrange_chart_data(t.cross_corr);

%plot 1sec window with 10sec window plot inset
make_xcorr_chart(mean_xcorr_data, lags, "cross correlation of spindle onset relative to SWR onset during post-task rest", true)

%%
% pre-task results
t = t_temp;
t(t.epoch == 'post-task_sleep',:) = [];

mean_xcorr_data = arrange_chart_data(t.cross_corr);

figure 
make_xcorr_chart(mean_xcorr_data, lags, "cross correlation of spindle onset relative to SWR onset during pre-task rest", true)

%%
% normalized post-task results
t = t_temp;
%filter out non-post-task epochs
t(t.epoch == 'pre-task_sleep',:) = [];

mean_xcorr_data = arrange_chart_data(t.cross_corr_norm);

%plot 1sec window with 10sec window plot inset
make_xcorr_chart(mean_xcorr_data, lags, "normalized cross correlation of spindle onset relative to SWR onset during post-task rest", true)

%%
% normalized pre-task results
t = t_temp;
%filter out non-post-task epochs
t(t.epoch == 'post-task_sleep',:) = [];

%manually transform data from cell array into 90x80,001 matrix (90 epochs by 80,001 1/8000Hz units) 
xcorr_data = cell2mat(t.cross_corr_norm);
xcorr_data = reshape(xcorr_data,80001,[]);
xcorr_data = xcorr_data'; 

%average across all days and rats, then smooth 
xcorr_data(40,:) = []; %for some reason row 40 has all NaN's in this version of the data only, so remove it
mean_xcorr_data = mean(xcorr_data);
mean_xcorr_data = smoothdata(mean_xcorr_data,'movmean',200); %25ms sliding window smoothing

%plot 1sec window with 10sec window plot inset
make_xcorr_chart(mean_xcorr_data, lags, "normalized cross correlation of spindle onset relative to SWR onset during pre-task rest", true)

%%
% normalized post-task results over days
t = t_temp;

t(t.epoch == 'pre-task_sleep',:) = []; %filter out non-post-task epochs
t_subset = t;

for i=1:14
    t_subset = t;
    t_subset(t.phase ~= 'Training' | t.day ~= i,:) = []; %keep only day i of training phase
    mean_xcorr_data = arrange_chart_data(t_subset.cross_corr_norm);
    make_xcorr_chart(mean_xcorr_data, lags, "test")
%     make_xcorr_chart(mean_xcorr_data, lags + ((i-1)*300), "test") %horizontal offset to see any trend in peaks over days
    hold on;
end

%chart formatting
title("cross correlation of spindle onset relative to SWR onset during post-task rest over days")
legend('day 1','day 2','day 3','day 4','day 5','day 6','day 7','day 8','day 9','day 10','day 11','day 12','day 13','day 14')

%%
% normalized post-task results of control vs experimental rats
t = t_temp;
t(t.epoch == 'pre-task_sleep',:) = [];

t(t.group ~= 'C',:) = []; %leave controls only
mean_xcorr_data = arrange_chart_data(t.cross_corr_norm);
make_xcorr_chart(mean_xcorr_data, lags, "test")
hold on;

t = t_temp;
t(t.epoch == 'pre-task_sleep',:) = [];
t(t.group ~= 'E',:) = []; %leave controls only
mean_xcorr_data = arrange_chart_data(t.cross_corr_norm);
make_xcorr_chart(mean_xcorr_data, lags, "test", true)

%chart formatting
title("normalized cross correlation of spindle onset relative to SWR onset during post-task rest")
legend('Control','Experimental')

%%
function make_xcorr_chart(mean_xcorr_data, lags, title_text, use_inset)  

    %plot 1sec window with 10sec window plot inset
%     figure 
    plot(lags,mean_xcorr_data) %main plot
    title(title_text)
    ylabel("Cross Correlation Strength(?)")
    xlabel("Lag (s)")
    xlim([-4000, 4000])
    set(gca,'XTick',linspace(-4000,4000,11)) 
    xticklabels(-0.5:.1:.5)
    
    if nargin > 3 && use_inset == true
        axes('Position',[.6,.6,.3,.3]) %inset plot
        box on
        plot(lags,mean_xcorr_data)
        xlabel("Lag (s)")
        set(gca,'XTick',linspace(-40000,40000,11)) %based on 40,000 unit window size, making 1 sec increment ticks
        xticklabels(-5:5)
    end
end

function mean_xcorr_data = arrange_chart_data(ydata)
    %transform data from cell array into 90x80,001 matrix (90 epochs by 80,001 1/8000Hz units) 
    xcorr_data = cell2mat(ydata);
    xcorr_data = reshape(xcorr_data,80001,[]);
    xcorr_data = xcorr_data'; 
    
    %average across all days and rats, then smooth 
    mean_xcorr_data = mean(xcorr_data);
    mean_xcorr_data = smoothdata(mean_xcorr_data,'movmean',200); %25ms sliding window smoothing
end