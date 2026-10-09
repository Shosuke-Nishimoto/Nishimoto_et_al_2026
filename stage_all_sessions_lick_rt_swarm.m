function stage_all_sessions_lick_rt_swarm

% NoGo first2
% path = {"D:\Data\paper\Lick_NoGo_first2", "D:\Data\paper\Stop_NoGo_first2"};
% last2
path = {"D:\Data\paper\Lick_last2", "D:\Data\paper\Stop_last2"};

Go_rt_lick = []; Go_rt_stop = [];
NoGo_rt_lick = []; NoGo_rt_stop = [];

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
                rt(i) = min([lick_plot2(rt_ind,2),2*sampling_rate]); % 刺激提示後2s以内になめなかった場合は0.95sとする
            end
            rt = rt/sampling_rate;
            
            temp_go = rt(rt<2 & TrueSide==0 & SelfInitiated==1);
            temp_nogo = rt(rt<2 & TrueSide==1 & SelfInitiated==1);
            if folder==1
                Go_rt_lick = [Go_rt_lick temp_go];
                NoGo_rt_lick = [NoGo_rt_lick temp_nogo];
            else
                Go_rt_stop = [Go_rt_stop temp_go]; 
                NoGo_rt_stop = [NoGo_rt_stop temp_nogo];
            end
        end
    end
end

%%%%%%%%%%
% Lick
figure('Position', [50 500 650 500]);
c = [0.980,0.541,0.831; 0.368,0.133,0.588];
hold on;
yline(0,'--','LineWidth',1.5,'Color','k');
yline(1,'-','LineWidth',1.5,'Color','k');
swarmchart(2*ones(length(Go_rt_lick),1),Go_rt_lick,2.5,c(1,:),'filled');
swarmchart(ones(length(NoGo_rt_lick),1),NoGo_rt_lick,2.5,c(2,:),'filled');
ylim([-0.1 2.1]);
xticks(1:2)
yticks(0:2)
view([90 -90]);  % xとyの役割を視覚的に入れ替える
box off;
set(gca,'TickDir','out','LineWidth',1.5)
hold off;

% Stop
figure('Position', [50 500 650 500]);
c = [0.286,0.858,0.250; 0.007,0.345,0.054];
hold on;
yline(0,'--','LineWidth',1.5,'Color','k');
yline(1,'-','LineWidth',1.5,'Color','k');
swarmchart(2*ones(length(Go_rt_stop),1),Go_rt_stop,2.5,c(1,:),'filled');
swarmchart(ones(length(NoGo_rt_stop),1),NoGo_rt_stop,2.5,c(2,:),'filled');
ylim([-0.1 2.1]);
xticks(1:2)
yticks(0:2)
view([90 -90]);  % xとyの役割を視覚的に入れ替える
box off;
set(gca,'TickDir','out','LineWidth',1.5)
hold off;

return