function sf = scaleFactor(coord, dis, zoom)
% SCALEFACTOR Calculates a scalefactor to scale the dis to zoom times the 
% dimensions of the structure defined by coords
 
 %--------- extract node coordinates ----------------------------------
 x = coord(:,1);
 y = coord(:,2);
 z = coord(:,3);
 
%--------- extract node displacements --------------------------------
 xx = dis(:,1);
 yy = dis(:,2);
 zz = dis(:,3);
    
%--------- calculate scale factor -------------------------------------
 lx = max(x) - min(x);
 ly = max(y) - min(y);
 lz = max(z) - min(z);
 L = sqrt(lx^2 + ly^2 + lz^2);  % length of the structure
 
 lL = max(sqrt(xx.^2 + yy.^2 + zz.^2)); % maximum total displacement
    
 sf = zoom * L / lL ; % displacements displayed as zoom times structure dimensions



end

