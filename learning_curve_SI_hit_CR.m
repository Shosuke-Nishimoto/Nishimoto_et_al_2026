function learning_curve_SI_hit_CR
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

data_table_lick_si = table();
data_table_lick_hit_s2 = table();
data_table_lick_hit_s35 = table();
data_table_lick_cr = table();
lick_si_n = zeros(1,length(lick_path));
lick_hit_s2_n = zeros(1,length(lick_path));
lick_hit_s35_n = zeros(1,length(lick_path));
lick_cr_n = zeros(1,length(lick_path));

for i = 1:length(lick_path)
    folderPath = lick_path{i};
    [~, this_mouse] = fileparts(folderPath);
    cd(folderPath)
    % フォルダ内の内容を取得
    files = dir(folderPath);
    % フォルダのみを抽出（. と .. を除外）
    isFolder = [files.isdir];
    folderNames = {files(isFolder).name};
    folderNames = folderNames(~ismember(folderNames, {'.', '..'}));

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

    si_rate = [];
    hit_rate_s2 = [];
    hit_rate_s35 = [];
    cr_rate = [];
    for j = 1:length(sortedfolderNames)
        cd(sortedfolderNames{j})
        load('Bpod_NI.mat')
        stage = classify_stage(TrueSide(SelfInitiated==1), Outcome(SelfInitiated==1));
        if stage >= 2
            si_rate = [si_rate; mean(SelfInitiated==1)];
            n_go = sum(TrueSide==0 & Outcome>=1 & Outcome<=2 & SelfInitiated==1);
            n_hit = sum(TrueSide==0 & Outcome==2 & SelfInitiated==1);
            this_hit = n_hit / n_go;
            if stage == 2
                hit_rate_s2 = [hit_rate_s2; this_hit];
            elseif stage >= 3
                hit_rate_s35 = [hit_rate_s35; this_hit];
            end
        end
        if stage >= 3
            den = sum(TrueSide==1 & Outcome>=1 & Outcome<=3 & Outcome~=2 & SelfInitiated==1);
            NoGo_accuracy = sum(TrueSide==1 & Outcome==1 & SelfInitiated==1) / den;
            cr_rate = [cr_rate; 1 - NoGo_accuracy];
        end
        cd('..')
    end
    data_table_lick_si(1,i) = {si_rate};
    data_table_lick_hit_s2(1,i) = {hit_rate_s2};
    data_table_lick_hit_s35(1,i) = {hit_rate_s35};
    data_table_lick_cr(1,i) = {cr_rate};
    lick_si_n(i) = length(si_rate);
    lick_hit_s2_n(i) = length(hit_rate_s2);
    lick_hit_s35_n(i) = length(hit_rate_s35);
    lick_cr_n(i) = length(cr_rate);
    fprintf('Lick %s  SI Stage2–5 = %d   Hit Stage2 = %d   Hit Stage3–5 = %d   CR Stage3–5 = %d\n', ...
        this_mouse, lick_si_n(i), lick_hit_s2_n(i), lick_hit_s35_n(i), lick_cr_n(i));
end

lick_color = [0.980 0.541 0.831; 0.368 0.133 0.588];
plot_curve(data_table_lick_si, lick_si_n, lick_color, 0.8, [0 0.5 0.8 1]);
plot_curve2(data_table_lick_hit_s2, lick_hit_s2_n, lick_color, 0.8, [0 0.5 0.8 1]);
plot_curve(data_table_lick_hit_s35, lick_hit_s35_n, lick_color, 0.8, [0 0.5 0.8 1]);
plot_curve(data_table_lick_cr, lick_cr_n, lick_color, 0.5, [0 0.5 1]);

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

data_table_stop_si = table();
data_table_stop_hit_s2 = table();
data_table_stop_hit_s35 = table();
data_table_stop_cr = table();
stop_si_n = zeros(1,length(stop_path));
stop_hit_s2_n = zeros(1,length(stop_path));
stop_hit_s35_n = zeros(1,length(stop_path));
stop_cr_n = zeros(1,length(stop_path));

