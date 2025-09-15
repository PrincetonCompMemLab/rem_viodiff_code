

DEVICENAME = '932'; %name of device you want to poll

if deburg
    DEVICENAME = 'Apple Internal Keyboard / Trackpad';
end%if deburg
%use this line if you want to mimic the trigger pulse (on a Mac) for debugging purposes

[index, devName] = GetKeyboardIndices;
for device = 1:length(index)
 if strcmp(devName(device),DEVICENAME)
   DEVICE = index(device);
 end
end

if ~exist('DEVICE', 'var')
    DEVICE = -1;
end
