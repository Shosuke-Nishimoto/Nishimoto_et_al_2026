function stage_all_sessions_velocity
% NoGo first2
% path = {"D:\Data\paper\Lick_NoGo_first2", "D:\Data\paper\Stop_NoGo_first2"};
% last2
path = {"D:\Data\paper\Lick_last2", "D:\Data\paper\Stop_last2"};
duration = -0.9:0.2:0.9;
Go_velocity = zeros(22,10,2); NoGo_velocity = zeros(22,10,2);
mice_num = 0;

for folder = 1:2
    folderPath = path{folder};
    cd(folderPath)

    list = dir('*.mat');
    list = natsortfiles({list.name});
    
    for mice = 1:length(list)/2
        for k = 2*mice-1:2*mice
            load(list{k});
            % 刺激提示前1.05sから、刺激提示後0.95sまでの速度
            mean_vel_trial = zeros(size(trial_start,2), 1);
            velocity_trial = zeros(size(trial_start,2), 2*sampling_rate);
            for i = 1:size(trial_start,2)
                mean_vel_trial(i) = mean(direction(1,stim_onset(i)+1-0.85*sampling_rate:stim_onset(i)-0.65*sampling_rate));
                velocity_trial(i,:) = direction(1,stim_onset(i)-1.05*sampling_rate+1:stim_onset(i)+0.95*sampling_rate);
            end

            % for go
            vel_go = velocity_trial(TrueSide==0 & SelfInitiated==1,:);
            temp_vel = mean(vel_go,1)/mean(mean_vel_trial,1);
            bin_width = 0.2*sampling_rate;
            num_bins = size(temp_vel, 2) / bin_width;
            temp_vel = arrayfun(@(i) mean(temp_vel((i-1)*bin_width+1 : i*bin_width)), 1:num_bins);

            Go_velocity(mice_num+mice,:,k-2*mice+2) = temp_vel;

            % for nogo
            vel_nogo = velocity_trial(TrueSide==1 & SelfInitiated==1,:);
            temp_vel = mean(vel_nogo,1)/mean(mean_vel_trial,1);
            bin_width = 0.2*sampling_rate;
            num_bins = size(temp_vel, 2) / bin_width;
            temp_vel = arrayfun(@(i) mean(temp_vel((i-1)*bin_width+1 : i*bin_width)), 1:num_bins);

            NoGo_velocity(mice_num+mice,:,k-2*mice+2) = temp_vel;
        end
    end
    if folder == 1
        mice_num = length(list)/2;
    end
end

Go_velocity_mice = mean(Go_velocity,3); NoGo_velocity_mice = mean(NoGo_velocity,3);

%%%%%%%%%%
% Lick
Go_velocity_mice_lick = Go_velocity_mice(1:mice_num,:);
NoGo_velocity_mice_lick = NoGo_velocity_mice(1:mice_num,:);

mean_values_vel = [mean(Go_velocity_mice_lick,1); mean(NoGo_velocity_mice_lick,1)];
se_dev_vel = [std(Go_velocity_mice_lick,0,1)/sqrt(size(Go_velocity_mice_lick,1));...
                std(NoGo_velocity_mice_lick,0,1)/sqrt(size(NoGo_velocity_mice_lick,1))];

rate_lick = (NoGo_velocity_mice_lick-Go_velocity_mice_lick)./(NoGo_velocity_mice_lick+Go_velocity_mice_lick);

