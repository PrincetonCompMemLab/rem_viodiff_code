% edited by eam 10/3/17
% edited by eam 9/4/18
% edited by eam 11/30/18 revert to 2 task conditions

function VioDiffCon_expand_mat
%% random seed
if verLessThan('matlab', '7.7')
    rand('seed',sum(100*clock));
    
elseif verLessThan('matlab', '7.14')
    currStream = RandStream.getDefaultStream;
    if currStream.Seed == 0 % (should only be done ONCE per session)
        RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
    end
    
else
    RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));
end%if verLessThan
%%
fMRI = 0; %for creating trial matrices
VioDiffCon_VarConfig;

% pair subcategory options (within condition)
pair_cate_mat{1} = [1,1;1,1]; % indoor/indoor
pair_cate_mat{2} = [1,1;2,2]; % indoor/outdoor
pair_cate_mat{3} = [2,2;1,1]; % outdoor/indoor
pair_cate_mat{4} = [2,2;2,2]; % outdoor/outdoor
pair_cate_mat{5} = [1,1;1,1]; % indoor/indoor
pair_cate_mat{6} = [1,1;2,2]; % indoor/outdoor
pair_cate_mat{7} = [2,2;1,1]; % outdoor/indoor
pair_cate_mat{8} = [2,2;2,2]; % outdoor/outdoor
%%
for subj = subjList
    
    if subj < 10
        SN = ['0' num2str(subj)];
    else
        SN = [num2str(subj)];
    end%if subj

    %% prep for post-study mat
    for i=1:nBlk_postlearning_scenes
        postStudy_scenes_mat{i} = [];
    end
    
    for i=1:nBlk_postlearning_faces
        postStudy_faces_mat{i} = [];
    end
    
    %% expansion
    for blk = 1:nBlk_learning
        for cond = 1:nCond
            pairID_cate_match{cond} = Shuffle(1:nPair{cond});
        end%for cond
        %%
        load([out_mat_dir '/repSeqMat_' SN '_' num2str(blk)], 'repSeqMat')
        
        learning_mat{blk} = [];
        
        start_slot = 1;
        
        for ii = 1:length(repSeqMat) %loop through each pair
            thisCond = repSeqMat(1,ii);%1:V+R+, 2:V-R+
            thisRep = repSeqMat(2,ii);%repetition number (of that pair in that condition)
            thisPairID = repSeqMat(3,ii);%pair id

            slots_filled = start_slot:start_slot+nItemPair{thisCond}-1;
            start_slot = start_slot+nItemPair{thisCond};
            learning_mat{blk}(1:4, slots_filled) = repmat(repSeqMat(1:4,ii), 1, nItemPair{thisCond});%1:cond, 2:rep, 3:ID, 4:ipi
            learning_mat{blk}(5, slots_filled) = 1:nItemPair{thisCond}; %5:order
            
            %upper, lower category
            learning_mat{blk}(6:7, slots_filled) = pair_cate_mat{pairID_cate_match{thisCond}(thisPairID)}(1:nItemPair{thisCond},:)';%6:uppper (subcategory - 1:indoor 2:outdoor), 7:lower (face or scene)
        end%for ii
        learning_mat{blk}(7,:) = 2;%scenes
    end%for blk
    
    %% image preparation
    for sup = 1:nSup
        for sub = 1:nSub
            imgAll = Shuffle(1:nImg_foler{sup}{sub});
            for blk = 1:nBlk_learning
                imgSet{blk}{sup}{sub} = imgAll((blk-1)*nImg_learning_blk{sup}{sub}+1 : ...
                    blk*nImg_learning_blk{sup}{sub});
            end%for blk
        end%for sub
    end%for sup
    
    %% inserting img id & time
    for blk = 1:nBlk_learning
        %%putting img num for the first rep
        for sub = 1:nSub
            learning_mat{blk}(8, learning_mat{blk}(2,:) == 1 & learning_mat{blk}(6,:) == sub) = imgSet{blk}{2}{sub};
        end%for cate
        %%
        %filling in all repetition, first
        for cond = 1:nCond
            for pair = 1:nPair{cond}
                for rep = 1:nRep{cond}-1
                    rep = rep+1;
                    for order = 1:nItemPair{cond}
                        learning_mat{blk}(8, learning_mat{blk}(1,:) == cond & learning_mat{blk}(2,:) == rep & learning_mat{blk}(3,:) == pair ...
                            & learning_mat{blk}(5,:) == order) = learning_mat{blk}(8, learning_mat{blk}(1,:) == cond & learning_mat{blk}(2,:) == 1 & learning_mat{blk}(3,:) == pair ...
                            & learning_mat{blk}(5,:) == order);
                    end%for order
                end%for rep
            end%for pair
        end%for cond
        
        %% for violation conditions, insert face on second trial of violation reps
        for cond = 1 %condition(s) with violations 1:V+R+
            for ii=1:length(vioRep{cond})
                learning_mat{blk}(7, learning_mat{blk}(1,:) == cond & learning_mat{blk}(2,:) == vioRep{cond}(ii) & learning_mat{blk}(5,:) == 2) = 1;%face
            end %for ii
        end
        
        %% deleting the first item for restudy trials
        for cond = [1 2] %condition(s) with restudy 1:V+R+ 2:V-R+
            for ii = 1:length(DiffRep{cond})
                learning_mat{blk}(:,  learning_mat{blk}(1,:) == cond & learning_mat{blk}(2,:) == DiffRep{cond}(ii) & learning_mat{blk}(5,:) == 1) = [];
            end%for ii
        end%for cond
        
        %% inserting face image
        for cond = 1 %condition(s) with violations 1:V+R+
            for sub = 1:nSub
                learning_mat{blk}(8, learning_mat{blk}(1,:) == cond & learning_mat{blk}(7,:) == 1 & learning_mat{blk}(6,:) == sub) = imgSet{blk}{1}{sub};
            end%for sub
        end %for cond

        %% inserting pre-study trials
        temp = learning_mat{blk}(:,learning_mat{blk}(2,:) == 1);
        
        %% check whether accidently preceding item is A and the next item is B
        
        randOrder = Shuffle(1:size(temp, 2));
        check = 0;
        
        while 1
            for ii = 1:length(randOrder)-1
                thisCond = temp(1,randOrder(ii));
                
                %                 if thisCond == 1
                if randOrder(ii) == randOrder(ii+1)-1 || randOrder(ii) == randOrder(ii+1)+1
                    check = check + 1;
                end
                %                 end%if thisCond
            end%for ii
            
            if ~check
                break
            else
                randOrder = Shuffle(1:size(temp, 2));
                check = 0;
            end
        end%while 1
        %%
        prestudy = [];
        for ii = 1:size(temp, 2)
            prestudy(:, ii) = temp(:, randOrder(ii));
        end%for ii
        
        %% end-1,end-2 trials of the pre-study trial should not be the same with the first & second trials of study
        
        while prestudy(8,end) == learning_mat{blk}(8,1) || prestudy(8,end-1) == learning_mat{blk}(8,1) ...
                || prestudy(8,end) == learning_mat{blk}(8,2) || prestudy(8,end-1) == learning_mat{blk}(8,2)
            
            randOrder = Shuffle(1:size(temp, 2));
            check = 0;
            
            while 1
                for ii = 1:length(randOrder)-1
                    thisCond = temp(1,randOrder(ii));
                    
                    %                     if thisCond == 1
                    if randOrder(ii) == randOrder(ii+1)-1 || randOrder(ii) == randOrder(ii+1)+1
                        check = check + 1;
                    end
                    %                     end%if thisCond
                end%for ii
                
                if ~check
                    break
                else
                    randOrder = Shuffle(1:size(temp, 2));
                    check = 0;
                end
            end%while 1
            
            for ii = 1:size(temp, 2)
                prestudy(:, ii) = temp(:, randOrder(ii));
            end%for ii
        end%for while
        
        prestudy(9:10,:) = 0;
        prestudy(1,:) = 3; %prestudy trials are "condition 3"
        
        %% insert additional trial info
        learning_mat{blk}(9,:) = 1:length(learning_mat{blk}); %add trial num to row 9
        learning_mat{blk}(10,:) = 1; %all scenes go into the same postlearning run
        
