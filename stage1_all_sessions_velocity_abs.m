function stage1_all_sessions_velocity_abs

path = 'D:\Data\paper\first2';
cd(path)

list = dir('*.mat');
list = natsortfiles({list.name});

duration = -0.9:0.2:1.9;
Free_velocity = zeros(22,15,2);

for mice = 1:length(list)/2
    for k = 2*mice-1:2*mice
        load(list{k});
        % 刺激提示前1.05sから、刺激提示後1.95sまでの速度
        velocity_trial = zeros(size(trial_start,2), 3*sampling_rate);
        for i = 1:size(trial_start,2)
            velocity_trial(i,:) = direction(1,stim_onset(i)-1.05*sampling_rate+1:stim_onset(i)+1.95*sampling_rate);
        end

        % Free trialのみ
        vel_free = velocity_trial(TrueSide==0 & SelfInitiated==1 & Outcome==4,:);
        bin_width = 0.2*sampling_rate;
        num_bins = size(vel_free, 2) / bin_width;
        temp_vel = zeros(1, num_bins);
        for b = 1:num_bins
            seg = vel_free(:, (b-1)*bin_width+1 : b*bin_width);
            temp_vel(b) = mean_bin_cm_per_s(seg, sampling_rate);
        end

        Free_velocity(mice,:,k-2*mice+2) = temp_vel;
    end
end

Free_velocity_mice = mean(Free_velocity,3);

mean_values_vel = mean(Free_velocity_mice,1);
se_dev_vel = std(Free_velocity_mice,0,1)/sqrt(size(Free_velocity_mice,1));

figure('Position', [50 500 650 500]);
hold on;
xline(0,'--','LineWidth',1.5,'Color','k');
xline(1,'-','LineWidth',1.5,'Color','k');
yline(5,'-','LineWidth',1.5,'Color',[0.4 0.4 0.4]);
plot(duration, mean_values_vel,...
    '-o', 'LineWidth', 3, 'MarkerSize', 5, 'Color', 'k', 'MarkerFaceColor', 'k');
errorbar(duration, mean_values_vel, se_dev_vel,...
    'Color','k','LineStyle','none','LineWidth',3);
xlim([-1 2])
xticks(-1:2)
ylim([0 40])
yticks([0 5 20 40])
box off;
set(gca,'TickDir','out','LineWidth',1.5)
hold off;

end

function cm = mean_bin_cm_per_s(seg, fs)
% 試行ごとに cm/s にしてから平均する。direction を先に平均すると符号が消える。
% ±1 は 1 エッジ、±2 は 2 エッジ、3 は +3。RPS = エッジ数 / 秒 / 1440。cm/s = RPS × 25。
n_trial = size(seg,1);
cm_trial = zeros(n_trial,1);
for t = 1:n_trial
    d = seg(t,:);
    edge = zeros(size(d));
    edge(d==1) = 1;
    edge(d==-1) = -1;
    edge(d==2) = 2;
    edge(d==-2) = -2;
    edge(d==3) = 3;
    rps = sum(edge) / (length(d)/fs) / 1440;
    cm_trial(t) = rps * 25;
end
cm = mean(cm_trial);
end
