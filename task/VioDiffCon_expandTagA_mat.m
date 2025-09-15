% edited by eam 9/4/18 for SleepVioDiff study
% edited by eam 11/30/18 reverting to 2 task conditions

% this script takes an already expanded learning_mat (stat learning phase
% pairs) and creates trial matrices for reward phase and decision phase 

function VioDiffCon_expandTagA_mat
%% random seed
if verLessThan('matlab', '7.7')
    rand('seed',sum(100*clock));
    
elseif verLessThan('matlab', '7.14')
    currStream = RandStream.getDefaultStream;
    if currStream.Seed == 0 % (should only be done ONCE per session)
        RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
    end
    
else
    RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));
end%if verLessThan

%%
fMRI = 0; %for creating trial matrices
VioDiffCon_VarConfig;

%%
for subj = subjList
%for subj = [55 59 67]
%for subj = [77]
    if subj < 10
        SN = ['0' num2str(subj)];
    else
        SN = [num2str(subj)];
    end%if subj
    
    load([out_mat_dir '/learning_mat_' SN], 'learning_mat');
    load([out_mat_dir '/learning_mat_row']);
    makeDecisionPairs; %pairs stim for Decision Phase (unique pairings for each subject)
    decision_pairs_subj{subj} = decision_pairings;
    
    %to keep track of rows in test_mat2
    row = learning_mat_row;
    row.Resp = [];
    row.RT = [];
    row.ACC = [];
    row.onset = [];
    row.recorded = [];
    row.fMRItrigger = [];
    
    test_mat2=[];
    
    %% make master matrix for reward-decision phase (test_mat2)
    for blk=1:nBlk_learning
        for cond = 1:nCond
            indx = find(learning_mat{blk}(1,:) == cond & learning_mat{blk}(2,:) == 1); %find each pair
            temp = [learning_mat{blk}(:,indx);repmat(blk,1,length(indx))];
            test_mat2 = [test_mat2 temp];
        end %for cond
    end %for blk
    
    test_mat2(12,:) = 1:length(test_mat2); %insert index to row 12
    
    row.learningBlk = 11; %update row structure
    row.Index = 12; %update row structure

%% Code each pair for pairtype and assign to cycles  

% 1:outdoor/outdoor
% 2:indoor/indoor
% 3:indoor/outdoor
% 4:outdoor/indoor

if mod(subj,2) == 1 %odd sid
    congruent = 1; %ii and oo pairs assigned to cycle 1
    incongruent = 2; %io and oi pairs assigned to cycle 2
elseif mod(subj,2) == 0 %even sid
    congruent = 2; %ii and oo pairs assigned to cycle 2
    incongruent = 1; %io and oi pairs assigned to cycle 1
end

indx = test_mat2(row.Index, test_mat2(row.order,:) == 1); %get A image of each pair

for i=1:length(indx)
    %thispair = [test_mat2(:,indx(i)) test_mat2(:,indx(i)+1)];
    if test_mat2(row.lower,indx(i)) == 1 %if A image is indoor
        if test_mat2(row.lower,indx(i)+1) == 1 %if B image is indoor 
            test_mat2(13,indx(i):indx(i)+1) = 2; %indoor/indoor
            test_mat2(14,indx(i):indx(i)+1) = congruent; 
        elseif test_mat2(row.lower,indx(i)+1) == 2
            test_mat2(13,indx(i):indx(i)+1) = 3; %indoor/outdoor
            test_mat2(14,indx(i):indx(i)+1) = incongruent; 
        end
    elseif test_mat2(row.lower,indx(i)) == 2 %if outdoor
        if test_mat2(row.lower,indx(i)+1) == 1 %if B image is indoor 
            test_mat2(13,indx(i):indx(i)+1) = 4; %outdoor/indoor
            test_mat2(14,indx(i):indx(i)+1) = incongruent;
        elseif test_mat2(row.lower,indx(i)+1) == 2
            test_mat2(13,indx(i):indx(i)+1) = 1; %outdoor/outdoor
            test_mat2(14,indx(i):indx(i)+1) = congruent; 
        end
    end
end

row.pairtype = 13; %update row structure
row.cycle = 14; %update row structure

%% For each pairtype within each block/condition, assign 1 to reward and one to neutral
% 1:reward
% 2:neutral

