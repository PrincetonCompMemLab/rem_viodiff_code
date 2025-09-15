%edited by eam 9/4/18
%modified by eam 1/14/19 for 2 task conditions

function paramSetting
%%
fMRI = 0;
VioDiffCon_VarConfig;
%%
param.nCond = nCond;
param.nPair{1} = nPair{1};
param.nPair{2} = nPair{2};

param.nItemPair{1} = nItemPair{1};
param.nItemPair{2} = nItemPair{2};

param.nRep{1} = nRep{1};
param.nRep{2} = nRep{2};
%%
param.nSession = 2; %1:pre, 2:post
param.nPhase = [1 2]; %pre(learning only), post(postlearning scenes, reward familiarization, reward + feedback, decision, postlearning faces, localizer)

% Session 1: learning
param.learning.nRun = nBlk_learning;
param.learning.runLength = 406;%in TR
param.learning.nTrial_blk = nTrial_learning_total; %total number of trials
param.learning.nTrial_prestudy = nTrial_prestudy; %number of prestudy trials
param.learning.dur_trial = trialDur;

% Session 2: postScenes and postFaces
param.postStudy.nRun = 1;
param.postStudy.runLength = 214;%in TR
param.postStudy.nTrial_blk = 96; %total number of trials
param.postStudy.dur_trial = trialDur;

% Session 2: familiarization
param.familiarization.nRun = nBlk_familiarization*nCycles_reward;
param.familiarization.runLength = 166;%in TR
param.familiarization.nTrial_blk = 48; %total number of trials
param.familiarization.dur_trial = trialDur_familiarization;

% Session 2: reward
param.reward.nRun = nBlk_reward*nCycles_reward;
param.reward.runLength = 406;%in TR
param.reward.nTrial_blk = 96; %total number of trials
param.reward.dur_trial = trialDur_reward;

% Session 2: decision
param.decision.nRun = nBlk_decision*nCycles_reward;
param.decision.runLength = 406;%in TR
param.decision.nTrial_blk = 192; %total number of trials
param.decision.dur_trial = trialDur_decision;


%% img related
param.nSup = 2;%1:face, 2:scene
param.nSub = 2;%face - 1:female, 2:male, scene = 1:indoor, 2:outdoor
%param.nLure = nLure;

%% fMRI related
param.durTR = 1.5;
param.shiftTR = 3;

%% %%%%%%%%%%%% localizer related
localizer_FSO_VarConfig;

%% img related
param.loc.nSup = 3;%1:face, 2:scene, 3:object
param.loc.nSub = 2;%face - 1:female, 2:male, scene = 1:indoor, 2:outdoor, object = 1:natural, 2:manmade

param.loc.nRun = nRun;
param.loc.runLength = 311;%in TR

param.loc.nTrial_blk = nTrial_blk;
param.loc.nTrial_run = nTrial_run;

param.loc.dur_trial = trialDur;

%% save
% curr_dir = pwd;
% out_mat_dir = [curr_dir '/out_mat'];
out_mat_dir = '/path/to/study/directory/data';
save([out_mat_dir '/paramSave'], 'param')
