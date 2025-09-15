% created 022415 gtk

clear all
clc
fclose('all');
%%
VioDiffCon_VarConfig

%% cond,order
repList{1}{1} = [1 2 3 4 6];
repList{1}{2} = [1 2 3 4 5 6 7];

repList{2}{1} = [1 2 3];
repList{2}{2} = [1 2 3 4 5];
%% load mat_row
load([out_mat_dir '/learning_mat_row'],'learning_mat_row');

% learning_mat_row.cond = 1;
% learning_mat_row.rep = 2;
% learning_mat_row.pairID = 3;
% learning_mat_row.ipi = 4;
% learning_mat_row.order = 5;
% learning_mat_row.lower = 6;
% learning_mat_row.upper = 7;
% learning_mat_row.imgID = 8;
% learning_mat_row.time = 9;
% learning_mat_row.testType = 10;
% learning_mat_row.Resp = 11;
% learning_mat_row.RT = 12;
% learning_mat_row.ACC = 13;
learning_mat_row.blk = 14;

%% load mat_row
load([out_mat_dir '/test_mat_row'], 'test_mat_row');

% test_mat_row.cond = 1;
% test_mat_row.rep = 2;
% test_mat_row.pairID = 3;
% test_mat_row.ipi = 4;
% test_mat_row.order = 5;
% test_mat_row.lower = 6;
% test_mat_row.upper = 7;
% test_mat_row.imgID = 8;
% test_mat_row.pre_time = 9;
% test_mat_row.testType = 10;
% test_mat_row.blk = 11;
% test_mat_row.trial = 12;
% test_mat_row.time = 13;
% test_mat_row.Resp = 14;
% test_mat_row.RT = 15;
% test_mat_row.ACC = 16;
% test_mat_row.Confi = 17;
%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analysis of learning phase
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for subj = subjList
    %%
    if subj < 10
        SN = [num2str(subj)];
    else
        SN = [num2str(subj)];
    end%if subj
    
    %% %%%%%%%%%%%%%%%%%%%%%
    % learning phase
    %% %%%%%%%%%%%%%%%%%%%%%
    rowNum = learning_mat_row;
    %% load data
    study_lists = dir([out_mat_dir '/learning_mat_' SN '.mat']);
    load([out_mat_dir '/' study_lists.name]);
    learningData = [];
    %%
    for blk = 1:nBlk_learning
        temp = learning_mat{blk};
        temp(rowNum.blk,:) = blk;
        
        learningData = [learningData temp];
    end%for blk
    
    lists = dir([out_mat_dir '/test_mat_' SN '.mat']);
    load([out_mat_dir '/' lists.name]);
    testData{1} = test_mat{1};
    testData{2} = test_mat{2};
    
    testMat = [testData{1} testData{2}];
    %%
    for blk = 1:nBlk_learning
        %%
        temp = learningData(:, learningData(rowNum.blk,:) == blk);
        %% checking repetition
        for cond = 1:nCond
            for pair = 1:nPair{cond}
                for order = 1:nItemPair{cond}
                    nnRep = length(repList{cond}{order});
                    %%
                    for rep = 1:nnRep
                        rr = repList{cond}{order}(rep);
                        
                        imgMat{subj}{blk}{cond}(pair, length(repList{cond}{1})*(order-1)+rep) = temp(rowNum.imgID,temp(rowNum.blk,:) == blk & temp(rowNum.cond,:) == cond & temp(rowNum.rep,:) == rr & temp(rowNum.pairID,:) == pair ...
                            & temp(rowNum.order,:) == order);
                    end%for rep
                end%for order
            end%for pair
        end%for cond
    end%for blk
    
    %%
    checkSum = 0;
    for blk = 1:nBlk_learning
        for cond = 1:nCond
            for pair = 1:nPair{cond}
                if cond == 1
                    if length(unique(imgMat{subj}{blk}{cond}(pair,1:5))) > 1 || length(unique(imgMat{subj}{blk}{cond}(pair,[6 7 8 10 12]))) > 1
                        thisCheck = 1;%error
                    else
                        thisCheck = 0;
                    end
                else
                    if length(unique(imgMat{subj}{blk}{cond}(pair,1:3))) > 1 || length(unique(imgMat{subj}{blk}{cond}(pair,4:8))) > 1
                        thisCheck = 1;%error
                    else
                        thisCheck = 0;
                    end
                end%if cond
                
                checkSum = thisCheck;
            end%for pair
        end%for cond
    end%for blk
    
    repCheck(subj) = checkSum;
    %%
    %% checking img overlab
    checkSum = 0;
    %%
    for upper = 1:2
        for lower = 1:2
            if upper == 2
                imgSet{upper}{lower} = learningData(rowNum.imgID,learningData(rowNum.upper,:) == upper & learningData(rowNum.lower,:) == lower & learningData(rowNum.rep,:) == 1 & learningData(rowNum.cond,:) ~= 3);
            else
                imgSet{upper}{lower} = learningData(rowNum.imgID,learningData(rowNum.upper,:) == upper & learningData(rowNum.lower,:) == lower);
            end%if upper
            
            temp_img = testMat(rowNum.imgID,testMat(rowNum.cond,:) == 3 & testMat(rowNum.upper,:) == upper & testMat(rowNum.lower,:) == lower);
            
            imgSet{upper}{lower} = [imgSet{upper}{lower} temp_img];
            
            nImgSet = length(imgSet{upper}{lower});
            
            if nImgSet ~= unique(imgSet{upper}{lower})%if overlapped
                checkSum = checkSum + 1;
            end
            
        end%for lower
    end%for upper
    
    imgOverlapCheck(subj) = checkSum;
    
    %% checking img overlap for test phase
    checkSum = 0;
    %%
    for lower = 1:2
        for testType = 1:2
            imgSet_study_test = sort(learningData(rowNum.imgID,learningData(rowNum.upper,:) == 2 & learningData(rowNum.lower,:) == lower & learningData(rowNum.rep,:) == 1 & learningData(rowNum.testType,:) == testType & learningData(rowNum.order,:) == 2));
            
            temp_img = sort(testData{testType}(rowNum.imgID,testData{testType}(rowNum.cond,:) ~= 3 & testData{testType}(rowNum.upper,:) == 2 & testData{testType}(rowNum.lower,:) == lower));
            
            imgSet{upper}{lower} = [imgSet{upper}{lower} temp_img];
            
            if isequal(imgSet_study_test, temp_img)
                checkSum = 0;
            else
                checkSum = checkSum+1;
            end
        end%for testType
    end%for lower

    img_study_test(subj) = checkSum;
    
    
    %% check onset
    repSet{1}{1} = [1:3];%cond,order
    repSet{1}{2} = [1:3 5 7];
    
    repSet{2}{1} = [1:3];
    repSet{2}{2} = [1:5];
    %%
    for cond = 1:nCond
        for order = 1:2
            nnRep = length(repSet{cond}{order});
            %%
            rr = 0;
            for rep = repSet{cond}{order}
                rr = rr + 1;
