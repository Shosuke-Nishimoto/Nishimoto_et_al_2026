function raster_plot
% 50ms程度ずれている可能性あり

path = {"D:\Data\paper\Lick_NoGo_first2\S112_NoGo_first1.mat",...
        "D:\Data\paper\Lick_last2\S112_last1.mat",...
        "D:\Data\paper\Stop_NoGo_first2\S102_NoGo_first1.mat",...
        "D:\Data\paper\Stop_last2\S102_last1.mat"};

for file = 1:length(path)
    load(path{file})
    % 全体
    lick_plot = [];
    for i = 1:size(trial_start,2)
        temp_lick = lick(lick>trial_start(i) & lick<trial_end(i));
        for j = 1:size(temp_lick,2)
            lick_plot(end+1,:) = [i,temp_lick(j)-stim_onset(i)];
        end
    end

    % for Go
    id_go = find(TrueSide==0 & SelfInitiated==1);
    lick_plot_go = lick_plot(ismember(lick_plot(:,1),id_go),:);
    [~, ~, rank_ind_go] = unique(lick_plot_go(:,1));
    
    % for No-Go
    id_nogo = find(TrueSide==1 & SelfInitiated==1);
    lick_plot_nogo = lick_plot(ismember(lick_plot(:,1),id_nogo),:);
    [~, ~, rank_ind_nogo] = unique(lick_plot_nogo(:,1));
    
    if file<3
        c = [0.980,0.541,0.831; 0.368,0.133,0.588];
    else
        c = [0.286,0.858,0.250; 0.007,0.345,0.054];
    end

    figure('Position',[50 500 500 200]);
    hold on;
    xline(0,'--','LineWidth',1.5,'Color','k');
    xline(1,'-','LineWidth',1.5,'Color','k');
    scatter(lick_plot_go(:,2)/sampling_rate,rank_ind_go,2.5,c(1,:),"filled")
    set(gca,'YDir','reverse');
    xlim([-1 3])
    ylim([1 size(id_go,2)])
    xticks(-1:3)
    yticks([100 200 300 400])
    box off;
    set(gca,'TickDir','out','LineWidth',1.5)
    hold off;
    
    figure('Position',[50 500 500 200]);
    hold on;
    xline(0,'--','LineWidth',1.5,'Color','k');
    xline(1,'-','LineWidth',1.5,'Color','k');
    scatter(lick_plot_nogo(:,2)/sampling_rate,rank_ind_nogo,2.5,c(2,:),"filled")
    set(gca,'YDir','reverse');
    xlim([-1 3])
    ylim([1 size(id_nogo,2)])
    xticks(-1:3)
    yticks([100 200 300 400])
    box off;
    set(gca,'TickDir','out','LineWidth',1.5)
    hold off;
end

end