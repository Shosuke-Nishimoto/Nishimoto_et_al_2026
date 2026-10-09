function stage_all_sessions_lick_rt
% last2
path = {"D:\Data\paper\Lick_last2", "D:\Data\paper\Stop_last2"};

Go_rt = zeros(22,2);
NoGo_rt = zeros(22,2);

mice_num = 0;

for folder = 1:2
    folderPath = path{folder};
    cd(folderPath)

    list = dir('*.mat');
    list = natsortfiles({list.name});
    
    for mice = 1:length(list)/2
        for k = 2*mice-1:2*mice
            load(list{k});
            % 全体
            lick_plot = [];
            for i = 1:size(trial_start,2)
                temp_lick = lick(lick>trial_start(i) & lick<trial_end(i));
                for j = 1:size(temp_lick,2)
                    lick_plot(end+1,:) = [i,temp_lick(j)-stim_onset(i)];
                end
            end

            % 各trialのrtを求める
            lick_plot2 = lick_plot(lick_plot(:,2)>0,:);
            rt = zeros(1,size(trial_start,2));
            for i = 1:size(trial_start,2)
                rt_ind = find(lick_plot2(:,1)==i,1);
                rt(i) = min([lick_plot2(rt_ind,2),0.95*sampling_rate]); % 刺激提示後0.95s以内になめなかった場合は0.95sとする
            end
            rt = rt/sampling_rate;
            
            temp_go = rt(rt<0.95 & TrueSide==0 & SelfInitiated==1);
            Go_rt(mice_num+mice,k-2*mice+2) = mean(temp_go);
            temp_nogo = rt(rt<0.95 & TrueSide==1 & SelfInitiated==1);
            NoGo_rt(mice_num+mice,k-2*mice+2) = mean(temp_nogo);
        end
    end
    if folder == 1
        mice_num = length(list)/2;
    end
end

%%%%%%%%%%
reaction_time = [mean(Go_rt,2,"omitmissing") mean(NoGo_rt,2,"omitmissing")];
data_lick = reaction_time(1:mice_num,:); data_stop = reaction_time(mice_num+1:end,:);
p_lick = signrank(data_lick(:,1),data_lick(:,2))
p_stop = signrank(data_stop(:,1),data_stop(:,2))
p_Go = ranksum(data_lick(:,1),data_stop(:,1))
p_NoGo = ranksum(data_lick(:,2),data_stop(:,2))

figure('Position', [50 500 500 500]);
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
ylim([0 1])
box off;
set(gca,'TickDir','out','LineWidth',1.5)
hold off;

return