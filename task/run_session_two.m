%%
global deburg

deburg = 1; %1 for debug settings
fMRI = 0; %0 for running outside scanner
sid='999';
version='999';
study_name='SVD';

nRuns_postlearning_scenes = 0;
nRuns_postlearning_faces = 1;
nCycles_reward_decision = 2;
nRuns_familiarization = 1; %runs per cycle
nRuns_reward = 2; %runs per cycle
nRuns_decision = 1; %runs per cycle

for i=1:nRuns_postlearning_scenes %postlearning SCENES
    VioDiffCon_postScenes(sid,study_name,i,fMRI,version);
    fprintf('Just completed postlearning SCENES run %d\n',i);
end

reward_runs = [1 2; 3 4];
for c=1:nCycles_reward_decision
    for i=1:nRuns_familiarization
        VioDiffCon_familiarization(sid,study_name,i*c,fMRI,version);
        fprintf('Just completed familiarization run %d\n',i*c);
    end
    
    for i=1:nRuns_reward
        r = reward_runs(c,i);
        VioDiffCon_reward(sid,study_name,r,fMRI,version);
        fprintf('Just completed REWARD run %d\n',r);
    end
    
    for i=1:nRuns_decision
        VioDiffCon_decision(sid,study_name,i*c,fMRI,version);
        fprintf('Just completed DECISION run %d\n',i*c);
    end
    
    fprintf('Just completed CYCLE %d\n',c);
end
    
for i=1:nRuns_postlearning_faces %postlearning FACES
    VioDiffCon_postFaces(sid,study_name,i,fMRI,version);
    fprintf('Just completed postlearning FACES run %d\n',i);
end
