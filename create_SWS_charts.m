%create slow wave sleep duration comparison charts for cohort 1.

%%
%%collect data
load('Y:\Seth_temp\Thesis recordings\epochs_table.mat') %load struct 'epochs_t'

%init empty duration arrays for columns
R1_SWS_total = duration(nan(length(epochs_t.rat_num),3)); %(based on https://www.mathworks.com/matlabcentral/answers/368435-create-an-array-of-empty-durations)
% R1_SWS_total.Format = "s"; %to specify as just seconds instead of default hh:mm:ss
R2_SWS_total = R1_SWS_total;
R1_SWS_pre45 = R1_SWS_total; %SWS duration before 45 min
R2_SWS_pre75 = R1_SWS_total; %SWS duration before 75 min

%add pre-task sleep and post-task SWS SWS duration columns
epochs_t = addvars(epochs_t,R1_SWS_pre45,R1_SWS_total,R2_SWS_pre75,R2_SWS_total,'After','file_path');

%fill duration values
for i = 1:length(epochs_t.rat_num) %for each epochs.mat file
    epochs_path = epochs_t.file_path{i};
    load([epochs_path, '\epochs.mat']) %import struct 'epochs'

    %note: for readability, i should split this into multiple lines later(?)
    epochs_t.R1_SWS_total(i) = seconds(sum(diff(epochs.tssws1'))/1e4);
    epochs_t.R2_SWS_total(i) = seconds(sum(diff(epochs.tssws2'))/1e4);

    %note: rename these vars or just make the conversion to seconds a function
    R1_ts_new = trim_to_duration(epochs.sleep1(1),epochs.tssws1,45);
    R2_ts_new = trim_to_duration(epochs.sleep2(1),epochs.tssws2,75);

    epochs_t.R1_SWS_pre45(i) = seconds(sum(diff(R1_ts_new'))/1e4);
    epochs_t.R2_SWS_pre75(i) = seconds(sum(diff(R2_ts_new'))/1e4);

end

%note: save chart for use in other scripts (better modularize this later)
save('Y:\Seth_temp\Thesis recordings\epochs_table_with_SWS_dur.mat','epochs_t')

%%
%%create plots

%helper functions
my_sem = @(x) std(x)/sqrt(size(x,1));

x = reshape(epochs_t.R1_SWS_pre45,15,[])'; %format durations into a 6x15 (# of rats by 15 days) matrix
x = circshift(x,-1,2); %move probe trial results in column 1 to last column instead and shift eveything else left
x = x/(minutes(45))*100;

y = reshape(epochs_t.R2_SWS_pre75,15,[])'; %format durations into a 6x15 (# of rats by 15 days) matrix
y = circshift(y,-1,2); %move probe trial results in column 1 to last column instead and shift eveything else left
y = y/(minutes(75))*100;

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
title("pre-task sleep duration")

%pre45 mean and std total
ax2 = nexttile;
shadedErrorBar(1:length(x),x,{@mean,my_sem},'lineprops',{'-o','LineWidth',1.5,'MarkerSize',8,'Color','g'})
title("pre-task sleep Mean duration for all rats (SEM)")

% %pre45 mean and std groups
% nexttile; hold on;
% shadedErrorBar(1:length(x_con),x_con,{@mean,@std},'lineprops',{'-o','LineWidth',1.5,'MarkerSize',8})
% shadedErrorBar(1:length(x_exp),x_exp,{@mean,@std},'lineprops',{'-o','LineWidth',1.5,'MarkerSize',8})
% legend('Control','Experimental')
% title("pre-task sleep Group duration (STD)")

%pre45 mean and sem groups
ax3 = nexttile; hold on;
shadedErrorBar(1:length(x_con),x_con,{@mean,my_sem},'lineprops',{'-o','LineWidth',1.5,'MarkerSize',8})
shadedErrorBar(1:length(x_exp),x_exp,{@mean,my_sem},'lineprops',{'-o','LineWidth',1.5,'MarkerSize',8})
legend('Control','Experimental')
title("pre-task sleep group duration (SEM)")

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
legend('Location','southwest')
title("post-task sleep duration")

%pre75 mean and std total
ax5 = nexttile;
shadedErrorBar(1:length(y),y,{@mean,my_sem},'lineprops',{'-o','LineWidth',1.5,'MarkerSize',8,'Color','g'})
title("post-task sleep Mean duration for all rats (SEM)")

% %pre75 mean and std groups
% nexttile; hold on;
% shadedErrorBar(1:length(y_con),y_con,{@mean,@std},'lineprops',{'-o','LineWidth',1.5,'MarkerSize',8})
% shadedErrorBar(1:length(y_exp),y_exp,{@mean,@std},'lineprops',{'-o','LineWidth',1.5,'MarkerSize',8})
% legend('Control','Experimental')
% title("post-task sleep Group duration (STD)")

%pre75 mean and sem groups
ax6 = nexttile; hold on;
shadedErrorBar(1:length(y_con),y_con,{@mean,my_sem},'lineprops',{'-o','LineWidth',1.5,'MarkerSize',8})
shadedErrorBar(1:length(y_exp),y_exp,{@mean,my_sem},'lineprops',{'-o','LineWidth',1.5,'MarkerSize',8})
legend('Control','Experimental')
title("post-task sleep group duration (SEM)")

%full chart formatting
title(charts,"Comparison of SWS duration")
linkaxes([ax1,ax2,ax3,ax4,ax5,ax6],'y')
xlabel(charts,'day','FontSize',14)
ylabel(charts,'% time in SWS out of total rest','FontSize',14)