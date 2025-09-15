function [outputArray] = insertCol(inputArray,toInsert,position)

outputArray = inputArray(:,1:position-1);
outputArray(:,position) = toInsert;

toBeMoved = inputArray(:,position:end);

outputArray(:, position+1:position+size(toBeMoved,2)) = toBeMoved;

