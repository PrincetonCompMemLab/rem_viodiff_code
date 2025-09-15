function [textures] = load_images(mainWindow, data)

global supRunNum

FSOC_varConfig;

for supC = 1:nSupCate%f/s, c/o
    for subC = 1:nSubCate%(m/f, m/n), (m/n, m/n)
        dirPath = [FLD_NAME.BLK{supRunNum} '/' FLD_NAME.SUPCATE{supRunNum}{supC} '/' FLD_NAME.SUBCATE{supRunNum}{supC}{subC}];
        imageIndices = unique( data.imgID(data.cSupCate == supC & data.cSupCate == subC));
        dirList{supC}{subC} = dir( dirPath );
        dirList{supC}{subC} = dirList{supC}{subC}(3:end); % skip . & ..
        if (strcmp(dirList{supC}{subC}(1).name,'.DS_Store')==1)
            dirList{supC}{subC} = dirList{supC}{subC}(2:end);
        end
        numImages = length( imageIndices );
        textures{supC}{subC} = [];
        for i=1:numImages
            img = imageIndices(i);
            common.progress_bar(i/numImages, mainWindow);
            
            % load image
            tempMat = imread( [dirPath '/' dirList{supC}{subC}(img).name] );
            textures{supC}{subC}(img) = Screen('MakeTexture',mainWindow,tempMat);
            clear tempMat;
        end
    end%for subC
end%for supC
end