function [D] = orth3DConstitutive(Ep, Es, nue, Gq)
% [D] = orth3DConstitutive(Ep, Es, nue, Gq)
%--------------------------------------------------------------------------
% PURPOSE
%  Calculates the local constitutive matrix for an orthotropic material in
%  3D.
%
% INPUT:    Ep      (1x1)   Young's Modulus parallel to fibre orientation
%           Es      (1x1)   Young's Modulus perpendicular to fibre 
%                           orientation
%           nue     (1x1)   poisson ration
%           Gq      (1x1)   shear modulus
%
% OUTPUT:   D       (6x6)   constitutive matrix
%
%--------------------------------------------------------------------------
% LAST MODIFIED: Arnd Koeppe 2012-08-16
%--------------------------------------------------------------------------

    dp = Ep / (1 - nue.^2 .* Es ./ Ep);
    ds = Es / (1 - nue.^2 .* Es ./ Ep);
    dps = nue * ds;
    dq = Gq;
    
    D = [dp     dps dps 0   0   0; ...
         dps    ds  dps 0   0   0; ...
         dps    dps ds  0   0   0; ...
         0      0   0   dq  0   0; ...
         0      0   0   0   dq  0; ...
         0      0   0   0   0   dq];

end

