function [fName] = writeOutput(problemName, output)
% [fName] = writeOutput(problemName, output)
%--------------------------------------------------------------------------
% PURPOSE
%  Prints the output data into a text file.
%
% INPUT:    problemName (str)   input file name (with extension: .in)
%           output   (struct)   output structure with fields of data, a
%                               header substruct to label the columns of
%                               each data field and/or substructs of data
%
%                                               output   -  H - Data1 - ...
%                                              /   |   \      \_ ...
%                                     Substruct1  ...   Data1  
%                                    /    |    \
%                                ...    ...    ...
%
% OUTPUT:   fName   (str)   output file name (with extension: .out)
%
%--------------------------------------------------------------------------
% LAST MODIFIED: Arnd Koeppe 2012-08-16
%--------------------------------------------------------------------------
 
 [problemName, isFileExist] = checkFileName(problemName,'in'); % corresponding input file exists
 if isFileExist == 2    % it is a data file and exists
    %----- create and open output file ------------------------------------
    fName = checkFileName(problemName, 'out');  % create output file name
    copyfile(problemName, fName);   % create output file and copy content of input file to output file
    fID = fopen(fName, 'a');  % open to add to output file
    
    fprintf(fID, '\n');     % new line
    
    %----- write output variables into output file ------------------------
    outFields = fieldnames(output);
    
    for i = 1 : length(outFields)  % all output fields
        if outFields{i} ~= 'H' % Ignore header substruct
            current = output.(outFields{i});

            % initialize header and format
            header = ['H ' outFields{i}];
            format = outFields{i};

            if isstruct(current)    % for structures use fieldnames as headers
                fields = fieldnames(current);
                for j = 1 : length(fields)  % all fields
                    header = [header '\t\t ' fields{j}];
                    format = [format '\t %9.5g'];
                end

                % convert struct to matrix
                output.current = cell2mat(struct2cell(current)');

            elseif isfloat(current) % for matrices
                if isfield(output, 'H') % any headers defined
                    if isfield(output.H, outFields{i})  % header line defined
                        colHeader = output.H.(outFields{i});
                        % seperate loops so header can be shorter than
                        % number of columns
                        for j = 1 : length(colHeader) % all header titles
                            header = [header '\t\t ' colHeader{j}];
                            %format = [format '\t %9.3g'];                            
                        end
                        for j = 1 : size(current, 2) % all columns
                            format = [format '\t %9.5g'];                        
                        end                        
                    else % generic header
                        for j = 1 : size(current, 2) % all columns
                            header = [header '\t\t Var' num2str(j)];
                            format = [format '\t %9.5g'];                        
                        end
                    end
                else % generic header
                    for j = 1 : size(current, 2) % all columns
                        header = [header '\t\t\t Var' num2str(j)];
                        format = [format '\t %9.5g'];                        
                    end                    
                end
            end

            % new line
            header = [header '\n'];
            format = [format '\n'];

            % print to file
            fprintf(fID, header);
            fprintf(fID, format, current');
            fprintf(fID, '\n');
        end
    end
    fclose(fID);
 else
    error([problemName, ' does not exist.']);
 end
 
end

