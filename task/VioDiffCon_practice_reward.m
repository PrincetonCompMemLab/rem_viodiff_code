function VioDiffCon_practice_reward(SN,NM,block,fMRI,version, left_handed)
global deburg

% for practice, always enter real SN (to get correct keymappings) and
% version = 'practice' (to use junk stimuli)

if nargin == 0
    SN = '999'; NM = 'SVD'; block = 1; fMRI = 0; deburg = 0; version='practice'; left_handed=0;
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
getKeypress;
keypressAssignment = keypressRandomization{this_subj}(4,:);

%% Vars related to screens and timing
stimDuration = 2.5; % in seconds
fixDuration = 0.5;
blinkTime = 0.5;
blinkDur = 0.1;
numBlinks = 1;
leadTime = 0.1; % start waiting for trigger this much time before desired start
respWindow = 2.5; %1.5
allowance = 0.05; % stop waiting for trigger after this

%stimDuration_feedback = 3.0;
response_feedback = 1; %show response feedback text for 1000ms before showing actual outcome
outcome = 1; %show actual outcome for 1000ms before showing winnings
winnings = 1; %show winnings for 1000ms before blank

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

if block == 1
    cycle = 1;
    run = 2;
elseif block == 2
    cycle = 1;
    run = 3;
elseif block == 3
    cycle = 2;
    run = 2;
elseif block == 4
    cycle = 2;
    run = 3;
end

data = reward_mat{2};
data_rows = reward_mat_row;
rewardphase_winnings{2} = [];
track_winnings = 0;

if deburg
    nTrials_thisrun = nTrials_debugmode;
else
    nTrials_thisrun = size(data);
    nTrials_thisrun = nTrials_thisrun(2);
end%if deburg

%% set-up screens
[screenNum, screenX, screenY, centerX, centerY, mainWindow, imageRect, centerRect, fixDotRect, refreshrate] = common.setup_screens(fMRI, backColor, textFont, textSize, imageSize, fixationSize);
'RewardFeedback'
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

%% Setups

% %set up diagnostic plot
% rd = common.response_diagnostics_gtv01(respWindow, nTrial_learning_total);

common.clear_screen(mainWindow, backColor);
FlushEvents('keyDown');

% show instructions
instructString{1} = 'This is a PREDICTION run.';
instructString{2} = ' ';
instructString{3} = 'Fixate on the circle in the center of the screen';
instructString{4} = sprintf('For each scene image, predict if it leads to a %s(index) or %s(middle) outcome', left_reward, right_reward);
instructString{5} = 'You will earn a percentage of your winnings at the end of the experiment';
instructString{6} = 'Press 1 when you are ready to start!';

