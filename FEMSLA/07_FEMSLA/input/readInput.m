function [input] = readInput(problemName)
% [input] = readInput(problemName)
%--------------------------------------------------------------------------
% PURPOSE
%  Reads the input data from the input file and saves them in structures
%  with fields named after column headers.
%
% INPUT:    problemName     (str)   input file name (with extension: .in)
%
% OUTPUT:   input   (struct)    input structure with fields of substructs
%                               for all the data from an input file. Fields
%                               of the substructs are named after column
%                               headers.
%
%--------------------------------------------------------------------------
% LAST MODIFIED: Arnd Koeppe 2012-08-16
%--------------------------------------------------------------------------
    
 fileid = fopen(problemName);
    
 fileData = textscan(fileid, '%s', 'Delimiter', '\n', 'MultipleDelimsAsOne', 1,'commentStyle', 'C'); % read complete file
 data = fileData{1,1}; % get data cell of lines from fileData
 
 H = struct;
 input = struct;

 for i = 1 : length(data)
     lineData = textscan(data{i}, '%s'); % read current line
     cols = lineData{1}; % get column data cell from lineData
     lineHeader = cols{1};
     if strcmp(lineHeader, 'H')
         % current line is new header line
         sName = cols{2};
         sFields = cols(3:end);
         H.(sName) = sFields;
         % initialize substruct with fields
         input.(sName) = cell2struct(cell(size(sFields)), sFields);
     elseif isfield(H, lineHeader)
         % rowheader is a known map (column headers are defined)
         for j = 1 : length(H.(lineHeader))
             input.(lineHeader).(H.(lineHeader){j})(end+1,1) = str2double(char(cols(j+1)))';
         end
     elseif strcmp(lineHeader, 'Title')
         % title line
         input.(lineHeader) = sprintf('%s ', cols{2:end});
%     elseif strcmp(lineHeader, 'ENDDAT')
%         % end of input data
%         break;
     end  
 end
    
end

