function [fileName, isFileExist] = checkFileName(fileName, extension)
% [fileName, isFileExist] = checkFileName(fileName, extension)
%--------------------------------------------------------------------------
% PURPOSE
%  Checks if file exists and has the right extension
%
% INPUT:    fileName       (str)       original file name (with or without
%                                   extension)
%           extension   (str)       desired extension
%
% OUTPUT:   fileName       (str)       file name with desired extension
%           isFileExist (logical)   true if file exists
%
%--------------------------------------------------------------------------
% LAST MODIFIED: Arnd Koeppe 2012-03-07
%--------------------------------------------------------------------------
 
 [fTitle] = strtok(fileName, '.'); % seperate file extension from title
 fileName = [fTitle, '.', extension];
 isFileExist = exist(fileName, 'file');
 
end

