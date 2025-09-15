function localizer_FSO(SN,NM,block,fMRI,version, left_handed)

global deburg

if nargin == 0
    SN = '176'; NM = 'SVD'; block = 1; fMRI = 0; deburg = 0; version='999'; left_handed=0; %for practice, enter real SN (to get correct keymappings) and version=999
end%if isempty

this_subj = str2num(SN);

%% boilerplate
seed = sum(100*clock);
rand('twister',seed);
ListenChar(2);
HideCursor;
GetSecs;

%% obtain platform-independent responses
KbName('UnifyKeyNames');

%GO=KbName('g');
GO='1';
LEFT = KbName('1!');%indoor
RIGHT = KbName('2@');%outdoor
EXIT = KbName('q');
THREE = KbName('3#');
FOUR = KbName('4$');
keys = [LEFT RIGHT THREE FOUR EXIT];
%% variables
localizer_FSO_VarConfig;
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
blinkTime = 0.3;
blinkDur = 0.1;
numBlinks = 0;
leadTime = 0.1; % start waiting for trigger this much time before desired start
respWindow = 1.0;
allowance = 0.05; % stop waiting for trigger after this

blk_instDuration = 1.5;

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
%load([out_mat_dir '/localizer_' SN], 'localizer_mat');
load([out_mat_dir '/localizer_' version], 'localizer_mat');
load([out_mat_dir '/localizer_row'], 'localizer_row');
data = localizer_mat{block};
data_rows = localizer_row;

if deburg
    nTrials_thisrun = 11;
else
    nTrials_thisrun = length(data);
end%if deburg

%% set-up screens
[screenNum, screenX, screenY, centerX, centerY, mainWindow, imageRect, centerRect, fixDotRect, refreshrate] = common.setup_screens(fMRI, backColor, textFont, textSize, imageSize, fixationSize);
'Functional Localizer'
block
nTrials_thisrun

%% load images
[textures, imgsize] = localizer_FSO_load_images(mainWindow, data, data_rows, fMRI);

%% Setups
common.clear_screen(mainWindow, backColor);
FlushEvents('keyDown');

% show instructions
instructString{1} = 'Fixate on the circle in the center of the screen';
instructString{2} = sprintf('For a scene image, report whether it is %s(index) or %s(middle)', left_scene, right_scene);
instructString{3} = sprintf('For a face image, report whether it is %s(index) or %s(middle)', left_face, right_face);
instructString{4} = sprintf('For an object image, report whether it is %s(index) or %s(middle)', left_object, right_object);
instructString{5} = 'Press the index finger button when you are ready to start!';

% if mod(str2double(SN),2) == 1 %odd SN
%     instructString{2} = 'For a scene image, report whether it is indoor(left) or outdoor(right)';
%     instructString{3} = 'For a face image, report whether it is female(left) or male(right)';
%     instructString{4} = 'For an object image, report whether it is natural(left) or manmade(right)';
%     ResponseType = {'Female          Male', 'Indoor         Outdoor', 'Natural          Manmade'};
% else %even SN
%     instructString{2} = 'For a scene image, report whether it is outdoor(left) or indoor(right)';
%     instructString{3} = 'For a face image, report whether it is male(left) or female(right)';
%     instructString{4} = 'For an object image, report whether it is manmade(left) or natural(right)';
%     ResponseType = {'Male          Female', 'Outdoor         Indoor', 'Manmade          Natural'};
% end%if mod

% instructString{5} = 'Press the left button when you are ready to start!';

