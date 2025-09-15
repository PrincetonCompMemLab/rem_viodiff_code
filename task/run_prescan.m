%%
global deburg

deburg = 0; %1 for debug settings
fMRI = 1; %0 for running outside scanner
sid='101';
version='01';
left_handed=0;
study_name='SVD';

nRuns_localizer = 2;

for i=1:nRuns_localizer %functional localizer
    localizer_FSO(sid,study_name,i,fMRI,version, left_handed);
    fprintf('Just completed LOCALIZER run %d\n',i);
end

%% for debugging

% for i=1:1 %postlearning SCENES
%     VioDiffCon_postStudy_scenes('999',study_name,i,0); %for debugging
%     fprintf('Just completed postlearning SCENES run %d\n',i);
% end

% for i=1:1 %postlearning FACES
%     VioDiffCon_postStudy_faces('999',study_name,i,1); 
%     fprintf('Just completed postlearning FACES run %d\n',i);
% end

% for i=1:1 %functional localizer
%     localizer_FSO('999','SV01',i,0); %for debugging
%     fprintf('Just completed localizer run %d\n',i);
% end