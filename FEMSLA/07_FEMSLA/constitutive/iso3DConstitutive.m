function [D] = iso3DConstitutive(E, nue)
% [D] = iso3DConstitutive(E, nue)
%--------------------------------------------------------------------------
% PURPOSE
%  Calculates the local constitutive matrix for an isotropic material in
%  3D.
%
% INPUT:    E       (1x1)   Young's Modulus
%                           orientation
%           nue     (1x1)   poisson ration
%
% OUTPUT:   D       (6x6)   constitutive matrix
%
%--------------------------------------------------------------------------
% LAST MODIFIED: Arnd Koeppe 2012-08-16
%--------------------------------------------------------------------------

    dn = E * (1 - nue) / ((1 + nue) * (1 - 2 * nue));
    dt = E * nue / ((1 + nue) * (1 - 2 * nue));
    ds = E / (2 * (1 + nue));
    
    D = [dn  dt  dt  0   0   0; ...
         dt  dn  dt  0   0   0; ...
         dt  dt  dn  0   0   0; ...
         0   0   0   ds  0   0; ...
         0   0   0   0   ds  0; ...
         0   0   0   0   0   ds];

end

