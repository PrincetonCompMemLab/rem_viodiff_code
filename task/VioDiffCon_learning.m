function VioDiffCon_learning(SN,NM,block,fMRI,version)
global deburg
if nargin == 0
    SN = '999'; NM = 'SVD'; block = 1; fMRI = 0; deburg = 0; version = '999';
end%if isempty

this_subj = str2num(SN);

%% boilerplate
seed = sum(100*clock);
rand('twister',seed);
ListenChar(2); %makes it so characters typed don't show up in the command window
HideCursor;
GetSecs;

% obtain platform-independent responses
KbName('UnifyKeyNames');
%KbQueueCreate; %creates cue using defaults
%KbQueueStart; %starts the cue

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
fixColor = 0; %black
respColor = 255; %white
backColor = 127; %screen background color (gray)
progWidth = 400; % image loading progress bar
progHeight = 20;
yposition = 200;%how to lower the recog & confi rects

%% load the data seqs for learning phase
%load([out_mat_dir '/learning_mat_' SN], 'learning_mat');
load([out_mat_dir '/learning_mat_' version], 'learning_mat');
load([out_mat_dir '/learning_mat_row'], 'learning_mat_row');
data = learning_mat{block};
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
[textures, imgsize] = VioDiffCon_load_images(mainWindow, data, data_rows, fMRI); %LM added fMRI has an input so that variable carries over to VioDiffCon_VarConf

%% Setups

% %set up diagnostic plot
% rd = common.response_diagnostics_gtv01(respWindow, nTrial_learning_total);

common.clear_screen(mainWindow, backColor);
FlushEvents('keyDown');

% show instructions
instructString{1} = 'Fixate on the circle in the center of the screen';
instructString{2} = sprintf('For a scene image, report whether it is %s(left) or %s(right)', left_scene, right_scene);
instructString{3} = sprintf('For a face image, report whether it is %s(left) or %s(right)', left_face, right_face);
instructString{4} = 'Press the left button when you are ready to start!';

% if mod(str2double(SN),2) == 1 %odd SN
%     instructString{2} = 'For a scene image, report whether it is indoor(left) or outdoor(right)';
%     instructString{3} = 'For a face image, report whether it is female(left) or male(right)';
% else %even SN
%     instructString{2} = 'For a scene image, report whether it is outdoor(left) or indoor(right)';
%     instructString{3} = 'For a face image, report whether it is male(left) or female(right)';
% end%if mod
% instructString{4} = 'Experimenter, press G to start!';

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

KbCheck(-1)

if (fMRI == 1)
    [runTime, recorded, TRcounter] = WaitTRPulsePTB3_skyra(2);
else
    runTime = GetSecs;
    TRcounter=2; %to match waiting for 2 TR pulses
end

Screen('Flip',mainWindow);
Priority(0);

% %for checking timing
% first_flip = Screen('Flip',mainWindow);
% first_flip = first_flip-runTime
%%
runLength = max(data(data_rows.time,:)) + trialDur + post_disdaq;
running_accuracy = 0;
time_counter=TR;
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
    
    % correctKey = keys(1,xSub);
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
    while(trialStart-GetSecs>blinkTime) % wait until blink time (500ms before trialStart)
%         if fMRI == 1
%             [x, recorded] = WaitTRPulse_EAM(time_counter+runTime+allowance, DEVICE); %count triggers during period leading up to trial
%             fMRItrigger = x; % x is time of scanner trigger as returned by KbQueueCheck
%             if recorded == 1
%                 TRcounter=TRcounter+1
%                 time_counter = time_counter + TR;
%             end
%         end
    end
    common.draw_fixation_dot(mainWindow, backColor, fixColor, fixDotRect); %draw dot first, otherwise it does not blink
    startPrep = Screen('Flip',mainWindow); 
    common.blink_fixation_dot(mainWindow, backColor, fixColor, fixDotRect, numBlinks, blinkDur, runTime, startPrep, refreshrate); %clears screen for blinkDur and redraws fixation dot to signal trial is starting
    
    % show image
    while(trialStart-GetSecs>leadTime); end % wait until lead time (100ms before trialStart), then start looking for trigger, and show image on next vertical refresh after trigger
    [recorded, stimStart, fMRItrigger] = common.show_image(screenNum, mainWindow, trialImage, [], xCntRect, fixColor, fixDotRect, fMRI, trialStart, allowance, refreshrate, DEVICE);

    onset = stimStart - runTime;
    if fMRI == 1
        fMRItrigger = fMRItrigger - runTime;
%         if recorded == 1
%             TRcounter = TRcounter+1;
%             time_counter = time_counter + TR;
%         end
    end
    
    % start listening for responses
    [rt, response, qq] = common.listen_for_response(mainWindow, stimStart, respWindow, stimDuration, respColor, fixColor, fixDotRect, keys, trialImage, [], xCntRect, runTime, DEVICE);

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
%     res_Inputs_names= {'block' 'trial' 'onset' 'plan' 'recorded' 'fMRItrigger' 'xCond' 'xRep' 'xPairID' 'xIPI' 'xOrder' 'xSup' 'xSub' 'xImgNum' 'resp' 'acc' 'rt'};
%     res_Inputs_values= [block trial onset xOnset recorded fMRItrigger xCond xRep xPairID xIPI xOrder xSup xSub xImgNum response accuracy rt];
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
    %data(17,trial) = TRcounter;
    
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
    
    while(trialStart+TR-GetSecs>leadTime) % catch TR trigger between trials
        if fMRI == 1
            [x, recorded] = WaitTRPulse_EAM(time_counter+runTime+allowance, DEVICE); %count triggers during period leading up to trial
            fMRItrigger = x; % x is time of scanner trigger as returned by KbQueueCheck
            if recorded == 1
                %TRcounter=TRcounter+1
                time_counter = time_counter + TR;
            end
        end
    end
    
%     %for checking timing
%     endtrialclear = endtrialclear-runTime;
%     trialoff = endtrialclear-onset
    
    save([output_dir '/data_learning_' SN '_block' num2str(block) '_' NM], 'data', 'data_rows', 'keypress', 'version');
    
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
instructString{1} = sprintf('Congratulations! You completed run %d of %d.', block, nBlk_learning);
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
    save([server_dir '/data_learning_' SN '_block' num2str(block) '_' NM], 'data', 'data_rows', 'keypress', 'version');
end

%% clean up and go home
%Total_num_TRs = TRcounter
KbQueueRelease(DEVICE);
KbReleaseWait;
sca;
ListenChar(1);
fclose('all');

