function stage_all_sessions_lick_rt_group
% Lick
% path = {"D:\Data\paper\Lick_NoGo_first2", "D:\Data\paper\Lick_last2"}; num = 12;
% Stop
path = {"D:\Data\paper\Stop_NoGo_first2", "D:\Data\paper\Stop_last2"}; num = 10;

Go_rt = zeros(num*2,2);
NoGo_rt = zeros(num*2,2);

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
data_1 = reaction_time(1:mice_num,:); data_2 = reaction_time(mice_num+1:end,:);
p_1 = signrank(data_1(:,1),data_1(:,2))
p_2 = signrank(data_2(:,1),data_2(:,2))
p_Go = signrank(data_1(:,1),data_2(:,1))
p_NoGo = signrank(data_1(:,2),data_2(:,2))
x = data_1(:,1);
sem = std(x)/sqrt(numel(x)); d = max(0, 1 - floor(log10(sem)));
fprintf('stage 3 Go   mean %.*f  standard error %.*f (n=%d)\n', d, mean(x), d, sem, numel(x));

x = data_1(:,2);
sem = std(x)/sqrt(numel(x)); d = max(0, 1 - floor(log10(sem)));
fprintf('stage 3 NoGo mean %.*f  standard error %.*f (n=%d)\n', d, mean(x), d, sem, numel(x));

x = data_2(:,1);
sem = std(x)/sqrt(numel(x)); d = max(0, 1 - floor(log10(sem)));
fprintf('stage 5 Go   mean %.*f  standard error %.*f (n=%d)\n', d, mean(x), d, sem, numel(x));

x = data_2(:,2);
sem = std(x)/sqrt(numel(x)); d = max(0, 1 - floor(log10(sem)));
fprintf('stage 5 NoGo mean %.*f  standard error %.*f (n=%d)\n', d, mean(x), d, sem, numel(x));

figure('Position', [50 500 650 500]);
hold on;
data = [data_1(:); data_2(:)];
col_1 = repmat(1:2, num, 1);
col_2 = repmat(1:2, num, 1);
colGroup = [col_1(:); col_2(:)];
condGroup = [ ...
    ones(numel(data_1),1); ...
    2*ones(numel(data_2),1)];
groupID = (condGroup - 1) * 2 + colGroup;

for i = 1:num
    plot([1;2],[data_1(i,1),data_1(i,2)],'Color',[0.75 0.75 0.75],'LineWidth',2.5)
end
for i = 1:num
    plot([3;4],[data_2(i,1),data_2(i,2)],'Color',[0.75 0.75 0.75],'LineWidth',2.5)
end
boxchart(groupID,data,'BoxWidth',0.5,...
        'BoxFaceColor','none','BoxEdgeColor','k','BoxMedianLineColor','k','WhiskerLineColor','k',...
        'MarkerStyle','+','MarkerSize',10,'MarkerColor','k','LineWidth',3);
xticks(1:4)
xticklabels(repelem(1:2,2))
xline(2 + 0.5, ':','LineWidth',1.5);
xlim([0.5 4.5])
ylim([0 1])
yticks([0 0.5 1])
box off;
set(gca,'TickDir','out','LineWidth',1.5)
hold off;

return