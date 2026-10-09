function stage_session_count
%%%%%%%%%%
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

group_paths = {lick_path, stop_path};
group_name = {'Lick', 'Stop'};

% 進級基準を満たした翌日に、設定を変えず行った Stage 3。補足の Stage 3 からだけ外す。
extra_stage3 = { ...
    'S76_Vis_Nishimoto_240903_Lick_OPT_Feb12_2025_Session1'
    'S97_Vis_Nishimoto_240903_Lick_OPT_May20_2025_Session2'
    'S112_Vis_Nishimoto_240903_Lick_OPT_Jul21_2025_Session1'};
extra_found = false(size(extra_stage3));

mouse_id = {};
mouse_group = {};
count_all = [];       % 余分な Stage 3 を含む
count_stage3_pass = []; % Stage 3 は進級に要した本数（余分な 1 本を除く）

for g = 1:2
    paths = group_paths{g};
    for i = 1:length(paths)
        folderPath = paths{i};
        [~, this_mouse] = fileparts(folderPath);
        
        files = dir(folderPath);
        isFolder = [files.isdir];
        folderNames = {files(isFolder).name};
        folderNames = folderNames(~ismember(folderNames, {'.', '..'}));

        dates = NaT(1, length(folderNames));
        sessions = zeros(1, length(folderNames));
        for j = 1:length(folderNames)
            fname = folderNames{j};
            dateToken = regexp(fname, '(?<dt>[A-Z][a-z]{2}\d{2}_\d{4})', 'names');
            sessToken = regexp(fname, 'Session(\d+)', 'tokens', 'once');
            dates(j) = datetime(dateToken.dt, 'InputFormat', 'MMMdd_yyyy', 'Locale', 'en_US');
            sessions(j) = str2double(sessToken{1});
        end
        
        [~, idx] = sortrows([datenum(dates)', sessions']);
        sortedfolderNames = folderNames(idx);

        this_all = zeros(1, 5);
        this_pass = zeros(1, 5);

        for j = 1:length(sortedfolderNames)
            matFile = fullfile(folderPath, sortedfolderNames{j}, 'Bpod_NI.mat');
            if ~isfile(matFile)
                warning('Bpod_NI.mat がありません: %s', matFile);
                continue
            end
            S = load(matFile, 'TrueSide', 'Outcome', 'SelfInitiated');
            TS = S.TrueSide(:);
            Out = S.Outcome(:);
            SI = S.SelfInitiated(:);
            stage = classify_stage(TS(SI == 1), Out(SI == 1));
            this_all(stage) = this_all(stage) + 1;
            extra_idx = find(strcmp(sortedfolderNames{j}, extra_stage3), 1);
            if ~isempty(extra_idx) && stage == 3
                extra_found(extra_idx) = true;
                fprintf('余分な Stage 3 を補足の Stage 3 から外す: %s %s\n', ...
                    this_mouse, sortedfolderNames{j});
            else
                this_pass(stage) = this_pass(stage) + 1;
            end
        end

        mouse_id{end+1, 1} = this_mouse;
        mouse_group{end+1, 1} = group_name{g};
        count_all(end+1, :) = this_all;
        count_stage3_pass(end+1, :) = this_pass;
        fprintf('%s %s Stage1–5 = %d %d %d %d %d    Stage3–5（余分な Stage 3 を含む）= %d\n', ...
            group_name{g}, this_mouse, this_pass, sum(this_all(3:5)));
    end
end

fprintf('補足の Stage 3 から外したセッション: %d\n', sum(extra_found));

is_lick = strcmp(mouse_group, 'Lick');
is_stop = strcmp(mouse_group, 'Stop');
stage2 = count_all(:, 2);
stage3to5 = sum(count_all(:, 3:5), 2);

fprintf('\n主検定（補正なし）\n');
report_ranksum('Stage 2', stage2(is_lick), stage2(is_stop));
report_ranksum('Stage 3–5（余分な Stage 3 を含む）', stage3to5(is_lick), stage3to5(is_stop));

