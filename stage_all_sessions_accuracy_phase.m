function stage_all_sessions_accuracy_phase
% NoGo first2
% path = {"D:\Data\paper\Lick_NoGo_first2", "D:\Data\paper\Stop_NoGo_first2"};
% last2
path = {"D:\Data\paper\Lick_last2", "D:\Data\paper\Stop_last2"};
Go_accuracy_first = zeros(22,2); NoGo_accuracy_first = zeros(22,2); Both_accuracy_first = zeros(22,2);
Go_accuracy_last = zeros(22,2); NoGo_accuracy_last = zeros(22,2); Both_accuracy_last = zeros(22,2);
d_prime_first = zeros(22,2); d_prime_last = zeros(22,2);
mice_num = 0;

for folder = 1:2
    folderPath = path{folder};
    cd(folderPath)

    list = dir('*.mat');
    list = natsortfiles({list.name});
    
    for mice = 1:length(list)/2
        for k = 2*mice-1:2*mice
            load(list{k});
            
            % 最初の200 trial
            TrueSide_first = TrueSide(1:200); Outcome_first = Outcome(1:200); ChosenSide_first = ChosenSide(1:200); SelfInitiated_first = SelfInitiated(1:200);
            % 最後の200 trial
            TrueSide_last = TrueSide(end-199:end); Outcome_last = Outcome(end-199:end); ChosenSide_last = ChosenSide(end-199:end); SelfInitiated_last = SelfInitiated(end-199:end);

            % 最初の200 trial
            Go_accuracy_first(mice_num+mice,k-2*mice+2)...
                = sum(TrueSide_first==0 & Outcome_first==2 & SelfInitiated_first==1)/sum(TrueSide_first==0 & Outcome_first>=1 & Outcome_first<=2 & SelfInitiated_first==1);
            NoGo_accuracy_first(mice_num+mice,k-2*mice+2)...
                = sum(TrueSide_first==1 & Outcome_first==1  & SelfInitiated_first==1)/sum(TrueSide_first==1 & Outcome_first>=1 & Outcome_first<=3 & Outcome_first~=2 & SelfInitiated_first==1);
            Both_accuracy_first(mice_num+mice,k-2*mice+2)...
                = sum(TrueSide_first==ChosenSide_first & Outcome_first~=4 & SelfInitiated_first==1)/sum(Outcome_first~=4 & SelfInitiated_first==1);
            h_rate = (sum(TrueSide_first==0 & Outcome_first==2 & SelfInitiated_first==1)+0.5)/(sum(TrueSide_first==0 & Outcome_first>=1 & Outcome_first<=2 & SelfInitiated_first==1)+1);
            f_rate = (sum(TrueSide_first==1 & Outcome_first==1 & SelfInitiated_first==1)+0.5)/(sum(TrueSide_first==1 & Outcome_first>=1 & Outcome_first<=3 & Outcome_first~=2 & SelfInitiated_first==1)+1);
            d_prime_first(mice_num+mice,k-2*mice+2) = norminv(h_rate) - norminv(f_rate);

            % 最後の200 trial
            Go_accuracy_last(mice_num+mice,k-2*mice+2)...
                = sum(TrueSide_last==0 & Outcome_last==2 & SelfInitiated_last==1)/sum(TrueSide_last==0 & Outcome_last>=1 & Outcome_last<=2 & SelfInitiated_last==1);
            NoGo_accuracy_last(mice_num+mice,k-2*mice+2)...
                = sum(TrueSide_last==1 & Outcome_last==1 & SelfInitiated_last==1)/sum(TrueSide_last==1 & Outcome_last>=1 & Outcome_last<=3 & Outcome_last~=2 & SelfInitiated_last==1);
            Both_accuracy_last(mice_num+mice,k-2*mice+2)...
                = sum(TrueSide_last==ChosenSide_last & Outcome_last~=4 & SelfInitiated_last==1)/sum(Outcome_last~=4 & SelfInitiated_last==1);
            h_rate = (sum(TrueSide_last==0 & Outcome_last==2 & SelfInitiated_last==1)+0.5)/(sum(TrueSide_last==0 & Outcome_last>=1 & Outcome_last<=2 & SelfInitiated_last==1)+1);
            f_rate = (sum(TrueSide_last==1 & Outcome_last==1 & SelfInitiated_last==1)+0.5)/(sum(TrueSide_last==1 & Outcome_last>=1 & Outcome_last<=3 & Outcome_last~=2 & SelfInitiated_last==1)+1);
            d_prime_last(mice_num+mice,k-2*mice+2) = norminv(h_rate) - norminv(f_rate);
        end
    end
    if folder == 1
        mice_num = length(list)/2;
    end
end

%%%%%%%%%%
% 最初の200 trialと最後の200 trialの正答率
accuracy = [mean(Go_accuracy_first,2) mean(Go_accuracy_last,2) mean(NoGo_accuracy_first,2) mean(NoGo_accuracy_last,2)];
data_lick = accuracy(1:mice_num,:); data_stop = accuracy(mice_num+1:end,:);

p_ranksum = zeros(1,size(data_lick,2));
for i = 1:size(data_lick,2)
    p_ranksum(i) = ranksum(data_lick(:,i),data_stop(:,i));
end
p_ranksum

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
% early No-Goとlate No-Goとで差があるか
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
% early No-Goとlate No-Goとで差があるか
p_stop_Go = signrank(data_stop(:,1), data_stop(:,2))
p_stop_NoGo = signrank(data_stop(:,3), data_stop(:,4))

%%%%%%%%%%
% 最初の200 trialと最後の200 trialの正答率の差
diff_accuracy = Both_accuracy_last - Both_accuracy_first;
data_lick = mean(diff_accuracy(1:mice_num,:),2); data_stop = mean(diff_accuracy(mice_num+1:end,:),2);

figure('Position', [50 500 250 500]);
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
ylim([-0.1 0.2])
xticks(1:2)
yticks([-0.1 0 0.1 0.2])
grid on;
box off;
set(gca,'XGrid','off','YGrid','on','TickDir','out','LineWidth',1.5)
hold off;

p = ranksum(data_lick,data_stop)

return