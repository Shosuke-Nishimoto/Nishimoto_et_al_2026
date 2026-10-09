function stage1_all_sessions_lick

path = 'D:\Data\paper\first2';
cd(path)

list = dir('*.mat');
list = natsortfiles({list.name});

duration = -0.9:0.2:1.9;
Free_lick = zeros(22,15,2);

for mice = 1:length(list)/2
    for k = 2*mice-1:2*mice
        load(list{k});
        bin_width = 0.2*sampling_rate;
        lick_trial = zeros(size(trial_start,2), 15);
        for i = 1:size(trial_start,2)
            % trial 内の lick を、刺激 onset からのサンプル番号にする。
            % ビン端は lick_vel_correlation.m と同じ。j=1 が [-1.05, -0.85) s。
            temp_lick = lick(lick>trial_start(i) & lick<trial_end(i))-stim_onset(i);
            lick_trial(i,:) = arrayfun(@(j) sum( ...
                temp_lick>=-sampling_rate+(j-1)*bin_width+1-0.05*sampling_rate & ...
                temp_lick<-sampling_rate+j*bin_width-0.05*sampling_rate), 1:15);
        end

        % Free trialのみ
        lick_free = lick_trial(TrueSide==0 & SelfInitiated==1 & Outcome==4,:);
        Free_lick(mice,:,k-2*mice+2) = mean(lick_free,1);
    end
end

Free_lick_mice = mean(Free_lick,3);

mean_values_lick = mean(Free_lick_mice,1);
se_dev_lick = std(Free_lick_mice,0,1)/sqrt(size(Free_lick_mice,1));

figure('Position', [750 500 650 500]);
hold on;
xline(0,'--','LineWidth',1.5,'Color','k');
xline(1,'-','LineWidth',1.5,'Color','k');
plot(duration, mean_values_lick,...
    '-o', 'LineWidth', 3, 'MarkerSize', 5, 'Color', 'k', 'MarkerFaceColor', 'k');
errorbar(duration, mean_values_lick, se_dev_lick,...
    'Color','k','LineStyle','none','LineWidth',3);
xlim([-1 2])
xticks(-1:2)
ylim([0 2])
yticks(0:2)
box off;
set(gca,'TickDir','out','LineWidth',1.5)
hold off;

end
