function make_boxplot_trial_type(mouse_num_1,mouse_num_2,data_Go,data_NoGo,plt,violin,lim)
data_both = [data_Go data_NoGo];
data_1 = data_both(1:mouse_num_1,:);
data_2 = data_both(mouse_num_1+1:mouse_num_1+mouse_num_2,:);

figure('Position',[50 500 650 500]);
hold on;
data = [data_1(:); data_2(:)];
col_1 = repmat(1:2, mouse_num_1, 1);
col_2 = repmat(1:2, mouse_num_2, 1);
colGroup = [col_1(:); col_2(:)];
condGroup = [ ...
    ones(numel(data_1),1); ...
    2*ones(numel(data_2),1)];
groupID = (condGroup - 1) * 2 + colGroup;

if violin==1
    v = violinplot(groupID,data);
    v(1).FaceColor = [0.3010 0.7450 0.9330];
end
if plt==1
    for i = 1:mouse_num_1
        plot([1;2],[data_1(i,1),data_1(i,2)],'Color',[0.75 0.75 0.75],'LineWidth',2.5)
        % scatter([1;2],[data_1(i,1),data_1(i,2)],10,'k','filled')
    end
    for i = 1:mouse_num_2
        plot([3;4],[data_2(i,1),data_2(i,2)],'Color',[0.75 0.75 0.75],'LineWidth',2.5)
        % scatter([3;4],[data_2(i,1),data_2(i,2)],10,'k','filled')
    end
end 
% boxplot(data, groupID,'Colors','rb','Widths',0.5,'Whisker',inf);
boxchart(groupID,data,'BoxWidth',0.5,...
        'BoxFaceColor','none','BoxEdgeColor','k','BoxMedianLineColor','k','WhiskerLineColor','k',...
        'MarkerStyle','+','MarkerSize',10,'MarkerColor','k','LineWidth',3);
xticks(1:4)
xticklabels(repelem(1:2,2))
yticks(0:0.5:1)
xline(2 + 0.5, ':','LineWidth',1.5);
xlim([0.5 4.5])
ylim(lim)
box off;
set(gca,'TickDir','out','LineWidth',1.5)
hold off;

return