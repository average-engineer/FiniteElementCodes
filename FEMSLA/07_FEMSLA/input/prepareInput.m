function [eDof, K, M, C, f, coord, dof, prop, bc, nen, sType eType, nID, k, err, title] = prepareInput(input)
% [eDof, K, M, C, f, coord, dof, prop, bc, nen, sType eType, nID, k, err, title] = prepareInput(input)
%--------------------------------------------------------------------------
% PURPOSE
%  Prepares the raw input data for ilbFE usage
%
% INPUT:    input   (struct)    input structure with fields of substructs
%                               for all the data from an input file.
%
% OUTPUT:   eDof    [elem dof1...;
%                             ...]  topology matrix
%           K       (nxn)           initialized stiffness matrix
%           M       (nxn)           initialized mass matrix
%           C       (nxn)           initialized damping matrix
%           f       (nx1)           load vector
%           coord   [x1 y1 z1;
%                         ...]      coordinates of all nodes
%           dof     [1 2...;
%                       ...]        indices of degrees of freedom for each 
%                                   node
%           prop    (struct)        element property structure
%           bc      [dof U;
%                      ...]         boundary conditions
%           nen     (1x1)           max number of nodes per element
%           sType   (1x1)           solver type (1 = linear static
%                                                2 = eigen frequency)
%           eType   (eNx1)          vector of the type of each element
%           nID     (nNx1)          vector of IDs of each node
%           k       (1x1)           number of steps
%           err     (1x1)           error
%           title   (str)           title of the problem
%
%--------------------------------------------------------------------------
% LAST MODIFIED: Arnd Koeppe 2012-08-16
%--------------------------------------------------------------------------

 title = input.Title;

%----- Solver and Element Types ------------------------------------- 
 sType = input.Solver.Type;
 if isfield(input.Solver, 'Steps')
     k = input.Solver.Steps;
 else
     k = 1;
 end
 if isfield(input.Solver, 'Error')
     err = input.Solver.Error;
 else
     err = 0;
 end
 
 eType = input.Elements.Type;

