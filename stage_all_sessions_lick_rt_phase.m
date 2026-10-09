function stage_all_sessions_lick_rt_phase
% last2
path = {"D:\Data\paper\Lick_last2", "D:\Data\paper\Stop_last2"};
Go_rt_first = zeros(22,2); Go_rt_last = zeros(22,2);
NoGo_rt_first = zeros(22,2); NoGo_rt_last = zeros(22,2);
mice_num = 0;

for folder = 1:2
    folderPath = path{folder};
    cd(folderPath)

    list = dir('*.mat');
    list = natsortfiles({list.name});
    
    for mice = 1:length(list)/2
        for k = 2*mice-1:2*mice
            load(list{k});
            % 全体（stage_all_sessions_lick_rt.m と同じ）
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

            % 最初の200 trial（stage_all_sessions_accuracy_phase.m と同じ切り方）
            rt_first = rt(1:200); TrueSide_first = TrueSide(1:200); SelfInitiated_first = SelfInitiated(1:200);
            temp_go = rt_first(rt_first<0.95 & TrueSide_first==0 & SelfInitiated_first==1);
            Go_rt_first(mice_num+mice,k-2*mice+2) = mean(temp_go);
            temp_nogo = rt_first(rt_first<0.95 & TrueSide_first==1 & SelfInitiated_first==1);
            NoGo_rt_first(mice_num+mice,k-2*mice+2) = mean(temp_nogo);

            % 最後の200 trial
            rt_last = rt(end-199:end); TrueSide_last = TrueSide(end-199:end); SelfInitiated_last = SelfInitiated(end-199:end);
            temp_go = rt_last(rt_last<0.95 & TrueSide_last==0 & SelfInitiated_last==1);
            Go_rt_last(mice_num+mice,k-2*mice+2) = mean(temp_go);
            temp_nogo = rt_last(rt_last<0.95 & TrueSide_last==1 & SelfInitiated_last==1);
            NoGo_rt_last(mice_num+mice,k-2*mice+2) = mean(temp_nogo);
        end
    end
    if folder == 1
        mice_num = length(list)/2;
    end
end

%%%%%%%%%%
% 最初の200 trialと最後の200 trialの first-lick latency（2セッション平均）
reaction_time = [mean(Go_rt_first,2,"omitmissing") mean(Go_rt_last,2,"omitmissing") mean(NoGo_rt_first,2,"omitmissing") mean(NoGo_rt_last,2,"omitmissing")];
data_lick = reaction_time(1:mice_num,:); data_stop = reaction_time(mice_num+1:end,:);

% Lick
figure('Position', [50 500 500 500]);
hold on;
data = data_lick(:);
col_lick = repmat(1:2, 12, 1);
colGroup = [col_lick(:); col_lick(:)];
condGroup = [ ...
    ones(numel(col_lick),1); ...
    2*ones(numel(col_lick),1)];
groupID = (condGroup - 1) * 2 + colGroup;

for i = 1:12
    plot([1;2],[data_lick(i,1),data_lick(i,2)],'Color',[0.75 0.75 0.75],'LineWidth',2.5)
    plot([3;4],[data_lick(i,3),data_lick(i,4)],'Color',[0.75 0.75 0.75],'LineWidth',2.5)
end
boxchart(groupID,data,'BoxWidth',0.5,...
        'BoxFaceColor','none','BoxEdgeColor','k','BoxMedianLineColor','k','WhiskerLineColor','k',...
        'MarkerStyle','+','MarkerSize',10,'MarkerColor','k','LineWidth',3);
xticks(1:4)
xticklabels(repelem(1:2,2))
yticks([0 0.5 1])
xline(2 + 0.5, ':','LineWidth',1.5);
xlim([0.5 4.5])
ylim([0 1])
box off;
set(gca,'TickDir','out','LineWidth',1.5)
hold off;
% early とlate とで差があるか
p_lick_Go = signrank(data_lick(:,1), data_lick(:,2))
p_lick_NoGo = signrank(data_lick(:,3), data_lick(:,4))

% Stop
figure('Position', [50 500 500 500]);
hold on;
data = data_stop(:);
col_stop = repmat(1:2, 10, 1);
colGroup = [col_stop(:); col_stop(:)];
condGroup = [ ...
    ones(numel(col_stop),1); ...
    2*ones(numel(col_stop),1)];
