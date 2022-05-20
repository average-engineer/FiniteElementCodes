function drawPostLoads(nodes, displacement, load)
% DRAWPOSTLOADS Draws loads in the current axes object

%--------- scale factors --------------------------------------------------
 maxAbsForce = max(max(abs(load.data(:, 2:4))));
 maxAbsMoment = max(max(abs(load.data(:, 5:7))));
 
 minCoord = min(min(nodes.data(:, 2:4)));
 maxCoord = max(max(nodes.data(:, 2:4)));
 L = abs(maxCoord - minCoord);
 
 forceScale = 0.1 * L / maxAbsForce;
 momentScale = 0.1 * L / maxAbsMoment;
 
%--------- coordinates ----------------------------------------------------
  nIDs = nodes.data(:, 1);
  lIDs = load.data(:,1);
  lIndex = ID2Index(lIDs, nIDs);
  
  x = nodes.data(lIndex, 2) + displacement.scale * displacement.data(lIndex,2);
  y = nodes.data(lIndex, 3) + displacement.scale * displacement.data(lIndex,3);
  z = nodes.data(lIndex, 4) + displacement.scale * displacement.data(lIndex,4);
  
  Fx = forceScale * load.data(:, 2);
  Fy = forceScale * load.data(:, 3);
  Fz = forceScale * load.data(:, 4);
  Mx = momentScale * load.data(:, 5);
  My = momentScale * load.data(:, 6);
  Mz = momentScale * load.data(:, 7);
 
%-------- draw loads ------------------------------------------------------
 quiver3(x, y, z, Fx, Fy, Fz, 'r');
 hold on;
 quiver3(x, y, z, Mx, My, Mz, 'g');
 hold off;

end

