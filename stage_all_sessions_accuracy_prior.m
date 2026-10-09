function stage_all_sessions_accuracy_prior
% last2
path = {"D:\Data\paper\Lick_last2", "D:\Data\paper\Stop_last2"};

Go_accuracy_1 = zeros(22,2); % Go>Go
NoGo_accuracy_1 = zeros(22,2); % Go>No-Go
Go_accuracy_2 = zeros(22,2); % No-Go>Go
NoGo_accuracy_2 = zeros(22,2); % No-Go>No-Go
mice_num = 0;

for folder = 1:2
    folderPath = path{folder};
    cd(folderPath)

    list = dir('*.mat');
    list = natsortfiles({list.name});
    
    for mice = 1:length(list)/2
        for k = 2*mice-1:2*mice
            load(list{k});
            
            % Go>Go
            Go_accuracy_1(mice_num+mice,k-2*mice+2)...
                = sum(go_go==1 & Outcome==2 & SelfInitiated==1)/sum(go_go==1 & Outcome>=1 & Outcome<=2 & SelfInitiated==1);

            % Go>No-Go
            NoGo_accuracy_1(mice_num+mice,k-2*mice+2)...
                = sum(go_no==1 & Outcome==1 & SelfInitiated==1)/sum(go_no==1 & Outcome>=1 & Outcome<=3 & Outcome~=2 & SelfInitiated==1);

            % No-Go>Go
            Go_accuracy_2(mice_num+mice,k-2*mice+2)...
                = sum(no_go==1 & Outcome==2 & SelfInitiated==1)/sum(no_go==1 & Outcome>=1 & Outcome<=2 & SelfInitiated==1);

            % No-Go>No-Go
            NoGo_accuracy_2(mice_num+mice,k-2*mice+2)...
                = sum(no_no==1 & Outcome==1 & SelfInitiated==1)/sum(no_no==1 & Outcome>=1 & Outcome<=3 & Outcome~=2 & SelfInitiated==1);
        end
    end
    if folder == 1
        mice_num = length(list)/2;
    end
end

%%%%%%%%%%
% 直前のtrial typeごとの正答率
accuracy = [mean(Go_accuracy_1,2) mean(Go_accuracy_2,2) mean(NoGo_accuracy_1,2) mean(NoGo_accuracy_2,2)];
data_lick = accuracy(1:mice_num,:); data_stop = accuracy(mice_num+1:end,:);

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
% Go>No-GoとNo-Go>No-Goとで差があるか
p_lick_Go = signrank(data_lick(:,1), data_lick(:,2))
p_lick_NoGo = signrank(data_lick(:,3), data_lick(:,4))

labels = {'current Go after Go','current Go after No-Go','current No-Go after Go','current No-Go after No-Go'};
for i = 1:4
    x = data_lick(:,i);
    x = x(~isnan(x));
    sem = std(x)/sqrt(numel(x)); d = max(0, 1 - floor(log10(sem)));
    fprintf('Lick %s  mean %.*f  standard error %.*f (n=%d)\n', labels{i}, d, mean(x), d, sem, numel(x));
end

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
% Go>No-GoとNo-Go>No-Goとで差があるか
p_stop_Go = signrank(data_stop(:,1), data_stop(:,2))
p_stop_NoGo = signrank(data_stop(:,3), data_stop(:,4))

labels = {'current Go after Go','current Go after No-Go','current No-Go after Go','current No-Go after No-Go'};
for i = 1:4
    x = data_stop(:,i); % Stop のブロックでは data_stop(:,i)
    x = x(~isnan(x));
    sem = std(x)/sqrt(numel(x)); d = max(0, 1 - floor(log10(sem)));
    fprintf('Stop %s  mean %.*f  standard error %.*f (n=%d)\n', labels{i}, d, mean(x), d, sem, numel(x));
end

return