function [eSm] = misesStress(eS)
% MISESSTRESS Calculates the mises stress eSm for an element of type eType
% out of the element stresses eS


 switch size(eS,2)
    case {10}  % shell, 4 node, 3D
        eSm = sqrt(eS(:,5).^2 + eS(:,6).^2 + eS(:,7).^2 ...
                   - eS(:,5) .* eS(:,6) - eS(:,6) .* eS(:,7)...
                   - eS(:,7) .* eS(:,5)...
                   + 3 * (eS(:,8).^2 + eS(:,9).^2 + eS(:,10).^2));        
%     case{7}
%         eSm = sqrt(eS(:,1:6:24).^2 + eS(:,2:6:24).^2 + eS(:, 3:6:24).^2 ...
%                    - eS(:,1:6:24) .* eS(:,2:6:24) - eS(:,2:6:24) .* eS(:,3:6:24)...
%                    - eS(:,3:6:24) .* eS(:,1:6:24)...
%                    + 3 * (eS(:,4:6:24).^2 + eS(:,5:6:24).^2 + eS(:,6:6:24).^2));     
     otherwise
        error('Invalid number length of Stress Vector');
 end


end

