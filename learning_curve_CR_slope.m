function learning_curve_CR_slope
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

[data_table_lick, lick_n, lick_slope, lick_intercept] = slopes_for_group(lick_path, 'Lick');

lick_color = [0.980 0.541 0.831; 0.368 0.133 0.588];
plot_curve_with_fit(data_table_lick, lick_n, lick_slope, lick_intercept, lick_color);

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

[data_table_stop, stop_n, stop_slope, stop_intercept] = slopes_for_group(stop_path, 'Stop');

stop_color = [0.286 0.858 0.250; 0.007 0.345 0.054];
plot_curve_with_fit(data_table_stop, stop_n, stop_slope, stop_intercept, stop_color);

disp('correct-rejection slope, stages 3-5')
p = ranksum(lick_slope, stop_slope)
report_mean_se('Lick', lick_slope);
report_mean_se('Stop', stop_slope);
fprintf('ranksum p = %.4g\n', p);
end

%%
function [data_table, session_number, slope, intercept] = slopes_for_group(path_list, group_name)
data_table = table();
session_number = zeros(1, length(path_list));
slope = zeros(1, length(path_list));
intercept = zeros(1, length(path_list));

for i = 1:length(path_list)
    folderPath = path_list{i};
    [~, this_mouse] = fileparts(folderPath);
    cr_rate = correct_rejection_stages_3to5(folderPath);
    t = (1:length(cr_rate))';
    y = cr_rate(:);
    ok = isfinite(y);
    coeff = polyfit(t(ok), y(ok), 1);
    slope(i) = coeff(1);
    intercept(i) = coeff(2);
    data_table(1, i) = {cr_rate};
    session_number(i) = length(cr_rate);
    fprintf('%s %s  Stage3–5 = %d   slope = %.5f\n', ...
        group_name, this_mouse, session_number(i), slope(i));
end
end

function cr_rate = correct_rejection_stages_3to5(folderPath)
cd(folderPath)
files = dir(folderPath);
isFolder = [files.isdir];
folderNames = {files(isFolder).name};
folderNames = folderNames(~ismember(folderNames, {'.', '..'}));

dates = NaT(1, length(folderNames));
sessions = zeros(1, length(folderNames));
for j = 1:length(folderNames)
    fname = folderNames{j};
    dateToken = regexp(fname, '(?<dt>[A-Z][a-z]{2}\d{2}_\d{4})', 'names');
    dates(j) = datetime(dateToken.dt, 'InputFormat', 'MMMdd_yyyy', 'Locale', 'en_US');
    sessToken = regexp(fname, 'Session(\d+)', 'tokens', 'once');
    sessions(j) = str2double(sessToken{1});
end

[~, idx] = sortrows([datenum(dates)', sessions']);
sortedfolderNames = folderNames(idx);

cr_rate = [];
for j = 1:length(sortedfolderNames)
    cd(sortedfolderNames{j})
    load('Bpod_NI.mat')
    stage = classify_stage(TrueSide(SelfInitiated==1), Outcome(SelfInitiated==1));
    if stage >= 3
        den = sum(TrueSide==1 & Outcome>=1 & Outcome<=3 & Outcome~=2 & SelfInitiated==1);
        NoGo_accuracy = sum(TrueSide==1 & Outcome==1 & SelfInitiated==1) / den;
        cr_rate = [cr_rate; 1 - NoGo_accuracy];
    end
    cd('..')
end
end

function plot_curve_with_fit(data_table, session_number, slope, intercept, color_ends)
figure('Position', [50 500 500 500]);
hold on;
yline(0.5, ':', 'LineWidth', 1.5, 'Color', 'k');
[~, idx_mouse] = sort(session_number);
n = length(idx_mouse);
colors = [linspace(color_ends(1,1), color_ends(2,1), n)', ...
            linspace(color_ends(1,2), color_ends(2,2), n)', ...
            linspace(color_ends(1,3), color_ends(2,3), n)'];
for i = 1:n
    c = colors(i,:);
    mouse = idx_mouse(end-i+1);
    data = data_table{1, mouse}{:};
    t = 1:length(data);
    scatter(t, data, 25, c, "filled");
    plot(t, slope(mouse) * t + intercept(mouse), '-', 'Color', c, 'LineWidth', 3);
end
xlim([0 ceil(max(session_number)/25)*25])
ylim([0 1])
xticks(0:25:ceil(max(session_number)/25)*25)
yticks([0 0.5 1])
box off;
set(gca, 'TickDir', 'out', 'LineWidth', 1.5)
add_mouse_colorbar(colors);
hold off;
end

function report_mean_se(group_name, x)
x = x(~isnan(x));
sem = std(x) / sqrt(numel(x));
d = max(0, 1 - floor(log10(sem)));
fprintf('%s  mean %.*f  standard error %.*f (n=%d)\n', ...
    group_name, d, mean(x), d, sem, numel(x));
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

function add_mouse_colorbar(colors)
n = size(colors, 1);
colormap(flipud(colors));
clim([0.5, n + 0.5]);
cb = colorbar('Location', 'eastoutside');
cb.Ticks = 1:n;
cb.TickDirection = 'out';
end