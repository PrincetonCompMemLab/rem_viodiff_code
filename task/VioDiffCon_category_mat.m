function VioDiffCon_category_mat

VioDiffCon_VarConfig;
for cond = 1:nCond
    for ii = 1:nPair{cond}
        %1st
        pair_cate_mat{ii}(1,1) = fix((ii-1)/(nPair{cond}/2))+1;%upper
        pair_cate_mat{ii}(1,2) = pair_cate_mat{ii}(1,1);%lower
        
        %2st
        pair_cate_mat{ii}(2,1) = mod(fix((ii-1)/(nPair{cond}/4)),2)+1;%upper
        pair_cate_mat{ii}(2,2) = pair_cate_mat{ii}(2,1);%lower
        
    end%for ii
end%for cond

save([out_mat_dir '/pair_cate_mat_test'], 'pair_cate_mat')
        
        
        
        