for i = 1:length(stop_path)
    folderPath = stop_path{i};
    [~, this_mouse] = fileparts(folderPath);
    cd(folderPath)
    % フォルダ内の内容を取得
    files = dir(folderPath);
    % フォルダのみを抽出（. と .. を除外）
    isFolder = [files.isdir];
    folderNames = {files(isFolder).name};
    folderNames = folderNames(~ismember(folderNames, {'.', '..'}));

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

    si_rate = [];
    hit_rate_s2 = [];
    hit_rate_s35 = [];
    cr_rate = [];
    for j = 1:length(sortedfolderNames)
        cd(sortedfolderNames{j})
        load('Bpod_NI.mat')
        stage = classify_stage(TrueSide(SelfInitiated==1), Outcome(SelfInitiated==1));
        if stage >= 2
            si_rate = [si_rate; mean(SelfInitiated==1)];
            n_go = sum(TrueSide==0 & Outcome>=1 & Outcome<=2 & SelfInitiated==1);
            n_hit = sum(TrueSide==0 & Outcome==2 & SelfInitiated==1);
            this_hit = n_hit / n_go;
            if stage == 2
                hit_rate_s2 = [hit_rate_s2; this_hit];
            elseif stage >= 3
                hit_rate_s35 = [hit_rate_s35; this_hit];
            end
        end
        if stage >= 3
            den = sum(TrueSide==1 & Outcome>=1 & Outcome<=3 & Outcome~=2 & SelfInitiated==1);
            NoGo_accuracy = sum(TrueSide==1 & Outcome==1 & SelfInitiated==1) / den;
            cr_rate = [cr_rate; 1 - NoGo_accuracy];
        end
        cd('..')
    end
    data_table_stop_si(1,i) = {si_rate};
    data_table_stop_hit_s2(1,i) = {hit_rate_s2};
    data_table_stop_hit_s35(1,i) = {hit_rate_s35};
    data_table_stop_cr(1,i) = {cr_rate};
    stop_si_n(i) = length(si_rate);
    stop_hit_s2_n(i) = length(hit_rate_s2);
    stop_hit_s35_n(i) = length(hit_rate_s35);
    stop_cr_n(i) = length(cr_rate);
    fprintf('Stop %s  SI Stage2–5 = %d   Hit Stage2 = %d   Hit Stage3–5 = %d   CR Stage3–5 = %d\n', ...
        this_mouse, stop_si_n(i), stop_hit_s2_n(i), stop_hit_s35_n(i), stop_cr_n(i));
end

stop_color = [0.286 0.858 0.250; 0.007 0.345 0.054];
plot_curve(data_table_stop_si, stop_si_n, stop_color, 0.8, [0 0.5 0.8 1]);
plot_curve2(data_table_stop_hit_s2, stop_hit_s2_n, stop_color, 0.8, [0 0.5 0.8 1]);
plot_curve(data_table_stop_hit_s35, stop_hit_s35_n, stop_color, 0.8, [0 0.5 0.8 1]);
plot_curve(data_table_stop_cr, stop_cr_n, stop_color, 0.5, [0 0.5 1]);
end

%%
function plot_curve(data_table, session_number, color_ends, y_criterion, yticks_use)
figure('Position', [50 500 500 500]);
hold on;
yline(y_criterion,':','LineWidth',1.5,'Color','k');
[~,idx_mouse] = sort(session_number);
n = length(idx_mouse);
colors = [linspace(color_ends(1,1),color_ends(2,1),n)',...
            linspace(color_ends(1,2),color_ends(2,2),n)',...
            linspace(color_ends(1,3),color_ends(2,3),n)'];
for i = 1:n
    c = colors(i,:);
    data = data_table{1,idx_mouse(end-i+1)}{:};
    plot(data,'Color',c,'LineWidth',3);
    scatter(1:length(data)-2,data(1:end-2),25,c,"filled");
    scatter([length(data)-1 length(data)],[data(end-1) data(end)],...
            50,[0 0 0],'d','LineWidth',3);
end
xlim([0 ceil(max(session_number)/25)*25])
ylim([0 1])
xticks(0:25:ceil(max(session_number)/25)*25)
yticks(yticks_use)
box off;
set(gca,'TickDir','out','LineWidth',1.5)
hold off;
end

function plot_curve2(data_table, session_number, color_ends, y_criterion, yticks_use)
figure('Position', [50 500 500 500]);
hold on;
yline(y_criterion,':','LineWidth',1.5,'Color','k');
[~,idx_mouse] = sort(session_number);
n = length(idx_mouse);
colors = [linspace(color_ends(1,1),color_ends(2,1),n)',...
            linspace(color_ends(1,2),color_ends(2,2),n)',...
            linspace(color_ends(1,3),color_ends(2,3),n)'];
for i = 1:n
    c = colors(i,:);
    data = data_table{1,idx_mouse(end-i+1)}{:};
    plot(data,'Color',c,'LineWidth',3);
    scatter(1:length(data),data,25,c,"filled");
end
xlim([0 ceil(max(session_number)/25)*25])
ylim([0 1])
xticks(0:25:ceil(max(session_number)/25)*25)
yticks(yticks_use)
box off;
set(gca,'TickDir','out','LineWidth',1.5)
hold off;
end

function stage = classify_stage(TrueSide, Outcome)
TrueSide = TrueSide(:);
Outcome = Outcome(:);
fN = mean(TrueSide == 1);
fF = mean(Outcome == 4);
if fN < 0.05 && fF > 0.9
    stage = 1;
elseif fN < 0.05 && fF > 0.35 && fF < 0.65
    stage = 2;
elseif fN > 0.4 && fN < 0.6 && fF > 0.18
    stage = 3;
elseif fN > 0.4 && fN < 0.6 && fF > 0.05 && fF <= 0.18
    stage = 4;
elseif fN > 0.4 && fN < 0.6 && fF <= 0.05
    stage = 5;
else
    stage = NaN;
end
end