for cycle = 1:nCycles_reward
    for cond = 1:nCond %stat learning condition
        for blk=1:nBlk_learning %stat learning block
            %indx = test_mat2(12, test_mat2(14,:) == cycle & test_mat2(11,:) == blk & test_mat2(1,:) == cond & test_mat2(5,:) ==1);
            indx = test_mat2(row.Index, test_mat2(row.cycle,:) == cycle & test_mat2(row.learningBlk,:) == blk & test_mat2(row.cond,:) == cond & test_mat2(row.order,:) ==1);
            pairtypes = unique(test_mat2(row.pairtype,indx));
            
            for type = 1:length(pairtypes) %included pairtypes
                %indx = test_mat2(12, test_mat2(14,:) == cycle & test_mat2(11,:) == blk & test_mat2(1,:) == cond & test_mat2(13,:) == pairtypes(type) & test_mat2(5,:) ==1);
                indx = test_mat2(row.Index, test_mat2(row.cycle,:) == cycle & test_mat2(row.learningBlk,:) == blk & test_mat2(row.cond,:) == cond & test_mat2(row.pairtype,:) == pairtypes(type) & test_mat2(row.order,:) ==1);
                %test_mat2(15,indx) = Shuffle(repmat([1 2],1,4));
                test_mat2(15,indx) = Shuffle([1 2]);
                test_mat2(15,indx+1) = test_mat2(15,indx);
            end
        end
    end
end

row.rewardcond = 15; %update row structure

%% Assign condition index to each pair and assign neutral 4 neutral stim to each reward stim for Decision phase
%coding scheme
%first digit: stat learning condition (1=V+R+, 2=V-R+)
%second digit: pairtype (0=outdoor/outdoor 1=indoor/indoor 3=indoor/outdoor
%4=outdoor/indoor)
%third digit: reward condition (1=reward, 2=neutral)
%fourth digit: pair number within condition, pairtype, and rewardcond (1-6)

for cond=1:nCond %1:V+R+, 2:V-R+
    for type=1:nPairtypes %1:outdoor/outdoor 2:indoor/indoor 3:indoor/outdoor 4:outdoor/indoor
        for reward=1:2 %1:reward 2:neutral
            indx = test_mat2(row.Index, test_mat2(row.cond,:) == cond & test_mat2(row.pairtype,:) == type & test_mat2(row.rewardcond,:) == reward & test_mat2(row.order,:)==1);

            if type == 1
                second_digit = 0; %outdoor/outdoor
            elseif type == 2
                second_digit = 1; %indoor/indoor
            elseif type == 3
                second_digit = 3; %indoor/outdoor
            elseif type == 4
                second_digit = 4; %outdoor/indoor
            end
            
            last_digit = 1:length(indx);
            
            for i=1:length(indx)
                code_num(i) = str2num(strcat(num2str(cond), num2str(second_digit), num2str(reward), num2str(last_digit(i))));
            end
            
            test_mat2(16,indx) = code_num;
            test_mat2(16,indx+1) = code_num;
            
            if reward == 1
                neutral_stim = decision_pairings{cond}{type}(:,2:5)';
                test_mat2(17:20,indx) = neutral_stim;
                test_mat2(17:20,indx+1) = neutral_stim;
            end
        end
    end
end

row.codenum = 16; %update row structure
row.neutral1 = 17; %update row structure
row.neutral2 = 18; %update row structure
row.neutral3 = 19; %update row structure
row.neutral4 = 20; %update row structure

%% Assign a location condition to each pair (L and R refer to screen location of rewarded stimulus)
% 1:LLRR 
% 2:LRLR
% 3:LRRL
% 4:RRLL
% 5:RLRL
% 6:RLLR

%1:Left 2:Right
locs{1} = [1 1 2 2];
locs{2} = [1 2 1 2];
locs{3} = [1 2 2 1];
locs{4} = [2 2 1 1];
locs{5} = [2 1 2 1];
locs{6} = [2 1 1 2];

nLocations=6;
% for cond=1:nCond 
%     for type=1:nPairtypes 
%             indx = test_mat2(row.Index, test_mat2(row.cond,:) == cond & test_mat2(row.pairtype,:) == type & test_mat2(row.rewardcond,:) == 1 & test_mat2(row.order,:)==1); %get rewarded pairs for each pairtype within condition
%             indx = test_mat2(row.Index, test_mat2(row.cond,:) == cond & test_mat2(row.rewardcond,:) == 1 & test_mat2(row.order,:)==1);
%             test_mat2(21,indx) = Shuffle(1:nLocations);
%             test_mat2(21,indx+1) = test_mat2(21,indx);
%     end
% end

