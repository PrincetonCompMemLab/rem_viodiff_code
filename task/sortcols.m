function [mat] = sortcols(mat, numRow)

temp = mat';
temp = sortrows(temp, numRow)';

mat = temp;


