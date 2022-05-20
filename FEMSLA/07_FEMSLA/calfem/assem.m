 function [K,f]=assem(eDof,K,Ke,f,fe)
% K=assem(edof,K,Ke)
% [K,f]=assem(edof,K,Ke,f,fe)
%-------------------------------------------------------------
% PURPOSE
%  Assemble element matrices Ke ( and fe ) into the global
%  stiffness matrix K ( and the global force vector f )
%  according to the topology matrix edof.
%
% INPUT: edof:       dof topology matrix
%        K :         the global stiffness matrix
%        Ke:         element stiffness matrix
%        f :         the global force vector
%        fe:         element force vector
%
% OUTPUT: K :        the new global stiffness matrix
%         f :        the new global force vector
%-------------------------------------------------------------

 t = eDof(:,2:end); % remove element IDs
 for i = 1 : size(eDof, 1);
     tmp = t(i,any(t(i,:),1));  % remove zeros
     K(tmp,tmp) = K(tmp,tmp) + Ke;
     if nargin==5
         f(tmp) = f(tmp) + fe;
     end
 end

