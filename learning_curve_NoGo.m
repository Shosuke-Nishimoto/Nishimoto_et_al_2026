function learning_curve_NoGo
%%%%%%%%%%
% Lick Group
lick_path = {"D:\Data\paper\Lick\S72"
                "D:\Data\paper\Lick\S74"
                "D:\Data\paper\Lick\S76"
                "D:\Data\paper\Lick\S84"
                "D:\Data\paper\Lick\S85"
                "D:\Data\paper\Lick\S88"
                "D:\Data\paper\Lick\S90"
                "D:\Data\paper\Lick\S97"
                "D:\Data\paper\Lick\S99"
                "D:\Data\paper\Lick\S104"
                "D:\Data\paper\Lick\S107"
                "D:\Data\paper\Lick\S112"};
lick_session_number = zeros(1,length(lick_path));
lick_nogo_session_number = zeros(1,length(lick_path));

data_table_lick = table();
for i = 1:length(lick_path)
    folderPath = lick_path{i};
    cd(folderPath)
    % フォルダ内の内容を取得
    files = dir(folderPath);
    % フォルダのみを抽出（. と .. を除外）
    isFolder = [files.isdir];
    folderNames = {files(isFolder).name};
    folderNames = folderNames(~ismember(folderNames, {'.', '..'}));
    lick_session_number(i) = length(folderNames);

    dates = NaT(1,length(folderNames));
    sessions = zeros(1,length(folderNames));
    % sortするため
    for j = 1:length(folderNames)
        fname = folderNames{j};
        % date
        dateToken = regexp(fname, '(?<dt>[A-Z][a-z]{2}\d{2}_\d{4})', 'names');
        dates(j) = datetime(dateToken.dt, 'InputFormat', 'MMMdd_yyyy', 'Locale', 'en_US');
        % session
        sessToken = regexp(fname, 'Session(\d+)', 'tokens', 'once');
        sessions(j) = str2double(sessToken{1});
    end

    %=== 日付 → Session番号 の順でソート ===%
    [~, idx] = sortrows([datenum(dates)', sessions']);
    sortedfolderNames = folderNames(idx);

    accuracy = [];
    for j = 1:length(sortedfolderNames)
        cd(sortedfolderNames{j})
        load('Bpod_NI.mat')
        if sum(TrueSide==1)~=0
            lick_nogo_session_number(i) = lick_nogo_session_number(i)+1;
            NoGo_accuracy = sum(TrueSide==1 & Outcome==1 & SelfInitiated==1)/sum(TrueSide==1 & Outcome>=1 & Outcome<=3 & Outcome~=2 & SelfInitiated==1);
            accuracy = [accuracy; 1-NoGo_accuracy];
        end
        cd('..')
    end
    % tableに格納
    data_table_lick(1,i) = {accuracy};
end

