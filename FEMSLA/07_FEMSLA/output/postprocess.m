function [fName] = postprocess(problemName, varargin)
% [fName] = postprocess(problemName, varargin)
%--------------------------------------------------------------------------
% PURPOSE
%  Gathers and prepares results to print them into an output file.
%
% INPUT:    problemName     (str)   input file name (with extension: .in)
%           (varagin)               variable number of parameters for
%                                   output
%
% OUTPUT:   fName   (str)   output file name (with extension: .out)
%
%--------------------------------------------------------------------------
% LAST MODIFIED: Arnd Koeppe 2012-08-16
%--------------------------------------------------------------------------
 
 optargin = length(varargin);
 %----- save variables into output struct -----------------------------
 for i = 1 : optargin
    output.(inputname(i+nargin-optargin)) = varargin{i};
 end
 
 %----- prepare output struct subfieldnames ---------------------------
 output = prepareOutput(output);
 
 %--------- export results to output file -----------------------------
 fName = writeOutput(problemName, output);

end