%         for cond = 1:nCond
%             for lower = 1:nSub
%                 %ll = size(learning_mat{blk}(8, learning_mat{blk}(1,:) == cond & learning_mat{blk}(2,:) == 1 & learning_mat{blk}(5,:) == 1 & learning_mat{blk}(6,:) == lower), 2);
%                 %ll = size(learning_mat{blk}(8, learning_mat{blk}(1,:) == cond & learning_mat{blk}(2,:) == 1 & learning_mat{blk}(6,:) == lower), 2);
%                 indx = find(learning_mat{blk}(1,:) == cond & learning_mat{blk}(2,:) == 1 & learning_mat{blk}(6,:) == lower); %find all instances of each subcategory within each condition
%                 %ttt = Shuffle(repmat(1:2, 1, ll/2));
%                 ttt = Shuffle(repmat(1:2, 1, length(indx)/2)); % assign equal number of outdoor/indoor images to each postlearning run
%                 %indx = learning_mat{blk}(9, learning_mat{blk}(1,:) == cond & learning_mat{blk}(2,:) == 1 & learning_mat{blk}(5,:) == 1 & learning_mat{blk}(6,:) == lower);
%                 %indx = learning_mat{blk}(9, learning_mat{blk}(1,:) == cond & learning_mat{blk}(2,:) == 1 & learning_mat{blk}(6,:) == lower);
%                 learning_mat{blk}(10, indx) = ttt;%first
%                 %learning_mat{blk}(10, indx+1) = ttt;%second
%             end%for lower
%         end%for cond

        %% isolate B scenes for postlearning_scenes and XY faces for postlearning_faces
        temp = learning_mat{blk};

        %scenes
        for test_type = 1:nBlk_postlearning_scenes
            this_add = temp(:, temp(10,:) == test_type & temp(2,:) == 1 & temp(5,:) == 2 & temp(7,:) == 2); %get B scenes assigned to each postlearning run
            this_add(11,:) = blk; % add a row saying which learning block scene came from
            postStudy_scenes_mat{test_type} = [postStudy_scenes_mat{test_type} this_add];
        end%for test_type
        
        %faces
        for test_type = 1:nBlk_postlearning_faces
            this_add = temp(:, temp(10,:) == test_type & temp(7,:) == 1); %get XY faces assigned to each postlearning run
            this_add(11,:) = blk; % add a row saying which learning block scene came from
            postStudy_faces_mat{test_type} = [postStudy_faces_mat{test_type} this_add];
        end%for test_type
        
        %% combining with pre-study trials
        learning_mat{blk} = [prestudy learning_mat{blk}];
        
        %% inserting time
        learning_mat{blk}(9,:) = disdaq + [0:size(learning_mat{blk},2)-1]*trialDur;
    end%for blk

    %% postlearning - inserting trial order
    for test_type = 1:nBlk_postlearning_scenes
        postStudy_scenes_mat{test_type}(12,:) = Shuffle(1:nTrial_postlearning_scenes);%trial order
        [postStudy_scenes_mat{test_type}] = sortcols(postStudy_scenes_mat{test_type}, 12);
        postStudy_scenes_mat{test_type}(13,:) = disdaq + [0:size(postStudy_scenes_mat{test_type},2)-1]*trialDur;%inserting time
    end%for test
    
    for test_type = 1:nBlk_postlearning_faces
        postStudy_faces_mat{test_type}(12,:) = Shuffle(1:nTrial_postlearning_faces);%trial order
        [postStudy_faces_mat{test_type}] = sortcols(postStudy_faces_mat{test_type}, 12);
        postStudy_faces_mat{test_type}(13,:) = disdaq + [0:size(postStudy_faces_mat{test_type},2)-1]*trialDur;%inserting time
    end%for test
    
    %% save the data
    save([out_mat_dir '/learning_mat_' SN], 'learning_mat');
    save([out_mat_dir '/postScenes_mat_' SN], 'postStudy_scenes_mat');
    save([out_mat_dir '/postFaces_mat_' SN], 'postStudy_faces_mat');
    
