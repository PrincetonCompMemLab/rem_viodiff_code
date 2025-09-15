function [recorded, stimStart, fMRItrigger] = show_image(screenNum, mainWindow, trialImage, imageRect, centerRect, fixColor, fixDotRect, fMRI, trialStart, allowance)

Priority(MaxPriority(screenNum));
Screen('DrawTexture',mainWindow,trialImage,imageRect,centerRect);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
if (fMRI == 1)
    [x, recorded] = WaitTRPulsePTB3_skyra(1,trialStart+allowance);
    stimStart = Screen('Flip',mainWindow);
    fMRItrigger = x;
else
    recorded = 1;
    stimStart = Screen('Flip',mainWindow,trialStart);
    fMRItrigger = -999;
end
Priority(0);