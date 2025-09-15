function VioDiffCon_practice_session1(SN,NM,block,fMRI,version)
global deburg

% for practice, always enter real SN (to get correct keymappings) and
% version = 'practice' (to use junk stimuli)

if nargin == 0
    SN = '172'; NM = 'SVD'; block = 1; fMRI = 0; deburg = 0; version = 'practice';
end%if isempty

left_handed = 0; %1 for left-handed, 0 for right-handed

this_subj = str2num(SN);

%% boilerplate
seed = sum(100*clock);
rand('twister',seed);
ListenChar(2); %makes it so characters typed don't show up in the command window
HideCursor;
GetSecs;

% obtain platform-independent responses
KbName('UnifyKeyNames');
KbQueueCreate; %creates cue using defaults
KbQueueStart; %starts the cue

%GO=KbName('g');
GO='1';
LEFT = KbName('1!');
RIGHT = KbName('2@');
EXIT = KbName('q');
THREE = KbName('3#');
FOUR = KbName('4$');
keys = [LEFT RIGHT THREE FOUR EXIT];

%% variables
VioDiffCon_VarConfig;
common.set_device;
getKeypress;

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
imageSize = 256; % assumed square
fixationSize = 4; % pixels
progWidth = 400; % image loading progress bar
progHeight = 20;
yposition = 200;%how to lower the recog & confi rects

%% load the data seqs for learning phase
%load([out_mat_dir '/learning_mat_' SN], 'learning_mat');
load([out_mat_dir '/learning_mat_' version], 'learning_mat');
load([out_mat_dir '/learning_mat_row'], 'learning_mat_row');
data = learning_mat;
data_rows = learning_mat_row;

if deburg
    nTrials_thisrun = nTrials_debugmode;
else
    nTrials_thisrun = length(data);
end %if deburg

%% set-up screens
[screenNum, screenX, screenY, centerX, centerY, mainWindow, imageRect, centerRect, fixDotRect, refreshrate] = common.setup_screens(fMRI, backColor, textFont, textSize, imageSize, fixationSize);
block
nTrials_thisrun

%% load images
[textures, imgsize] = VioDiffCon_load_images_practice(mainWindow, data, data_rows, fMRI); %LM added fMRI has an input so that variable carries over to VioDiffCon_VarConf

%% Instructions

% page 1
common.clear_screen(mainWindow, backColor);
FlushEvents('keyDown');

% show instructions
%instructString{1} = 'NOTE: For the purpose of this practice session, the 1 and 2 buttons on the laptop will correspond to left and right.';
instructString{1} = 'There will be 6 runs of the task in this session.';
instructString{2} = 'You will view streams of images presented one after another. Images will either be SCENES or FACES.';
instructString{3} = 'Whenever you see a SCENE, you should judge whether it is an indoor or outdoor scene.';
instructString{4} = 'Whenever you see a FACE, you should judge whether it is a male or female face.';
instructString{5} = 'Please make your responses as quickly and accurately as possible.';
instructString{6} = 'The black fixation dot will turn white to indicate that your response has been recorded for that trial.';
instructString{7} = 'Press 1 to continue.';

