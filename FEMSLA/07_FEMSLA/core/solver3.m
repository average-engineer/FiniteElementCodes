function [fName] = solver3(problemName, eDof, K, M, C, coord, dof, prop, bc, nen, eType, nID, k)
% [fName] = solver3(problemName, eDof, K, M, C, coord, dof, prop, bc, nen, eType, nID, k)
%--------------------------------------------------------------------------
% PURPOSE
%  Solves dynamic, linear problems through iteration in the time domain.
%
% INPUT:    eDof    [elem dof1...;
%                             ...]  topology matrix
%           K       (nxn)           initialized stiffness matrix
%           M       (nxn)           initialized mass matrix
%           C       (nxn)           initialized damping matrix
%           coord   [x1 y1 z1;
%                         ...]      coordinates of all nodes
%           dof     [1 2...;
%                       ...]        indices of degrees of freedom for each 
%                                   node
%           prop    (struct)        element property structure
%           bc      [node x y...;
%                            ...]   boundary conditions
%           nen     (1x1)           max number of nodes per element
%           eType   (eNx1)          vector of the type of each element
%           nID     (nNx1)          vector of IDs of each node
%           k       (1x1)           number of steps
%
% OUTPUT:   fName   (str)   output file name (with extension: .out)
%
%--------------------------------------------------------------------------
% LAST MODIFIED: Arnd Koeppe 2012-03-07
%
%   !!! WORK IN PROGRESS !!! NOT FINISHED !!!
%
%--------------------------------------------------------------------------
 
 disp('- Dynamic response through iteration in time domain');
 disp(['-- Begin calculating global stiffness, mass and damping matrices of ''', problemName, ''' ...']);
 
%----- element coordinates --------------------------------------
 [eX,eY,eZ] = coordXtr(eDof, coord, dof, nen);

%----- create element stiffness matrices Ke and assemble into K -
 for i = 1 : size(eType, 1)
     switch eType(i)
         case {222} % beam, 2 Node, 2D
             eP = [prop.Ep(i) prop.A(i) prop.I(i)];
             
             [Ke Me] = beam2d(eX(i,:), eY(i,:), eP);
             K = assem(eDof(i,:), K, Ke);
             M = assem(eDof(i,:), M, Me);
             C = assem(eDof(i,:), C, Ce);
         case {543} % shell isoparametric, 4 Node, 3D
             Ep = prop.Ep(i);
             Es = prop.Es(i);
             nue = prop.nue(i);
             Gq = prop.Gq(i);
             phi = prop.phi(i);
             t = prop.t(i);
             rho = prop.rho(i);
             a = prop.a(i);
             b = prop.b(i);

             DUD = orth3DConstitutive(Ep, Es, nue, Gq);
             D = constitutiveTrans(DUD, phi);

             ir = 3;

             eP = [t ir rho a b];

             [Ke, Me, Ce] = shelli4d(eX(i,:), eY(i,:), eZ(i,:), eP, D);
             K = assem(eDof(i,:), K, Ke);
             M = assem(eDof(i,:), M, Me);
             C = assem(eDof(i,:), C, Ce);
     end
 end
 
  disp(['-- Finished calculating global stiffness, mass and damping matrices of ''', problemName, '''!']);
  disp(' ');
  
%----- solve the system of equations ----------------------------
 disp(['-- Begin solving of ''', problemName, ''' ...']);

 % [ef, B] = solvedyn(K, M, bc, k);
 
 disp(['-- Finished solving of ''', problemName, '''!']);
 disp(' ');

%----- process output -----------------------------------------------------

 
%--------- write output file ---------------------------------------------
 % fName = postprocess(problemName);
 
 disp(['-- Writing output file: ''', fName, '''']);
 
 disp(' ');
 disp('----------------------------------------');
 
end

