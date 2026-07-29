% NAME
filename = "Bpod_NI.mat";
% filename = "S105_last2.mat";

% sampling_rate = 1000;
sampling_rate = 2000;

%%
list = dir('block*.mat');
list = natsortfiles({list.name});
nTrials = 0; % Number of Trials
TrueSide = []; % left(Go):0, right(NoGo):1
ChosenSide = []; % left(Go):0, right(NoGo):1, undefined:2
Outcome = []; % incorrect choice:1, reward:2, correct rejection:3, undefined(FreeTrial):4
SelfInitiated = []; % Self-initiated:1, Passive:0% PostStim ON:1, OFF:2
EvidenceStrength = []; % PostOFF & OptOFF:1, PostOFF & OptON:0.9, PostON & OptOFF:0.6, PostON & OptON:0.5
Opto_trial = []; % Photo_stimulus:1, No_Photo:0
c
StimDuration = [];

for i = 1:length(list)
    load(list{i});
    TrueSide = [TrueSide saveBlock.TrueSide];
    ChosenSide = [ChosenSide saveBlock.ChosenSide];
    Outcome = [Outcome saveBlock.Outcome];
    SelfInitiated = [SelfInitiated saveBlock.SelfInitiated];
    EvidenceStrength = [EvidenceStrength saveBlock.EvidenceStrength];
    Opto_trial = [Opto_trial saveBlock.Opto_trial];
    RawEvents_Trial = [RawEvents_Trial saveBlock.RawEvents.Trial];
    StimDuration = [StimDuration saveBlock.StimDuration];
end


nTrials = saveBlock.nTrials;
FreqSide = saveBlock.FreqSide;
AccumulatedWater = saveBlock.AccumulatedWater;

nSelfInitiated = sum(SelfInitiated==1);
disp('Self-initiated Rate')
disp(nSelfInitiated/nTrials);

% PostOFF & OptOFF:1
Go_accuracy_1 = sum(TrueSide==0 & Outcome==2 & EvidenceStrength==1)/sum(TrueSide==0 & Outcome>=1 & Outcome<=2 & EvidenceStrength==1);
NoGo_accuracy_1 = sum(TrueSide==1 & Outcome==1 & EvidenceStrength==1)/sum(TrueSide==1 & Outcome>=1 & Outcome<=3 & Outcome~=2 & EvidenceStrength==1);
if ~isnan(Go_accuracy_1) && ~isnan(NoGo_accuracy_1)
    name = ["Go" "NoGo"];
    res = [Go_accuracy_1 NoGo_accuracy_1];
    figure(1)
    bar(name, res)
    ylim([0 1])
    title("PostOFF & OptOFF")
end

% PostOFF & OptON:0.9
Go_accuracy_2 = sum(TrueSide==0 & Outcome==2 & EvidenceStrength==0.9)/sum(TrueSide==0 & Outcome>=1 & Outcome<=2 & EvidenceStrength==0.9);
NoGo_accuracy_2 = sum(TrueSide==1 & Outcome==1 & EvidenceStrength==0.9)/sum(TrueSide==1 & Outcome>=1 & Outcome<=3 & Outcome~=2 & EvidenceStrength==0.9);
if ~isnan(Go_accuracy_2) && ~isnan(NoGo_accuracy_2)
    name = ["Go" "NoGo"];
    res = [Go_accuracy_2 NoGo_accuracy_2];
    figure(2)
    bar(name, res)
    ylim([0 1])
    title("PostOFF & OptON")
end

% PostON & OptOFF:0.6
Go_accuracy_3 = sum(TrueSide==0 & Outcome==2 & EvidenceStrength==0.6)/sum(TrueSide==0 & Outcome>=1 & Outcome<=2 & EvidenceStrength==0.6);
NoGo_accuracy_3 = sum(TrueSide==1 & Outcome==1 & EvidenceStrength==0.6)/sum(TrueSide==1 & Outcome>=1 & Outcome<=3 & Outcome~=2 & EvidenceStrength==0.6);
if ~isnan(Go_accuracy_3) && ~isnan(NoGo_accuracy_3)
    name = ["Go" "NoGo"];
    res = [Go_accuracy_3 NoGo_accuracy_3];
    figure(3)
    bar(name, res)
    ylim([0 1])
    title("PostON & OptOFF")
