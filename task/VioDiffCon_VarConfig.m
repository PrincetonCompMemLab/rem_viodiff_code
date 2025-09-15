%% variable configuration
% 022215, gtk
% edited by eam 9/28/17
% edited by eam 9/4/18
% edited by eam 11/30/18 revert to 2 task conditions

% % set to 0 for creating task versions
% fMRI = 0; %make sure this is uncommented when actually running task

%% Condition Settings
nCond = 2; %number of task conditions
% Condition 1: Violation + restudy V+R+ (AB-AB-AB-AX-B-AY-B)
% Condition 2: No violation control V-R+ (AB-AB-AB-B-B)

nPair{1} = 8; %number of pairs per run per condition
nPair{2} = 8;

nItemPair{1} = 2;
nItemPair{2} = 2;

nRep{1} = 7;%3 reps of AB, and AX-B-AY-B (4)
nRep{2} = 5;%3 reps of AB, and B-B (2)

nTrials{1} = 12; %M+R+ (AB-AB-AB-AX-B-AY-B)
nTrials{2} = 8; %M-R+ (AB-AB-AB-B-B)

%% # of blocks
nBlk_learning = 6; %stat learning runs
nBlk_postlearning_scenes = 1; %postlearning SCENES
nBlk_postlearning_faces = 1; %postlearning FACES

nCycles_reward = 2; %reward-decision cycles for reward association task
nBlk_familiarization = 1; %familiarization runs per cycle
nReps_reward = 4; %number of reward+feedback learning repetitions per item
nReps_decision = 4; %number of decision trials per item
nBlk_reward = 2; %number of reward learning runs per cycle
nBlk_decision = 1; %number of decision runs per cycle 

nReps_reward_total = nReps_reward + nBlk_familiarization; 

nTrials_debugmode = 5; %number of trials for each run when debugging

%% img related
nSup = 2;% Categories 1:face, 2:scene
nSub = 2;% Subcategories face - 1:female, 2:male, scene = 1:indoor, 2:outdoor

for sup = 1:nSup
    for sub = 1:nSub
        if sup == 1 % if face
            nImg_learning_blk{sup}{sub} = (nPair{1}*nItemPair{1})/nSub; %number of faces/subcategory/block
        else % if scene
            nImg_learning_blk{sup}{sub} = nPair{1}*nItemPair{1}*nCond/nSub; %number of scenes/subcategory/block
        end
        nImg_learning{sup}{sub} = nImg_learning_blk{sup}{sub}*nBlk_learning; %total num images/subcategory
        nImg_foler{sup}{sub} = nImg_learning{sup}{sub};
    end%for sub
end%for sup
clear sup sub

%% # of trials per blk

nTrial_learning_blk = 0;
nTrial_prestudy = 0;
nTrial_postlearning_scenes = 0;
nTrial_postlearning_faces = 0;

for cond = 1:nCond % all values are number of trials per block
    nTrial_learning_blk = nTrial_learning_blk + nPair{cond}*nTrials{cond};
    nTrial_prestudy = nTrial_prestudy + nPair{cond}*nItemPair{cond}; %number of items presented during prestudy (every scene from each pair in each condition)
    nTrial_postlearning_scenes = nTrial_postlearning_scenes + (nPair{cond}*nBlk_learning)/nBlk_postlearning_scenes; %only B scenes included in postlearning snapshot
end

for cond = 1 %only condition with faces
    nTrial_postlearning_faces = nTrial_postlearning_faces + (nPair{cond}*nBlk_learning*2)/nBlk_postlearning_faces;
end

nTrial_learning_total = nTrial_learning_blk+nTrial_prestudy; %number of trials/block learning phase (combine prestudy and learning trials)

clear cond

%% directory related
% directory for matrix
curr_dir = pwd;
out_mat_dir = [curr_dir '/out_mat'];

% directory for output
curr_dir = pwd;

if fMRI == 1
    output_dir = [curr_dir '/output_skyra'];
elseif fMRI == 0
    output_dir = [curr_dir '/output_debug'];
end

% directory for copying to server
server_dir = '/path/to/server/directory/data/behavioral';

% directory for anal
curr_dir = pwd;
anal_dir = [curr_dir '/Anal'];

% directory for stim
curr_dir = pwd;
supClass = {'face', 'scene'};
subClass{1} = {'female', 'male'};
subClass{2} = {'indoor', 'outdoor'};

for sup = 1:nSup
    for sub = 1:nSub
        stim_dir{sup}{sub} = [curr_dir '/stim/' supClass{sup} '/' subClass{sup}{sub}];
        stim_practice_dir{sup}{sub} = [curr_dir '/stim/' supClass{sup} '/unused/' subClass{sup}{sub}];
    end%for sub
end%for sup

%% time related
disdaq = 12;
post_disdaq = 18;
trialDur = 3; %stat learning
trialDur_familiarization = 4.5;
trialDur_reward = 6;
trialDur_decision = 3;
TR = 1.5;

%%
nRepPair = 3;
vioRep{1} = [nRepPair+1 nRepPair+3]; %V+R+ violation trials are 4,6
DiffRep{1} = [nRepPair+2 nRepPair+4]; %restudy trials are 5,7

vioRep{2} = [];
DiffRep{2} = [nRepPair+1 nRepPair+2]; %restudy trials are 4,5; no violation trials

%% Decision Phase Settings
nPairtypes = 4; %o/o i/i i/o o/i
nTestreps = 4; %number of decision preference trials per pair
nPairtypes_cond = 48/nPairtypes/2; %total num pairs per condition/pairtypes and split in half (1/2 rewarded, 1/2 neutral)

%% subj
subjList = [4:105];

