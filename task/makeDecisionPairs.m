% edited by eam 11/30/18 reverting to 2 task conditions

%coding scheme
%first digit: stat learning condition (1=V+R+, 2=V-R+)
%second digit: pairtype (0=outdoor/outdoor 1=indoor/indoor 3=indoor/outdoor
%4=outdoor/indoor)
%third digit: reward condition (1=reward, 2=neutral)
%fourth digit: pair number within condition, pairtype, and rewardcond (1-6)

%% 
for cond = 1:nCond
    start_num = 1000*cond;
    condition_labels{cond}(:,1) = [(start_num+11:start_num+16)';(start_num+21:start_num+26)']; %o/o
    condition_labels{cond}(:,2) = [(start_num+111:start_num+116)';(start_num+121:start_num+126)']; %i/i
    condition_labels{cond}(:,3) = [(start_num+311:start_num+316)'; (start_num+321:start_num+326)'];%i/o
    condition_labels{cond}(:,4) = [(start_num+411:start_num+416)'; (start_num+421:start_num+426)'];%o/i

%     outdoor_outdoor=condition_labels{cond}(:,1);
%     indoor_indoor=condition_labels{cond}(:,2);
%     indoor_outdoor=condition_labels{cond}(:,3);
%     outdoor_indoor=condition_labels{cond}(:,4);
    
    for pairtype = 1:nPairtypes
        trialpairings = condition_labels{cond}(:,pairtype);
        reward_pairs = trialpairings(1:length(trialpairings)/2); %first half are reward 
        neutral_pairs = trialpairings(length(trialpairings)/2+1:length(trialpairings)); %second half are neutral
        
        for i=1:nTestreps-2
            neutral_pairs = [neutral_pairs neutral_pairs]; %duplicate
        end
        
        if pairtype == 1
            %outdoor_outdoor = condition_labels{cond}(:,pairtype);
            outdoor_outdoor=[reward_pairs neutral_pairs];
            temp=outdoor_outdoor;
        elseif pairtype == 2
            %indoor_indoor = condition_labels{cond}(:,pairtype);
            indoor_indoor=[reward_pairs neutral_pairs];
            temp=indoor_indoor;
        elseif pairtype == 3
            %indoor_outdoor = condition_labels{cond}(:,pairtype);
            indoor_outdoor=[reward_pairs neutral_pairs];
            temp=indoor_outdoor;
        elseif pairtype == 4
            %outdoor_indoor = condition_labels{cond}(:,pairtype);
            outdoor_indoor=[reward_pairs neutral_pairs];
            temp=outdoor_indoor;
        end

        for r=2:nTestreps+1
            success=0;
            repeat=0;
            temp(:,r) = Shuffle(temp(:,r));
            while success==0
                for i=1:size(temp,1)
                    if r == 2
                        if temp(i,1) == temp(i,r)
                            repeat = repeat+1;
                        end
                    elseif r == 3
                        if temp(i,1) == temp(i,r) || temp(i,r-1) == temp(i,r)
                            repeat = repeat+1;
                        end
                    elseif r == 4
                        if temp(i,1) == temp(i,r) || temp(i,r-1) == temp(i,r) || temp(i,r-2) == temp(i,r)
                            repeat = repeat+1;
                        end
                    elseif r == 5
                        if temp(i,1) == temp(i,r) || temp(i,r-1) == temp(i,r) || temp(i,r-2) == temp(i,r) || temp(i,r-3) == temp(i,r)
                            repeat = repeat+1;
                        end
                    end
                end
                if repeat > 0 %if there was a repeat between 1 and 2
                    temp(:,r) = Shuffle(temp(:,r));
                    repeat=0;
                else
                    success = 1;
                end
            end
        end
        
        for i=1:size(temp,1)
            test=unique(temp(i,:));
            if length(test) < nTestreps+1
                ('ERROR')
                SN
                cond
                pairtype
                i
            end
        end
%         ('all good! condition:')
%         cond
%         ('pairtype:')
%         pairtype
        
        decision_pairings{cond}{pairtype}=temp;
        
    end %for pairtype
end %for condition

clear pairtype cond





    