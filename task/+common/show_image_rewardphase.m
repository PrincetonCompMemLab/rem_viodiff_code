function [recorded, stimStart, fMRItrigger] = show_image_rewardphase(screenNum, mainWindow, trialImage, imageRect, centerRect, fixColor, fixDotRect, fMRI, trialStart, allowance, refreshrate, DEVICE)

Priority(MaxPriority(screenNum));
Screen('DrawTexture',mainWindow,trialImage,imageRect,centerRect);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);

if fMRI == 1
    % [x, recorded] = WaitTRPulsePTB3_skyra(1,trialStart+allowance);
    [x, recorded] = WaitTRPulse_EAM(trialStart+allowance, DEVICE);
    stimStart = Screen('Flip',mainWindow,[],1); %leave image in backbuffer
    %stimStart = Screen('Flip',mainWindow,[]); % don't leave image in backbuffer
    fMRItrigger = x; % x is time of scanner trigger as returned by KbQueueCheck 
else
    recorded = 1;
    stimStart = Screen('Flip',mainWindow,trialStart-refreshrate/3,1);
    %stimStart = Screen('Flip',mainWindow,trialStart-refreshrate/4);
    fMRItrigger = -999; %no scanner trigger if fMRI = 0
end
Priority(0);