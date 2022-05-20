function [row] = findVectorInMatrix(A, b)
% FINDVECTORINMATRIX [row] = findVectorInMatrix(A, b)
% Searches a row vector b in a matrix A and returns its row index

 % find index of first occurence of b in reshaped Matrix A
 ind = strfind(reshape(A',1,[]),b);
 
 % index corresponds to start of a row
 ind = ind((ind-1)/size(A,2) == fix((ind-1)/size(A,2)));
 
 % convert index to row index
 row = ceil(ind / size(A,2));

end