for instruct=1:length(instructString)
    tempBounds = Screen('TextBounds',mainWindow,instructString{instruct});
    Screen('drawtext',mainWindow,instructString{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
clear instructString;
Screen('Flip',mainWindow);

% common.wait_for_experimenter_ok('g');
% common.clear_screen(mainWindow, backColor);
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
runLength = max(data(data_rows.time,:)) + trialDur + post_disdaq;%in sec
running_accuracy = 0;

CateType = {'Face', 'Scene', 'Object'};

if left_handed == 1
    ResponseType = {sprintf('%s          %s', right_face, left_face), sprintf('%s          %s', right_scene, left_scene), sprintf('%s          %s', right_object, left_object)};
else
    ResponseType = {sprintf('%s          %s', left_face, right_face), sprintf('%s          %s', left_scene, right_scene), sprintf('%s          %s', left_object, right_object)};
end

%% start trial sequence
for trial=1:nTrials_thisrun
    xSup = data(data_rows.sup,trial);%1:face 2:scene, 3:object
    xSub = data(data_rows.sub,trial);
    xImgNum = data(data_rows.imgID,trial);
    xOnset = data(data_rows.time,trial);
    xBlk = data(data_rows.blk,trial);%this block
    xBlk_trial = data(data_rows.trial,trial);%# of trial within each "block" (not run)
    %% correct key
    % correctKey = keys(1,xSub);
    xKeypress = keypressRandomization{this_subj}(xSup,xSub);
    correctKey = keys(1,xKeypress);
    
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
    
    % show instruction before the first trial of each block
    if xBlk_trial == 1
        while(trialStart-GetSecs> blk_instDuration); end % wait until fixation time
        instructString{1} = CateType{xSup};
        instructString{2} = ' ';
        instructString{3} = ' ';
        instructString{4} = ResponseType{xSup};
        
        for instruct=1:length(instructString)
            tempBounds = Screen('TextBounds',mainWindow,instructString{instruct});
            Screen('drawtext',mainWindow,instructString{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
            clear tempBounds;
        end
        clear instructString;
        
        Screen('Flip',mainWindow);
        WaitSecs(1.2);
        common.clear_screen(mainWindow, backColor);
        Screen('Flip',mainWindow);
    end%if xBlk
    
    % show fixation
    common.draw_fixation_dot(mainWindow, backColor, fixColor, fixDotRect);
    Screen('Flip',mainWindow);
    
    % show image
    while(trialStart-GetSecs>leadTime); end % wait until fixation time
    [recorded, stimStart, fMRItrigger] = common.show_image(screenNum, mainWindow, trialImage, [], xCntRect, fixColor, fixDotRect, fMRI, trialStart, allowance, refreshrate, DEVICE);
    
    % start listening for responses
    [rt, response, qq] = common.listen_for_response(mainWindow, stimStart, respWindow, stimDuration, respColor, fixColor, fixDotRect, keys, trialImage, [], xCntRect, [], DEVICE);
    
    onset = stimStart - runTime;
    if fMRI == 1
        fMRItrigger = fMRItrigger - runTime;
    end
    
    % measuring the accuracy
    if isnan(response)
        accuracy = 0;
        response = 7;%no response
%     elseif length(response) > 1
%         accuracy = 0;
%         response = 5;
    else
        accuracy = keys(response) == correctKey;
    end%if isnan

    common.draw_fixation_dot(mainWindow, backColor, fixColor, fixDotRect);
    Screen('Flip',mainWindow);
    
    % print trial results
    % onset = stimStart - runTime;
    res_Inputs_names= {'run' 'blk' 'trial' 'onset' 'plan' 'recorded' 'fMRItrigger' 'xSup' 'xSub' 'xImgNum' 'resp' 'acc' 'rt'};
    res_Inputs_values= [block xBlk xBlk_trial onset xOnset recorded fMRItrigger xSup xSub xImgNum response accuracy rt];
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
    
    save([output_dir '/data_localizer_' SN '_block' num2str(block) '_' NM], 'data', 'data_rows', 'keypress', 'version');
end % trial loop

%% save output files
% save([output_dir '/data_localizer_' SN '_block' num2str(block) '_' NM], 'data', 'data_rows');

common.clear_screen(mainWindow, backColor);
Screen('Flip',mainWindow);

block_accuracy = round(running_accuracy/nTrials_thisrun*100);

if deburg
else
    if ~qq
        while(GetSecs-runTime < runLength); end
    end
end

if block == 1
    this_run = 11;
elseif block == 2
    this_run = 12;
end

% show feedback
clear instructString
instructString{1} = sprintf('Congratulations! You completed run %d of 2.', this_run);
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
    save([server_dir '/data_localizer_' SN '_block' num2str(block) '_' NM], 'data', 'data_rows', 'keypress', 'version');
end
%% clean up and go home
KbQueueRelease(DEVICE);
KbReleaseWait;
sca;
ListenChar(1);
fclose('all');

