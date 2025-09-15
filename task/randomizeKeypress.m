
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


fMRI=0; %set to 0 for generating keypresses prior to experiment
VioDiffCon_VarConfig;

%% categories (xSup) and value assigned to each subcategory (xSub) in trial matrices

%female(=1)/male(=2)
%indoor(=1)/outdoor(=2)
%natural(=1)/manmade(=2)
%reward(=1)/neutral(=2)

keypress_options = 1:2;
categories_to_randomize = 4;

for subj = [101:299 997 999]
%for subj = subjList
    if subj < 10
        SN = ['0' num2str(subj)];
    else
        SN = [num2str(subj)];
    end%if subj

    temp = zeros(categories_to_randomize,length(keypress_options));
    
    for i=1:categories_to_randomize
        temp(i,:) = Shuffle(keypress_options);
    end
    
    keypressRandomization{subj} = temp;
    
end

keypressRandomization_row.faces = 1;
keypressRandomization_row.scenes = 2;
keypressRandomization_row.objects = 3;
keypressRandomization_row.reward = 4;

save([out_mat_dir '/keypressRandomization'], 'keypressRandomization', 'keypressRandomization_row');        
    