end

% PostON & OptON:0.5
Go_accuracy_4 = sum(TrueSide==0 & Outcome==2 & EvidenceStrength==0.5)/sum(TrueSide==0 & Outcome>=1 & Outcome<=2 & EvidenceStrength==0.5);
NoGo_accuracy_4 = sum(TrueSide==1 & Outcome==1 & EvidenceStrength==0.5)/sum(TrueSide==1 & Outcome>=1 & Outcome<=3 & Outcome~=2 & EvidenceStrength==0.5);
if ~isnan(Go_accuracy_4) && ~isnan(NoGo_accuracy_4)
    name = ["Go" "NoGo"];
    res = [Go_accuracy_4 NoGo_accuracy_4];
    figure(4)
    bar(name, res)
    ylim([0 1])
    title("PostON & OptON")
end

%% NI raw dataの表示
% list_NI = dir('NI*.mat');
list_NI = dir('LogFile*.mat');
list_NI = {list_NI.name};

load(list_NI{1});

% figure;
% plot(t,ch(1,:))
% title("Trial Start & Valve Open")
% figure;
% plot(t,ch(2,:))
% title("Trial End")
% figure;
% plot(t,ch(3,:))
% title("Run")
% figure;
% plot(t,ch(4,:))
% title("Stop")
% figure;
% plot(t,ch(5,:))
% title("Rotary Encoder raw A")
% figure;
% plot(t,ch(6,:))
% title("Rotary Encoder raw B")
figure;
plot(t,ch(7,:))
title("Target Stimulus Onset")
% figure;
% plot(t,ch(8,:))
% title("Lick")

%% NIは2 kHz
% 3なら334, 5なら200

trial_start = [];
trial_end = [];
reward = [];
stim_onset = [];
stim_offset = [];
run = [];
stop = [];
lick = [];

% threshold = sort(ch(7,:),'descend');
% lum_threshold = 0.8*threshold(sampling_rate);
% lum_threshold2 = 0.95*threshold(sampling_rate);

lum_threshold = -3;
lum_threshold2 = -3;

for i = 2:size(ch(1,:),2)
    % trial startとrewardのタイミングを取得
    if ch(1,i)>3 && ch(1,i-1)<3
        if ch(1,i+0.2*sampling_rate)>4
            trial_start(end+1) = i;
        else
            reward(end+1) = i;
        end
    end
    % trial endのタイミングを取得
    if ch(2,i)>3 && ch(2,i-1)<3
        trial_end(end+1) = i;
    end
    % run: 一定距離走ったタイミングを取得
    if ch(3,i)>3 && ch(3,i-1)<3
        run(end+1) = i;
    end
    % stop: 止まったタイミングを取得
    if ch(4,i)>3 && ch(4,i-1)<3
        stop(end+1) = i;
    end
    % stimulus onsetのタイミングを取得 sessionによって揺らぎがあるから要確認
    if ch(7,i)>lum_threshold && ch(7,i-1)<lum_threshold
        stim_onset(end+1) = i;
    elseif ch(7,i)<lum_threshold2 && ch(7,i-1)>lum_threshold2
        stim_offset(end+1) = i;
    end
    % lickのタイミングを取得
    if ch(8,i)>3 && ch(8,i-1)<3
        lick(end+1) = i;
    end
end

if ~isempty(stim_onset) && ~isempty(stim_offset)
    stim_onset = stim_onset(stim_onset>trial_start(1));
    stim_offset = stim_offset(stim_offset>stim_onset(1));
end

disp('Numbers of trial_start and trial_end are matched?');
disp(size(trial_start,2)==size(trial_end,2));
disp('Number of reward');
disp(size(reward,2));

%%
% stim_onset, offsetの正確なタイミングをBpodを参照して位置合わせ

% Bpod
stim_onset_bpod = zeros(1,size(trial_end,2));
stim_offset_bpod = zeros(1,size(trial_end,2));
for i = 1:length(RawEvents_Trial)
    stim_onset_bpod(i) = RawEvents_Trial{1,i}.States.TriggerStim(1)*sampling_rate; % 2kHz sampling
    stim_offset_bpod(i) = stim_onset_bpod(i)+StimDuration(i)*sampling_rate;
