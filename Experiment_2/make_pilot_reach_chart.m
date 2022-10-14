%quick visualization of pilot results

figure
hold on
rectangle('Position',[0.5,0,1,7],'FaceColor',[0.8196, 0.9490, 0.9216])
rectangle('Position',[1.5,0,1,7],'FaceColor',[0.8196, 0.9490, 0.9216])
rectangle('Position',[2.5,0,3,7],'FaceColor',[0.8196, 0.9490, 0.9216])
rectangle('Position',[5.5,0,3,7],'FaceColor',[0.8196, 0.9490, 0.9216])

data = [1,7,6,4;0,0,0,0;0,3,2,1;1,3,0,1;3,2,1,0;3,4,5,1;5,4,4,1;2,4,4,5];
plot(data)