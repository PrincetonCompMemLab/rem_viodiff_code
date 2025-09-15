function [rt, response, qq] = listen_for_response_decisionphase(mainWindow, stimStart, respWindow, stimDuration, respColor, fixColor, fixDotRect, keys, trialImage_reward, trialImage_neutral, imageRect, centerRect_reward, centerRect_neutral, leftRect, rightRect, DEVICE)
qq = 0;
rt = 0;
response = nan;
imageRemoved = false;

%FlushEvents('keyDown');
KbQueueFlush(DEVICE);
while (GetSecs<stimStart+respWindow) % wait until max response time
    if (~imageRemoved)
        if (GetSecs>stimStart+stimDuration) % remove image if > duration
            Screen(mainWindow,'FillOval',fixColor,fixDotRect); %keep dot black even if key pressed
%             if (rt>0)
%                 Screen(mainWindow,'FillOval',respColor,fixDotRect); 
%             else
%                 Screen(mainWindow,'FillOval',fixColor,fixDotRect);
%             end
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
                
                if response > 2
                    feedbackRect = [];
                elseif response == 1 %choose left
                    feedbackRect = [leftRect(1,1:2)-2 leftRect(1,3:4)+2];
                elseif response == 2 %choose right
                    feedbackRect = [rightRect(1,1:2)-2 rightRect(1,3:4)+2];
                end
                if (~imageRemoved) % keep image up if < duration
                    Screen('DrawTexture',mainWindow,trialImage_reward,imageRect,centerRect_reward);
                    Screen('DrawTexture',mainWindow,trialImage_neutral,imageRect,centerRect_neutral);
                end
                Screen(mainWindow,'FillOval',fixColor,fixDotRect);
                if response < 3
                    Screen(mainWindow, 'FrameRect', [0 0 255], feedbackRect, 5);
                    Screen('DrawTexture',mainWindow,trialImage_reward,imageRect,centerRect_reward);
                    Screen('DrawTexture',mainWindow,trialImage_neutral,imageRect,centerRect_neutral);
                end
                Screen('Flip',mainWindow,[],1); %leave in backbuffer
            end
        end
    end
end

end