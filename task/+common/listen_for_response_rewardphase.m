function [rt, response, qq] = listen_for_response_rewardphase(mainWindow, stimStart, respWindow, stimDuration, respColor, fixColor, fixDotRect, keys, trialImage, imageRect, centerRect, DEVICE)
qq = 0;
rt = 0;
response = nan;
imageRemoved = false;

%FlushEvents('keyDown');
KbQueueFlush(DEVICE);
while (GetSecs<stimStart+respWindow) % wait until max response time
    if (~imageRemoved)
        if (GetSecs>stimStart+stimDuration) % remove image if > duration
            if (rt>0) && response < 3
                Screen(mainWindow,'FillOval',respColor,fixDotRect);
            else
                Screen(mainWindow,'FillOval',fixColor,fixDotRect);
            end
            Screen('Flip',mainWindow,[],1); %leave in backbuffer
            imageRemoved = 1;
        end
    end
    if (rt==0) % check for responses if none received yet
        [pressed, firstPress] = KbQueueCheck(DEVICE); %[keyIsDown,secs,keyCode] = KbCheck(-1);
        if pressed %if (keyIsDown)
            firstPress(find(firstPress==0))=NaN; %get rid of 0s
            [secs, keyCode]=min(firstPress); %KbName(keyCode) will convert KeyID to keyname
            if any(keys==keyCode) %if ( any(keyCode(keys)) )
                rt = secs-stimStart;
                response = find(keys==keyCode); %response = find( keyCode(keys) );
                if response == length(keys)%if EXIT,..
                    qq = 1;break
                end
                %                 if (~imageRemoved) % keep image up if < duration
                %                     Screen('DrawTexture',mainWindow,trialImage,imageRect,centerRect);
                %                 end
                if response < 3 %valid keypress
                    Screen(mainWindow,'FillOval',respColor,fixDotRect); %change to dot to white
                else %invalid keypress
                    Screen(mainWindow,'FillOval',fixColor,fixDotRect); %don't change fixation dot color
                end
                Screen('Flip',mainWindow,[],1); %leave in backbuffer
            end
        end
    end
end

end