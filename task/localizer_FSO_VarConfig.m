%% variable configuratioin of localizer
% 022215, gtk
% 012918, eam

%% category related
%fMRI = 0; %make sure this is set to 1 for fMRI
nSup = 3;%1:face, 2:scene, 3:object
nSub = 2;%face - 1:female, 2:male, scene = 1:indoor, 2:outdoor, object = 1:natural, 2:manmade
%% # of blocks
nRun = 2;
nBlk = 15;
nBlk_sup = nBlk/nSup;
%% img related
nImg_sub_blk = 5;% # of img (of each sub-category) per each run (5 for each block)
nImg_sub_run = 5 * nBlk_sup;% # of img (of each sub-category) per each run (5 for each blcok)
nImg_sub = nImg_sub_run * nRun;% # of img of each sub-category
%% # of trial
nTrial_blk = nImg_sub_blk*nSub;
nTrial_run = nTrial_blk * nBlk;
%% time related
disdaq = 12;
post_disdaq = 18;
trialDur = 1.5;
restDur = trialDur*nTrial_blk;
blkDur = trialDur*nTrial_blk;
%% directory related
% directory for matrix
curr_dir = pwd;
out_mat_dir = [curr_dir '/out_mat'];

% directory for output
curr_dir = pwd;
% output_dir = [curr_dir '/output'];

if fMRI == 1
    output_dir = [curr_dir '/output_skyra'];
else
    output_dir = [curr_dir '/output_debug'];
end

% directory for copying to server
server_dir = '/path/to/server/directory/data/behavioral';

% directory for anal
curr_dir = pwd;
anal_dir = [curr_dir '/Anal'];

% directory for stim
curr_dir = pwd;
supClass = {'face', 'scene', 'object'};
subClass{1} = {'female', 'male'};
subClass{2} = {'indoor', 'outdoor'};
subClass{3} = {'natural', 'manmade'};

for sup = 1:nSup
    for sub = 1:nSub
        stim_dir{sup}{sub} = [curr_dir '/stim_loc/' supClass{sup} '/' subClass{sup}{sub}];
    end%for sub
end%for sup

%% subj
subjList = [4:105];