end

% NI
stim_onset_ni = zeros(2,size(stim_onset,2));
j = 0;
for i = 1:size(stim_onset_ni,2)
    val = 0;
    while val>=0
        j = j+1;
        f_val = val;
        if j <= size(trial_start,2)
            val = stim_onset(i) - trial_start(j);
        else
            val = -1; % 最後のtrialのため
        end
    end
    stim_onset_ni(1,i) = j-1;
    stim_onset_ni(2,i) = f_val;
    j = j-2;
end

stim_offset_ni = zeros(2,size(stim_offset,2));
j = 0;
for i = 1:size(stim_offset_ni,2)
    val = 0;
    while val>=0
        j = j+1;
        f_val = val;
        if j <= size(trial_start,2)
            val = stim_offset(i) - trial_start(j);
        else
            val = -1; % 最後のtrialのため
        end
    end
    stim_offset_ni(1,i) = j-1;
    stim_offset_ni(2,i) = f_val;
    j = j-2;
end

% Bpodの値に近いNIの値を採用
if ~isempty(stim_onset) && ~isempty(stim_offset)
    stim_onset_new = zeros(1,size(trial_end,2));
    for i = 1:size(trial_end,2)
        index = find(stim_onset_ni(1,:)==i);
        [M,I] = min(abs(stim_onset_ni(2,index) - stim_onset_bpod(i)));
        stim_onset_new(i) = stim_onset(index(I));
    end

    stim_offset_new = zeros(1,size(trial_end,2));
    for i = 1:size(trial_end,2)
        index = find(stim_offset_ni(1,:)==i);
        [M,I] = min(abs(stim_offset_ni(2,index) - stim_offset_bpod(i)));
        stim_offset_new(i) = stim_offset(index(I));
    end

    stim_onset = stim_onset_new;
    stim_offset = stim_offset_new;

    % runとstopが逆の時用 BOX3
    temp_run = run; temp_stop = stop;
    if min(abs(temp_run-stim_onset(1))) > min(abs(temp_stop-stim_onset(1)))
        run = temp_stop; stop = temp_run;
    end

end
trial_duration = trial_end(1:size(trial_end,2))-trial_start(1:size(trial_end,2));
disp('sec/trial');
disp(mean(trial_duration)/sampling_rate);

%%
go_correct = zeros(1,size(TrueSide,2));
go_error = zeros(1,size(TrueSide,2));
nogo_correct = zeros(1,size(TrueSide,2));
nogo_error = zeros(1,size(TrueSide,2));

% Free Trialは含めない
for i = 1:size(TrueSide,2)
    if TrueSide(i)==0 && Outcome(i)==2
        go_correct(i) = 1;
    elseif TrueSide(i)==0 && Outcome(i)==1
        go_error(i) = 1;
    elseif TrueSide(i)==1 && Outcome(i)==3
        nogo_correct(i) = 1;
    elseif TrueSide(i)==1 && Outcome(i)==1
        nogo_error(i) = 1;
    end
end

%% Go/No-Go それぞれの中での種類分け

% 1個前までさかのぼる
% Go>Go, No-Go>Go, Go>No-Go, No-Go>No-Go
go_go = zeros(1,size(TrueSide,2));
no_go = zeros(1,size(TrueSide,2));
go_no = zeros(1,size(TrueSide,2));
no_no = zeros(1,size(TrueSide,2));

for i = 2:size(TrueSide,2)
    if TrueSide(i-1)==0 && TrueSide(i)==0
        go_go(i) = 1;
    elseif TrueSide(i-1)==1 && TrueSide(i)==0
        no_go(i) = 1;
    elseif TrueSide(i-1)==0 && TrueSide(i)==1
        go_no(i) = 1;
    elseif TrueSide(i-1)==1 && TrueSide(i)==1
        no_no(i) = 1;
    end
end

% 2個前までさかのぼる
%% rotary encoderの角速度を計算

p_a = ch(5,:); p_a(p_a<3) = 0; p_a(p_a>=3) = 1;
p_b = ch(6,:); p_b(p_b<3) = 0; p_b(p_b>=3) = 1;
direction = ones(1, size(ch,2));
d_1 = 1; d_2 = -1;