%%%%%%%%%%
% Supplementary: Stage 1–5 を 1 枚。各 Stage の左が Lick、右が Stop。
% Stage のあいだは xline で区切る。Stage 3 は余分なセッションを除く。
figure('Position', [50 500 1500 500]);
hold on;
x_all = [];
y_all = [];
xtick_pos = [];
for s = 1:5
    lick_n = count_stage3_pass(is_lick, s);
    stop_n = count_stage3_pass(is_stop, s);
    x_lick = (s - 1) * 3 + 1;
    x_stop = (s - 1) * 3 + 2;
    x_all = [x_all; x_lick * ones(numel(lick_n), 1); x_stop * ones(numel(stop_n), 1)];
    y_all = [y_all; lick_n(:); stop_n(:)];
    xtick_pos = [xtick_pos, x_lick, x_stop];
end
if ~isempty(y_all)
    swarmchart(x_all', y_all', 20, 'k', 'filled');
    boxchart(x_all, y_all, 'BoxWidth', 0.5, ...
        'BoxFaceColor', 'none', 'BoxEdgeColor', 'k', 'BoxMedianLineColor', 'k', 'WhiskerLineColor', 'k', ...
        'MarkerStyle', 'none', 'LineWidth', 3);
end
for s = 1:4
    xline(3*s, '-', 'LineWidth', 1.5);
end
xlim([0.5 14.5])
xticks(xtick_pos)
ymax = max(count_stage3_pass(:));
ylim([0, ymax + 1])
yticks(0:20:60)
box off;
set(gca, 'TickDir', 'out', 'LineWidth', 1.5)
hold off;

%%%%%%%%%%
% Main: Stage 2 と Stage 3–5 を別 figure。上側が Lick、下側が Stop。
% ビン幅は figure ごとにここを変える。
bin_width_stage2 = 10;
x_limit_stage2 = 60;
bin_width_stage3to5 = 15; % learning_curve_NoGo.m の edges = 0:15:90
x_limit_stage3to5 = 90;

c = [0.521, 0.086, 0.819; 0.231, 0.666, 0.196];
bin_width = [bin_width_stage2, bin_width_stage3to5];
x_limit = [x_limit_stage2, x_limit_stage3to5];
values = {stage2, stage3to5};
for p = 1:2
    edges = 0:bin_width(p):x_limit(p);
    if edges(end) < x_limit(p)
        edges(end + 1) = edges(end) + bin_width(p);
    end
    figure('Position', [80 + 40 * p, 500, 500, 500]);
    hold on;
    lick_n = values{p}(is_lick);
    stop_n = values{p}(is_stop);
    counts_lick = histcounts(lick_n, edges);
    counts_stop = histcounts(stop_n, edges);
    centers = edges(1:end-1) + diff(edges) / 2;
    bar(centers, counts_lick, 'FaceColor', c(1, :), 'EdgeColor', 'k', 'LineWidth', 1.5);
    bar(centers, -counts_stop, 'FaceColor', c(2, :), 'EdgeColor', 'k', 'LineWidth', 1.5);
    yline(0, 'k', 'LineWidth', 1);
    xlim([0 x_limit(p)])
    peak = max([counts_lick, counts_stop, 1]);
    ylim([-peak, peak])
    yticks_use = -12:ceil((peak-1) / 2):12;
    yticks(yticks_use)
    yticklabels(abs(yticks_use))
    xticks(0:(x_limit(p) / 3):x_limit(p))
    box off;
    set(gca, 'XGrid','off','YGrid','on','TickDir', 'out', 'LineWidth', 1.5)
    hold off;
end
end

%%
function report_ranksum(label, lick_n, stop_n)
print_mean_se(label, 'Lick', lick_n);
print_mean_se(label, 'Stop', stop_n);
if numel(lick_n) >= 1 && numel(stop_n) >= 1
    p = ranksum(lick_n, stop_n);
    fprintf('%s  Lick median %.1f (n=%d)  Stop median %.1f (n=%d)  ranksum p = %.4g\n', ...
        label, median(lick_n), numel(lick_n), median(stop_n), numel(stop_n), p);
end
end

function stage = classify_stage(TrueSide, Outcome)
[stage, ~, ~] = classify_stage_parts(TrueSide, Outcome);
end

function [stage, fN, fF] = classify_stage_parts(TrueSide, Outcome)
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

function print_mean_se(label, group_name, x)
x = x(~isnan(x));
sem = std(x) / sqrt(numel(x));
fprintf('%s  %s  mean %.4g  standard error %.4g (n=%d)\n', ...
    label, group_name, mean(x), sem, numel(x));
end