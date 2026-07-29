function stage_all_sessions_lick_num_group
% Lick
% path = {"D:\Data\paper\Lick_NoGo_first2", "D:\Data\paper\Lick_last2"}; num = 12;
% Stop
path = {"D:\Data\paper\Stop_NoGo_first2", "D:\Data\paper\Stop_last2"}; num = 10;

Go_lick = zeros(2*num,2);
NoGo_lick = zeros(2*num,2);

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
data_1 = licking_number(1:mice_num,:); data_2 = licking_number(mice_num+1:end,:);
p_1 = signrank(data_1(:,1),data_1(:,2))
p_2 = signrank(data_2(:,1),data_2(:,2))
p_Go = signrank(data_1(:,1),data_2(:,1))
p_NoGo = signrank(data_1(:,2),data_2(:,2))

figure('Position',[50 500 650 500]);
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
ylim([-0.25 5])
yticks([0 2.5 5])
box off;
set(gca,'TickDir','out','LineWidth',1.5)
hold off;

% GoとNo-Goのlick回数の差
diff_lick = (Go_lick-NoGo_lick)./(Go_lick+NoGo_lick); diff_lick = mean(diff_lick,2,"omitmissing");
% diff_lick = asinh(Go_lick)-asinh(NoGo_lick); diff_lick = mean(diff_lick,2);
data_1 = diff_lick(1:mice_num,:); data_2 = diff_lick(mice_num+1:end,:);
p_diff = signrank(data_1,data_2)

figure('Position',[50 500 650 500]);
hold on;
data = [data_1; data_2];
group = [ones(size(data_1,1),1); 2*ones(size(data_2,1),1)];
for i = 1:num
    plot([1;2],[data_1(i),data_2(i)],'Color',[0.75 0.75 0.75],'LineWidth',2.5)
end
boxchart(group,data,'BoxWidth',0.5,...
        'BoxFaceColor','none','BoxEdgeColor','k','BoxMedianLineColor','k','WhiskerLineColor','k',...
        'MarkerStyle','+','MarkerSize',10,'MarkerColor','k','LineWidth',3);
xlim([0.5 2.5])
ylim([-0.3 1])
xticks(1:2)
box off;
set(gca,'TickDir','out','LineWidth',1.5)
hold off;

return