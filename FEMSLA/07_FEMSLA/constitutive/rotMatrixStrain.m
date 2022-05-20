function [TEps] = rotMatrixStrain(phi)
% [TEps] = rotMatrixStrain(phi)
%--------------------------------------------------------------------------
% PURPOSE
%  Calculates strain rotation matrix for fibre composite layers.
%
% INPUT:    phi     (1x1)   angle of rotation
%
% OUTPUT:   TEps    (6x6)   strain rotation matrix
%
%--------------------------------------------------------------------------
% LAST MODIFIED: Arnd Koeppe 2012-03-07
%--------------------------------------------------------------------------

    C = cos(phi * pi / 180);
    S = sin(phi * pi / 180);
    
    TEps = eye(6);
    TEps([1 2 4], [1 2 4]) =  [C^2       S^2     S*C; ...
                               S^2       C^2     -S*C;...
                               -2*S*C    2*S*C   C^2 - S^2];

end

