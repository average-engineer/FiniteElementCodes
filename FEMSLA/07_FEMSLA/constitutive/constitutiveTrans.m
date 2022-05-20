function [DPhi] = constitutiveTrans(D, phi)
% [DPhi] = constitutiveTrans(D, phi)
%--------------------------------------------------------------------------
% PURPOSE
%  Rotates a constitutive matrix by an angle
%
% INPUT:    D       (6x6)   constitutive matrix
%           phi     (1x1)   rotation angle
%
% OUTPUT:   DPhi    (6x6)   rotated constitutive matrix
%
%--------------------------------------------------------------------------
% LAST MODIFIED: Arnd Koeppe 2012-03-07
%--------------------------------------------------------------------------
    
 % rotation matrices
 TSig = rotMatrixStress(phi);
 TEps = rotMatrixStrain(phi);
    
 % rotate
 DPhi = TSig^-1 * D * TEps;
 
end

