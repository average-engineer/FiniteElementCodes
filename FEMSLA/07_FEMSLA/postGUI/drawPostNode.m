function [nodes] = drawPostNode(nodes, displacement)
% DRAWPOSTNODE Draws nodes in the current axes object

%--------- Node Coordinates --------------------------------------------
 nID = nodes.data(:,1);
 nX = nodes.data(:,2) + displacement.scale * displacement.data(:,2);
 nY = nodes.data(:,3) + displacement.scale * displacement.data(:,3);
 nZ = nodes.data(:,4) + displacement.scale * displacement.data(:,4);

%--------- Draw All Nodes -------------------------------------------
 %plot3(nX, nY, nZ, 'Marker', 'd', 'Markersize', 10, 'LineStyle', 'none',...
                   %'Color', 'r');               
                   
%--------- Draw Selected Node -----------------------------------               
 nodes.hP = plot3(nX(nodes.i), nY(nodes.i), nZ(nodes.i), 'Marker', 'd',... 
                    'Markersize', 20, 'LineStyle', 'none',...
                    'Color', 'b');               
 
%--------- Enumerate All Nodes --------------------------------------
 %for i = 1 : size(nX,1)
    %text(nX(i), nY(i), nZ(i), num2str(nID(i)), 'Color', 'r', 'HorizontalAlignment', 'center');
 %end
 
%--------- Enumerate Selected Node ---------------------------------- 
 nodes.hT = text(nX(nodes.i), nY(nodes.i), nZ(nodes.i),...
                    num2str(nID(nodes.i)), 'Color', 'b',...
                    'HorizontalAlignment', 'center');
 
end

