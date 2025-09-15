function localizer_FSO_mat
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
fMRI=0; %for creating trial matrices
localizer_FSO_VarConfig;
%%
for subj = subjList

    if subj < 10
        SN = ['0' num2str(subj)];
    else
        SN = [num2str(subj)];
    end%if subj
    %% img shuffling
    for sup = 1:nSup
        for sub = 1:nSub
            %%
            imgAll = Shuffle(1:nImg_sub);
%             imgAll = 1:nImg_sub;
            %%
            for run = 1:nRun
                imgSet{sup}{sub}{run} = imgAll((run-1)*nImg_sub_run + 1:run*nImg_sub_run);
            end%for run
        end%for sub
    end%for sup
    %%
    for run = 1:nRun
        localizer_mat{run} = [];%for concatenation
        
        % randomization of categories of blocks
        blk_cate_order = Shuffle(repmat(1:nSup, 1, nBlk_sup));
        %%
        temp = [];
        %%
        for blk = 1:nBlk
            blkOnset = disdaq + (blk-1)*(blkDur + restDur);
            blk_lastOnset = blkOnset+blkDur-trialDur;
            
            temp(1,1:nTrial_blk) = blk_cate_order(blk);%sup-category
            temp(2,1:nTrial_blk) = Shuffle(repmat(1:nSub, 1, nTrial_blk/nSub));%sub-category
            temp(3,1:nTrial_blk) = blkOnset:trialDur:blk_lastOnset;
            temp(4,1:nTrial_blk) = 1:nTrial_blk;
            temp(5,1:nTrial_blk) = blk;%block num
            temp(6,1:nTrial_blk) = run;%run num
            localizer_mat{run} = [localizer_mat{run} temp];
        end%for blk
        
        %% inserting img ids
        for sup = 1:nSup
            for sub = 1:nSub
                localizer_mat{run}(7, localizer_mat{run}(1,:) == sup & localizer_mat{run}(2,:) == sub) = imgSet{sup}{sub}{run};
            end%for sub
        end%for sup
    end%for run
    %% save
    save([out_mat_dir '/localizer_' SN], 'localizer_mat');
    %% condition rows
    if subj == subjList(1)
        localizer_row.sup = 1;
        localizer_row.sub = 2;
        localizer_row.time = 3;
        localizer_row.trial = 4;
        localizer_row.blk = 5;
        localizer_row.run = 6;
        localizer_row.imgID = 7;
        localizer_row.Resp = 8;
        localizer_row.RT = 9;
        localizer_row.ACC = 10;
        localizer_row.onset = 11;
        localizer_row.recorded = 12;
        localizer_row.fMRItrigger = 13;
        save([out_mat_dir '/localizer_row'], 'localizer_row');
    end
end%for subj



