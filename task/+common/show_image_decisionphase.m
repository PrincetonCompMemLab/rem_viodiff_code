function [recorded, stimStart, fMRItrigger] = show_image_decisionphase(screenNum, mainWindow, trialImage_reward, trialImage_neutral, imageRect, centerRect_reward, centerRect_neutral, fixColor, fixDotRect, fMRI, trialStart, allowance, refreshrate, DEVICE)

Priority(MaxPriority(screenNum));
Screen('DrawTexture',mainWindow,trialImage_reward,imageRect,centerRect_reward);
Screen('DrawTexture',mainWindow,trialImage_neutral,imageRect,centerRect_neutral);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);

if fMRI == 1
    % [x, recorded] = WaitTRPulsePTB3_skyra(1,trialStart+allowance);
    [x, recorded] = WaitTRPulse_EAM(trialStart+allowance, DEVICE);
    stimStart = Screen('Flip',mainWindow); %waits for TR pulse and flips on next possible refresh
    fMRItrigger = x; % x is time of scanner trigger as returned by KbQueueCheck
else
    recorded = 1;
    stimStart = Screen('Flip',mainWindow,trialStart-refreshrate/3);
    fMRItrigger = -999; %no scanner trigger if fMRI = 0
end
Priority(0);