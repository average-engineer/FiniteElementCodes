  function [eD]=extract(eDof,a)
% ed=extract(edof,a)
%-------------------------------------------------------------
% PURPOSE
%  Extract element displacements from the global displacement
%  vector according to the topology matrix edof.
%
% INPUT:   a:  the global displacement vector
%
%         edof:  topology matrix
%
% OUTPUT: ed:  element displacement matrix
%-------------------------------------------------------------
 
 eD = 1i * ones(size(eDof, 1), size(eDof, 2) - 1);

 t = eDof(:,2:end);
    
 for i = 1 : size(eDof, 1)
     tmp = t(i,any(t(i,:),1));  % remove zeros
     eD(i,1:size(tmp,2)) = a(tmp)';
 end
