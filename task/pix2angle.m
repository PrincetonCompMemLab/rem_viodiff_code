
%converts monitor pixels into degrees of visual angle.
%
%Inputs:
%display.dist (distance from screen (cm))
%display.width (width of screen (cm))
%display.resolution (number of pixels of display in horizontal direction)
%
%ang (visual angle)
%
%Warning: assumes isotropic (square) pixels

%Written 11/1/07 gmb zre

% Princeton Skyra measurements
display.dist = 73; %cm
display.width = 36.6; %cm
display.resolution = [1920,1080];

pix = 256;

%Calculate pixel size
pixSize = display.width/display.resolution(1);   %cm/pix

sz = pix*pixSize;  %cm (duh)

ang = 2*180*atan(sz/(2*display(1).dist))/pi;