figure('Position', [50 500 500 500]);
hold on;
yline(0.5,':','LineWidth',1.5,'Color','k');
[~,idx_lick] = sort(lick_nogo_session_number);
colors = [linspace(0.980,0.368,length(idx_lick))',...
            linspace(0.541,0.133,length(idx_lick))',...
            linspace(0.831,0.588,length(idx_lick))'];
for i = 1:length(idx_lick)
    c = colors(i,:);
    data = data_table_lick{1,idx_lick(end-i+1)}{:};
    plot(data,'Color',c,'LineWidth',3);
    scatter(1:length(data)-2,data(1:end-2),25,c,"filled");
    scatter([length(data)-1 length(data)],[data(end-1) data(end)],...
            50,[0 0 0],'d','LineWidth',3);
end
xlim([0 75])
ylim([0 1])
xticks(0:25:75)
yticks([0 0.5 1])
box off;
set(gca,'TickDir','out','LineWidth',1.5)
hold off;

%%%%%%%%%%
% Stop Group
stop_path = {"D:\Data\paper\Stop\S80"
                "D:\Data\paper\Stop\S83"
                "D:\Data\paper\Stop\S86"
                "D:\Data\paper\Stop\S89"
                "D:\Data\paper\Stop\S93"
                "D:\Data\paper\Stop\S94"
                "D:\Data\paper\Stop\S100"
                "D:\Data\paper\Stop\S102"
                "D:\Data\paper\Stop\S103"
                "D:\Data\paper\Stop\S105"};
stop_session_number = zeros(1,length(stop_path));
stop_nogo_session_number = zeros(1,length(stop_path));

data_table_stop = table();
for i = 1:length(stop_path)
    folderPath = stop_path{i};
    cd(folderPath)
    % フォルダ内の内容を取得
    files = dir(folderPath);
    % フォルダのみを抽出（. と .. を除外）
    isFolder = [files.isdir];
    folderNames = {files(isFolder).name};
    folderNames = folderNames(~ismember(folderNames, {'.', '..'}));
    stop_session_number(i) = length(folderNames);

    dates = NaT(1,length(folderNames));
    sessions = zeros(1,length(folderNames));
    % sortするため
    for j = 1:length(folderNames)
        fname = folderNames{j};
        % date
        dateToken = regexp(fname, '(?<dt>[A-Z][a-z]{2}\d{2}_\d{4})', 'names');
        dates(j) = datetime(dateToken.dt, 'InputFormat', 'MMMdd_yyyy', 'Locale', 'en_US');
        % session
        sessToken = regexp(fname, 'Session(\d+)', 'tokens', 'once');
        sessions(j) = str2double(sessToken{1});
    end

    %=== 日付 → Session番号の順でソート ===%
    [~, idx] = sortrows([datenum(dates)', sessions']);
    sortedfolderNames = folderNames(idx);

    accuracy = [];
    for j = 1:length(sortedfolderNames)
        cd(sortedfolderNames{j})
        load('Bpod_NI.mat')
        if sum(TrueSide==1)~=0
            stop_nogo_session_number(i) = stop_nogo_session_number(i)+1;
            NoGo_accuracy = sum(TrueSide==1 & Outcome==1 & SelfInitiated==1)/sum(TrueSide==1 & Outcome>=1 & Outcome<=3 & Outcome~=2 & SelfInitiated==1);
            accuracy = [accuracy; 1-NoGo_accuracy];
        end
        cd('..')
    end
    % tableに格納
    data_table_stop(1,i) = {accuracy};
end
hold off;

figure('Position', [50 500 500 500]);
hold on;
yline(0.5,':','LineWidth',1.5,'Color','k');
[~,idx_stop] = sort(stop_nogo_session_number);
colors = [linspace(0.286,0.007,length(idx_stop))',...
            linspace(0.858,0.345,length(idx_stop))',...
            linspace(0.250,0.054,length(idx_stop))'];
for i = 1:length(idx_stop)
    c = colors(i,:);
    data = data_table_stop{1,idx_stop(end-i+1)}{:};
    plot(data,'Color',c,'LineWidth',3);
    scatter(1:length(data)-2,data(1:end-2),25,c,"filled");
    scatter([length(data)-1 length(data)],[data(end-1) data(end)],...
            50,[0 0 0],'d','LineWidth',3);
end
xlim([0 75])
ylim([0 1])
xticks(0:25:75)
yticks([0 0.5 1])
box off;
set(gca,'TickDir','out','LineWidth',1.5)
hold off;

%%%%%%%%%%
% Total Sessions
p_total = ranksum(lick_session_number,stop_session_number)

% Histogram Lick & Stop
edges = 0:15:90;
counts_lick = histcounts(lick_session_number,edges);
counts_stop = histcounts(stop_session_number,edges);
centers = edges(1:end-1) + diff(edges)/2;

figure('Position', [50 500 500 500]);
c = [0.521,0.086,0.819; 0.231,0.666,0.196];
hold on;
bar(centers,counts_lick,'FaceColor',c(1,:),'EdgeColor','k','LineWidth',1.5);
bar(centers,-counts_stop,'FaceColor',c(2,:),'EdgeColor','k','LineWidth',1.5);
xlim([0 90])
ylim([-5 5])
xticks(0:30:90)
yticks(-4:2:4)
box off;
set(gca,'XGrid','off','YGrid','on','TickDir','out','LineWidth',1.5)
hold off;

% Boxplot Both
figure('Position', [50 500 250 500]);
hold on;
data = [lick_session_number(:); stop_session_number(:)];
group = [ones(length(lick_session_number),1);...
            2*ones(length(stop_session_number),1)];
swarmchart(group',data',20,'k','filled');
boxchart(group,data,'BoxWidth',0.5,...
        'BoxFaceColor','none','BoxEdgeColor','k','BoxMedianLineColor','k','WhiskerLineColor','k',...
        'MarkerStyle','none','LineWidth',3);
xlim([0.5 2.5])
ylim([0 85])
xticks(1:2)
grid on;
box off;
set(gca,'XGrid','off','YGrid','on','TickDir','out','LineWidth',1.5)
hold off;

%%%%%%%%%%
% Total No-Go Sessions
p_NoGo = ranksum(lick_nogo_session_number,stop_nogo_session_number)

% Histogram Lick & Stop
edges_nogo = 0:15:90;
counts_lick_nogo = histcounts(lick_nogo_session_number,edges);
counts_stop_nogo = histcounts(stop_nogo_session_number,edges);
centers_nogo = edges_nogo(1:end-1) + diff(edges_nogo)/2;

figure('Position', [50 500 500 500]);
c = [0.521,0.086,0.819; 0.231,0.666,0.196];
hold on;
bar(centers_nogo,counts_lick_nogo,'FaceColor',c(1,:),'EdgeColor','k','LineWidth',1.5);
bar(centers_nogo,-counts_stop_nogo,'FaceColor',c(2,:),'EdgeColor','k','LineWidth',1.5);
xlim([0 90])
ylim([-5 5])
xticks(0:30:90)
yticks(-4:2:4)
box off;
set(gca,'XGrid','off','YGrid','on','TickDir','out','LineWidth',1.5)
hold off;

% Boxplot
figure('Position', [50 500 250 500]);
hold on;
data = [lick_nogo_session_number(:); stop_nogo_session_number(:)];
group = [ones(length(lick_nogo_session_number),1);...
            2*ones(length(stop_nogo_session_number),1)];
swarmchart(group',data',20,'k','filled');
boxchart(group,data,'BoxWidth',0.5,...
        'BoxFaceColor','none','BoxEdgeColor','k','BoxMedianLineColor','k','WhiskerLineColor','k',...
        'MarkerStyle','none','LineWidth',3);
xlim([0.5 2.5])
ylim([0 85])
xticks(1:2)
grid on;
box off;
set(gca,'XGrid','off','YGrid','on','TickDir','out','LineWidth',1.5)
hold off;

%%%%%%%%%%
% Total Go Sessions
lick_go_session_number = lick_session_number-lick_nogo_session_number; stop_go_session_number = stop_session_number-stop_nogo_session_number;
p_Go = ranksum(lick_go_session_number,stop_go_session_number)

figure('Position', [50 500 250 500]);
hold on;
data = [lick_go_session_number(:); stop_go_session_number(:)];
group = [ones(length(lick_go_session_number),1);...
            2*ones(length(stop_go_session_number),1)];
swarmchart(group',data',20,'k','filled');
boxchart(group,data,'BoxWidth',0.5,...
        'BoxFaceColor','none','BoxEdgeColor','k','BoxMedianLineColor','k','WhiskerLineColor','k',...
        'MarkerStyle','none','LineWidth',3);
xlim([0.5 2.5])
ylim([0 60])
xticks(1:2)
grid on;
box off;
set(gca,'XGrid','off','YGrid','on','TickDir','out','LineWidth',1.5)
hold off;

return