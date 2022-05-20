function [fName] = solver2(problemName, eDof, K, M, coord, dof, prop, bc, nen, eType, nID, k)
% [fName] = solver2(problemName, eDof, K, M, coord, dof, prop, bc, nen, eType, nID, k)
%--------------------------------------------------------------------------
% PURPOSE
%  Solves eigen frequencies and modal node displacement of a finite element
%  problem.
%
% INPUT:    eDof    [elem dof1...;
%                             ...]  topology matrix
%           K       (nxn)           initialized stiffness matrix
%           M       (nxn)           initialized mass matrix
%           coord   [x1 y1 z1;
%                         ...]      coordinates of all nodes
%           dof     [1 2...;
%                       ...]        indices of degrees of freedom for each 
%                                   node
%           prop    (struct)        element property structure
%           bc      [dof U;
%                      ...]         boundary conditions
%           nen     (1x1)           max number of nodes per element
%           eType   (eNx1)          vector of the type of each element
%           nID     (nNx1)          vector of IDs of each node
%           k       (1x1)           number of steps
%
% OUTPUT:   fName   (str)   output file name (with extension: .out)
%
%--------------------------------------------------------------------------
% LAST MODIFIED: Arnd Koeppe 2012-08-16
%--------------------------------------------------------------------------

 disp('- Eigen Frequency and Modal Analysis');
 disp(['-- Begin calculating global stiffness matrix of ''', problemName, ''' ...']);
 
%----- element coordinates --------------------------------------
 [eX,eY,eZ] = coordXtr(eDof, coord, dof, nen);

%----- create element stiffness matrices Ke and assemble into K -
 N = size(eType, 1);
 for i = 1 : N
     switch eType(i)
         case {222} % beam, 2 Node, 2D
             eP = extractProperties(eType(i), i, prop);          
             [Ke Me] = beam2d(eX(i,:), eY(i,:), eP);
             K = assem(eDof(i,:), K, Ke);
             M = assem(eDof(i,:), M, Me);
         case {543} % shell isoparametric, 4 Node, 3D
             [eP, D] = extractProperties(eType(i), i, prop);
             [Ke, Me] = shelli4d(eX(i,:), eY(i,:), eZ(i,:), eP, D);
             K = assem(eDof(i,:), K, Ke);
             M = assem(eDof(i,:), M, Me);
     end
 end
 
  disp(['-- Finished calculating global stiffness and mass matrices of ''', problemName, '''!']);
  disp(' ');
  
%----- solve the system of equations ----------------------------
 disp(['-- Begin solving of ''', problemName, ''' ...']);

 [ef, B] = solveig(K, M, bc, k);
 
 disp(['-- Finished solving of ''', problemName, '''!']);
 disp(' ');

%----- modal frequencies --------------------------------------------------
 modes = (1 : size(ef, 1))';
 mFreq = [modes, ef];
 
%----- modal displacements ------------------------------------------------
 nDof = size(dof, 2);
 m = reshape(repmat(modes', size(nID,1), 1), [],1);    % inflate modes by repeating each number
 mDisp = [m, repmat(nID, size(B,2), 1), reshape(B, nDof, [])'];
 
%--------- write output file ---------------------------------------------
 fName = postprocess(problemName, mFreq, mDisp);
 
 disp(['-- Writing output file: ''', fName, '''']);
 
 disp(' ');
 disp('----------------------------------------');
 
end

