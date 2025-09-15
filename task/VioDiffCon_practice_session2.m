%%
global deburg

deburg = 0; %1 for debug settings
sid='179';
left_handed=0;
% 
VioDiffCon_practice_familiarization(sid,'SVD',1,0,'practice');
VioDiffCon_practice_reward(sid,'SVD',1,0,'practice', left_handed);
VioDiffCon_practice_decision(sid,'SVD',1,0,'practice');
