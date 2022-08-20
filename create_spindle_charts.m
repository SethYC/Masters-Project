%create (early) spindle analysis charts. 

%%
%%collect data

%load epochs directory table with SWS duration information from create_SWS_charts()
load('Y:\Seth_temp\Thesis recordings\epochs_table_with_SWS_dur.mat') %created by create_epochs_directories_table()

%init empty arrays for columns
R1_spindle_count_pre45 = zeros(length(epochs_t.rat_num),1);
R2_spindle_count_pre75 = R1_spindle_count_pre45;
R1_spindle_count_total = R1_spindle_count_pre45;
R2_spindle_count_total = R1_spindle_count_pre45;

%add columns to table
epochs_t = addvars(epochs_t,R1_spindle_count_pre45,R1_spindle_count_total,...
                   R2_spindle_count_pre75,R2_spindle_count_total,'After','R2_SWS_total');

%fill spindle count columns
for i = 1:length(epochs_t.rat_num) %for each epochs.mat file
    epochs_path = epochs_t.file_path{i};
    load([epochs_path, '\epochs.mat']) %import struct 'epochs'

    %total columns
    epochs_t.R1_spindle_count_total(i) = size(epochs.tsspin1,1);
    epochs_t.R2_spindle_count_total(i) = size(epochs.tsspin2,1);
    
    %trim spindles past time limit of epochs
    %note: rename vars later maybe
    R1_ts_temp = trim_to_duration(epochs.sleep1(1),epochs.tsspin1,45);
    R2_ts_temp = trim_to_duration(epochs.sleep2(1),epochs.tsspin2,75);

    %pre columns
    epochs_t.R1_spindle_count_pre45(i) = size(R1_ts_temp,1);
    epochs_t.R2_spindle_count_pre75(i) = size(R2_ts_temp,1);

end

%save chart 
save('Y:\Seth_temp\Thesis recordings\epochs_table_with_SWS_dur_spindles.mat','epochs_t')

%%
%%create plots
%note: the following section is largely the same as plot creation is in
%create_SWS_charts

%helper functions
mean_omitNaN = @(x) mean(x,'omitnan');
std_omitNaN = @(x) std(x,'omitnan');
sem_omitNaN = @(x) std(x,'omitnan')/sqrt(size(x,1)); %standard error of the mean, although std is preferred in graphs based on https://doi.org/10.4103/2229-3485.100662
my_sem = @(x) std(x)/sqrt(size(x,1));

x = reshape(epochs_t.R1_spindle_count_pre45,15,[])'; %format durations into a 6x15 (# of rats by 15 days) matrix
x = circshift(x,-1,2); %move probe trial results in column 1 to last column instead and shift eveything else left

y = reshape(epochs_t.R2_spindle_count_pre75,15,[])'; %format durations into a 6x15 (# of rats by 15 days) matrix
y = circshift(y,-1,2); %move probe trial results in column 1 to last column instead and shift eveything else left

%get equivalent matrices for SWS duration
R1_dur = reshape(epochs_t.R1_SWS_pre45,15,[])'; 
R1_dur = circshift(R1_dur,-1,2);
R2_dur = reshape(epochs_t.R2_SWS_pre75,15,[])'; 
R2_dur = circshift(R2_dur,-1,2); 

%normalize counts by SWS duration
x = x./seconds(R1_dur);
y = y./seconds(R2_dur);

%get rid of Inf (from having no SWS in an epoch)
x(x==Inf) = 0;
y(y==Inf) = 0;

%filter out values above 1 spindle per second average (temporary threshold)
% x(x>1) = NaN;
% y(y>1) = NaN;

%split into groups
x_exp = x([2,4,5,6],:); %pre-task pre45
x_con = x([1,3],:);

y_exp = y([2,4,5,6],:); %post-task pre75
y_con = y([1,3],:);

%----------------------------------
%pre-task pre45 charts

