function [indexMat] = ID2Index(IDMat, IDs)
% [indexMat] = ID2Index(IDMat, IDs)
%--------------------------------------------------------------------------
% PURPOSE
%  Replaces each value of IDMat with the corresponding row index of that
%  value in IDs and outputs the resulting matrix as indexMat.
%
% INPUT:    IDMat       (nxm)   matrix of various IDs
%           IDs                 vector of all IDs
%
% OUTPUT:   indexMat    (nxm)   matrix of corresponding index in IDs
%
%--------------------------------------------------------------------------
% LAST MODIFIED: Arnd Koeppe 2012-08-16
%--------------------------------------------------------------------------
 
 [n, m] = size(IDMat);
 indexMat = zeros(n,m);
 for r = 1 : n
     for c = 1 : m
		 if IDMat(r,c) ~= 0
			index = find(IDs==IDMat(r,c));
			indexMat(r,c) = index(1,1);
		 end
     end
 end
 
end