switch sampling_rate
    case 1000
        for i = 2:size(p_a,2)
            if p_a(i-1)==0 && p_a(i)==0 && p_b(i-1)==0 && p_b(i)==1
                direction(i) = d_1;
            elseif p_a(i-1)==0 && p_a(i)==0 && p_b(i-1)==1 && p_b(i)==0
                if direction(i-1)>=1
                    direction(i) = 3*d_1;
                else
                    direction(i) = d_2;
                end
            elseif p_a(i-1)==0 && p_a(i)==1 && p_b(i-1)==1 && p_b(i)==1
                direction(i) = d_1;
            elseif p_a(i-1)==0 && p_a(i)==1 && p_b(i-1)==0 && p_b(i)==0
                if direction(i-1)>=1
                    direction(i) = 3*d_1;
                else
                    direction(i) = d_2;
                end
            elseif p_a(i-1)==1 && p_a(i)==0 && p_b(i-1)==0 && p_b(i)==0
                direction(i) = d_1;
            elseif p_a(i-1)==1 && p_a(i)==0 && p_b(i-1)==1 && p_b(i)==1
                if direction(i-1)>=1
                    direction(i) = 3*d_1;
                else
                    direction(i) = d_2;
                end
            elseif p_a(i-1)==1 && p_a(i)==1 && p_b(i-1)==1 && p_b(i)==0
                direction(i) = d_1;
            elseif p_a(i-1)==1 && p_a(i)==1 && p_b(i-1)==0 && p_b(i)==1
                if direction(i-1)>=1
                    direction(i) = 3*d_1;
                else
                    direction(i) = d_2;
                end
            elseif p_a(i-1)==p_a(i) && p_b(i-1)==p_b(i)
                if direction(i-1)>=2
                    direction(i) = 4*d_1;
                else
                    direction(i) = 0;
                end
            elseif direction(i-1)<0
                direction(i) = 2*d_2;
            else
                direction(i) = 2*d_1;
            end
        end

    otherwise
        for i = 2:size(p_a,2)
            if p_a(i-1)==0 && p_a(i)==0 && p_b(i-1)==0 && p_b(i)==1
                direction(i) = d_1;
            elseif p_a(i-1)==0 && p_a(i)==0 && p_b(i-1)==1 && p_b(i)==0
                direction(i) = d_2;
            elseif p_a(i-1)==0 && p_a(i)==1 && p_b(i-1)==1 && p_b(i)==1
                direction(i) = d_1;
            elseif p_a(i-1)==0 && p_a(i)==1 && p_b(i-1)==0 && p_b(i)==0
                direction(i) = d_2;
            elseif p_a(i-1)==1 && p_a(i)==0 && p_b(i-1)==0 && p_b(i)==0
                direction(i) = d_1;
            elseif p_a(i-1)==1 && p_a(i)==0 && p_b(i-1)==1 && p_b(i)==1
                direction(i) = d_2;
            elseif p_a(i-1)==1 && p_a(i)==1 && p_b(i-1)==1 && p_b(i)==0
                direction(i) = d_1;
            elseif p_a(i-1)==1 && p_a(i)==1 && p_b(i-1)==0 && p_b(i)==1
                direction(i) = d_2;
            elseif p_a(i-1)==p_a(i) && p_b(i-1)==p_b(i)
                direction(i) = 0;
            elseif direction(i)<0
                direction(i) = 2*d_2;
            else
                direction(i) = 2*d_1;
            end
        end
        for i = 2:size(p_a,2)-1
            if direction(i)==-1 && (direction(i-1)>=2 || direction(i+1)>=2)
                direction(i)=3;
            end
        end
end
    

%% ファイルに出力
save(filename, "ChosenSide", "EvidenceStrength", "TrueSide", "Outcome", ...
    "Opto_trial", "SelfInitiated", "nSelfInitiated", "nTrials",...
    "lick", "reward", "run", "stop", "stim_onset", "stim_offset",...
    "trial_start", "trial_end", "sampling_rate",...
    "go_correct", "go_error", "nogo_correct", "nogo_error",...
    "go_go", "go_no", "no_go", "no_no",...
    "direction")