function [] = waiting_for_scanner(mainWindow, backColor)

Screen(mainWindow,'FillRect',backColor);
DrawFormattedText(mainWindow, 'Waiting for scanner...', 'center', 'center', [0 0 0]);
Screen('Flip',mainWindow);