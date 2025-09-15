function VioDiffCon_decision(SN,NM,block,fMRI,version)
global deburg
if nargin == 0
    SN = '999'; NM = 'SVD'; block = 1; fMRI = 0; deburg = 0; version='999';
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
% KbQueueCreate; %creates cue using defaults
% KbQueueStart; %starts the cue

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

KbQueueCreate(DEVICE); %creates cue using defaults
KbQueueStart(DEVICE); %starts the cue
%% Vars related to screens and timing

% Original size (before moving the projector screen back)
textSize = 18;
imageSize = 256; % assumed square
fixationSize = 4; % pixels

% % Updated size (after moving the projector screen back)
% textSize = 20;
% imageSize = round(256*1.125); % assumed square
% fixationSize = round(4*1.125); % pixels

stimDuration = 2.5; % in seconds
fixDuration = 0.5;
blinkTime = 0.5;
blinkDur = 0.1;
numBlinks = 1;
leadTime = 0.1; % start waiting for trigger this much time before desired start
respWindow = 2.5;
allowance = 0.05; % stop waiting for trigger after this

textColor = 0;
textFont = 'Arial';
textSpacing = 25;
fixColor = 0;
respColor = 255;
backColor = 127;
progWidth = 400; % image loading progress bar
progHeight = 20;
yposition = 200;%how to lower the recog & confi rects

%% load the data seqs for learning phase
%load([out_mat_dir '/decision_mat_' SN], 'decision_mat');
load([out_mat_dir '/decision_mat_' version], 'decision_mat');
load([out_mat_dir '/decision_mat_row'], 'decision_mat_row');
data = decision_mat{block}{1};
data_rows = decision_mat_row;
decisionphase_winnings{block} = [];
track_winnings = 0;

if deburg
    nTrials_thisrun = nTrials_debugmode;
else
    nTrials_thisrun = length(data);
end%if deburg

%% set-up screens
[screenNum, screenX, screenY, centerX, centerY, mainWindow, imageRect, centerRect, fixDotRect, refreshrate] = common.setup_screens(fMRI, backColor, textFont, textSize, imageSize, fixationSize);
'Decision Phase'
block
nTrials_thisrun

leftX = round(screenX*0.33); %Left side "center"
rightX = round(screenX*0.67); %Right side "center"

%% load images
[textures, imgsize] = VioDiffCon_load_images_decisionphase(mainWindow, data, data_rows, fMRI); %LM added fMRI has an input so that variable carries over to VioDiffCon_VarConf
%% Setups

% %set up diagnostic plot
% rd = common.response_diagnostics_gtv01(respWindow, nTrial_learning_total);

common.clear_screen(mainWindow, backColor);
FlushEvents('keyDown');

% show instructions
instructString{1} = 'This is a DECISION run.';
instructString{2} = ' ';
instructString{3} = 'Fixate on the circle in the center of the screen';
instructString{4} = 'Using the left and right buttons, report which scene you think is more likely to lead to winning $1';
instructString{5} = 'Press the left button when you are ready to start!';

