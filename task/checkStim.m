% check stim pairs
close all; clear all

fMRI = 0; 
subj=999;
if subj < 10
    SN = ['0' num2str(subj)];
else
    SN = [num2str(subj)];
end%if subj

VioDiffCon_VarConfig;

load([out_mat_dir '/learning_mat_' SN])
load([out_mat_dir '/learning_mat_row'])
load([out_mat_dir '/postScenes_mat_' SN])
load([out_mat_dir '/postFaces_mat_' SN])
load([out_mat_dir '/postStudy_mat_row'])
load([out_mat_dir '/reward_mat_' SN])
load([out_mat_dir '/reward_mat_row'])
load([out_mat_dir '/decision_mat_' SN])
load([out_mat_dir '/decision_mat_row'])

learning_pairs = [];
row = learning_mat_row;
for block = 1:nBlk_learning
    for i=1:length(learning_mat{block})
        this_trial = learning_mat{block}(:,i)';
        learning_pairs = [learning_pairs; block i this_trial];
    end
end

learning_pairs2 = [];
for i=1:length(learning_pairs)
    this_cond = learning_pairs(i,3);
    this_order = learning_pairs(i,7);
    if this_order == 1
        fill = [13:15];
    else 
        fill = [16:18];
    end
    this_category = learning_pairs(i,9);
    this_subcategory = learning_pairs(i,8);
    this_imgID = learning_pairs(i,10);
    %result = strcat(num2str(this_category),'.', num2str(this_subcategory),'.', num2str(this_imgID)); 
    if this_cond == 4
        learning_pairs2(i,1:12) = learning_pairs(i,:);
        learning_pairs2(i,fill) = [this_category this_subcategory this_imgID];
    else
        if this_order == 1
            learning_pairs2(i,1:12) = learning_pairs(i,:);
            learning_pairs2(i,fill) = [this_category this_subcategory this_imgID];
        else 
            learning_pairs2(i-1,fill) = [this_category this_subcategory this_imgID];
        end
    end
end

    

postscene_pairs = [];
row = postStudy_mat_row;
for block = 1:nBlk_postlearning_scenes
    for i=1:length(postStudy_scenes_mat{block})
        this_trial = postStudy_scenes_mat{block}(:,i)';
        postscene_pairs = [postscene_pairs; block i this_trial];
    end
end

postface_pairs = [];
row = postStudy_mat_row;
for block = 1:nBlk_postlearning_faces
    for i=1:length(postStudy_faces_mat{block})
        this_trial = postStudy_faces_mat{block}(:,i)';
        postface_pairs = [postface_pairs; block i this_trial];
    end
end

familiarization_pairs = [];
row = reward_mat_row;
for cycle = 1:nCycles_reward
    for block = 1:nBlk_familiarization
        for i=1:length(reward_mat{cycle}{block})
            this_trial = reward_mat{cycle}{block}(:,i)';
            familiarization_pairs = [familiarization_pairs; cycle i this_trial];
        end
    end
end

reward_pairs = [];
row = reward_mat_row;
for cycle = 1:nCycles_reward
    for block = 2:1+nBlk_reward
        for i=1:length(reward_mat{cycle}{block})
            this_trial = reward_mat{cycle}{block}(:,i)';
            reward_pairs = [reward_pairs; cycle block i this_trial];
        end
    end
end

decision_pairs = [];
row = decision_mat_row;
for cycle = 1:nCycles_reward
    for block = 1:nBlk_decision
        for i=1:length(decision_mat{cycle}{block})
            this_trial = decision_mat{cycle}{block}(:,i)';
            decision_pairs = [decision_pairs; cycle i this_trial];
        end
    end
end
        




