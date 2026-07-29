function stage_all_sessions_lick_num
% NoGo first2
% path = {"D:\Data\paper\Lick_NoGo_first2", "D:\Data\paper\Stop_NoGo_first2"};
% last2
path = {"D:\Data\paper\Lick_last2", "D:\Data\paper\Stop_last2"};

Go_lick = zeros(22,2);
NoGo_lick = zeros(22,2);

mice_num = 0;

for folder = 1:2
    folderPath = path{folder};
    cd(folderPath)

    list = dir('*.mat');
    list = natsortfiles({list.name});
    
    for mice = 1:length(list)/2
        for k = 2*mice-1:2*mice
            load(list{k});   
            time_lick = 1*sampling_rate;

            % 刺激提示後1s
            num_lick = [];

            for i = 1:size(trial_start,2)
                temp_lick = lick(lick>stim_onset(i)-0.05*sampling_rate & lick<stim_onset(i)+time_lick-0.05*sampling_rate);
                num_lick(end+1) = size(temp_lick,2);
            end
            
            Go_lick_num = num_lick(TrueSide==0 & SelfInitiated==1);
            Go_lick(mice_num+mice,k-2*mice+2) = mean(Go_lick_num);
            NoGo_lick_num = num_lick(TrueSide==1 & SelfInitiated==1);
            NoGo_lick(mice_num+mice,k-2*mice+2) = mean(NoGo_lick_num);
        end
    end
    if folder == 1
        mice_num = length(list)/2;
    end
end

%%%%%%%%%%
licking_number = [mean(Go_lick,2) mean(NoGo_lick,2)];
data_lick = licking_number(1:mice_num,:); data_stop = licking_number(mice_num+1:end,:);
p_lick = signrank(data_lick(:,1),data_lick(:,2))
p_stop = signrank(data_stop(:,1),data_stop(:,2))
p_Go = ranksum(data_lick(:,1),data_stop(:,1))
p_NoGo = ranksum(data_lick(:,2),data_stop(:,2))

figure('Position',[50 500 500 500]);
hold on;
data = [data_lick(:); data_stop(:)];
col_lick = repmat(1:2, 12, 1);
col_stop = repmat(1:2, 10, 1);
colGroup = [col_lick(:); col_stop(:)];
condGroup = [ ...
    ones(numel(data_lick),1); ...
    2*ones(numel(data_stop),1)];
groupID = (condGroup - 1) * 2 + colGroup;

% swarmchart(groupID',data',10,'k','filled');
% v = violinplot(groupID,data);
% v(1).FaceColor = [0.3010 0.7450 0.9330];
for i = 1:12
    plot([1;2],[data_lick(i,1),data_lick(i,2)],'Color',[0.75 0.75 0.75],'LineWidth',2.5)
    % scatter([1;2],[data_lick(i,1),data_lick(i,2)],10,'k','filled')
end
for i = 1:10
    plot([3;4],[data_stop(i,1),data_stop(i,2)],'Color',[0.75 0.75 0.75],'LineWidth',2.5)
    % scatter([3;4],[data_stop(i,1),data_stop(i,2)],10,'k','filled')
end
% boxplot(data, groupID,'Colors','rb','Widths',0.5,'Whisker',inf);
boxchart(groupID,data,'BoxWidth',0.5,...
        'BoxFaceColor','none','BoxEdgeColor','k','BoxMedianLineColor','k','WhiskerLineColor','k',...
        'MarkerStyle','+','MarkerSize',10,'MarkerColor','k','LineWidth',1.5);
xticks(1:4)
xticklabels(repelem(1:2,2))
xline(2 + 0.5, ':','LineWidth',1.5);
xlim([0.5 4.5])
ylim([-0.25 5])
box off;
set(gca,'TickDir','out','LineWidth',1.5)
hold off;

% GoとNo-Goのlick回数の差
diff_lick = (Go_lick-NoGo_lick)./(Go_lick+NoGo_lick); diff_lick = mean(diff_lick,2,"omitmissing");
% diff_lick = asinh(Go_lick)-asinh(NoGo_lick); diff_lick = mean(diff_lick,2);
data_lick = diff_lick(1:mice_num,:); data_stop = diff_lick(mice_num+1:end,:);
p_diff = ranksum(data_lick,data_stop)

figure('Position',[50 500 500 500]);
hold on;
data = [data_lick; data_stop];
group = [ones(size(data_lick,1),1); 2*ones(size(data_stop,1),1)];
swarmchart([ones(1,size(data_lick,1)) 2*ones(1,size(data_stop,1))],...
    [data_lick' data_stop'],20,'k','filled');
boxchart(group,data,'BoxWidth',0.5,...
        'BoxFaceColor','none','BoxEdgeColor','k','BoxMedianLineColor','k','WhiskerLineColor','k',...
        'MarkerStyle','none','LineWidth',1.5);
xlim([0.5 2.5])
ylim([-0.3 1])
xticks(1:2)
box off;
set(gca,'TickDir','out','LineWidth',1.5)
hold off;

return