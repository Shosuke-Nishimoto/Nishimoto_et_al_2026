function lick_vel_correlation_trial

path = "D:\Data\paper\first2";
cd(path)

list = dir('*.mat');
list = natsortfiles({list.name});

licking = [];
velocity = [];
mouse_id = [];

for mice = 1:length(list)/2
    lick_hist = [];
    velocity_hist = [];

    % 刺激前から刺激提示後まで
    for k = 2*mice-1:2*mice
        load(list{k});
        % 刺激提示前1sから、刺激提示後2sまでのLick, Velocity
        mean_vel_trial = zeros(size(trial_start,2), 1);
        lick_trial = zeros(size(trial_start,2), 1);
        velocity_trial = zeros(size(trial_start,2), 1);
        for i = 1:size(trial_start,2)
            % Lick
            temp_lick = lick(lick>trial_start(i) & lick<trial_end(i))-stim_onset(i);
            lick_trial(i) = sum(temp_lick>=-sampling_rate+1-0.05*sampling_rate & temp_lick<2*sampling_rate-0.05*sampling_rate);
            % Velocity
            mean_vel_trial(i) = mean(direction(1,stim_onset(i)+1-0.85*sampling_rate:stim_onset(i)-0.65*sampling_rate));
            temp_vel = direction(1,stim_onset(i)-sampling_rate+1-0.05*sampling_rate:stim_onset(i)+2*sampling_rate-0.05*sampling_rate);
            velocity_trial(i) = mean(temp_vel);
        end

        % Free trialのみを解析に使用
        lick_hist = [lick_hist; lick_trial(TrueSide==0 & SelfInitiated==1 & Outcome==4)];
        velocity_hist = [velocity_hist; velocity_trial(TrueSide==0 & SelfInitiated==1 & Outcome==4)/mean(mean_vel_trial,1)];
    end

    licking = [licking; zscore(lick_hist,0)]; velocity = [velocity; zscore(velocity_hist,0)];
    mouse_id = [mouse_id; repmat(mice, size(lick_hist,1), 1)];
end

%%
T = table();
T.mouse_id = categorical(mouse_id);
T.lick_z = licking;
T.vel_z = velocity;

lme = fitlme(T, 'vel_z ~ lick_z + (1|mouse_id)');
lme.Coefficients

X = licking(:); Y = velocity(:);
figure('Position',[50 500 500 500]);
hold on;
scatter(X,Y,15,[0.75 0.75 0.75],'filled')
a = lme.Coefficients.Estimate(2); b = lme.Coefficients.Estimate(1);
x_line = linspace(min(X),max(X),100);
plot(x_line, polyval([a,b], x_line),'LineWidth',2.5,'Color','k');
xlim([-5 5])
ylim([-5 5])
xticks([-4 0 4])
yticks([-4 0 4])
box off;
set(gca,'TickDir','out','LineWidth',1.5)
hold off;

return