function VioDiffCon_practice_familiarization(SN,NM,block,fMRI,version)
global deburg

% for practice, always enter real SN (to get correct keymappings) and
% version = 'practice' (to use junk stimuli)

if nargin == 0
    SN = '999'; NM = 'SVD'; block = 1; fMRI = 0; deburg = 0; version='practice';
end%if isempty

this_subj = str2num(SN);
%% boilerplate
seed = sum(100*clock);
rand('twister',seed);
ListenChar(2);
HideCursor;
GetSecs;

% obtain platform-independent responses
KbName('UnifyKeyNames');
KbQueueCreate; %creates cue using defaults
KbQueueStart; %starts the cue

%GO=KbName('g');
GO='1';
LEFT = KbName('1!');%indoor
RIGHT = KbName('2@');%outdoor
EXIT = KbName('q');
THREE = KbName('3#');
FOUR = KbName('4$');
keys = [LEFT RIGHT THREE FOUR EXIT];

%% variables
VioDiffCon_VarConfig;
common.set_device;
% getKeypress; %no keypress during familiarization phase

%% Vars related to screens and timing
stimDuration = 1.0; % in seconds
fixDuration = 0.5;
blinkTime = 0.5;
blinkDur = 0.1;
numBlinks = 1;
leadTime = 0.1; % start waiting for trigger this much time before desired start
respWindow = 1.5;
allowance = 0.05; % stop waiting for trigger after this

textColor = 0;
textFont = 'Arial';
textSize = 24;
textSpacing = 25;
fixColor = 0;
respColor = 255;
backColor = 127;
imageSize = 256; % assumed square (this is variable for scene image size)
fixationSize = 4; % pixels
progWidth = 400; % image loading progress bar
progHeight = 20;
yposition = 200;%how to lower the recog & confi rects

%% load the data seqs for learning phase
%load([out_mat_dir '/reward_mat_' SN], 'reward_mat');
load([out_mat_dir '/reward_mat_' version], 'reward_mat');
load([out_mat_dir '/reward_mat_row'], 'reward_mat_row');
data = reward_mat{1}; %block == cycle and familiarization is always first run of the cycle
data_rows = reward_mat_row;

if deburg
    nTrials_thisrun = nTrials_debugmode;
else
    nTrials_thisrun = size(data);
    nTrials_thisrun = nTrials_thisrun(2);
end%if deburg

%% set-up screens
[screenNum, screenX, screenY, centerX, centerY, mainWindow, imageRect, centerRect, fixDotRect, refreshrate] = common.setup_screens(fMRI, backColor, textFont, textSize, imageSize, fixationSize);
'Familiarization'
block
nTrials_thisrun

%% load images
[textures, imgsize] = VioDiffCon_load_images_practice(mainWindow, data, data_rows, fMRI); %LM added fMRI has an input so that variable carries over to VioDiffCon_VarConf

% load reward and neutral outcome images
tempMat = imread('reward.jpg');
sss = size(tempMat);
imgsize_reward = sss(:,1:2);%size in 2D
texture_reward = Screen('MakeTexture',mainWindow,tempMat);
clear tempMat

tempMat = imread('neutral.jpg');
sss = size(tempMat);
imgsize_neutral = sss(:,1:2);%size in 2D
texture_neutral = Screen('MakeTexture',mainWindow,tempMat);
clear tempMat

%% Instructions

% page 1
common.clear_screen(mainWindow, backColor);
FlushEvents('keyDown');

% show instructions
%instructString{1} = 'NOTE: For the purpose of this practice session, the 1 and 2 buttons on the laptop will correspond to left and right.';
%instructString{2} = ' ';
instructString{1} = 'There will be 10 task runs in this session.';
instructString{2} = 'The first and last runs will be similar to what you did this morning.';
instructString{3} = 'In run 1, you will see SCENES only.';
instructString{4} = 'Again, for each SCENE, you should judge whether it is an indoor or outdoor scene.';
instructString{5} = 'In run 10, you will see FACES only.';
instructString{6} = 'For each FACE, you should judge whether it is a male or female face.';
instructString{7} = ' ';
instructString{8} = 'Please make your responses as quickly and accurately as possible.';
instructString{9} = 'The black fixation dot will turn white to indicate that your response has been recorded for that trial.';
instructString{10} = ' ';
instructString{11} = 'Press 1 to continue.';