for instruct=1:length(instructString)
    tempBounds = Screen('TextBounds',mainWindow,instructString{instruct});
    Screen('drawtext',mainWindow,instructString{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
Screen('Flip',mainWindow);

% wait for subject to start
common.wait_for_experimenter_ok(GO);
common.waiting_for_scanner(mainWindow, backColor); %show waiting for scanner message until first two pulses recorded below

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
Screen('TextSize', mainWindow,24); %use larger font size for trial feedback
%% start trial sequence
for trial=1:nTrials_thisrun
    %this_trial = trial*2-1;
    xCond = data(data_rows.cond,trial);
    xRep = data(data_rows.rep,trial);%rep num
    xPairID = data(data_rows.pairID,trial);
    xIPI = data(data_rows.ipi,trial);%inter-pair-interval
    xOrder = data(data_rows.order,trial);
    xSup = data(data_rows.upper,trial);%1:face 2:scene
    xSub = data(data_rows.lower,trial);
    xImgNum = data(data_rows.imgID,trial); %888=reward 999=neutral
    xOnset = data(data_rows.time,trial);
    xOnset_feedback = xOnset+stimDuration;
    xRewardCond = data(data_rows.rewardcond,trial);

    xKeypress = keypressRandomization{this_subj}(4,xRewardCond);
    correctKey = keys(1,xKeypress);
    
%     if left_handed == 1
%         if correctKey == 30
%             correctKey=31;
%         elseif correctKey == 31
%             correctKey=30;
%         end
%     end
%     
    xImgSize = imgsize{xSup}{xSub}{xImgNum};%size of this img in 2D (y and x)
    trialImage = textures{xSup}{xSub}(xImgNum); %load img texture
    chRatio = imageRect(3)/max(xImgSize);
    xImgSize_resized = round([0 0 xImgSize(2)*chRatio xImgSize(1)*chRatio]);
    xCntRect = round([centerX-xImgSize_resized(3)/2, centerY-xImgSize_resized(4)/2,centerX+xImgSize_resized(3)/2,centerY+xImgSize_resized(4)/2]); %re-centering
    
    if xRewardCond == 1 %reward outcome
        xImgSize = imgsize_reward;%size of this img in 2D (y and x)
        trialImage_outcome = texture_reward; %load img texture
    elseif xRewardCond == 2 %neutral outcome
        xImgSize = imgsize_neutral;%size of this img in 2D (y and x)
        trialImage_outcome = texture_neutral; %load img texture
    end
    imageRect_outcome = [0,0,imageSize*2,imageSize]; %make rectangle instead of square
    chRatio = imageRect_outcome(3)/max(xImgSize);
    xImgSize_resized = round([0 0 xImgSize(2)*chRatio xImgSize(1)*chRatio]);
    remainingX = screenX - ((screenX-xCntRect(3))/2);
    xCntRect_outcome = round([remainingX-xImgSize_resized(3)/2, centerY-xImgSize_resized(4)/2,remainingX+xImgSize_resized(3)/2,centerY+xImgSize_resized(4)/2]); %re-centering
    
    Screen('PreloadTextures',mainWindow, trialImage);
    Screen('PreloadTextures',mainWindow, trialImage_outcome);
    
    %% start trial
    trialStart = xOnset+runTime;
    
    if trial == 1 %only blink on first trial
        % blink fixation
        while(trialStart-GetSecs>blinkTime); end % wait until blink time
        startPrep = GetSecs;
        common.blink_fixation_dot(mainWindow, backColor, fixColor, fixDotRect, numBlinks, blinkDur, runTime, startPrep, refreshrate);
    end
    
    % show scene image
    while(trialStart-GetSecs>leadTime); end % wait until fixation time
    [recorded, stimStart, fMRItrigger] = common.show_image_rewardphase(screenNum, mainWindow, trialImage, [], xCntRect, fixColor, fixDotRect, fMRI, trialStart, allowance, refreshrate, DEVICE);
    
    % start listening for responses
    [rt, response, qq] = common.listen_for_response_rewardphase(mainWindow, stimStart, respWindow, stimDuration, respColor, fixColor, fixDotRect, keys, trialImage, [], xCntRect, DEVICE);
    
    onset = stimStart - runTime;
    if fMRI == 1
        fMRItrigger = fMRItrigger - runTime;
    end
    
    if left_handed == 1
        if response == 1 %if they pressed middle finger button (which is 1 for a leftie), that is like a rightie pressing 2
            response=2;
        elseif response == 2
            response=1;
        end
    end
    
    %measuring accuracy
    if isnan(response)
        accuracy = 0;
        response = 7;%no response
        xSubjResponse = 7;
    elseif response == 3 || response == 4 %invalid keypress
        accuracy = 0;
        xSubjResponse = 7; %treat invalid responses as no response
    else
        accuracy = keys(response) == correctKey;
        xSubjResponse = find(keypressAssignment==response); %convert keypress to reward or neutral response
    end%if isnan

    if xSubjResponse == 2 %responded neutral
        sub_response = 'You responded NO REWARD';
        dotColor = respColor; %keep fixation dot white
        winning_text = '0';
        winning_color = [0 0 0];
    elseif xSubjResponse == 1 %responded reward
        sub_response = 'You responded REWARD';
        dotColor = respColor;
        if xRewardCond == 1 %actually reward
            track_winnings = track_winnings + 1;
            winning_text = 'You win +1';
            winning_color = [0 255 0];
        elseif xRewardCond == 2 %actually neutral
            track_winnings = track_winnings - 1;
            winning_text = 'You lose -1';
            winning_color = [255 0 0];
        end
    elseif xSubjResponse == 7 %no response
        sub_response = 'NO RESPONSE';
        dotColor = fixColor; %keep fixation dot black
        winning_text = '0';
        winning_color = [0 0 0];
%     elseif xSubjResponse == 3 %multiple responses
%         sub_response = 'NO RESPONSE'; %display "NO RESPONSE" message
%         dotColor = fixColor; %keep fixation dot black
%         winning_text = '0';
%         winning_color = [0 0 0];
    end
    
    %% feedback
    feedbackStart = xOnset_feedback+runTime;

    % show response feedback text "You responded REWARD"
    %DrawFormattedText(mainWindow, sub_response, 'center', centerRect(4)+100, [0 0 0]);
    DrawFormattedText(mainWindow, sub_response, 'center', centerRect(4)+screenY/15, [0 0 0]);
    response_onset = Screen ('Flip', mainWindow, feedbackStart-refreshrate/3,1);
    
    % show actual outcome picture
    Screen('DrawTexture',mainWindow,trialImage_outcome,[],xCntRect_outcome); %draw actual outcome
    outcome_onset = Screen('Flip',mainWindow,response_onset+response_feedback-refreshrate/3,1); %Flip and don't clear previous screen
    
    % show win/loss/no change
    %DrawFormattedText(mainWindow, winning_text, remainingX, centerRect(4)-250, winning_color); %draw subject winnings in color
    DrawFormattedText(mainWindow, winning_text, xCntRect_outcome(1), xCntRect_outcome(2)-screenY/30, winning_color); %draw subject winnings in color
    %DrawFormattedText(mainWindow, winning_text, 'center', centerRect(2)-screenY/30, winning_color); %draw subject winnings in color
    winning_onset = Screen ('Flip', mainWindow, outcome_onset+outcome-refreshrate/3);
    
    % clear screen except fixation dot
    common.draw_fixation_dot(mainWindow, backColor, fixColor, fixDotRect);
    screen_cleared = Screen('Flip',mainWindow, winning_onset+winnings-refreshrate/3);
    
    % print trial results
    %res_Inputs_names= {'block' 'trial' 'onset' 'plan' 'recorded' 'fMRItrigger' 'xCond' 'xRep' 'xPairID' 'xIPI' 'xOrder' 'xSup' 'xSub' 'xImgNum' 'resp' 'acc' 'rt'};
    %res_Inputs_values= [block trial onset xOnset recorded fMRItrigger xCond xRep xPairID xIPI xOrder xSup xSub xImgNum response accuracy rt];
    res_Inputs_names= {'block' 'trial' 'onset' 'plan' 'recorded' 'fMRItrigger' 'resp' 'acc' 'rt'};
    res_Inputs_values= [block trial onset xOnset recorded fMRItrigger response accuracy rt];
    var_floats = {'onset' 'plan' 'fMRItrigger' 'rt'};
    common.write_log_data_v03(res_Inputs_names, res_Inputs_values, var_floats, trial);
    fprintf('\n');
    
%     %for checking timing
%     check_outcome = outcome_onset - response_onset
%     check_winning = winning_onset - outcome_onset
%     check_screenclear = screen_cleared - winning_onset

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
    
    rewardphase_winnings{cycle}{run} = track_winnings;
    save([output_dir '/practice_reward_' SN '_block' num2str(block) '_' NM], 'data', 'rewardphase_winnings', 'data_rows', 'keypress', 'version');
end % trial loop

% save([output_dir '/data_reward_' SN '_block' num2str(block) '_' NM], 'data', 'rewardphase_winnings', 'data_rows', 'keypress');

common.clear_screen(mainWindow, backColor);
Screen('Flip',mainWindow);

if block == 1
    this_run = 3;
elseif block == 2
    this_run = 4;
elseif block == 3
    this_run = 7;
elseif block == 4
    this_run = 8;
end

if deburg
else
    if ~qq
        while(GetSecs-runTime < runLength); end
    end
end

% show feedback
clear instructString
Screen('TextSize', mainWindow,textSize); % set back to default
instructString{1} = 'Congratulations! You completed the practice run.';
instructString{2} = ' ';
instructString{3} = sprintf('You earned %d bonus points during that run.', track_winnings);

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
%     save([server_dir '/data_reward_' SN '_block' num2str(block) '_' NM], 'data', 'rewardphase_winnings', 'data_rows', 'keypress', 'version');
% end
%%
% clean up and go home
KbQueueRelease;
KbReleaseWait;
sca;
ListenChar(1);
fclose('all');

