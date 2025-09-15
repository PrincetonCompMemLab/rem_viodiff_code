function [recorded stimStart] = show_image(screenNum, mainWindow, xSup, trialImage, imageRect, centerRect, fixColor, fixDotRect, fMRI, trialStart, allowance)

Priority(MaxPriority(screenNum));

[widthX,heightY] = WindowSize(mainWindow);

Screen('DrawTexture',mainWindow,trialImage,imageRect,centerRect);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
if xSup == 1 %face
    DrawFormattedText(mainWindow,'female',widthX/4,heightY/2);
    DrawFormattedText(mainWindow,'male',widthX-widthX/3,heightY/2); 
elseif xSup == 2 %scene
    DrawFormattedText(mainWindow,'indoor',widthX/4,heightY/2);
    DrawFormattedText(mainWindow,'outdoor',widthX-widthX/3,heightY/2); 
end 

if (fMRI == 1)
    [x, recorded] = WaitTRPulsePTB3_skyra(1,trialStart+allowance);
    stimStart = Screen('Flip',mainWindow);
else
    recorded = 1;
    stimStart = Screen('Flip',mainWindow,trialStart);
end
Priority(0);