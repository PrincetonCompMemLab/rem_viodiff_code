function [textures, imgsize] = VioDiffCon_load_images_practice(mainWindow, data, data_rows, fMRI)

VioDiffCon_VarConfig;
for sup = 1:nSup%1:face, 2:scene
    for sub = 1:nSub
        
        dirPath = [stim_practice_dir{sup}{sub}];
        imageIndices = unique(data(data_rows.imgID, data(data_rows.upper,:) == sup & data(data_rows.lower,:) == sub));
        
        dirList{sup}{sub} = dir( dirPath );
        dirList{sup}{sub} = dirList{sup}{sub}(3:end); % skip . & ..
        if (strcmp(dirList{sup}{sub}(1).name,'.DS_Store')==1)
            dirList{sup}{sub} = dirList{sup}{sub}(2:end);
        end
        numImages = length( imageIndices );
        textures{sup}{sub} = [];
        for i=1:numImages
            img = imageIndices(i);
            common.progress_bar(i/numImages, mainWindow);
            
            % load image
            tempMat = imread( [dirPath '/' dirList{sup}{sub}(img).name] );
            sss = size(tempMat);
            imgsize{sup}{sub}{img} = sss(:,1:2);%size in 2D
            textures{sup}{sub}(img) = Screen('MakeTexture',mainWindow,tempMat);
            clear tempMat;
        end%for i
    end%for sub
end%for sup
