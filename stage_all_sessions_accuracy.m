function stage_all_sessions_accuracy
% Lick
path = {"D:\Data\paper\Lick_NoGo_first2", "D:\Data\paper\Lick_last2"}; num_lick = 12;
Go_accuracy_lick = zeros(num_lick*2,2); NoGo_accuracy_lick = zeros(num_lick*2,2);
mice_num = 0;

for folder = 1:2
    folderPath = path{folder};
    cd(folderPath)

    list = dir('*.mat');
    list = natsortfiles({list.name});
    
    for mice = 1:length(list)/2
        for k = 2*mice-1:2*mice
            load(list{k});
            
            Go_accuracy_lick(mice_num+mice,k-2*mice+2)...
                = sum(TrueSide==0 & Outcome==2 & SelfInitiated==1)/sum(TrueSide==0 & Outcome>=1 & Outcome<=2 & SelfInitiated==1);
            NoGo_accuracy_lick(mice_num+mice,k-2*mice+2)...
                = sum(TrueSide==1 & Outcome==1 & SelfInitiated==1)/sum(TrueSide==1 & Outcome>=1 & Outcome<=3 & Outcome~=2 & SelfInitiated==1);
        end
    end
    if folder == 1
        mice_num = length(list)/2;
    end
end

%%%%%%%%%%
accuracy_lick = [mean(Go_accuracy_lick,2) mean(NoGo_accuracy_lick,2)];
make_boxplot_trial_type(num_lick,num_lick,accuracy_lick(:,1),accuracy_lick(:,2),1,0,[0 1]);

%%
% Stop
path = {"D:\Data\paper\Stop_NoGo_first2", "D:\Data\paper\Stop_last2"}; num_stop = 10;
Go_accuracy_stop = zeros(num_stop*2,2); NoGo_accuracy_stop = zeros(num_stop*2,2);
mice_num = 0;

for folder = 1:2
    folderPath = path{folder};
    cd(folderPath)

    list = dir('*.mat');
    list = natsortfiles({list.name});
    
    for mice = 1:length(list)/2
        for k = 2*mice-1:2*mice
            load(list{k});
            
            Go_accuracy_stop(mice_num+mice,k-2*mice+2)...
                = sum(TrueSide==0 & Outcome==2 & SelfInitiated==1)/sum(TrueSide==0 & Outcome>=1 & Outcome<=2 & SelfInitiated==1);
            NoGo_accuracy_stop(mice_num+mice,k-2*mice+2)...
                = sum(TrueSide==1 & Outcome==1 & SelfInitiated==1)/sum(TrueSide==1 & Outcome>=1 & Outcome<=3 & Outcome~=2 & SelfInitiated==1);
        end
    end
    if folder == 1
        mice_num = length(list)/2;
    end
end

%%%%%%%%%%
accuracy_stop = [mean(Go_accuracy_stop,2) mean(NoGo_accuracy_stop,2)];
make_boxplot_trial_type(num_stop,num_stop,accuracy_stop(:,1),accuracy_stop(:,2),1,0,[0 1]);

%%
% stage 3
disp('stage 3')
p_Go = ranksum(accuracy_lick(1:num_lick,1),accuracy_stop(1:num_stop,1))
p_NoGo = ranksum(accuracy_lick(1:num_lick,2),accuracy_stop(1:num_stop,2))
x = accuracy_lick(1:num_lick,1);
y = accuracy_stop(1:num_stop,1);
fprintf('stage 3 Go   Lick %.5f ± %.5f (n=%d)  Stop %.5f ± %.5f (n=%d)\n', ...
    mean(x), std(x)/sqrt(numel(x)), numel(x), mean(y), std(y)/sqrt(numel(y)), numel(y));

x = accuracy_lick(1:num_lick,2);
y = accuracy_stop(1:num_stop,2);
fprintf('stage 3 NoGo Lick %.5f ± %.5f (n=%d)  Stop %.5f ± %.5f (n=%d)\n', ...
    mean(x), std(x)/sqrt(numel(x)), numel(x), mean(y), std(y)/sqrt(numel(y)), numel(y));

% stage 5
disp('stage 5')
p_Go = ranksum(accuracy_lick(num_lick+1:end,1),accuracy_stop(num_stop+1:end,1))
p_NoGo = ranksum(accuracy_lick(num_lick+1:end,2),accuracy_stop(num_stop+1:end,2))
x = accuracy_lick(num_lick+1:end,1);
y = accuracy_stop(num_stop+1:end,1);
fprintf('stage 5 Go   Lick %.5f ± %.5f (n=%d)  Stop %.5f ± %.5f (n=%d)\n', ...
    mean(x), std(x)/sqrt(numel(x)), numel(x), mean(y), std(y)/sqrt(numel(y)), numel(y));

x = accuracy_lick(num_lick+1:end,2);
y = accuracy_stop(num_stop+1:end,2);
fprintf('stage 5 NoGo Lick %.5f ± %.5f (n=%d)  Stop %.5f ± %.5f (n=%d)\n', ...
    mean(x), std(x)/sqrt(numel(x)), numel(x), mean(y), std(y)/sqrt(numel(y)), numel(y));

return