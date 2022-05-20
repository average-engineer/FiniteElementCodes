function [IDMat] = Index2ID(indexMat, IDs)
% [indexMat] = ID2Index(IDMat, IDs)
%--------------------------------------------------------------------------
% PURPOSE
%  Replaces each value of indexMat with the corresponding value of that
%  row index in IDs and outputs the resulting matrix as IDMat.
%
% INPUT:    indexMat    (nxm)   matrix of corresponding index in IDs
%           IDs                 vector of all IDs
%
% OUTPUT:   IDMat       (nxm)   matrix of various IDs
%
%--------------------------------------------------------------------------
% LAST MODIFIED: Arnd Koeppe 2012-03-07
%--------------------------------------------------------------------------

 IDMat = IDs(indexMat);
 
end

