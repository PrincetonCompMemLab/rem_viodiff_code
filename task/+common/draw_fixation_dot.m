function [] = draw_fixation_dot(mainWindow, backColor, fixColor, fixDotRect)

Screen(mainWindow,'FillRect',backColor);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);