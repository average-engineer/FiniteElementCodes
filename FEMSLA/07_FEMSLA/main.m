function [fName] = main(problemName)
% [fName] = main(problemName)
%--------------------------------------------------------------------------
% PURPOSE
%  Executes ilbFE to solve the specified problem
%
% INPUT:    problemName     (str)   input file name (with extension: .in)
%
% OUTPUT:   fName           (str)   output file name (with extension: .out)
%
%--------------------------------------------------------------------------
% LAST MODIFIED: Arnd Koeppe 2012-03-07
%--------------------------------------------------------------------------
 
 %clear all;
 clc;

 format shortG;
 
 disp('----------------------------------------');
 disp('--------------- ilb / FE ---------------');
 disp('----------------------------------------');
 
 disp(' ');
 disp(['- Begin reading and preprocessing of ''', problemName, ''' ...']);
 
 [eDof, K, M, C, f, coord, dof, prop, bc, nen, sType, eType, nID, k, err, title] = preprocess(problemName);
 
 disp(['- Finished reading and preprocessing of ''', problemName, '''!']);
 disp(' ');
 
 disp(['- Problem:     ' title]);
 disp(' ');
 
 switch sType
     case {1}
         % static linear analysis
         fName = solver1(problemName, eDof, K, f, coord, dof, prop, bc, nen, eType, nID);
     case {2}
         % eigen frequency and modal analysis
         fName = solver2(problemName, eDof, K, M, coord, dof, prop, bc, nen, eType, nID, k);
     case {3}
         % dynamic response through iteration in time domain
         %fName = solver3(problemName, eDof, K, M, C, coord, dof, prop, bc, nen, eType, nID, k, err);
 end
 
 %--------- open output GUI--------------------------------------------
 openOutputGUI(fName);
 
end