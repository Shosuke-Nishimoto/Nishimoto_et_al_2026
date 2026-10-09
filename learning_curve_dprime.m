function learning_curve_dprime
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

data_table_lick_dp = table();
lick_dp_n = zeros(1,length(lick_path));

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

    dprime = [];
    for j = 1:length(sortedfolderNames)
        cd(sortedfolderNames{j})
        load('Bpod_NI.mat')
        stage = classify_stage(TrueSide(SelfInitiated==1), Outcome(SelfInitiated==1));
        if stage >= 3
            dprime = [dprime; session_dprime(TrueSide, Outcome, SelfInitiated)];
        end
        cd('..')
    end
    data_table_lick_dp(1,i) = {dprime};
    lick_dp_n(i) = length(dprime);
    fprintf('Lick %s  Stage3–5 = %d   last d'' = %.3f\n', this_mouse, lick_dp_n(i), dprime(end));
end

lick_color = [0.980 0.541 0.831; 0.368 0.133 0.588];
plot_dprime(data_table_lick_dp, lick_dp_n, lick_color);

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

data_table_stop_dp = table();
stop_dp_n = zeros(1,length(stop_path));

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

    dprime = [];
    for j = 1:length(sortedfolderNames)
        cd(sortedfolderNames{j})
        load('Bpod_NI.mat')
        stage = classify_stage(TrueSide(SelfInitiated==1), Outcome(SelfInitiated==1));
        if stage >= 3
            dprime = [dprime; session_dprime(TrueSide, Outcome, SelfInitiated)];
        end
        cd('..')
    end
    data_table_stop_dp(1,i) = {dprime};
    stop_dp_n(i) = length(dprime);
    fprintf('Stop %s  Stage3–5 = %d   last d'' = %.3f\n', this_mouse, stop_dp_n(i), dprime(end));
end

stop_color = [0.286 0.858 0.250; 0.007 0.345 0.054];
plot_dprime(data_table_stop_dp, stop_dp_n, stop_color);
end

%%
function dp = session_dprime(TrueSide, Outcome, SelfInitiated)
n_go = sum(TrueSide==0 & Outcome>=1 & Outcome<=2 & SelfInitiated==1);
n_hit = sum(TrueSide==0 & Outcome==2 & SelfInitiated==1);
n_nogo = sum(TrueSide==1 & Outcome>=1 & Outcome<=3 & Outcome~=2 & SelfInitiated==1);
n_fa = sum(TrueSide==1 & Outcome==1 & SelfInitiated==1);
if n_go == 0 || n_nogo == 0
    dp = NaN;
    return
end
H = n_hit / n_go;
F = n_fa / n_nogo;
H = correct_rate_01(H, n_go);
F = correct_rate_01(F, n_nogo);
dp = norminv(H) - norminv(F);
end

function p = correct_rate_01(p, n)
if p <= 0
    p = 1 / (2 * n);
elseif p >= 1
    p = 1 - 1 / (2 * n);
end
end

function plot_dprime(data_table, session_number, color_ends)
figure('Position', [50 500 500 500]);
hold on;
[~,idx_mouse] = sort(session_number);
n = length(idx_mouse);
colors = [linspace(color_ends(1,1),color_ends(2,1),n)',...
            linspace(color_ends(1,2),color_ends(2,2),n)',...
            linspace(color_ends(1,3),color_ends(2,3),n)'];
vals = [];
for i = 1:n
    c = colors(i,:);
    data = data_table{1,idx_mouse(end-i+1)}{:};
    vals = [vals; data(:)];
    plot(data,'Color',c,'LineWidth',3);
    scatter(1:length(data)-2,data(1:end-2),25,c,"filled");
    scatter([length(data)-1 length(data)],[data(end-1) data(end)],...
            50,[0 0 0],'d','LineWidth',3);
end
xlim([0 ceil(max(session_number)/25)*25])
xticks(0:25:ceil(max(session_number)/25)*25)
ylim([-0.5 4])
yticks(0:4)
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
