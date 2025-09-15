function [] = clear_screen(mainWindow, backColor)

Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);