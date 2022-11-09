%quick visualization of pilot results

figure
hold on

%barrier with original well location region
rectangle('Position',[3.5,0,6,100],'EdgeColor','#C0C0C0','FaceColor',[1.00,0.91,0.96])

%far-well + barrier region
rectangle('Position',[9.5,0,7,100],'EdgeColor','#C0C0C0','FaceColor','#FFFFE4')

%low-shelf regions
rectangle('Position',[16.5,0,1,100],'EdgeColor','#C0C0C0','FaceColor',[0.8196, 0.9490, 0.9216])
rectangle('Position',[17.5,0,1,100],'EdgeColor','#C0C0C0','FaceColor',[0.8196, 0.9490, 0.9216])
rectangle('Position',[18.5,0,3,100],'EdgeColor','#C0C0C0','FaceColor',[0.8196, 0.9490, 0.9216])
rectangle('Position',[21.5,0,7,100],'EdgeColor','#C0C0C0','FaceColor',[0.8196, 0.9490, 0.9216])

data = [1,7,6,4;0,0,0,0;0,3,2,1;1,3,0,1;3,2,1,0;3,4,5,1;5,4,4,1;2,4,4,5]; %data only from first 8 days of low-shelf testing 
data_full = [19,26,43,20,20;25,30,44,26,33;26,32,48,26,19;0,0,0,0,0;0,0,0,1,0;1,0,0,2,0;0,0,0,1,0;0,0,0,0,0;0,0,0,1,1;4,0,3,5,4;3,2,6,3,2;1,2,3,5,3;0,1,6,5,5;2,5,6,1,4;0,4,6,7,3;1,1,2,3,6;1,7,6,4,8;0,0,0,0,NaN;0,3,2,1,NaN;1,3,0,1,NaN;3,2,1,0,NaN;3,4,5,1,NaN;5,4,4,1,NaN;2,4,4,5,NaN;7,3,1,3,NaN;4,5,1,3,NaN;3,1,2,4,NaN;3,6,1,5,NaN];
data_full(1:3,:) = data_full(1:3,:)/60*100; %convert to percent reach success out of 60 trials
data_full(4:end,:) = data_full(4:end,:)/20*100; %also percent reach success, but out of 20 trials

plot(data_full)
xlabel("day",'FontSize',18)
ylabel("% success", 'FontSize',18)
xlim([0,28.5])
title("individual % success per day")

%%
%mean chart

figure
hold on

%same colored rectangle regions as above chart
rectangle('Position',[3.5,0,6,100],'EdgeColor','#C0C0C0','FaceColor',[1.00,0.91,0.96])
rectangle('Position',[9.5,0,7,100],'EdgeColor','#C0C0C0','FaceColor','#FFFFE4')
rectangle('Position',[16.5,0,1,100],'EdgeColor','#C0C0C0','FaceColor',[0.8196, 0.9490, 0.9216])
rectangle('Position',[17.5,0,1,100],'EdgeColor','#C0C0C0','FaceColor',[0.8196, 0.9490, 0.9216])
rectangle('Position',[18.5,0,3,100],'EdgeColor','#C0C0C0','FaceColor',[0.8196, 0.9490, 0.9216])
rectangle('Position',[21.5,0,7,100],'EdgeColor','#C0C0C0','FaceColor',[0.8196, 0.9490, 0.9216])

%compute mean % sucess per day 
avg_successes = mean(data_full',"omitnan");
std_successes = std(data_full',"omitnan");
plot(avg_successes,'-o')
% errorbar(avg_successes,std_successes,'-o') %with error bars
xlabel("day",'FontSize',18)
ylabel("% success", 'FontSize',18)
xlim([0,28.5])
title("mean % successes per day",'FontSize',18)

%%
%mean chart with fitted trend line

figure
hold on

%same colored rectangle regions as above chart
rectangle('Position',[3.5,0,6,100],'EdgeColor','#C0C0C0','FaceColor',[1.00,0.91,0.96])
rectangle('Position',[9.5,0,7,100],'EdgeColor','#C0C0C0','FaceColor','#FFFFE4')
rectangle('Position',[16.5,0,1,100],'EdgeColor','#C0C0C0','FaceColor',[0.8196, 0.9490, 0.9216])
rectangle('Position',[17.5,0,1,100],'EdgeColor','#C0C0C0','FaceColor',[0.8196, 0.9490, 0.9216])
rectangle('Position',[18.5,0,3,100],'EdgeColor','#C0C0C0','FaceColor',[0.8196, 0.9490, 0.9216])
rectangle('Position',[21.5,0,7,100],'EdgeColor','#C0C0C0','FaceColor',[0.8196, 0.9490, 0.9216])

%compute mean % sucess per day 
avg_successes = mean(data_full',"omitnan");
std_successes = std(data_full',"omitnan");
plot(avg_successes(1:3),'-ob')
plot(4:9,avg_successes(4:9),'-ob')
plot(10:16,avg_successes(10:16),'-ob')
plot(17,avg_successes(17),'-ob')
plot(18,avg_successes(18),'-ob')
plot(19:21,avg_successes(19:21),'-ob')
plot(22:28,avg_successes(22:28),'-ob')

xlabel("day",'FontSize',18)
ylabel("% success", 'FontSize',18)
xlim([0,28.5])
title("mean % successes per day with trend lines",'FontSize',18)