%pre45 all rats
%maybe ineffeicent way to plot each rat's pre45 dur, but works for now
charts = tiledlayout('flow'); 
ax1 = nexttile; hold on;
plot(x(2,:),'-o','markersize', 5, 'DisplayName','rat 1E')
plot(x(4,:),'-o','markersize', 5, 'DisplayName','rat 2E')
plot(x(5,:),'-o','markersize', 5, 'DisplayName','rat 3E')
plot(x(6,:),'-o','markersize', 5, 'DisplayName','rat 4E')
plot(x(1,:),'-o','markersize', 5, 'DisplayName','rat 1C')
plot(x(3,:),'-o','markersize', 5, 'DisplayName','rat 2C')
legend
title("pre-task spindle rates")

%pre45 mean and std total
ax2 = nexttile;
shadedErrorBar(1:length(x),x,{mean_omitNaN,sem_omitNaN},'lineprops',{'-o','LineWidth',1.5,'MarkerSize',8,'Color','g'})
title("pre-task sleep mean spindle rates for all rats (SEM)")

% %pre45 mean and std groups
% nexttile; hold on;
% shadedErrorBar(1:length(x_con),x_con,{mean_omitNaN,@std},'lineprops',{'-o','LineWidth',1.5,'MarkerSize',8})
% shadedErrorBar(1:length(x_exp),x_exp,{mean_omitNaN,@std},'lineprops',{'-o','LineWidth',1.5,'MarkerSize',8})
% legend('Control','Experimental')
% title("pre-task sleep Group spindle rates (STD)")

%pre45 mean and sem groups
ax3 = nexttile; hold on;
shadedErrorBar(1:length(x_con),x_con,{mean_omitNaN,sem_omitNaN},'lineprops',{'-o','LineWidth',1.5,'MarkerSize',8})
shadedErrorBar(1:length(x_exp),x_exp,{mean_omitNaN,sem_omitNaN},'lineprops',{'-o','LineWidth',1.5,'MarkerSize',8})
legend('Control','Experimental')
title("pre-task sleep group spindle rates (SEM)")

%-----------------------------------------
%post-task pre75 charts

%pre75 all rats
ax4 = nexttile; hold on;
plot(y(2,:),'-o','markersize', 5, 'DisplayName','rat 1E')
plot(y(4,:),'-o','markersize', 5, 'DisplayName','rat 2E')
plot(y(5,:),'-o','markersize', 5, 'DisplayName','rat 3E')
plot(y(6,:),'-o','markersize', 5, 'DisplayName','rat 4E')
plot(y(1,:),'-o','markersize', 5, 'DisplayName','rat 1C')
plot(y(3,:),'-o','markersize', 5, 'DisplayName','rat 2C')
legend
title("post-task spindle rates")

%pre75 mean and std total
ax5 = nexttile;
shadedErrorBar(1:length(y),y,{mean_omitNaN,sem_omitNaN},'lineprops',{'-o','LineWidth',1.5,'MarkerSize',8,'Color','g'})
title("post-task sleep spindle rates for all rats (SEM)")

% %pre75 mean and std groups
% nexttile; hold on;
% shadedErrorBar(1:length(y_con),y_con,{mean_omitNaN,@std},'lineprops',{'-o','LineWidth',1.5,'MarkerSize',8})
% shadedErrorBar(1:length(y_exp),y_exp,{mean_omitNaN,@std},'lineprops',{'-o','LineWidth',1.5,'MarkerSize',8})
% legend('Control','Experimental')
% title("post-task sleep Group spindle rates (STD)")

%pre75 mean and sem groups
ax6 = nexttile; hold on;
shadedErrorBar(1:length(y_con),y_con,{mean_omitNaN,sem_omitNaN},'lineprops',{'-o','LineWidth',1.5,'MarkerSize',8})
shadedErrorBar(1:length(y_exp),y_exp,{mean_omitNaN,sem_omitNaN},'lineprops',{'-o','LineWidth',1.5,'MarkerSize',8})
legend('Control','Experimental')
title("post-task sleep group spindle rates (SEM)")

%full chart formatting
title(charts,"Comparison of spindle rates")
linkaxes([ax1,ax2,ax3,ax4,ax5,ax6],'y')
xlabel(charts,'day')
ylabel(charts,'mean spindles per second of SWS')
