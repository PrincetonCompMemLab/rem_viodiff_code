function [] = progress_bar(proportion, mainWindow)
  progWidth = 400; % image loading progress bar
  progHeight = 20;
  
  [screenX screenY] = Screen('WindowSize',mainWindow);
  centerX = screenX/2;
  centerY = screenY/2;
  progRect = [centerX-progWidth/2,centerY-progHeight/2,centerX+progWidth/2,centerY+progHeight/2];

  Screen('FrameRect',mainWindow,0,progRect,10);
  Screen('FillRect',mainWindow,0,progRect);
  Screen('FillRect',mainWindow,[255 0 0],progRect-[0 0 round((1-proportion)*progWidth) 0]);
  Screen('Flip',mainWindow);
end