function [nodes, elements, mat, prop, load, bc, displacement, stress, frequencies] = preparePostData(output)
%PREPAREDATA Prepares the output data for postGUI usage

 nodes.data = cell2mat(struct2cell(output.Nodes)');
 
 if size(nodes.data, 2) < 4
	 nodes.data = [nodes.data zeros(size(nodes.data, 1),1)];
 end
 
 elements.data = cell2mat(struct2cell(output.Elements)');
 mat.data = cell2mat(struct2cell(output.Materials)');
 prop.data = cell2mat(struct2cell(output.Properties)');
 bc.data = cell2mat(struct2cell(output.BC)');

 %----- find and readd unused nodes --------------------------------------- 
 
 % find unrestrained (dummy) nodes
 dummyNodesLogical = ~ismember(output.Nodes.ID, elements.data(:,5:end));
 
 if any(dummyNodesLogical)
	 disp(' ');
	 disp('!!!!!!!!!!!!!!!!!! Warning !!!!!!!!!!!!!!!!!!');
	 disp('Unrestrained nodes found:');
	 disp(output.Nodes.ID(dummyNodesLogical)');
	 disp('');
	 disp('Readding unrestrained nodes for postprocessing.');
	 disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
	 disp(' ');
 end 
 
 %----- check for unknown element types -----------------------------------
 
 knownEType = [122 123 222 223 332 342 382 543 683];
 eType = output.Elements.Type';
 
 foundEType = ismember(eType, knownEType);
 
 if any(~foundEType, 2)
	 disp(' ');
	 disp('!!!!!!!!!!!!!!!!!! Warning !!!!!!!!!!!!!!!!!!');
	 disp('Unknown element types in postprocess GUI:');
	 disp(eType(~foundEType));
	 disp('');
	 disp('Attempting to draw anyways.');
	 disp('You can change the way elements are drawn in:');
	 disp('     drawPostElements.m     ');
	 disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
	 disp(' ');
 end
 
%--------- element type ---------------------------------------------------
 %eType = elements.data(:,2);

 switch output.Solver.Type
    
    case {1}    % linear static analysis
		
		load.data = zeros(size(output.Loads.ForceX, 1), 7);
		
		if isfield(output.Loads, 'NodeID')
			load.data(:,1) = output.Loads.NodeID;
		end
		if isfield(output.Loads, 'ForceX')
			load.data(:,2) = output.Loads.ForceX;
		end
		if isfield(output.Loads, 'ForceY')
			load.data(:,3) = output.Loads.ForceY;
		end
		if isfield(output.Loads, 'ForceZ')
			load.data(:,4) = output.Loads.ForceZ;
		end
		if isfield(output.Loads, 'MomentX')
			load.data(:,5) = output.Loads.MomentX;
		end
		if isfield(output.Loads, 'MomentY')
			load.data(:,6) = output.Loads.MomentY;
		end
		if isfield(output.Loads, 'MomentZ')
			load.data(:,7) = output.Loads.MomentZ;
		end
		
		
		%--------- displacement data --------------------------------------
		% readd dummy nodes to displacement data
		displacement.data = zeros(size(nodes.data,1), 7);
		displacement.data(:,1) = nodes.data(:,1);
        displacement.data(~dummyNodesLogical,:) = cell2mat(struct2cell(output.nDisp)');
		
        coord = nodes.data(:, 2:4);
        dis = displacement.data(:, 2:4);

        %--------- total displacements ------------------------------------
        displacement.total = sqrt(dis(:,1).^2 + dis(:,2).^2 + dis(:,3).^2);

        %--------- scale factor -------------------------------------------
        displacement.scale = scaleFactor(coord, dis, 0.1);

        %--------- stress data --------------------------------------------
        stress.data = cell2mat(struct2cell(output.eStress)');

        %--------- mises stress -------------------------------------------
        stress.mises = misesStress(stress.data);

        nodes.i = size(displacement.data, 1);
        elements.i = size(elements.data, 1);
		
		frequencies = [];
		
	case {2}	% eigenvalue analysis
		
		%--------- displacement data --------------------------------------
		mFreq = cell2mat(struct2cell(output.mFreq)');
        mDisp = cell2mat(struct2cell(output.mDisp)');

		% readd dummy nodes to displacement data
		displacement.data = zeros(size(nodes.data,1), 8, size(mFreq, 1));
		displacement.data(:,2,:) = repmat(nodes.data(:,1), [1 1 size(displacement.data, 3)]);
		displacement.data(~dummyNodesLogical,:,:) = permute(reshape(mDisp', size(mDisp, 2), [], size(mFreq,1)),[2 1 3]);
		
        coord = repmat(nodes.data(:,2:4), [1 1 size(displacement.data, 3)]);
        dis = displacement.data(:,3:5,:);

        %--------- total displacements ------------------------------------
        displacement.total = sqrt(dis(:,1,:).^2 + dis(:,2,:).^2 + dis(:,3,:).^2);

        %--------- scale factor -------------------------------------------
        displacement.scale = scaleFactor(coord, dis, 0.1);

        %--------- frequencies data --------------------------------------------
        frequencies.data = mFreq(:,2);

        nodes.i = size(displacement.data, 1);
		elements.i = 0;
        frequencies.i = 1;
		
		load = [];
		stress = [];
 end
 
end