for instruct=1:length(instructString)
    tempBounds = Screen('TextBounds',mainWindow,instructString{instruct});
    Screen('drawtext',mainWindow,instructString{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
Screen('Flip',mainWindow);

%common.wait_for_experimenter_ok('g');
%common.clear_screen(mainWindow, backColor);
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
runLength = max(data(data_rows.time,:)) + trialDur_decision + post_disdaq;

%% start trial sequence
for trial=1:nTrials_thisrun
    xCond = data(data_rows.cond,trial);%1:pair 2:single
    xRep = data(data_rows.rep,trial);%rep num
    xPairID = data(data_rows.pairID,trial);
    xIPI = data(data_rows.ipi,trial);%inter-pair-interval
    xOrder = data(data_rows.order,trial);
    xSup = data(data_rows.upper,trial);%1:face 2:scene
    xSub = data(data_rows.lower,trial);
    xImgNum = data(data_rows.imgID,trial);
    xOnset = data(data_rows.time,trial);
    
    xNeutralSub = data(data_rows.neutral_subcat,trial);
    xNeutralImgNum = data(data_rows.neutral_imgID,trial);
    
    xLoc = data(data_rows.reward_screenLoc,trial); %location of rewarded image
    correctKey = keys(1,xLoc); %response mapping
    
    % Rewarded image
    xImgSize = imgsize{xSup}{xSub}{xImgNum};%size of this img in 2D (y and x)
    chRatio = imageRect(3)/max(xImgSize);
    xImgSize_resized = round([0 0 xImgSize(2)*chRatio xImgSize(1)*chRatio]);
    if xLoc == 1 %rewarded image is on LEFT
        xCntRect_reward = round([leftX-xImgSize_resized(3)/2, centerY-xImgSize_resized(4)/2,leftX+xImgSize_resized(3)/2,centerY+xImgSize_resized(4)/2]); %re-centering
        leftRect = xCntRect_reward;
    elseif xLoc == 2 %rewarded image is on RIGHT
        xCntRect_reward = round([rightX-xImgSize_resized(3)/2, centerY-xImgSize_resized(4)/2,rightX+xImgSize_resized(3)/2,centerY+xImgSize_resized(4)/2]); %re-centering
        rightRect = xCntRect_reward;
    end
    
    % Neutral image
    xImgSize = imgsize{xSup}{xNeutralSub}{xNeutralImgNum};%size of this img in 2D (y and x)
    chRatio = imageRect(3)/max(xImgSize);
    xImgSize_resized = round([0 0 xImgSize(2)*chRatio xImgSize(1)*chRatio]);
    if xLoc == 1 %rewarded image is on left, neutral is on RIGHT
        xCntRect_neutral = round([rightX-xImgSize_resized(3)/2, centerY-xImgSize_resized(4)/2,rightX+xImgSize_resized(3)/2,centerY+xImgSize_resized(4)/2]); %re-centering
        rightRect = xCntRect_neutral;
    elseif xLoc == 2 %rewarded image is on right, neutral is on LEFT
        xCntRect_neutral = round([leftX-xImgSize_resized(3)/2, centerY-xImgSize_resized(4)/2,leftX+xImgSize_resized(3)/2,centerY+xImgSize_resized(4)/2]); %re-centering
        leftRect = xCntRect_neutral;
    end

    %load img texture
    trialImage_reward = textures{xSup}{xSub}(xImgNum);
    trialImage_neutral = textures{xSup}{xNeutralSub}(xNeutralImgNum);
    
    Screen('PreloadTextures',mainWindow, trialImage_reward);
    Screen('PreloadTextures',mainWindow, trialImage_neutral);
    
    trialStart = xOnset+runTime;
    
    % do not blink fixation
    while(trialStart-GetSecs>blinkTime); end % wait until blink time
    common.draw_fixation_dot(mainWindow, backColor, fixColor, fixDotRect); %draw dot first, otherwise it does not blink
    startPrep = Screen('Flip',mainWindow);
    %common.blink_fixation_dot(mainWindow, backColor, fixColor, fixDotRect, numBlinks, blinkDur, runTime, startPrep, refreshrate);
    
    % show images
    while(trialStart-GetSecs>leadTime); end % wait until fixation time
    [recorded, stimStart, fMRItrigger] = common.show_image_decisionphase(screenNum, mainWindow, trialImage_reward, trialImage_neutral, [], xCntRect_reward, xCntRect_neutral, fixColor, fixDotRect, fMRI, trialStart, allowance, refreshrate, DEVICE);
    
    % start listening for responses
    [rt, response, qq] = common.listen_for_response_decisionphase(mainWindow, stimStart, respWindow, stimDuration, respColor, fixColor, fixDotRect, keys, trialImage_reward, trialImage_neutral, [], xCntRect_reward, xCntRect_neutral, leftRect, rightRect, DEVICE);
    
    onset = stimStart - runTime;
    if fMRI == 1
        fMRItrigger = fMRItrigger - runTime;
    end
    
    % measuring the accuracy
    if isnan(response)
        accuracy = 0;
        response = 7;%no response
    elseif length(response) > 1 %not sure about correct key
        accuracy = 0;
        response = 3;
    else
        accuracy = keys(response) == correctKey;
    end%if isnan
    
    if accuracy == 1
        track_winnings = [track_winnings + 1];
    end
    
    common.draw_fixation_dot(mainWindow, backColor, fixColor, fixDotRect);
    Screen('Flip',mainWindow, stimStart+stimDuration-refreshrate/3); %clear screen after 2.5s
    
    % print trial results
%     res_Inputs_names= {'block' 'trial' 'onset' 'plan' 'recorded' 'fMRItrigger' 'xCond' 'xRep' 'xPairID' 'xIPI' 'xOrder' 'xSup' 'xSub' 'xImgNum' 'resp' 'acc' 'rt'};
%     res_Inputs_values= [block trial onset xOnset recorded fMRItrigger xCond xRep xPairID xIPI xOrder xSup xSub xImgNum response accuracy rt];
    res_Inputs_names= {'block' 'trial' 'onset' 'plan' 'recorded' 'fMRItrigger' 'AorB' 'rewardLoc' 'resp' 'acc' 'rt'};
    res_Inputs_values= [block trial onset xOnset recorded fMRItrigger xOrder xLoc response accuracy rt];
    var_floats = {'onset' 'plan' 'fMRItrigger' 'rt'};
    common.write_log_data_v03(res_Inputs_names, res_Inputs_values, var_floats, trial);
    fprintf('\n');
    
    % recording in the data structure
    data(data_rows.Resp,trial) = response;
    data(data_rows.ACC,trial) = accuracy;
    data(data_rows.RT,trial) = rt;
    data(data_rows.onset,trial) = onset;
    data(data_rows.recorded,trial) = recorded;
    data(data_rows.fMRItrigger,trial) = fMRItrigger;
    
    %escape
    if qq
        break
    end
    
%     common.clear_screen(mainWindow, backColor);
%     Screen('Flip',mainWindow);

decisionphase_winnings{block} = track_winnings;
save([output_dir '/data_decision_' SN '_block' num2str(block) '_' NM], 'data', 'decisionphase_winnings', 'data_rows', 'version');

end % trial loop

% % save([output_dir '/data_decision_' SN '_block' num2str(block) '_' NM], 'data', 'data_rows');

common.clear_screen(mainWindow, backColor);
Screen('Flip',mainWindow);

if deburg
else
    if ~qq
        while(GetSecs-runTime < runLength); end
    end
end

if block == 1
    this_run = 5;
elseif block == 2
    this_run = 9;
end

% show feedback
clear instructString
instructString{1} = sprintf('Congratulations! You completed run %d of 10.',this_run);
instructString{2} = ' ';
instructString{3} = sprintf('You earned %d bonus points during that run.', track_winnings);

for instruct=1:length(instructString)
    tempBounds = Screen('TextBounds',mainWindow,instructString{instruct});
    Screen('drawtext',mainWindow,instructString{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
Screen('Flip',mainWindow);
WaitSecs(5);

% save to server
if deburg
else
    save([server_dir '/data_decision_' SN '_block' num2str(block) '_' NM], 'data', 'decisionphase_winnings', 'data_rows', 'version');
end
%%
% clean up and go home
KbQueueRelease(DEVICE);
KbReleaseWait;
sca;
ListenChar(1);
fclose('all');

