function [eX, eY, eZ] = coordXtr(eDof, coord, dof, nen)
%[eX, eY, eZ] = coordXtr(eDof, coord, dof, nen)
%[eX, eY] = coordXtr(eDof, coord, dof, nen)
%--------------------------------------------------------------------------
% PURPOSE
%    Extract nodal coordinate data from the global coordinate 
%    matrix for a number of elements with variable number of 
%    element nodes and dof. 
%
% INPUT:  eDof :  topology matrix , dim(t) = nie x ned+1
%                         nie = number of identical elements
%                         ned = number of element dof's  
%
%         coord: global coordinate matrix 
%
%         dof:   global nodal dof matrix 
%
%         nen:   number of element nodes
%
% OUTPUT: eX,eY,eZ : element coordinate matrices
%         eX = [x1 x2 ...xnen;    one row for each element
%               ...     ...  ;
%               nel     ...  ]  
%               dim = nel x nen ;   nel: number of elemnts 
%--------------------------------------------------------------------------
% LAST MODIFIED: Arnd Koeppe 2012-08-16
%--------------------------------------------------------------------------
 
 % initialize
 %nDof = size(dof, 2);
 eX = zeros(size(eDof, 1), nen);
 eY = zeros(size(eDof, 1), nen);
 if (nargout == 3)
    eZ = zeros(size(eDof, 1), nen);
 end
 
 for i = 1 : size(eDof, 1) 
	 ceDof = eDof(i,:);
	 j = 0;
	 prevENL = 0;
	 for cDof = ceDof(2:end)
		 eNodeLogical = ismember(dof, cDof);
		 if cDof ~= 0
			 if any(xor(any(prevENL,2), any(eNodeLogical,2)),1)
				 % next node
				 j = j+1;
			 end
			 switch find(any(eNodeLogical, 1))
				 case {1}
					 eX(i,j) = coord(eNodeLogical(:,1),1)';
				 case {2}
					 eY(i,j) = coord(eNodeLogical(:,2),2)';
				 case {3}
					 eZ(i,j) = coord(eNodeLogical(:,3),3)';	 
			 end
		 end
		 prevENL = eNodeLogical;
	 end
 end
 
end

