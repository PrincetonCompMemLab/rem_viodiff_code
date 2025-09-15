function [textures loc_image_order] = load_images_localizer(mainWindow, IMAGE_DIR_PATH, INDOOR, OUTDOOR, MALE, FEMALE, INDOOR_DIR_PATH, OUTDOOR_DIR_PATH, MALE_DIR_PATH, FEMALE_DIR_PATH, localizer_images)

for categ=[INDOOR OUTDOOR MALE FEMALE]
    if (categ == INDOOR)
      dirPath = [IMAGE_DIR_PATH '/' INDOOR_DIR_PATH];
      imageIndices = localizer_images{INDOOR};
      loc_image_order{INDOOR} = imageIndices;
    elseif (categ == OUTDOOR)
      dirPath = [IMAGE_DIR_PATH '/' OUTDOOR_DIR_PATH];
      imageIndices = localizer_images{OUTDOOR};
      loc_image_order{OUTDOOR} = imageIndices;
    elseif (categ == MALE)
      dirPath = [IMAGE_DIR_PATH '/' MALE_DIR_PATH];
      imageIndices = randperm(36); % clean up
      loc_image_order{MALE} = imageIndices;
    elseif (categ == FEMALE)
      dirPath = [IMAGE_DIR_PATH '/' FEMALE_DIR_PATH];
      imageIndices = randperm(36);
      loc_image_order{FEMALE} = imageIndices;
    end
    dirList{categ} = dir( dirPath );
    dirList{categ} = dirList{categ}(3:end); % skip . & ..
    if (strcmp(dirList{categ}(1).name,'.DS_Store')==1)
        dirList{categ} = dirList{categ}(2:end);
    end

    numImages = length( imageIndices );
    textures{categ} = [];
    for i=1:numImages
        img = imageIndices(i);
        common.progress_bar(i/numImages, mainWindow);
        
        % load image
        tempMat = imread( [dirPath '/' dirList{categ}(img).name] );
        textures{categ}(img) = Screen('MakeTexture',mainWindow,tempMat);
        clear tempMat;
    end
end


end