for cycle = 1:nCycles_reward
    indx = test_mat2(row.Index, test_mat2(row.cycle,:) == cycle & test_mat2(row.rewardcond,:) == 1 & test_mat2(row.order,:)==1);
    shuffle_locs = Shuffle(repmat(1:nLocations,1,4));
    test_mat2(21,indx) = shuffle_locs;
    test_mat2(21,indx+1) = test_mat2(21,indx);
end

row.location = 21; %update row structure

%% expand test_mat2 to create Reward and Decision phase 
for cycle = 1:nCycles_reward 
    %% Reward Phase
    index = test_mat2(row.Index, test_mat2(row.cycle,:) == cycle & test_mat2(row.order,:)==1); %index columns included in Reward task (A items only)
    temp = test_mat2(1:row.rewardcond,index);
    
%     reward_trial = zeros(15,1);
%     reward_trial(row.imgID,1) = 888; % code for reward image
%     neutral_trial = zeros(15,1);
%     neutral_trial(row.imgID,1) = 999;
    
    for blk = 1:nReps_reward_total
        reward_mat{cycle}{blk} = [];
        temp(row.Index,:) = Shuffle(1:length(temp)); %update index row with new trial order
        reward_mat{cycle}{blk} = sortcols(temp, row.Index); 
%         temp2 = reward_mat{cycle}{blk};
%         temp3 = [];
        temp3 = reward_mat{cycle}{blk};