figure('Position', [50 500 650 500]);
c = [0.980,0.541,0.831; 0.368,0.133,0.588];
hold on;
xline(0,'--','LineWidth',1.5,'Color','k');
% fill([duration, fliplr(duration)],...
%     [mean_values_vel(1,:)+se_dev_vel(1,:), fliplr(mean_values_vel(1,:)-se_dev_vel(1,:))],...
%     [0.8, 0.8, 1], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
plot(duration, mean_values_vel(1,:),...
    '-o', 'LineWidth', 3, 'MarkerSize', 5, 'Color', c(1,:), 'MarkerFaceColor', c(1,:));
errorbar(duration, mean_values_vel(1,:),se_dev_vel(1,:),...
    'Color',c(1,:),'LineStyle','none','LineWidth',3);
% fill([duration, fliplr(duration)],...
%     [mean_values_vel(2,:)+se_dev_vel(2,:), fliplr(mean_values_vel(2,:)-se_dev_vel(2,:))],...
%     [1, 0.7, 0.7], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
plot(duration, mean_values_vel(2,:),...
    '-o', 'LineWidth', 3, 'MarkerSize', 5, 'Color', c(2,:), 'MarkerFaceColor', c(2,:));
errorbar(duration, mean_values_vel(2,:),se_dev_vel(2,:),...
    'Color',c(2,:),'LineStyle','none','LineWidth',3);
xlim([-1 1])
ylim([-0.05 1.1]);
xticks(-1:1)
yticks([0 0.5 1])
box off;
set(gca,'TickDir','out','LineWidth',1.5)
hold off;

%%%%%%%%%%
% Stop
Go_velocity_mice_stop = Go_velocity_mice(mice_num+1:end,:);
NoGo_velocity_mice_stop = NoGo_velocity_mice(mice_num+1:end,:);

mean_values_vel = [mean(Go_velocity_mice_stop,1); mean(NoGo_velocity_mice_stop,1)];
se_dev_vel = [std(Go_velocity_mice_stop,0,1)/sqrt(size(Go_velocity_mice_stop,1));...
                std(NoGo_velocity_mice_stop,0,1)/sqrt(size(NoGo_velocity_mice_stop,1))];

rate_stop = (NoGo_velocity_mice_stop-Go_velocity_mice_stop)./(NoGo_velocity_mice_stop+Go_velocity_mice_stop);

figure('Position', [50 500 650 500]);
c = [0.286,0.858,0.250; 0.007,0.345,0.054];
hold on;
xline(0,'--','LineWidth',1.5,'Color','k');
% fill([duration, fliplr(duration)],...
%     [mean_values_vel(1,:)+se_dev_vel(1,:), fliplr(mean_values_vel(1,:)-se_dev_vel(1,:))],...
%     [0.8, 0.8, 1], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
plot(duration, mean_values_vel(1,:),...
    '-o', 'LineWidth', 3, 'MarkerSize', 5, 'Color', c(1,:), 'MarkerFaceColor', c(1,:));
errorbar(duration, mean_values_vel(1,:),se_dev_vel(1,:),...
    'Color',c(1,:),'LineStyle','none','LineWidth',3);
% fill([duration, fliplr(duration)],...
%     [mean_values_vel(2,:)+se_dev_vel(2,:), fliplr(mean_values_vel(2,:)-se_dev_vel(2,:))],...
%     [1, 0.7, 0.7], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
plot(duration, mean_values_vel(2,:),...
    '-o', 'LineWidth', 3, 'MarkerSize', 5, 'Color', c(2,:), 'MarkerFaceColor', c(2,:));
errorbar(duration, mean_values_vel(2,:),se_dev_vel(2,:),...
    'Color',c(2,:),'LineStyle','none','LineWidth',3);
xlim([-1 1])
ylim([-0.05 1.1]);
xticks(-1:1)
yticks([0 0.5 1])
box off;
set(gca,'TickDir','out','LineWidth',1.5)
hold off;

%%%%%%%%%%
c = 10;
p_Go = ranksum(Go_velocity_mice_lick(:,c),Go_velocity_mice_stop(:,c))
p_NoGo = ranksum(NoGo_velocity_mice_lick(:,c),NoGo_velocity_mice_stop(:,c))

x = Go_velocity_mice_lick(:,c);
sem = std(x)/sqrt(numel(x)); d = max(0, 1 - floor(log10(sem)));
fprintf('Go   Lick mean %.*f  standard error %.*f (n=%d)\n', d, mean(x), d, sem, numel(x));

x = NoGo_velocity_mice_lick(:,c);
sem = std(x)/sqrt(numel(x)); d = max(0, 1 - floor(log10(sem)));
fprintf('NoGo Lick mean %.*f  standard error %.*f (n=%d)\n', d, mean(x), d, sem, numel(x));

x = Go_velocity_mice_stop(:,c);
sem = std(x)/sqrt(numel(x)); d = max(0, 1 - floor(log10(sem)));
fprintf('Go   Stop mean %.*f  standard error %.*f (n=%d)\n', d, mean(x), d, sem, numel(x));

x = NoGo_velocity_mice_stop(:,c);
sem = std(x)/sqrt(numel(x)); d = max(0, 1 - floor(log10(sem)));
fprintf('NoGo Stop mean %.*f  standard error %.*f (n=%d)\n', d, mean(x), d, sem, numel(x));

return