%                 (rr-1)*2+cond
                onsetMat{order}(subj,(rr-1)*2+cond) = mean(learningData(rowNum.time,learningData(rowNum.cond,:) == cond & learningData(rowNum.order,:) == order & learningData(rowNum.rep,:) == rep));
            end
        end
    end%for cond
    
    %% check cate infor for each pair
    
    for cond = 1:nCond
        pairCateSet{cond} = [];
        for blk = 1:nBlk_learning
            for pair = 1:nPair{cond}
                ccc = learningData(rowNum.lower:rowNum.upper,learningData(rowNum.cond,:) == cond & learningData(rowNum.rep,:) == 1 & learningData(rowNum.pairID,:) == pair & learningData(rowNum.blk,:) == blk);
                pairCateSet{cond} = [pairCateSet{cond} ccc];
            end
        end%for blk
        
        nnn = length(pairCateSet{cond})/2;
        
        for int = 1:nnn
            thisCateSet =  pairCateSet{cond}(1,(int-1)*2+1:int*2);
            
            thisPairID = (thisCateSet(1)-1)*2 + thisCateSet(2);
            
            pairIDSet(cond,int) = thisPairID;
        end%for int
    end%for cond
    
    if sort(pairIDSet(1,:)) ~= sort(pairIDSet(2,:))
        thisError = 1;
    else
        thisError = 0;
    end
    
    pairCateCheck(subj) = thisError;
    
end%for subj

