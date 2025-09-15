function VioDiffCon_postScenes(SN,NM,block,fMRI,version)
global deburg
if nargin == 0
    SN = '999'; NM = 'SVD'; block = 1; fMRI = 1; deburg = 1; version='997';
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
getKeypress;

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
textSpacing = 25;
fixColor = 0;
respColor = 255;
backColor = 127;
progWidth = 400; % image loading progress bar
progHeight = 20;
yposition = 200;%how to lower the recog & confi rects

%% load the data seqs for learning phase
%load([out_mat_dir '/postScenes_mat_' SN], 'postStudy_scenes_mat');
load([out_mat_dir '/postScenes_mat_' version], 'postStudy_scenes_mat');
load([out_mat_dir '/postStudy_mat_row'], 'postStudy_mat_row');
data = postStudy_scenes_mat{block};
data_rows = postStudy_mat_row;

if deburg
    nTrials_thisrun = nTrials_debugmode;
else
    nTrials_thisrun = length(data);
end%if deburg

%% set-up screens
[screenNum, screenX, screenY, centerX, centerY, mainWindow, imageRect, centerRect, fixDotRect, refreshrate] = common.setup_screens(fMRI, backColor, textFont, textSize, imageSize, fixationSize);
'postScenes'
block
nTrials_thisrun

%% load images
[textures, imgsize] = VioDiffCon_load_images(mainWindow, data, data_rows, fMRI); %LM added fMRI has an input so that variable carries over to VioDiffCon_VarConf
%% Setups

% %set up diagnostic plot
% rd = common.response_diagnostics_gtv01(respWindow, nTrial_learning_total);

common.clear_screen(mainWindow, backColor);
FlushEvents('keyDown');

% show instructions
instructString{1} = 'This run is SCENES ONLY';
instructString{2} = ' ';
instructString{3} = 'Fixate on the circle in the center of the screen';
instructString{4} = sprintf('For each scene image, report whether it is %s(left) or %s(right)', left_scene, right_scene);
instructString{5} = 'Press the left button when you are ready to start!';

% if mod(str2double(SN),2) == 1 %odd SN
%     instructString{2} = 'For each scene image, report whether it is indoor(left) or outdoor(right)';
% else %even SN
%     instructString{2} = 'For each scene image, report whether it is outdoor(left) or indoor(right)';
% end%if mod

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
runLength = max(data(data_rows.time,:)) + trialDur + post_disdaq;
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
    
    %correctKey = keys(1,xSub);
    
%     % response counterbalancing
%     if mod(str2double(SN), 2) %if odd SN
%         correctKey = keys(1,xSub);
%     else %if even SN
%         correctKey = keys(1,2/xSub);
%     end%if mod
    
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
    while(trialStart-GetSecs>blinkTime); end % wait until blink time
    common.draw_fixation_dot(mainWindow, backColor, fixColor, fixDotRect); %draw dot first, otherwise it does not blink
    startPrep = Screen('Flip',mainWindow);
    common.blink_fixation_dot(mainWindow, backColor, fixColor, fixDotRect, numBlinks, blinkDur, runTime, startPrep, refreshrate);
    
    % show image
    while(trialStart-GetSecs>leadTime); end % wait until fixation time
    [recorded, stimStart, fMRItrigger] = common.show_image(screenNum, mainWindow, trialImage, [], xCntRect, fixColor, fixDotRect, fMRI, trialStart, allowance, refreshrate, DEVICE);
    
    onset = stimStart - runTime;
    % start listening for responses
    [rt, response, qq] = common.listen_for_response(mainWindow, stimStart, respWindow, stimDuration, respColor, fixColor, fixDotRect, keys, trialImage, [], xCntRect, [], DEVICE);
    
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
    res_Inputs_names= {'block' 'trial' 'onset' 'plan' 'recorded' 'fMRItrigger' 'xCond' 'xSub' 'resp' 'acc' 'rt'};
    res_Inputs_values= [block trial onset xOnset recorded fMRItrigger xCond xSub response accuracy rt];
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
    
    common.clear_screen(mainWindow, backColor);
    Screen('Flip',mainWindow);
    
    save([output_dir '/data_postScenes_' SN '_block' num2str(block) '_' NM], 'data', 'data_rows', 'keypress', 'version');
    
end % trial loop

% save([output_dir '/data_postScenes_' SN '_block' num2str(block) '_' NM], 'data', 'data_rows', 'keypress');

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
instructString{1} = 'Congratulations! You completed run 1 of 10.';
instructString{2} = ' ';
instructString{3} = sprintf('Your accuracy on the last run was %d%% correct.', block_accuracy);

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
    save([server_dir '/data_postScenes_' SN '_block' num2str(block) '_' NM], 'data', 'data_rows', 'keypress', 'version');
end
%%
% clean up and go home
KbQueueRelease(DEVICE);
KbReleaseWait;
sca; %close all screens
ListenChar(1);
fclose('all');