end%for subj

% %% condition rows
% learning_mat_row.cond = 1; %V+R+ (1) V-R+ (2) 
% learning_mat_row.rep = 2; %pair repetition
% learning_mat_row.pairID = 3; %pair number (1 thru nPair)
% learning_mat_row.ipi = 4; %inter-trial interval (this is really inter-pair*2)
% learning_mat_row.order = 5; %order within pair (1 or 2)
% learning_mat_row.lower = 6; %subcategory (1) female or indoor (2) male or outdoor
% learning_mat_row.upper = 7; %face (1) or scene (2)
% learning_mat_row.imgID = 8; %imgID
% learning_mat_row.time = 9; %presentation time
% learning_mat_row.testType = 10; %postlearning run (currently only 1 run)
% learning_mat_row.Resp = 11;
% learning_mat_row.RT = 12;
% learning_mat_row.ACC = 13;
% learning_mat_row.onset = 14;
% learning_mat_row.recorded = 15;
% learning_mat_row.fMRItrigger = 16;
% save([out_mat_dir '/learning_mat_row'], 'learning_mat_row');
% 
% % rows 1 thru 10 are the same as learning_mat (except row 9 which lists
% % learning trial num instead of trial timing); postStudy rows are the same
% % for scene and face matrices
% postStudy_mat_row.cond = 1;
% postStudy_mat_row.rep = 2;
% postStudy_mat_row.pairID = 3;
% postStudy_mat_row.ipi = 4;
% postStudy_mat_row.order = 5;
% postStudy_mat_row.lower = 6;
% postStudy_mat_row.upper = 7;
% postStudy_mat_row.imgID = 8;
% postStudy_mat_row.learningTrialnum = 9; %original learning trial number (within block)
% postStudy_mat_row.testType = 10;
% postStudy_mat_row.blk = 11; %learning block number
% postStudy_mat_row.trial = 12; %postlearning trial num
% postStudy_mat_row.time = 13; %postlearning presentation time
% postStudy_mat_row.Resp = 14;
% postStudy_mat_row.RT = 15;
% postStudy_mat_row.ACC = 16;
% postStudy_mat_row.onset = 17;
% postStudy_mat_row.recorded = 18;
% postStudy_mat_row.fMRItrigger = 19;
% save([out_mat_dir '/postStudy_mat_row'], 'postStudy_mat_row');
