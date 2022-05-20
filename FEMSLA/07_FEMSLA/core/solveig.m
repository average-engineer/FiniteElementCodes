function [ef, B] = solveig(K, M, bc, k)
% [ef, B] = solveig(K, M, bc)
% [ef, B] = solveig(K, M, [])
% [ef, B] = solveig(K, M, [], k)
% [ef, B] = solveig(K, M, bc, k)
%--------------------------------------------------------------------------
% PURPOSE
%  Calculates the eigen frequencies and the normized node
%  displacements associated with the eigen frequencies of the structure.
%
% INPUT:    K       (nxn)           stiffness matrix of the structure
%           M       (nxn)           mass matrix of the structure
%           bc      [dof U;
%                     ...]          boundary conditions (can be empty)
%           k       (1x1)           number of eigen frequencies requested
%                                   (optional, finds all ef if left out)
%
% OUTPUT:   ef      (nx1), (kx1)    vector of eigen frequencies
%           B       (nxk)           eigen vector for each mode / eigen
%                                   frequency
%
%--------------------------------------------------------------------------
% LAST MODIFIED: Arnd Koeppe 2012-07-25
%--------------------------------------------------------------------------
 
 N = size(K, 1);
 
 fdof = 1 : N;  % free degrees of freedom
 
 if (~isempty(bc))   % boundary conditions
     bc(bc(:,2) ~= 0,:) = []; % remove non zero boundary conditions
     
     % remove restrained degrees of freedom
     fdof(bc(:,1)) = []; 
 end
 
 % make sure M doesn't have non zero elements on the diagonal and 
 % remove the corresponding degrees of freedom
 % (useful for lumped mass matrices)
 % i = find(diag(M(fdof, fdof)) == 0);
 
%  fdof(diag(M(fdof, fdof)) == 0) = [];
 
 K0 = K(fdof, fdof);
 M0 = M(fdof, fdof);
    
 if (nargin == 4)
    % k eigen values requested
    [V, D] = eigs(K0, M0, k, 'sm');  % 'sm': smallest magnitude
 else
    % all eigen values requested
    [V, D] = eig(K0, M0);
 end
 
 [ef, IX] = sort(sqrt(diag(D)) / (2 * pi));
 
 % re-add constrained and neglected dofs  
 B = zeros(N, size(V, 2));
 B(fdof, :) = V(:,IX);
 
 % remove infinite frequencies
 B = B(:, isfinite(ef));
 ef = ef(isfinite(ef));
 
end

