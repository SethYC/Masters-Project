%Notebook style script to generate reach success charts from a spreadsheet
%of results. Can either plot individual rat results or the group results. 

%helper functions
mean_omitNaN = @(x) mean(x,'omitnan');
std_omitNaN = @(x) std(x,'omitnan');
sem_omitNaN = @(x) std(x,'omitnan')/sqrt(size(x,1)); %standard error of the mean, although std is preferred in graphs based on https://doi.org/10.4103/2229-3485.100662
my_sem = @(x) std(x)/sqrt(size(x,1));

%load data
results = readmatrix("C:\Users\seth.campbell\OneDrive - University of Lethbridge\Documents\Masters\Thesis\Reaching Scores - cohort 1 (draft).xlsx");
results = results(2:end,2:end);
results = results/20*100; %convert reaching scores out of 20 to a percentage

%split groups
con_group = results(5:6,:); %control group
exp_group = results(1:4,:); %experimental group

%shift 1C's data to start of learning
x = circshift(con_group(1,:),-3); %shift left by 3 days so first success occurs on day 2
x(end-2:end) = NaN; %fill right side with NaNs so later averaging and stats are not thrown off
con_group(1,:) = x;

%shared chart formatting
figure; hold on;
rectangle('Position',[14.5 0 1 100], 'EdgeColor','none','FaceColor',[0.8196    0.9490    0.9216])
text(15.5,-3.75,'probe','HorizontalAlignment','center','FontSize', 11)
ylim([0 100])
xlim([1 15.5])
ylabel("% successes")
xlabel('day')
grid on 


%% group results
%STD version
% shadedErrorBar(1:length(results),con_group,{mean_omitNaN,std_omitNaN},'lineprops',{'-o'}) %use this version once there are more than 2 rats in control group(?)
% shadedErrorBar(1:length(results),con_group,{mean_omitNaN,@std},'lineprops',{'-o','LineWidth',1.5,'MarkerSize',8}) %past day 12 has only 1 rat, so std makes no sense, so i can't use std_omitNaN which shows an error bar on day 13
% shadedErrorBar(1:length(results),exp_group,{mean_omitNaN,std_omitNaN},'lineprops',{'-o','LineWidth',1.5,'MarkerSize',8})
% title("Group comparison of reach successes over time (STD)")

%SEM version
shadedErrorBar(1:length(results),con_group,{mean_omitNaN,my_sem},'lineprops',{'-o','LineWidth',1.5,'MarkerSize',8}) 
shadedErrorBar(1:length(results),exp_group,{mean_omitNaN,sem_omitNaN},'lineprops',{'-o','LineWidth',1.5,'MarkerSize',8})
title("Group comparison of reach successes over time (SEM)")

legend('control','experimental')

%% individual rat results
plot(results(1,:),'-o','markersize', 5, 'DisplayName','rat 1E')
plot(results(2,:),'-o','markersize', 5, 'DisplayName','rat 2E')
plot(results(3,:),'-o','markersize', 5, 'DisplayName','rat 3E')
plot(results(4,:),'-o','markersize', 5, 'DisplayName','rat 4E')
plot(results(5,:),'-o','markersize', 5, 'DisplayName','rat 1C')
plot(results(6,:),'-o','markersize', 5, 'DisplayName','rat 2C')
legend
title("Reach successes over time")