%         for i=1:length(temp2)
%             this_trial = temp2(:,i);
%             this_rewardcond = temp2(row.rewardcond,i);
%             if this_rewardcond == 1 %if reward trial
%                 temp3 = [temp3 this_trial reward_trial]; %concatenate trials
%             elseif this_rewardcond == 2
%                 temp3 = [temp3 this_trial neutral_trial];
%             end
%         end

        if blk == 1 %familiarization
            temp3(row.Index,:) = 1:length(temp3); %update trial numbers
            temp3(16,:) = disdaq + [0:size(temp3,2)-1]*trialDur_familiarization; %insert timing
        else
        end

        reward_mat{cycle}{blk} = temp3;
        clear temp3
    end
    
    clear index temp
    
    %combine blocks 2-3(=run1) and blocks 4-5(=run2)
    temp=[];
    for blk = 2:3
        temp = [temp reward_mat{cycle}{blk}];
    end
    temp(row.Index,:) = 1:length(temp); %update trial numbers
    temp(16,:) = disdaq + [0:size(temp,2)-1]*trialDur_reward; %insert timing
    
    reward_mat{cycle}{2} = temp;
    reward_mat{cycle}{3} = [];
    clear temp
    
    temp=[];
    for blk = 4:5
        temp = [temp reward_mat{cycle}{blk}];
    end
    
    temp(row.Index,:) = 1:length(temp); %update trial numbers
    temp(16,:) = disdaq + [0:size(temp,2)-1]*trialDur_reward; %insert timing
    
    reward_mat{cycle}{3} = temp;
    reward_mat{cycle}{4} = [];
    reward_mat{cycle}{5} = [];
    clear temp
    
    %make sure same scene isn't tested back-to-back
    for blk=2:3
        for i=2:length(reward_mat{cycle}{blk})
            this_img = reward_mat{cycle}{blk}(row.imgID,i);
            previous_img = reward_mat{cycle}{blk}(row.imgID,i-1);
            if this_img == previous_img %then check subcategory (they shouldn't match)
                this_subcat = reward_mat{cycle}{blk}(row.lower,i);
                previous_subcat = reward_mat{cycle}{blk}(row.lower,i-1);
                if this_subcat == previous_subcat
                    ('ERROR: repeating scene during reward phase')
                    subj
                    blk
                    i
                end
            end
        end
    end
    
    %% Decision Phase
    % save neutral stim info
    index = test_mat2(row.Index, test_mat2(row.cycle,:) == cycle & test_mat2(row.rewardcond,:) == 2); %A and B neutral scenes
    neutral_stim_info{cycle} = test_mat2(1:row.codenum,index);
    neutral_stim_info{cycle}(row.Index,:) = 1:length(neutral_stim_info{cycle});
    clear index
    
    index = test_mat2(row.Index, test_mat2(row.cycle,:) == cycle & test_mat2(row.rewardcond,:) == 1); %rewarded A and B scenes
    temp = test_mat2(row.cond:row.rewardcond,index);
    
    for blk=1:nReps_decision
        temp(16,:) = test_mat2(16+blk,index); %get neutral stim for that block and put in row 16
        for i=1:length(temp) %convert neutral codenum to info needed to find image (subcat and imgID)
            AorB = temp(row.order,i);
            neutralcode = temp(row.codenum,i);
            get_neutralstim = neutral_stim_info{cycle}(row.Index,(neutral_stim_info{cycle}(row.order,:) == AorB & neutral_stim_info{cycle}(row.codenum,:) == neutralcode));
            neutral_subcat = neutral_stim_info{cycle}(row.lower, get_neutralstim);
            neutral_imgID = neutral_stim_info{cycle}(row.imgID, get_neutralstim);
            
            %check to make sure rewarded and neutral subcategories match
            if neutral_subcat == temp(row.lower,i)
            else
                ('ERROR! Decision phase subcategories do not match.')
                cycle
                blk
                i
            end
            
            temp(17:18,i) = [neutral_subcat neutral_imgID]'; %add neutral image info to rows 17 and 18
        end
        
        %convert location condition code to actual location of rewarded image for that block
        temp(19,:) = test_mat2(row.location,index); %copy location info to row 19
        for i=1:length(temp)
            this_loccond = temp(19,i);
            actual_loc = locs{this_loccond}(blk);
            temp(19,i) = actual_loc; 
        end
        
        decision_mat{cycle}{blk}=[];
        temp(row.Index,:) = Shuffle(1:length(temp));  %update index row with new trial order
        decision_mat{cycle}{blk} = sortcols(temp, row.Index);
        
        %decision_mat{cycle}{blk}(row.Index,:) = 1:length(decision_mat{cycle}{blk}); %update trial numbers
%         decision_mat{cycle}{blk}(20,:) = disdaq + [0:size(decision_mat{cycle}{blk},2)-1]*trialDur_decision; %insert timing
    end
    
    %combine blocks 1-4(=run1)
    temp=[];
    for blk = 1:4
        temp = [temp decision_mat{cycle}{blk}];
    end
    temp(row.Index,:) = 1:length(temp); %update trial numbers
    temp(20,:) = disdaq + [0:size(temp,2)-1]*trialDur_decision; %insert timing
    
    decision_mat{cycle}{1} = temp;
    decision_mat{cycle}{2} = [];
    decision_mat{cycle}{3} = [];
    decision_mat{cycle}{4} = [];
    
    %make sure same scene isn't tested back-to-back
    
    clear index temp    
end %for cycle

    %% save the data
    save([out_mat_dir '/reward_mat_' SN], 'reward_mat');
    save([out_mat_dir '/decision_mat_' SN],'decision_mat');
    save([out_mat_dir '/test_mat2_' SN], 'test_mat2', 'decision_pairings', 'neutral_stim_info');
    
    clear learning_mat reward_mat decision_mat neutral_stim_info test_mat2
end%for subj

%% condition rows
% test_mat2_row.cond = row.cond; %stat learning condition
% test_mat2_row.rep = 2; %pair repetition
% test_mat2_row.pairID = 3; %pair number (1 thru nPair)
% test_mat2_row.ipi = 4; %inter-pair interval
% test_mat2_row.order = row.order; %trial order within pair
% test_mat2_row.lower = row.lower; % subcategory (1) female or indoor (2) male or outdoor
% test_mat2_row.upper = 7; % face (1) or scene (2)
% test_mat2_row.imgID = 8; %image number
% test_mat2_row.trial = 9; %original learning block trial timing
% test_mat2_row.postlearningBlk = 10; %
% test_mat2_row.learningBlk = 11; %original learning block 1-6
% test_mat2_row.indx = row.Index; %index
% test_mat2_row.pairtype = row.pairtype; % 1:outdoor/outdoor 2:indoor/indoor 3:indoor/outdoor 4:outdoor/indoor
% test_mat2_row.cycle = row.cycle; %1 or 2
% test_mat2_row.rewardcond = row.rewardcond; %1:reward 2:neutral
% test_mat2_row.conditionIndx = row.codenum; %see notes above for coding scheme
% test_mat2_row.neutral1 = 17; %conditionIndx of neutral stim paired with reward stim 1st time
% test_mat2_row.neutral2 = 18; %conditionIndx of neutral stim paired with reward stim 2nd time
% test_mat2_row.neutral3 = 19; %conditionIndx of neutral stim paired with reward stim 3rd time
% test_mat2_row.neutral4 = 20; %conditionIndx of neutral stim paired with reward stim 4th time
% test_mat2_row.location = 21; %screen location counterbalance (balanced within cycle only)
% save([out_mat_dir '/test_mat2_row'], 'test_mat2_row');
% 
% %
% reward_mat_row.cond = row.cond; %stat learning condition
% reward_mat_row.rep = 2; %pair repetition
% reward_mat_row.pairID = 3; %pair number (1 thru nPair)
% reward_mat_row.ipi = 4; %inter-pair interval
% reward_mat_row.order = row.order; %trial order within pair
% reward_mat_row.lower = row.lower; % subcategory (1) female or indoor (2) male or outdoor
% reward_mat_row.upper = 7; % face (1) or scene (2)
% reward_mat_row.imgID = 8; %image number
% reward_mat_row.trial = 9; %original learning block trial timing
% reward_mat_row.postlearningBlk = 10; %
% reward_mat_row.learningBlk = 11; %original learning block 1-6
% reward_mat_row.indx = row.Index; %index
% reward_mat_row.pairtype = row.pairtype; % 1:outdoor/outdoor 2:indoor/indoor 3:indoor/outdoor 4:outdoor/indoor
% reward_mat_row.cycle = row.cycle; %1 or 2
% reward_mat_row.rewardcond = row.rewardcond; %1:reward 2:neutral
% reward_mat_row.time = 16; %stimulus onset time
% reward_mat_row.Resp = 17;
% reward_mat_row.RT = 18;
% reward_mat_row.ACC = 19;
% reward_mat_row.onset = 20;
% reward_mat_row.recorded = 21;
% reward_mat_row.fMRItrigger = 22;
% reward_mat_row.onsetOutcome = 20;
% reward_mat_row.recordedOutcome = 21;
% reward_mat_row.fMRItriggerOutcome = 22;
% save([out_mat_dir '/reward_mat_row'], 'reward_mat_row');
% 
% %
% decision_mat_row.cond = row.cond; %stat learning condition
% decision_mat_row.rep = 2; %pair repetition
% decision_mat_row.pairID = 3; %pair number (1 thru nPair)
% decision_mat_row.ipi = 4; %inter-pair interval
% decision_mat_row.order = row.order; %trial order within pair
% decision_mat_row.lower = row.lower; % subcategory (1) female or indoor (2) male or outdoor
% decision_mat_row.upper = 7; % face (1) or scene (2)
% decision_mat_row.imgID = 8; %image number
% decision_mat_row.trial = 9; %original learning block trial timing
% decision_mat_row.postlearningBlk = 10; %
% decision_mat_row.learningBlk = 11; %original learning block 1-6
% decision_mat_row.indx = row.Index; %index
% decision_mat_row.pairtype = row.pairtype; % 1:outdoor/outdoor 2:indoor/indoor 3:indoor/outdoor 4:outdoor/indoor
% decision_mat_row.cycle = row.cycle; %1 or 2
% decision_mat_row.rewardcond = row.rewardcond; %1:reward 2:neutral
% decision_mat_row.neutral_codenum = 16; 
% decision_mat_row.neutral_subcat = 17; %1:indoor 2:outdoor
% decision_mat_row.neutral_imgID = 18;
% decision_mat_row.reward_screenLoc = 19; %rewarded scene is shown on left(1) or right(2) side of screen
% decision_mat_row.time = 20; %stimulus onset time
% decision_mat_row.Resp = 21;
% decision_mat_row.RT = 22;
% decision_mat_row.ACC = 23;
% decision_mat_row.onset = 24;
% decision_mat_row.recorded = 25;
% decision_mat_row.fMRItrigger = 26;
% save([out_mat_dir '/decision_mat_row'], 'decision_mat_row');
end