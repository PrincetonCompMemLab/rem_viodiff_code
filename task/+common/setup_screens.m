function [screenNum, screenX, screenY, centerX, centerY, mainWindow, imageRect, centerRect, fixDotRect, refreshrate] = setup_screens(fMRI, backColor, textFont, textSize, imageSize, fixationSize)
global deburg

if fMRI
    screenNum = 1;
else
    screenNum = 0;
end

if deburg
    screenNum = 0;
end%if deburg
screenNum

% this is only for testing!
% screenNum = 1;
Screen('Preference', 'SkipSyncTests', 1); %1 to skip, 0 for maximum accuracy and reliability

[screenX screenY] = Screen('WindowSize',screenNum);
mainWindow = Screen(screenNum,'OpenWindow',backColor);

centerX = screenX/2;
centerY = screenY/2;
Screen(mainWindow,'TextFont',textFont);
Screen(mainWindow,'TextSize',textSize);
imageRect = [0,0,imageSize,imageSize];
centerRect = [centerX-imageSize/2,centerY-imageSize/2,centerX+imageSize/2,centerY+imageSize/2];
fixDotRect = [centerX-fixationSize,centerY-fixationSize,centerX+fixationSize,centerY+fixationSize];

refreshrate = Screen('GetFlipInterval', mainWindow);
refreshrate
end