for instruct=1:length(instructString)
    tempBounds = Screen('TextBounds',mainWindow,instructString{instruct});
    Screen('drawtext',mainWindow,instructString{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
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
instructString{1} = 'Fixate on the circle in the center of the screen';
instructString{2} = sprintf('For a scene image, report whether it is %s(index) or %s(middle)', left_scene, right_scene);
instructString{3} = sprintf('For a face image, report whether it is %s(index) or %s(middle)', left_face, right_face);
instructString{4} = 'Press 1 when you are ready to start!';

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
running_accuracy = 0;
%% start trial sequence
for trial=1:nTrials_thisrun
    xCond = data(data_rows.cond,trial);%1:pair 2:single
    xRep = data(data_rows.rep,trial);%rep num
    xPairID = data(data_rows.pairID,trial);
    xIPI = data(data_rows.ipi,trial);%inter-pair-interval
    xOrder = data(data_rows.order,trial);%1:init 2:foll
    xSup = data(data_rows.upper,trial);%1:face 2:scene
    xSub = data(data_rows.lower,trial);
    xImgNum = data(data_rows.imgID,trial);
    xOnset = data(data_rows.time,trial);
    
    %% correct key
    xKeypress = keypressRandomization{this_subj}(xSup,xSub);
    correctKey = keys(1,xKeypress);
    
    if left_handed == 1
        if correctKey == 30
            correctKey=31;
        elseif correctKey == 31
            correctKey=30;
        end
    end

    % for object images, the x-y ration is not 1, so the center rect for
    % each image should be modified!
    xImgSize = imgsize{xSup}{xSub}{xImgNum};%size of this img in 2D (y and x)
    chRatio = imageRect(3)/max(xImgSize);
    xImgSize_resized = round([0 0 xImgSize(2)*chRatio xImgSize(1)*chRatio]);
    
    %re-centering
    xCntRect = round([centerX-xImgSize_resized(3)/2, centerY-xImgSize_resized(4)/2,centerX+xImgSize_resized(3)/2,centerY+xImgSize_resized(4)/2]);
    
    %load img texture
    trialImage = textures{xSup}{xSub}(xImgNum);
    
    Screen('PreloadTextures',mainWindow, trialImage);
    
    trialStart = xOnset+runTime;
    
    % blink fixation
    while(trialStart-GetSecs>blinkTime); end % wait until blink time (500ms before trialStart)
    common.draw_fixation_dot(mainWindow, backColor, fixColor, fixDotRect); %draw dot first, otherwise it does not blink
    startPrep = Screen('Flip',mainWindow); 
    common.blink_fixation_dot(mainWindow, backColor, fixColor, fixDotRect, numBlinks, blinkDur, runTime, startPrep, refreshrate); %clears screen for blinkDur and redraws fixation dot to signal trial is starting
    
    % show image
    while(trialStart-GetSecs>leadTime); end % wait until lead time (100ms before trialStart), then start looking for trigger, and show image on next vertical refresh after trigger
    [recorded, stimStart, fMRItrigger] = common.show_image(screenNum, mainWindow, trialImage, [], xCntRect, fixColor, fixDotRect, fMRI, trialStart, allowance, refreshrate, DEVICE);

    % start listening for responses
    [rt, response, qq] = common.listen_for_response(mainWindow, stimStart, respWindow, stimDuration, respColor, fixColor, fixDotRect, keys, trialImage, [], xCntRect, runTime, DEVICE);
    
    onset = stimStart - runTime;
    if fMRI == 1
        fMRItrigger = fMRItrigger - runTime;
    end
    
    % measuring the accuracy
    if isnan(response)
        accuracy = 0;
        response = 7;%no response
%     elseif length(response) > 1 %not sure about correct key
%         accuracy = 0;
%         response = 5;
    else
        accuracy = keys(response) == correctKey;
    end%if isnan
    
%     common.draw_fixation_dot(mainWindow, backColor, fixColor, fixDotRect);
%     Screen('Flip',mainWindow);
    
    % print trial results
    res_Inputs_names= {'block' 'trial' 'onset' 'plan' 'recorded' 'fMRItrigger' 'xCond' 'xRep' 'xOrder' 'xSup' 'xSub' 'resp' 'acc' 'rt'};
    res_Inputs_values= [block trial onset xOnset recorded fMRItrigger xCond xRep xOrder xSup xSub response accuracy rt];
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
    
    running_accuracy = running_accuracy + accuracy;
    
    %escape
    if qq
        break
    end

%     %program gets to this point at 1.5s after stim onset
%     line257 = GetSecs-runTime;
%     line257 = line220-onset

    common.clear_screen(mainWindow, backColor);
    Screen('Flip',mainWindow);
    
%     %for checking timing
%     endtrialclear = endtrialclear-runTime;
%     trialoff = endtrialclear-onset
    
    save([output_dir '/practice_learning_' SN '_block' num2str(block) '_' NM], 'data', 'data_rows', 'keypress', 'version');
    
end % trial loop

% save([output_dir '/data_learning_' SN '_block' num2str(block) '_' NM], 'data', 'data_rows', 'keypress');

common.clear_screen(mainWindow, backColor);
Screen('Flip',mainWindow);

block_accuracy = round(running_accuracy/nTrials_thisrun*100);

if deburg
else
    if ~qq
        while(GetSecs-runTime < runLength); end
    end
end

% show feedback
clear instructString
instructString{1} = 'Congratulations! You completed the practice run.';
instructString{2} = ' ';
instructString{3} = sprintf('Your accuracy on the last run was %d%% correct.', block_accuracy);

for instruct=1:length(instructString)
    tempBounds = Screen('TextBounds',mainWindow,instructString{instruct});
    Screen('drawtext',mainWindow,instructString{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
Screen('Flip',mainWindow);
WaitSecs(5);

% % save to server
% if deburg
% else
%     save([server_dir '/data_learning_' SN '_block' num2str(block) '_' NM], 'data', 'data_rows', 'keypress', 'version');
% end

%% clean up and go home
KbQueueRelease;
KbReleaseWait;
sca;
ListenChar(1);
fclose('all');

