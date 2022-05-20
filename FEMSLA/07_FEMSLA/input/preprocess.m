function [eDof, K, M, C, f, coord, dof, prop, bc, nen, sType, eType, nID, k, err, title] = preprocess(problemName)
% [eDof, K, M, C, f, coord, dof, prop, bc, nen, sType, eType, nID, k, err, title] = preprocess(problemName)
%--------------------------------------------------------------------------
% PURPOSE
%  Reads the input information from an input file and prepares the data for
%  the ilbFE core programm.
%
% INPUT:    problemName     (str)   input file name (with extension: .in)
%
% OUTPUT:   eDof    [elem dof1...;
%                             ...]  topology matrix
%           K       (nxn)           initialized stiffness matrix
%           M       (nxn)           initialized mass matrix
%           C       (nxn)           initialized damping matrix
%           f       (nx1)           load vector
%           coord   [x1 y1 z1;
%                         ...]      coordinates of all nodes
%           dof     [1 2...;
%                       ...]        indices of degrees of freedom for each 
%                                   node
%           prop    (struct)        element property structure
%           bc      [dof U;
%                      ...]         boundary conditions
%           nen     (1x1)           max number of nodes per element
%           sType   (1x1)           solver type (1 = linear static
%                                                2 = eigen frequency)
%           eType   (eNx1)          vector of the type of each element
%           nID     (nNx1)          vector of IDs of each node
%           k       (1x1)           number of steps
%           err     (1x1)           error
%           title   (str)           title of the problem
%
%--------------------------------------------------------------------------
% LAST MODIFIED: Arnd Koeppe 2012-08-16
%--------------------------------------------------------------------------

 % Check if file exists
 % problemName = input('Enter the Problem Name (File)? ','s');
 [problemName, isFileExist] = checkFileName(problemName,'in');
 if isFileExist == 2    % it is a data file
    [input] = readInput(problemName);
    [eDof, K, M, C, f, coord, dof, prop, bc, nen, sType, eType, nID, k, err, title] = prepareInput(input);
 else
    disp('Problem Data does not exist');
    return
 end
 fclose('all');
 
end