%----- find and remove unused nodes ---------------------------------- 
 % extract node data
 j = 1;
 eNodes = [];
 while isfield(input.Elements, ['N' num2str(j)])
	eNodes = [eNodes input.Elements.(['N' num2str(j)])]; % element node IDs
    j = j + 1;
 end
 
 % find unrestrained (dummy) nodes
 dummyNodesLogical = ~ismember(input.Nodes.ID, eNodes);
 
 if any(dummyNodesLogical)
	 disp(' ');
	 disp('!!!!!!!!!!!!!!!!!! Warning !!!!!!!!!!!!!!!!!!');
	 disp('Unrestrained nodes found:');
	 disp(input.Nodes.ID(dummyNodesLogical)');
	 disp('');
	 disp('Removing unrestrained nodes and continuing.');
	 disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
	 disp(' ');
 end
 
 % remove dummy nodes
 cc = fieldnames(input.Nodes);
 for i = 1 : length(cc)
	nodes.(cc{i}) = input.Nodes.(cc{i})(~dummyNodesLogical);
 end
 
%----- Node IDs -------------------------------------
 nID = nodes.ID;
 
%----- Global coordinates --------------------------
 if isfield(nodes, 'Z')
     % Z coordinates exist
     coord = [nodes.X, nodes.Y, nodes.Z];
 else
     % Z coordinates don't exist --> set to 0
     coord = [nodes.X, nodes.Y, zeros(size(nodes.X, 1),1)];
 end
 
%----- Degrees of Freedom --------------------------
% How many Degrees of Freedom per direction (rotational DoF?)
 if any(ismember([223 543], eType))
     % 3D - Structure Elements
     % 2 DoF per direction (translation, rotation) and all directions
     % active
     dof = reshape((1 : 2*numel(coord))', [], size(coord, 1))';
     nDim = 3;
 elseif any(ismember([123 683], eType))     
     % 3D - Continuum Elements
     % 1 DoF per direction (translation)
     dof = reshape((1 : numel(coord))', [], size(coord, 1))';
     nDim = 3;     
 elseif any(ismember([222 229], eType))
     % 2D - Structure Elements
     % 2D Beam element (2 translation and 1 rotation)
     dof = reshape((1 : 1.5*numel(coord(:,1:2)))', [], size(coord, 1))';
     nDim = 2;
 elseif any(ismember([122 332 342 382], eType))
     % 2D - Continuum Elements
     % 1 DoF per direction (translation), one direction (Z) disabled
     dof = reshape(1 : numel(coord(:,1:2)), [], size(coord, 1))';
     nDim = 2;
 end

%----- number of nodes per element -------------------------------------
 nens = zeros(size(eType, 1), 1);
 
 for i = 1 : size(eType, 1)
     switch eType(i)
         case {382, 683} % 8 Node Elements
             nens(i) = 8;
         case {342 543}  % 4 Node Elements
             nens(i) = 4;
         case {332} % 3 Node Elements
             nens(i) = 3;
         case {122, 123, 222, 223, 229}   % 2 Node Elements
             nens(i) = 2;
     end
 end
 nen = max(nens);
 
%----- Topology Matrix eDof -------------------------------------
 eDof = zeros(size(eType, 1), 3*(nDim-1)*nen+1);
 eDof(:,1) = input.Elements.ID;
 
 for i = 1 : size(eType, 1)
     % extract node data
%      j = 1;
%      eNodes = [];
%      while isfield(input.Elements, ['N' num2str(j)])
%          if input.Elements.(['N' num2str(j)])(i) ~= 0
%             eNodes = [eNodes input.Elements.(['N' num2str(j)])(i)]; % element node IDs
%          end
%          j = j + 1;
% 	 end
	 ceNodes = eNodes(i,:);
	 ceNodes(ceNodes == 0) = [];
     eIndices = ID2Index(ceNodes, nID);   % internal indices of elemen nodes
     
     % assign dof directions to an element
     %                   2  3  4  5     6     7
     % eDof:    3D: [eID x1 y1 z1 phiX1 phiY1 phiZ1 ...]
     %          2D: [eID x1 y1 phiZ1 ...]
     switch eType(i)
         case {122}   % bar, 2 Node, 2D
             eDof(i,[2 3 5 6]) = [dof(eIndices(1),:), dof(eIndices(2),:)];
         case {123}   % bar, 2 Node, 3D
             eDof(i,[2 3 4 8 9 10]) = [dof(eIndices(:,1),:), dof(eIndices(:,2),:)];
         case {222}   % beam, 2 Node, 2D
             eDof(i,2:7) = [dof(eIndices(1),:), dof(eIndices(2),:)];
         case {229}   % Timoshenko beam, 2 Node, 2D
             eDof(i,2:7) = [dof(eIndices(1),:), dof(eIndices(2),:)];
         case {223}   % beam, 2 Node, 3D
             eDof(i,2:13) = [dof(eIndices(1),:), dof(eIndices(2),:)];
         case {332} % membrane, 3 Node, 2D
             eDof(i,[2 3 5 6 8 9]) = [dof(eIndices(1),:), dof(eIndices(2),:),...
                                      dof(eIndices(3),:)];             
         case {342} % membrane (isoparametric), 4 Node, 2D
             eDof(i,[2 3 5 6 8 9 11 12]) = [dof(eIndices(1),:), dof(eIndices(2),:),...
                                            dof(eIndices(3),:), dof(eIndices(4),:)];
         case {382}
             eDof(i,[2 3 5 6 8 9 11 12 14 15 17 18 20 21 23 24]) = ...
                                            [dof(eIndices(1),:), dof(eIndices(2),:),...
                                            dof(eIndices(3),:), dof(eIndices(4),:),...
                                            dof(eIndices(5),:), dof(eIndices(6),:),...
                                            dof(eIndices(7),:), dof(eIndices(8),:)];             
         case {543} % shell (isoparametric), 4 Node, 3D
             eDof(i,2:25) = [dof(eIndices(1),:), dof(eIndices(2),:),...
                             dof(eIndices(3),:), dof(eIndices(4),:)];
         case {683}
             eDof(i,[2:4 8:10 14:16 20:22 26:28 32:34 38:40 44:46]) = ...
                                            [dof(eIndices(1),:), dof(eIndices(2),:),...
                                             dof(eIndices(3),:), dof(eIndices(4),:),...
                                             dof(eIndices(5),:), dof(eIndices(6),:),...
                                             dof(eIndices(7),:), dof(eIndices(8),:)];                            
     end
 end
 
%----- Stiffness matrix K and load vector f ---------------------
 K = zeros(numel(dof));
 
 switch sType
     case {1}   % static linear
        M = [];
        C = [];
        f = zeros(numel(dof),1);
        
        % ORDER OF LOADS PROBLEMATIC
        % Add forces in the directions of dof to zero load vector
        loadIndex = ID2Index(input.Loads.NodeID, nodes.ID);
        loads = cell2mat(struct2cell(input.Loads)');   % removes field names and writes field content into matrix
        loadDof = find(any(loads(:,2:end), 1));  % find all loaded degrees of freedom
        loads = loads(:,loadDof+1); % remove ID column and non loaded degrees of freedom
        f(reshape(dof(loadIndex,loadDof)', [], 1), 1) = reshape(loads', [], 1);
     case {2}   % eigen frequencies and modal analysis
        M = zeros(numel(dof));
        C = [];
        f = [];
     case {3}   % dynamic response
        M = zeros(numel(dof));
        C = zeros(numel(dof));
        f = zeros(numel(dof),1);
 end
 
%----- Element properties ---------------------------------------
 for i = 1 : size(eType, 1)
     switch eType(i)
         case {122, 123} % bar elements
             matIndex = ID2Index(input.Elements.MatID(i), input.Materials.ID);
             propIndex = ID2Index(input.Elements.PropID(i), input.Properties.ID);        
             prop.Ep(i) = input.Materials.Ep(matIndex);
             prop.A(i) = input.Properties.A(propIndex);
         case {222} % beam element 2D
             matIndex = ID2Index(input.Elements.MatID(i), input.Materials.ID);
             propIndex = ID2Index(input.Elements.PropID(i), input.Properties.ID);        
             prop.Ep(i) = input.Materials.Ep(matIndex);
             prop.A(i) = input.Properties.A(propIndex);
             prop.I(i) = input.Properties.I(propIndex);
			 prop.zMax(i) = input.Properties.zMax(propIndex);
         case {229} % Timoshenko beam element 2D
             matIndex = ID2Index(input.Elements.MatID(i), input.Materials.ID);
             propIndex = ID2Index(input.Elements.PropID(i), input.Properties.ID);        
             prop.Ep(i) = input.Materials.Ep(matIndex);
             prop.Gq(i) = input.Materials.Gq(matIndex);
             prop.ks(i) = input.Materials.ks(matIndex);
             prop.A(i) = input.Properties.A(propIndex);
             prop.I(i) = input.Properties.I(propIndex);
         case {223} % beam element 3D
             matIndex = ID2Index(input.Elements.MatID(i), input.Materials.ID);
             propIndex = ID2Index(input.Elements.PropID(i), input.Properties.ID);        
             prop.Ep(i) = input.Materials.Ep(matIndex);
             prop.Gq(i) = input.Materials.Gq(matIndex);
             prop.A(i) = input.Properties.A(propIndex);
             prop.Iy(i) = input.Properties.Iy(propIndex);
             prop.Iz(i) = input.Properties.Iz(propIndex);
             prop.Kv(i) = input.Properties.Kv(propIndex);
             prop.xz(i) = input.Properties.xz(propIndex);
             prop.yz(i) = input.Properties.yz(propIndex);
             prop.zz(i) = input.Properties.zz(propIndex);
			 prop.zMax(i) = input.Properties.zMax(propIndex);
			 prop.yMax(i) = input.Properties.yMax(propIndex);
         case {332 342 382} % membrane elements
             matIndex = ID2Index(input.Elements.MatID(i), input.Materials.ID);
             propIndex = ID2Index(input.Elements.PropID(i), input.Properties.ID);
             prop.Ep(i) = input.Materials.Ep(matIndex);
             prop.Es(i) = input.Materials.Es(matIndex);         
             prop.nue(i) = input.Materials.nue(matIndex);
             prop.Gq(i) = input.Materials.Gq(matIndex);
             prop.phi(i) = input.Materials.phi(matIndex);
             prop.t(i) = input.Properties.t(propIndex);
         case {543} % shell elements
             matIndex = ID2Index(input.Elements.MatID(i), input.Materials.ID);
             propIndex = ID2Index(input.Elements.PropID(i), input.Properties.ID);
             prop.Ep(i) = input.Materials.Ep(matIndex);
             prop.Es(i) = input.Materials.Es(matIndex);         
             prop.nue(i) = input.Materials.nue(matIndex);
             prop.Gq(i) = input.Materials.Gq(matIndex);
             prop.phi(i) = input.Materials.phi(matIndex);
             prop.t(i) = input.Properties.t(propIndex);
             switch sType
                 case {2}
                     prop.rho(i) = input.Materials.rho(matIndex);
                 case {3}
                     prop.rho(i) = input.Materials.rho(matIndex);
                     prop.a(i) = input.Materials.a(matIndex);
                     prop.b(i) = input.Materials.b(matIndex);
             end
         case {683} % solid elements
             matIndex = ID2Index(input.Elements.MatID(i), input.Materials.ID);
             % propIndex = ID2Index(input.Elements.PropID(i), input.Properties.ID);
             prop.Ep(i) = input.Materials.Ep(matIndex);
             prop.nue(i) = input.Materials.nue(matIndex);
     end
 end
 
%----- Boundary Conditions --------------------------------------
 if isfield(input, 'BC')
    bcIndex = ID2Index(input.BC.NodeID, nodes.ID);
    boundary = cell2mat(struct2cell(input.BC)');
    bc = [reshape(dof(bcIndex,:)', [], 1),...
          reshape(boundary(:, 2:end)', [], 1)];
    % Remove non fixed (imaginary) Directions
    bc((imag(bc(:,2)) ~= 0),:) = [];
 else
     bc = [];
 end
 
end
