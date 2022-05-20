function [] = openOutputGUI(fName)
%OPENOUTPUTGUI Opens the Output GUI

 warning('off', 'MATLAB:declareGlobalBeforeUse');
 
 global nodes elements mat prop load bc displacement stress frequencies
 
 output = readInput(fName);
 
 if isfield(output, 'eStress')
	[nodes, elements, mat, prop, load, bc, displacement, stress] = preparePostData(output);
	warning('on', 'MATLAB:declareGlobalBeforeUse');
	ilbFEPostGUI;
 elseif isfield(output, 'mFreq')
	[nodes, elements, mat, prop, ~, bc, displacement, ~, frequencies] = preparePostData(output);
	warning('on', 'MATLAB:declareGlobalBeforeUse');
	ilbFEPostFreqGUI;
 else
	 error(['Unknown output data: ' fName]);
 end

end

