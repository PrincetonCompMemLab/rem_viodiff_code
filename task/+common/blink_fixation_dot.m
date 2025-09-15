function [] = blink_fixation_dot(mainWindow, backColor, fixColor, fixDotRect, numBlinks, blinkDur, runTime, startPrep, refreshrate)

for i=1:numBlinks
  common.clear_screen(mainWindow, backColor);
  boff = Screen('Flip',mainWindow, startPrep+refreshrate*4-refreshrate/3);
  common.draw_fixation_dot(mainWindow, backColor, fixColor, fixDotRect);
  %doton2 = Screen('Flip',mainWindow,boff+blinkDur-refreshrate/3);
  Screen('Flip',mainWindow,boff+blinkDur-refreshrate/3);
end

%for checking timing
% startPrep = startPrep-runTime
% clearscreen = boff-runTime
% doton2 = doton2-runTime
% check_blinkDur1 = clearscreen-startPrep
% check_blinkDur2 = doton2-clearscreen