groupID = (condGroup - 1) * 2 + colGroup;

for i = 1:10
    plot([1;2],[data_stop(i,1),data_stop(i,2)],'Color',[0.75 0.75 0.75],'LineWidth',2.5)
    plot([3;4],[data_stop(i,3),data_stop(i,4)],'Color',[0.75 0.75 0.75],'LineWidth',2.5)
end
boxchart(groupID,data,'BoxWidth',0.5,...
        'BoxFaceColor','none','BoxEdgeColor','k','BoxMedianLineColor','k','WhiskerLineColor','k',...
        'MarkerStyle','+','MarkerSize',10,'MarkerColor','k','LineWidth',3);
xticks(1:4)
xticklabels(repelem(1:2,2))
yticks([0 0.5 1])
xline(2 + 0.5, ':','LineWidth',1.5);
xlim([0.5 4.5])
ylim([0 1])
box off;
set(gca,'TickDir','out','LineWidth',1.5)
hold off;
% early とlate とで差があるか
p_stop_Go = signrank(data_stop(:,1), data_stop(:,2))
p_stop_NoGo = signrank(data_stop(:,3), data_stop(:,4))

%%%%%%%%%%
% 最初の200 trialと最後の200 trialのreaction timeの差
diff_rt_Go = (Go_rt_last - Go_rt_first)./(Go_rt_last + Go_rt_first);
diff_rt_NoGo = (NoGo_rt_last - NoGo_rt_first)./(NoGo_rt_last + NoGo_rt_first);
data_lick = mean(diff_rt_Go(1:mice_num,:),2,"omitmissing"); data_stop = mean(diff_rt_Go(mice_num+1:end,:),2,"omitmissing");
data_NoGo_lick = mean(diff_rt_NoGo(1:mice_num,:),2,"omitmissing"); data_NoGo_stop = mean(diff_rt_NoGo(mice_num+1:end,:),2,"omitmissing");
mouse_mean = {data_lick, data_stop, data_NoGo_lick, data_NoGo_stop};
labels = {'Go Lick', 'Go Stop', 'No-Go Lick', 'No-Go Stop'};
for i = 1:4
    x = mouse_mean{i};
    sem = std(x)/sqrt(numel(x));
    fprintf('%s  mean %.6g  SEM %.6g (n=%d)\n', ...
        labels{i}, mean(x), sem, numel(x));
end

% Go
figure('Position', [50 500 150 500]);
hold on;
data = [data_lick; data_stop];
group = [ones(size(data_lick,1),1); 2*ones(size(data_stop,1),1)];
s = swarmchart([ones(1,size(data_lick,1)) 2*ones(1,size(data_stop,1))],...
    [data_lick' data_stop'],30,'k','filled');
s.XJitterWidth = 0.4;
boxchart(group,data,'BoxWidth',0.5,...
        'BoxFaceColor','none','BoxEdgeColor','k','BoxMedianLineColor','k','WhiskerLineColor','k',...
        'MarkerStyle','none','LineWidth',3);
xlim([0.5 2.5])
ylim([-0.1 0.3])
xticks(1:2)
yticks(-0.1:0.1:0.3)
box off;
set(gca,'TickDir','out','LineWidth',1.5)
hold off;

p = ranksum(data_lick,data_stop)

% No-Go
figure('Position', [50 500 150 500]);
hold on;
data = [data_NoGo_lick; data_NoGo_stop];
group = [ones(size(data_NoGo_lick,1),1); 2*ones(size(data_NoGo_stop,1),1)];
s = swarmchart([ones(1,size(data_NoGo_lick,1)) 2*ones(1,size(data_NoGo_stop,1))],...
    [data_NoGo_lick' data_NoGo_stop'],30,'k','filled');
s.XJitterWidth = 0.4;
boxchart(group,data,'BoxWidth',0.5,...
    'BoxFaceColor','none','BoxEdgeColor','k','BoxMedianLineColor','k','WhiskerLineColor','k',...
    'MarkerStyle','none','LineWidth',3);
xlim([0.5 2.5])
ylim([-0.1 0.3])
xticks(1:2)
yticks(-0.1:0.1:0.3)
box off;
set(gca,'TickDir','out','LineWidth',1.5)
hold off;

p = ranksum(data_NoGo_lick,data_NoGo_stop)

return
