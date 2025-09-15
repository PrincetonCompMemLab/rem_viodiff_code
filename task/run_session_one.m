%%
global deburg

deburg = 1; %1 for debug settings
fMRI = 0; %0 for running outside scanner
sid='999';
version='999';
study_name='SVD';

nRuns_learning = 6;

for i=1:nRuns_learning
    VioDiffCon_learning(sid,study_name,i,fMRI,version); %for fMRI
    fprintf('Just completed learning run %d\n',i);
end

%% for debugging

% for i=3:3
%     VioDiffCon_learning('999','SV01',i,0); %for debugging
%     fprintf('Just completed learning run %d\n',i);
% end