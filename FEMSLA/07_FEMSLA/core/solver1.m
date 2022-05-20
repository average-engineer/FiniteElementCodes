function [fName] = solver1(problemName, eDof, K, f, coord, dof, prop, bc, nen, eType, nID)
% [fName] = solver1(problemName, eDof, K, f, coord, dof, prop, bc, nen, eType, nID)
%--------------------------------------------------------------------------
% PURPOSE
%  Solves static, linear finite element problems.
%
% INPUT:    eDof    [elem dof1...;
%                             ...]  topology matrix
%           K       (NxN)           initialized stiffness matrix
%           f       (Nx1)           load vector
%           coord   [x1 y1 z1;
%                         ...]      coordinates of all nodes
%           dof     [1 2...;
%                       ...]        indices of degrees of freedom for each 
%                                   node
%           prop    (struct)        element property structure
%           bc      [dof U;
%                      ...]         boundary conditions
%           nen     (1x1)           max number of nodes per element
%           eType   (Nex1)          vector of the type of each element
%           nID     (Nnx1)          vector of IDs of each node
%
% OUTPUT:   fName   (str)   output file name (with extension: .out)
%
%--------------------------------------------------------------------------
% LAST MODIFIED: Arnd Koeppe 2012-08-16
%--------------------------------------------------------------------------
 disp('- Static Linear Analysis');
 disp(['-- Begin calculating global stiffness matrix of ''', problemName, ''' ...']);
 
%----- Element coordinates --------------------------------------
 [eX,eY,eZ] = coordXtr(eDof, coord, dof, nen);
 
%----- Create element stiffness matrices Ke and assemble into K -
 N = size(eType, 1);
 for i = 1 : N
     switch eType(i)
         case {122} % bar, 2 Node, 2D 
             eP = extractProperties(eType(i), i, prop);
             Ke = bar2e(eX(i,:), eY(i,:), eP);
             K = assem(eDof(i,:), K, Ke);
         case {123} % bar, 2 Node, 3D
             eP = extractProperties(eType(i), i, prop);
             Ke = bar3e(eX(i,:), eY(i,:), eZ(i,:), eP);
             K = assem(eDof(i,:), K, Ke);
         case {222} % beam, 2 Node, 2D
             eP = extractProperties(eType(i), i, prop);
             Ke = beam2e(eX(i,:), eY(i,:), eP);
             K = assem(eDof(i,:), K, Ke);
         case {229} % Timoshenko beam, 2 Node, 2D
             eP = extractProperties(eType(i), i, prop);
             Ke = beam2t(eX(i,:), eY(i,:), eP);
             K = assem(eDof(i,:), K, Ke);
         case {223} % beam, 2 Node, 3D
             [eP, ~, e0] = extractProperties(eType(i), i, prop);
             Ke = beam3e(eX(i,:), eY(i,:), eZ(i,:), e0, eP);
             K = assem(eDof(i,:), K, Ke);
         case {332} % plane/membrane, 3 Node, 2D
             [eP, D] = extractProperties(eType(i), i, prop);
             [Ke, fe] = plante(eX(i,:), eY(i,:), eP, D);
             [K, f] = assem(eDof(i,:), K, Ke, f, fe);                   
         case {342} % plane/membrane (isoparametric), 4 Node, 2D
             [eP, D] = extractProperties(eType(i), i, prop);
             [Ke, fe] = plani4e(eX(i,:), eY(i,:), eP, D);
             [K, f] = assem(eDof(i,:), K, Ke, f, fe);             
         case {382} % plane/membrane (isoparametric), 8 Node, 2D
             [eP, D] = extractProperties(eType(i), i, prop);
             [Ke, fe] = plani8e(eX(i,:), eY(i,:), eP, D);
             [K, f] = assem(eDof(i,:), K, Ke, f, fe);               
         case {543} % shell (isoparametric), 4 Node, 3D
             [eP, D] = extractProperties(eType(i), i, prop);
             [Ke, fe] = shelli4e(eX(i,:), eY(i,:), eZ(i,:), eP, D);
             [K, f] = assem(eDof(i,:), K, Ke, f, fe);
         case {683} % solid (isoparametric), 8 Node, 3D
             [eP, D] = extractProperties(eType(i), i, prop);
             [Ke, fe] = soli8e(eX(i,:), eY(i,:), eZ(i,:), eP, D);
             [K, f] = assem(eDof(i,:), K, Ke, f, fe);             
     end
 end
 
  disp(['-- Finished calculating global stiffness matrix of ''', problemName, '''!']);
  disp(' ');
  
%----- Solve the system of equations ----------------------------
 disp(['-- Begin solving of ''', problemName, ''' ...']);

 [a, r] = solveq(K, f, bc);

  disp(['-- Finished solving of ''', problemName, '''!']);
  disp(' ');

%----- Element stresses -------------------------------------------

 disp(['-- Begin stress analysis of ''', problemName, ''' ...']);

 eD = extract(eDof,a);
 eS = zeros(nen * size(eType, 1), ceil(size(dof, 2)/3)*3 + 4);
 
 for i = 1 : N
	 
	 eDi = eD(i,(imag(eD(i,:)) == 0));	% remove imaginary (disabled) element dofs
	 
     switch eType(i)
         case {122} % bar, 2 Node, 2D
             eP = extractProperties(eType(i), i, prop);
             eStmp = bar2s(eX(i,:), eY(i,:), eP, eDi);
             [~, j] = ismember([eDof(i,2) eDof(i,5)], dof);    % find node indices of element nodes
             eS(nen*i-1 : nen*i,1:7) = [eDof(i,1) eType(i) 1 nID(j(1)) eStmp 0 0;...
                                         eDof(i,1) eType(i) 2 nID(j(2)) eStmp 0 0];
         case {123} % bar, 2 Node, 3D
             eP = extractProperties(eType(i), i, prop);
             eStmp = bar3s(eX(i,:), eY(i,:), eZ(i,:), eP, eDi);
             [~, j] = ismember([eDof(i,2) eDof(i,8)], dof);    % find node indices of element nodes
             eS(nen*i-1 : nen*i,1:7) = [eDof(i,1) eType(i) 1 nID(j(1)) eStmp 0 0;...
                                         eDof(i,1) eType(i) 2 nID(j(2)) eStmp 0 0];             
         case {222} % beam, 2 Node, 2D
             eP = extractProperties(eType(i), i, prop);
             % write only into columns that have nonzero value in eDof
             eStmp = beam2s(eX(i,:), eY(i,:), eP, eDi);
             [~, j] = ismember([eDof(i,2) eDof(i,5)], dof);    % find node indices of element nodes
             eS(nen*i-1 : nen*i,1:5) = [eDof(i,1)*ones(2,1), eType(i)*ones(2,1), (1:2)', nID(j), eStmp];
         case {229} % Timoshenko beam, 2 Node, 2D
             eP = extractProperties(eType(i), i, prop);
             % write only into columns that have nonzero value in eDof
             eStmp = beam2ts(eX(i,:), eY(i,:), eP, eDi);
             [~, j] = ismember([eDof(i,2) eDof(i,5)], dof);    % find node indices of element nodes
             eS(nen*i-1 : nen*i,1:5) = [eDof(i,1)*ones(2,1), eType(i)*ones(2,1), (1:2)', nID(j), eStmp];                     
         case {223} % beam, 2 Node, 3D
             [eP, ~, e0] = extractProperties(eType(i), i, prop);
             eStmp = beam3s(eX(i,:), eY(i,:), eZ(i,:), e0, eP, eDi);
             [~, j] = ismember([eDof(i,2) eDof(i,8)], dof);    % find node indices of element nodes
             eS(nen*i-1 : nen*i,1:10) = [eDof(i,1)*ones(2,1), eType(i)*ones(2,1), (1:2)', nID(j), eStmp];               
         case {332} % plane/membrane, 3 Node, 2D
             [eP, D] = extractProperties(eType(i), i, prop);
             eStmp = plants(eX(i,:), eY(i,:), eP, D, eDi);
             [~, j] = ismember([eDof(i,2) eDof(i,5) eDof(i,8)], dof);    % find node indices of element nodes             
             eS(nen*i-2 : nen*i,1:7) = [eDof(i,1)*ones(3,1), eType(i)*ones(3,1), (1:3)', nID(j), repmat(eStmp(:,[1 2 4]),3,1)];
         case {342} % plane/membrane (isoparametric), 4 Node, 2D
             [eP, D] = extractProperties(eType(i), i, prop);
             eStmp = plani4s(eX(i,:), eY(i,:), eP, D, eDi);
             [~, j] = ismember([eDof(i,2) eDof(i,5) eDof(i,8) eDof(i,11)], dof);    % find node indices of element nodes             
             eS(nen*i-3 : nen*i,1:7) = [eDof(i,1)*ones(4,1), eType(i)*ones(4,1), (1:4)', nID(j), eStmp(1:4,[1 2 4])];
         case {382} % plane/membrane (isoparametric), 8 Node, 2D
             [eP, D] = extractProperties(eType(i), i, prop);
             % plani8s returns normal AND shear stresses even though each
             % element node only allows translative and no rotational
             % displacements --> eStmp after reshaping fills the whole row
             % of eS and thus more than eDof has nonzero entries!
             eStmp = plani8s(eX(i,:), eY(i,:), eP, D, eDi);
             % eS(i,any(eDof(i,2:end),1)) = reshape(eStmp(:,[1 2 4])', 1, []);
             % eS(i,:) = reshape(eStmp([1:4 6:9],[1 2 4])', 1, []);   % remove center integraton point stresses since there is no node nearby
             [~, j] = ismember([eDof(i,2) eDof(i,5) eDof(i,8) eDof(i,11)...
                                eDof(i,14) eDof(i,17) eDof(i,20) eDof(i,23)], dof);    % find node indices of element nodes             
             eS(nen*i-7 : nen*i,1:7) = [eDof(i,1)*ones(8,1), eType(i)*ones(8,1), (1:8)', nID(j), eStmp([1:4 6:9],[1 2 4])];
         case {543} % shell (isoparametric), 4 Node, 3D
             [eP, D] = extractProperties(eType(i), i, prop);
             eStmp = shelli4s(eX(i,:), eY(i,:), eZ(i,:), eP, D, eDi);
             [~, j] = ismember([eDof(i,2) eDof(i,8) eDof(i,14) eDof(i,20)], dof);    % find node indices of element nodes             
             eS(nen*i-3 : nen*i,1:10) = [eDof(i,1)*ones(4,1), eType(i)*ones(4,1), (1:4)', nID(j), eStmp(1:4,:)];             
         case {683} % solid (isoparametric), 8 Node, 3D
             [eP, D] = extractProperties(eType(i), i, prop);
             eStmp = soli8s(eX(i,:), eY(i,:), eZ(i,:), eP, D, eDi);
             %eS(i,:) = reshape(eStmp(1:8,:)', 1, []);
             [~, j] = ismember([eDof(i,2) eDof(i,8) eDof(i,14) eDof(i,20)...
                                eDof(i,26) eDof(i,32) eDof(i,38) eDof(i,44)], dof);    % find node indices of element nodes
             eS(nen*i-7 : nen*i,1:10) = [eDof(i,1)*ones(8,1), eType(i)*ones(8,1), (1:8)', nID(j), eStmp(1:8,:)];             
     end
 end
 
  disp(['-- Finished stress analysis of ''', problemName, '''!']);
  disp(' ');

 %--------- extract node displacements --------------------------------
 nDof = size(dof,2);    % number of degrees of freedom per node
 nDisp = zeros(size(nID,1), nDof+1); % 6+1 columns (node id + max dof per node)
 nDisp(:,1) = nID;
 nDisp(:,2:end) = reshape(a, nDof, [])';
 
 %--------- extract element stress ------------------------------------
 eStress = eS(any(eS, 2),:);	% remove empty nodes
 

 fName = postprocess(problemName, nDisp, eStress);
 
 disp(['-- Writing output file: ''', fName, '''']);
 
 disp(' ');
 disp('----------------------------------------');
 
end

