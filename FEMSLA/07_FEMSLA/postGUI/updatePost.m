function [nodes] = updatePost(hAxes, displacement, nodes, stress, elements, load)
%UPDATEPOST Redraws the current model consisting of displaced Nodes and Elements

 global displayMode;

 axes(hAxes);
 cla(hAxes);
 axis(hAxes, 'auto');
 %drawLoads(nodes, load);   
 hold on;  
 
 nodes = drawPostNode(nodes, displacement);    
 
 if displayMode.original > 0
	drawPostElements(nodes, [], elements, []);
 end
 drawPostElements(nodes, displacement, elements, stress);
 
 if displayMode.loads > 0
    drawPostLoads(nodes, displacement, load);
 end
 
 colorbar;
 
 hold off;

end

