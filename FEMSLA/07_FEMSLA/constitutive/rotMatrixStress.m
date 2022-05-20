function [TSig] = rotMatrixStress(phi)
% [TSig] = rotMatrixStress(phi)
%--------------------------------------------------------------------------
% PURPOSE
%  Calculates stress rotation matrix for fibre composite layers.
%
% INPUT:    phi     (1x1)   angle of rotation
%
% OUTPUT:   TSig    (6x6)   stress rotation matrix
%
%--------------------------------------------------------------------------
% LAST MODIFIED: Arnd Koeppe 2012-03-07
%--------------------------------------------------------------------------

    C = cos(phi / 180 * pi);
    S = sin(phi / 180 * pi);

    TSig = eye(6);
    TSig([1 2 4], [1 2 4]) =  [C^2   S^2     2*S*C; ...
                               S^2   C^2     -2*S*C; ...
                               -S*C  S*C     C^2 - S^2];
end
