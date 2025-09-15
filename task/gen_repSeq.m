% edited by eam 10/2/17
% edited by eam 9/4/18
% edited by eam 11/30/18 to revert to 2 task conditions

function gen_repSeq()
fMRI = 0;
VioDiffCon_VarConfig;

for subj = subjList
    if subj < 10
        SN = ['0' num2str(subj)];
    else
        SN = [num2str(subj)];
    end
    
    for blk = 1:nBlk_learning
        while 1
            clearvars -except SN blk fMRI
            
            success = 0;

            VioDiffCon_VarConfig;
            
            pairs(1,:) = 1:nPair{1};
            pairs(2,:) = 1:nPair{2};
%             pairs(3,:) = 1:nPair{3};
            
            nSlot = 0;
            for cond = 1:nCond
                nSlot = nSlot+nPair{cond}*nRep{cond};
            end%for cond
            
            slots = 1:nSlot;
            slots_filled = zeros(1,nSlot);
            
            conds = [];
            for cond = 1:nCond
                conds = [conds repmat(cond,1,nPair{cond})];
            end%for cond
            
            % shuffle condition, and then assign a repetition number to
            % within each condition
            conds = Shuffle(conds);
            for cond = 1:nCond
                conds(2, conds(1,:) == cond) = 1:nPair{cond};
            end%for cond

            countID = 0;
            %% limit of inter-pair pairs
            limit = [2 20]; % range of inter-pair intervals
            pairID_set = [];%record pair id
            
            %% start from 1st item
            while 1
                %determine the 1st item
                count_recal_item = 0;%count calcualation for each item
                countID = countID + 1;%id of pairs (1~32)
                
                this_cond = conds(1,countID);
                % Condition 1: Violation + restudy V+R+ (AB-AB-AB-AX-B-AY-B)
                % Condition 2: No violation control V-R+ (AB-AB-AB-B-B)
                thisPairID = conds(2,countID);%pair id
                
                free_slots = find(slots_filled==0);%not filled slot
                
                thisSlot{this_cond}{thisPairID}{1} = min(free_slots);%determine the 1st item's location
                % slots_filled(thisSlot{this_cond}{thisPairID}{1}) = thisPairID*((-1)^this_cond);%fill the slot
                
                % *****Lizzie Edit*****
                cond_multiplier{1} = 1;
                cond_multiplier{2} = 10;
