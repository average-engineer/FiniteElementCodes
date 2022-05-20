function [output] = prepareOutput(output)
% [output] = prepareOutput(output)
%--------------------------------------------------------------------------
% PURPOSE
%  Prepares ilbFE variables for the output file.
%
% INPUT:    output  (struct)    output structure with fields of data and/or
%                               substructs of data
%
%                                               output
%                                              /   |   \
%                                     Substruct1  ...   Data1  
%                                    /    |    \
%                                ...    ...    ...
%
% OUTPUT:   output  (struct)    output structure with fields of data, a
%                               header substruct to label the columns of
%                               each data field and/or substructs of data
%
%                                               output   -  H - Data1 - ...
%                                              /   |   \      \_ ...
%                                     Substruct1  ...   Data1  
%                                    /    |    \
%                                ...    ...    ...
%
%--------------------------------------------------------------------------
% LAST MODIFIED: Arnd Koeppe 2012-08-16
%--------------------------------------------------------------------------
 
 outFields = fieldnames(output);
 
 for i = 1 : length(outFields)
	 
     currentName = outFields{i};
	 
     switch currentName
		 
         case {'eStress'} % element stress
             output.H.(currentName) = {'eID', 'eType', 'eNode', 'nID',...
						'sigX', 'sigY', 'sigZ', 'tauXY', 'tauYZ', 'tauZX'};
			 if size(output.eStress, 2) < 10
				 % fill up blanks with zeros
				 zf = zeros(size(output.eStress, 1), 1);
				 output.eStress = [output.eStress(:,1:6), zf, output.eStress(:,7), zf, zf];
			 end
			 
         case {'nDisp'} % node displacement
             output.H.(currentName) = {'nID', 'U', 'V', 'W', 'rX', 'rY', 'rZ'};
			 
			 if size(output.nDisp, 2) < 7
				 % fill up blanks with zeros
				 if size(output.nDisp, 2) < 4
					 output.nDisp = [output.nDisp(:,1:3), zeros(size(output.nDisp, 1), 4);];
				 else
					 output.nDisp = [output.nDisp(:,1:4), zeros(size(output.nDisp, 1), 3);];
				 end
			 end
			 
         case {'mFreq'} % modal frequency
             output.H.(currentName) = {'Mode' 'f'};
			 
         case {'mDisp'} % modal displacement
             output.H.(currentName) = {'Mode', 'nID', 'U', 'V', 'W', 'rX', 'rY', 'rZ'};
             
             if size(output.mDisp, 2) < 6
				 % fill up blanks with zeros
					 output.mDisp = [output.mDisp(:,1:4), zeros(size(output.mDisp, 1), 3), output.mDisp(:,5)];
			 end
             
%              if size(output.mDisp, 2) < 7
% 				 % fill up blanks with zeros
% 				 if size(output.mDisp, 2) < 4
% 					 output.mDisp = [output.mDisp(:,1:3), zeros(size(output.mDisp, 1), 4);];
% 				 else
% 					 output.mDisp = [output.mDisp(:,1:4), zeros(size(output.mDisp, 1), 3);];
% 				 end
% 			 end
			 
     end
 end

end

