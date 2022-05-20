function [nodes] = updatePostFreq(hAxes, displacement, nodes, elements, frequencies)
%UPDATEPOSTFREQ Redraws the current model consisting of displaced Nodes and Elements

global displayMode;

 axes(hAxes);
 cla(hAxes);
 axis(hAxes, 'auto');

 hold on;  
 
 thisDisp = displacement;
 thisDisp.data = thisDisp.data(:,2:end,frequencies.i);
 thisDisp.total = thisDisp.total(:,:,frequencies.i);
 
 nodes = drawPostNode(nodes, thisDisp); 
 
 if displayMode.original > 0
	drawPostElements(nodes, [], elements, []);
 end
 drawPostElements(nodes, thisDisp, elements, []);
 
 colorbar;
 
 hold off;

end

