function [rt response qq] = listen_for_response_until(mainWindow, stimStart, respWindow, stimDuration, respColor, fixColor, fixDotRect, keys, trialImage, imageRect, centerRect)
qq = 0;
rt = 0;
response = 7;
imageRemoved = false;
keyIsDown = 0;

FlushEvents('keyDown');
while ~keyIsDown % wait until max response time
    if (~imageRemoved)
        if (GetSecs>stimStart+stimDuration) % remove image if > duration
            if (rt>0)
                Screen(mainWindow,'FillOval',respColor,fixDotRect);
            else
                Screen(mainWindow,'FillOval',fixColor,fixDotRect);
            end
            Screen('Flip',mainWindow);
            imageRemoved = 1;
        end
    end
    if (rt==0) % check for responses if none received yet
        [keyIsDown,secs,keyCode] = KbCheck(-1);
        if (keyIsDown)
            if ( any(keyCode(keys)) )
                rt = secs-stimStart;
                response = find( keyCode(keys) );
                if response == length(keys)%if EXIT,..
                    qq = 1;break
                end
                if (~imageRemoved) % keep image up if < duration
                    Screen('DrawTexture',mainWindow,trialImage,imageRect,centerRect);
                end
                Screen(mainWindow,'FillOval',respColor,fixDotRect);
                Screen('Flip',mainWindow);
                WaitSecs(0.2)
            end
        end
    end
end



end