for instruct=1:length(instructString)
    tempBounds = Screen('TextBounds',mainWindow,instructString{instruct});
    Screen('drawtext',mainWindow,instructString{instruct},centerX-tempBounds(3)/2,centerY/2-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
Screen('Flip',mainWindow);
common.wait_for_experimenter_ok(GO);
common.waiting_for_scanner(mainWindow, backColor);


% page 2
common.clear_screen(mainWindow, backColor);
FlushEvents('keyDown');
clear instructString

% show instructions
instructString{1} = 'In runs 2-9, you will be doing a reward learning task.';
instructString{2} = 'In this task, you will learn whether scenes are associated with a reward or neutral outcome.';
instructString{3} = 'This task is broken into 3 phases - FAMILIARIZATION, PREDICTION, and DECISION phases.';
instructString{4} = ' ';
instructString{5} = 'In the FAMILIARIZATION phase, you will see a scene followed by either an image of a $1 bill or a gray rectangle.';
instructString{6} = 'This represents a scene leading to either "winning $1" or "not winning"';
instructString{7} = ' ';
instructString{8} = 'During this phase you do not need to make any responses.';
instructString{9} = 'However, you should pay attention because in later parts of the experiment you will be asked';
instructString{10} = 'to make predictions and/or decisions about whether each scene leads to a reward or not. ';
instructString{11} = ' ';
instructString{12} = 'Press 1 to continue.';

for instruct=1:length(instructString)
    tempBounds = Screen('TextBounds',mainWindow,instructString{instruct});
    Screen('drawtext',mainWindow,instructString{instruct},centerX-tempBounds(3)/2,centerY/2-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
Screen('Flip',mainWindow);
common.wait_for_experimenter_ok(GO);
common.waiting_for_scanner(mainWindow, backColor);

% page 3
common.clear_screen(mainWindow, backColor);
FlushEvents('keyDown');
clear instructString

% show instructions
instructString{1} = 'Next, you will do two PREDICTION runs.';
instructString{2} = ' ';
instructString{3} = 'In this phase, you will see a scene and your task is to predict if that scene is rewarded or not (i.e., neutral).';
instructString{4} = 'You have 2.5 seconds to make a prediction, so respond as quickly and accurately as possible.';
instructString{5} = 'After you make your prediction, you will be shown the actual outcome, and any bonus points you might have won or lost on that trial.';
instructString{6} = ' ';
instructString{7} = 'This is how you can earn bonus points during this phase:';
instructString{8} = 'If you predict reward and the actual outcome is reward, you WIN +1 point.';
instructString{9} = 'If you predict reward and the actual outcome is neutral, you LOSE -1 point.';
instructString{10} = 'If you predict neutral, you will not win or lose any points, regardless of the outcome.';
instructString{11} = 'Therefore, the optimal strategy (to avoid losing points) is to only predict reward on trials'; 
instructString{12} = 'where you are fairly confident the actual outcome is reward.'; 
instructString{13} = 'You will be awarded a percentage of the bonus points you earn during this phase in a monetary bonus.';
instructString{14} = ' ';
instructString{15} = 'Press 1 to continue.';

for instruct=1:length(instructString)
    tempBounds = Screen('TextBounds',mainWindow,instructString{instruct});
    Screen('drawtext',mainWindow,instructString{instruct},centerX-tempBounds(3)/2,centerY/2-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
Screen('Flip',mainWindow);
common.wait_for_experimenter_ok(GO);
common.waiting_for_scanner(mainWindow, backColor);

% page 4
common.clear_screen(mainWindow, backColor);
FlushEvents('keyDown');
clear instructString

% show instructions
instructString{1} = 'Next, you will do a DECISION run.';
instructString{2} = ' ';
instructString{3} = 'In this phase, you will see two scenes on either side of the screen.';
instructString{4} = 'Your task is to choose the scene you think is more likely to lead to "winning" $1.';
instructString{5} = 'A blue frame will indicate which scene you chose.';
instructString{6} = 'If you correctly choose the winning scene, you will earn a bonus point.';
instructString{7} = ' ';
instructString{8} = 'You have 2.5 seconds to make a decision, so respond as quickly and accurately as possible.';
instructString{9} = 'It is extremely important that you make a response on each and every trial.';
instructString{10} = 'Even if you see scenes that were not shown during the prediction phase,';
instructString{11} = 'you should still choose which one you feel is more likely to lead to winning $1.';
instructString{12} = ' ';
instructString{13} = 'Press 1 to continue.';

for instruct=1:length(instructString)
    tempBounds = Screen('TextBounds',mainWindow,instructString{instruct});
    Screen('drawtext',mainWindow,instructString{instruct},centerX-tempBounds(3)/2,centerY/2-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
Screen('Flip',mainWindow);
common.wait_for_experimenter_ok(GO);
common.waiting_for_scanner(mainWindow, backColor);

% page 5
common.clear_screen(mainWindow, backColor);
FlushEvents('keyDown');
clear instructString

% show instructions
instructString{1} = 'You will do 2 full cycles of FAMILIARIZATION, PREDICTION (x2 runs), and DECISION phases.';
instructString{2} = 'Before getting in the scanner, you will now run through a quick practice cycle.';
instructString{3} = ' ';
instructString{4} = 'Press 1 to begin the practice.';

for instruct=1:length(instructString)
    tempBounds = Screen('TextBounds',mainWindow,instructString{instruct});
    Screen('drawtext',mainWindow,instructString{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
Screen('Flip',mainWindow);
common.wait_for_experimenter_ok(GO);
common.waiting_for_scanner(mainWindow, backColor);

% page 6
common.clear_screen(mainWindow, backColor);
FlushEvents('keyDown');
clear instructString

% show instructions
instructString{1} = 'This is a FAMILIARIZATION run.';
instructString{2} = ' ';
instructString{3} = 'Fixate on the circle in the center of the screen';
instructString{4} = 'Try to remember the reward or neutral outcome associated with each scene.';
instructString{5} = 'You do not need to make any responses during this phase.';
instructString{6} = 'Press 1 when you are ready to start!';

for instruct=1:length(instructString)
    tempBounds = Screen('TextBounds',mainWindow,instructString{instruct});
    Screen('drawtext',mainWindow,instructString{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
Screen('Flip',mainWindow);
common.wait_for_experimenter_ok(GO);
common.waiting_for_scanner(mainWindow, backColor);

% wait for initial trigger
Priority(MaxPriority(screenNum));
common.draw_fixation_dot(mainWindow, backColor, fixColor, fixDotRect);

if (fMRI == 1)
    runTime = WaitTRPulsePTB3_skyra(2);
else
    runTime = GetSecs;
end

Screen('Flip',mainWindow);
Priority(0);
%%
runLength = max(data(data_rows.time,:)) + trialDur;

%% start trial sequence
for trial=1:nTrials_thisrun
    xCond = data(data_rows.cond,trial);
    xRep = data(data_rows.rep,trial);%rep num
    xPairID = data(data_rows.pairID,trial);
    xIPI = data(data_rows.ipi,trial);%inter-pair-interval
    xOrder = data(data_rows.order,trial);
    xSup = data(data_rows.upper,trial);%1:face 2:scene
    xSub = data(data_rows.lower,trial);
    xImgNum = data(data_rows.imgID,trial); %888=reward 999=neutral
    xOnset = data(data_rows.time,trial);
    xOnset_outcome = xOnset+TR;
    xRewardCond = data(data_rows.rewardcond, trial);
    
    if xRewardCond == 1 %reward outcome
        xImgSize_outcome = imgsize_reward;%size of this img in 2D (y and x)
        trialImage_outcome = texture_reward; %load img texture
    elseif xRewardCond == 2 %neutral outcome
        xImgSize_outcome = imgsize_neutral;%size of this img in 2D (y and x)
        trialImage_outcome = texture_neutral; %load img texture
    end
    
    %resize outcome image
    imageRect_outcome = [0,0,imageSize*2,imageSize]; %make rectangle instead of square
    chRatio = imageRect_outcome(3)/max(xImgSize_outcome);
    xImgSize_outcome_resized = round([0 0 xImgSize_outcome(2)*chRatio xImgSize_outcome(1)*chRatio]);
    xCntRect_outcome = round([centerX-xImgSize_outcome_resized(3)/2, centerY-xImgSize_outcome_resized(4)/2,centerX+xImgSize_outcome_resized(3)/2,centerY+xImgSize_outcome_resized(4)/2]); %re-centering
    
    %scene image
    xImgSize = imgsize{xSup}{xSub}{xImgNum};%size of this img in 2D (y and x)
    trialImage = textures{xSup}{xSub}(xImgNum); %load img texture
    chRatio = imageRect(3)/max(xImgSize);
    xImgSize_resized = round([0 0 xImgSize(2)*chRatio xImgSize(1)*chRatio]);
    xCntRect = round([centerX-xImgSize_resized(3)/2, centerY-xImgSize_resized(4)/2,centerX+xImgSize_resized(3)/2,centerY+xImgSize_resized(4)/2]); %re-centering
    
    Screen('PreloadTextures',mainWindow, trialImage);
    Screen('PreloadTextures',mainWindow, trialImage_outcome);
    
    trialStart = xOnset+runTime;
    trialStart_outcome = xOnset_outcome+runTime;
    
    % blink fixation
    while(trialStart-GetSecs>blinkTime); end % wait until blink time
    common.draw_fixation_dot(mainWindow, backColor, fixColor, fixDotRect); %draw dot first, otherwise it does not blink
    startPrep = Screen('Flip',mainWindow);
    common.blink_fixation_dot(mainWindow, backColor, fixColor, fixDotRect, numBlinks, blinkDur, runTime, startPrep, refreshrate);
    
    % show image
    while(trialStart-GetSecs>leadTime); end % wait until fixation time
    [recorded, stimStart, fMRItrigger] = common.show_image(screenNum, mainWindow, trialImage, [], xCntRect, fixColor, fixDotRect, fMRI, trialStart, allowance, refreshrate, DEVICE);
    
    % start listening for responses -- no response required, but this will
    % record a response if subject erroneously responds
    [rt, response, qq] = common.listen_for_response(mainWindow, stimStart, respWindow, stimDuration, fixColor, fixColor, fixDotRect, keys, trialImage, [], xCntRect, [], DEVICE); %no response required, so don't change dot color
    
    %     % clear screen
    %     Screen(mainWindow,'FillRect',backColor);
    %     Screen('Flip',mainWindow);
    
    % show outcome
    while(trialStart_outcome-GetSecs>leadTime); end % wait until next TR
    [recorded_outcome, stimStart_outcome, fMRItrigger_outcome] = common.show_image(screenNum, mainWindow, trialImage_outcome, [], xCntRect_outcome, fixColor, fixDotRect, fMRI, trialStart_outcome, allowance, refreshrate, DEVICE);
    
    % clear screen
    Screen(mainWindow,'FillRect',backColor);
    Screen('Flip',mainWindow, stimStart_outcome+stimDuration-refreshrate/3);
    
    onset = stimStart - runTime;
    outcomeOnset = stimStart_outcome - runTime;
    %     scene_offset = onset - xOnset
    %     outcomeOffset = outcomeOnset - xOnset_outcome
    
    if fMRI == 1
        fMRItrigger = fMRItrigger - runTime; %convert to timing relative to onset
        fMRItrigger_outcome = fMRItrigger_outcome - runTime; %convert to timing relative to onset
    end
    
    % if subject accidentally responded
    if isnan(response)
        accuracy = NaN;
        response = 7;%no response
    else
        %         accuracy = keys(response) == correctKey;
        accuracy = NaN; %no response required
    end%if isnan
    
    % print trial results
    res_Inputs_names= {'block' 'trial' 'onset' 'plan' 'recorded' 'fMRItrigger'  'outcomeOnset' 'outcomePlan' 'outcomeRecorded' 'outcomefMRItrigger' 'xRewardCond' 'resp' 'acc' 'rt'};
    res_Inputs_values= [block trial onset xOnset recorded fMRItrigger outcomeOnset xOnset_outcome recorded_outcome fMRItrigger_outcome xRewardCond response accuracy rt];
    var_floats = {'onset' 'plan' 'fMRItrigger' 'outcomeOnset' 'outcomePlan' 'outcomefMRItrigger' 'rt'};
    common.write_log_data_v03(res_Inputs_names, res_Inputs_values, var_floats, trial);
    fprintf('\n');
    
    % recording in the data structure
    data(data_rows.Resp,trial) = response;
    data(data_rows.ACC,trial) = accuracy;
    data(data_rows.RT,trial) = rt;
    data(data_rows.onset,trial) = onset;
    data(data_rows.recorded,trial) = recorded;
    data(data_rows.fMRItrigger,trial) = fMRItrigger;
    data(data_rows.onsetOutcome, trial) = outcomeOnset;
    data(data_rows.recordedOutcome, trial) = recorded_outcome;
    data(data_rows.fMRItriggerOutcome, trial) = fMRItrigger_outcome;
    
    %escape
    if qq
        break
    end
    
    save([output_dir '/practice_familiarization_' SN '_block' num2str(block) '_' NM], 'data', 'data_rows', 'version');
    
end % trial loop

% save([output_dir '/data_familiarization_' SN '_block' num2str(block) '_' NM], 'data', 'data_rows');

common.clear_screen(mainWindow, backColor);
Screen('Flip',mainWindow);

if deburg
else
    if ~qq
        while(GetSecs-runTime < runLength); end
    end
end

if block == 1
    this_run = 2;
elseif block == 2
    this_run = 6;
end

% % save to server
% if deburg
% else
%     save([server_dir '/data_familiarization_' SN '_block' num2str(block) '_' NM], 'data', 'data_rows', 'version');
% end

%% clean up and go home
KbQueueRelease;
KbReleaseWait;
sca;
ListenChar(1);
fclose('all');