%                 cond_multiplier{3} = 100;
                slots_filled(thisSlot{this_cond}{thisPairID}{1}) = thisPairID*cond_multiplier{this_cond};%fill the slot
                
                %record pair id
                % pairID_set(this_cond,thisPairID) = thisPairID*((-1)^this_cond);
                pairID_set(this_cond,thisPairID) = thisPairID*cond_multiplier{this_cond};
                
                free_slots = find(slots_filled==0);%remaining slots
                possible_slots = free_slots(free_slots >= thisSlot{this_cond}{thisPairID}{1}+limit(1)+1 & free_slots <= thisSlot{this_cond}{thisPairID}{1}+limit(2)+1);%slots that fit to limit
                
                rep = 1;
                %start filling in rep
                while 1
                    rep = rep+1;
                    
                    if rep == 2
                        if isempty(possible_slots)
                            break
                        end
                    end%if rep
                    
                    count_recal_rep = 0;%count calcualation for each repetition
                    
                    thisSlot{this_cond}{thisPairID}{rep} = RandSel(possible_slots,1);
                    % slots_filled(thisSlot{this_cond}{thisPairID}{rep}) = thisPairID*((-1)^this_cond);
                    slots_filled(thisSlot{this_cond}{thisPairID}{rep}) = thisPairID*cond_multiplier{this_cond};
                    free_slots = find(slots_filled==0);
                    
                    if rep < nRep{this_cond} %if # of repetition not the end (4 or 3)
                        %searching for next possible slots
                        possible_slots = free_slots(free_slots >= thisSlot{this_cond}{thisPairID}{rep}+limit(1)+1 & free_slots <= thisSlot{this_cond}{thisPairID}{rep}+limit(2)+1);
                        
                        %if not possible
                        while isempty(possible_slots)
                            count_recal_item = count_recal_item + 1;
                            %erase this selected for the rep
                            slots_filled(thisSlot{this_cond}{thisPairID}{rep}) = 0;
                            free_slots = find(slots_filled==0);
                            
                            %searching from previous rep
                            possible_slots = free_slots(free_slots >= thisSlot{this_cond}{thisPairID}{rep-1}+limit(1)+1 & free_slots <= thisSlot{this_cond}{thisPairID}{rep-1}+limit(2)+1);
                            thisSlot{this_cond}{thisPairID}{rep} = RandSel(possible_slots,1);%select again for this rep
                            % slots_filled(thisSlot{this_cond}{thisPairID}{rep}) = thisPairID*((-1)^this_cond);%fill in again
                            slots_filled(thisSlot{this_cond}{thisPairID}{rep}) = thisPairID*cond_multiplier{this_cond};%fill in again
                            free_slots = find(slots_filled==0);
                            %searching for next possible slots 'again'
                            possible_slots = free_slots(free_slots >= thisSlot{this_cond}{thisPairID}{rep}+limit(1)+1 & free_slots <= thisSlot{this_cond}{thisPairID}{rep}+limit(2)+1);
                            
                            %count # of recalcualation
                            count_recal_rep = count_recal_rep+1;
                            
                            if count_recal_item > 10000
                                break
                            end%if count
                            
                            %if not possible
                            if rep >= 3
                                if count_recal_rep > 1000
                                    %erase this selected for the rep
                                    slots_filled(thisSlot{this_cond}{thisPairID}{rep}) = 0;
                                    slots_filled(thisSlot{this_cond}{thisPairID}{rep-1}) = 0;
                                    free_slots = find(slots_filled==0);
                                    possible_slots = free_slots(free_slots >= thisSlot{this_cond}{thisPairID}{rep-2}+limit(1)+1 & free_slots <= thisSlot{this_cond}{thisPairID}{rep-2}+limit(2)+1);
                                    rep = rep - 2; break%out of search of this item, and go to 2nd search
                                end%if count_recal_rep
                            end%if rep
                        end%while
                    end%if rep
                    
                    if rep == nRep{this_cond}
                        break%out of rep of this item
                    end
                    
                    if count_recal_item > 10000%out of repetition
                        break
                    end%if count
                end%while 1
                
                if rep == 2
                    if isempty(possible_slots)
                        break
                    end
                end%if rep
                
                
%                 if countID == nPair{1}+nPair{2}+nPair{3} && isempty(find(slots_filled == 0, 1))
                if countID == nPair{1}+nPair{2} && isempty(find(slots_filled == 0, 1))
                    success = 1; break
                end
                
                if count_recal_item > 10000%start again!!!
                    break
                end%if count
            end%while 1
            
            if success
                break
            end
        end%while 1
        
        %% generating matrix
        repSeqMat = [];
        IPIMat = [];
        if success
            for cond = 1:nCond
                for pair = 1:nPair{cond}
                    % thisPairID = pair*((-1)^cond);
                    thisPairID = pair*cond_multiplier{cond};
                    thisRepSet = find(slots_filled == thisPairID);
                    
                    repSeqMat(1,thisRepSet) = cond; % 1 or 2
                    repSeqMat(2,thisRepSet) = 1:nRep{cond}; % 1 thru 7 (condition 1), 1 thru 5 (condition 2)
                    repSeqMat(3,thisRepSet) = pair; 
                    for rep = 1:length(thisRepSet)-1
                        temp = slots_filled(thisRepSet(rep)+1:thisRepSet(rep+1)-1); %1:single digit, 2:double digit, 3:triple digit
                        % xITI = nItemPair{1}*length(temp(temp < 0))+nItemPair{2}*length(temp(temp > 0)); %use this if two conditions have different nPair per condition
                        % xITI = nItemPair{1}*length(temp(temp < 10))+nItemPair{2}*(length(temp(temp > 9)) - length(temp(temp > 99)))+nItemPair{3}*length(temp(temp > 99)); %use this if three conditions have different nPair per condition
                        xITI = 2*length(temp);
                        IPIMat(pair,rep,cond) = xITI;
                        repSeqMat(4,thisRepSet(rep)) = xITI;
                    end%for rep
                end%for pair
            end%for cond
            save([out_mat_dir '/repSeqMat_' SN '_' num2str(blk)], 'repSeqMat')
        end%if success
    end%for blka
end%for subj
