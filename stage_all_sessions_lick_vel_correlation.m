function stage_all_sessions_lick_vel_correlation

path = "D:\Data\paper\first2";
cd(path)

list = dir('*.mat');
list = natsortfiles({list.name});

licking = [];
velocity = [];
R = zeros(22,1);

for mice = 1:length(list)/2
    lick_hist = [];
    velocity_hist = [];

    % 刺激後から
    for k = 2*mice-1:2*mice
        load(list{k});
        bin_width = 0.2*sampling_rate;
        % 刺激提示から、刺激提示後1sまでのLick, Velocity
        mean_vel_trial = zeros(size(trial_start,2), 1);
        lick_trial = zeros(size(trial_start,2), 15);
        velocity_trial = zeros(size(trial_start,2), 15);
        for i = 1:size(trial_start,2)
            % Lick
            temp_lick = lick(lick>trial_start(i) & lick<trial_end(i))-stim_onset(i);
            lick_trial(i,:) = arrayfun(@(j) sum(temp_lick>=-sampling_rate+(j-1)*bin_width+1-0.05*sampling_rate & temp_lick<-sampling_rate+j*bin_width-0.05*sampling_rate), 1:15);
            % Velocity
            mean_vel_trial(i) = mean(direction(1,stim_onset(i)+1-0.85*sampling_rate:stim_onset(i)-0.65*sampling_rate));
            temp_vel = direction(1,stim_onset(i)-sampling_rate+1-0.05*sampling_rate:stim_onset(i)+2*sampling_rate-0.05*sampling_rate);
            velocity_trial(i,:) = arrayfun(@(j) mean(temp_vel((j-1)*bin_width+1 : j*bin_width)), 1:15);
        end

        % Free trialのみを解析に使用
        lick_hist = [lick_hist; lick_trial(TrueSide==0 & SelfInitiated==1 & Outcome==4,:)];
        velocity_hist = [velocity_hist; velocity_trial(TrueSide==0 & SelfInitiated==1 & Outcome==4,:)/mean(mean_vel_trial,1)];
    end

    av_lick_hist = mean(zscore(lick_hist,0,'all'),1); av_velocity_hist = mean(zscore(velocity_hist,0,'all'),1);
    licking = [licking; av_lick_hist]; velocity = [velocity; av_velocity_hist];
    x = av_lick_hist(:); y = av_velocity_hist(:);
    [r,~] = corrcoef(x,y);
    R(mice) = r(1,2);
end

% X = licking(:); Y = velocity(:);
% [r,p] = corrcoef(X,Y);
% 
% figure('Position',[50 500 500 500]);
% hold on;
% scatter(X,Y,50,[0.75 0.75 0.75],'filled')
% coefficients = polyfit(X,Y, 1); % 一次の多項式回帰 (y = ax + b)
% Y_fit = polyval(coefficients, X); % 回帰直線のy値を計算
% plot(X, Y_fit,'LineWidth',2.5,'Color','k'); % 回帰直線
% xticks(-1:1)
% yticks(-2:1)
% box off;
% set(gca,'TickDir','out','LineWidth',1.5)
% hold off;
% 
% disp(mean(R));
% disp(r(1,2));
% disp(p(1,2));

%%
T = table();
T.mouse_id = categorical(repmat((1:22)',15, 1));
T.bin_id    = categorical(repelem((1:15)',22));
T.lick_z    = licking(:);
T.vel_z     = velocity(:);

lme = fitlme(T, 'vel_z ~ lick_z + (1|mouse_id)');
lme.Coefficients

X = licking(:); Y = velocity(:);
figure('Position',[50 500 500 500]);
hold on;
scatter(X,Y,50,[0.75 0.75 0.75],'filled')
a = lme.Coefficients.Estimate(2); b = lme.Coefficients.Estimate(1);
Y_fit = polyval([a,b], X); % 回帰直線のy値を計算
plot(X, Y_fit,'LineWidth',2.5,'Color','k'); % 回帰直線
xticks(-1:1)
yticks(-2:1)
box off;
set(gca,'TickDir','out','LineWidth',1.5)
hold off;

return