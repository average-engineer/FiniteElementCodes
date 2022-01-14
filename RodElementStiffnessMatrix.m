%***************LOCAL STIFFNESS MATRIX FOR 1D ROD ELEMENTS*****************

% Last Modified: 22nd October, 2021
% Author: Ashutosh Mukherjee
%**************************************************************************
%%
function [Ke] = RodElementStiffnessMatrix(alpha,E,A,L)

% Function for computing the element stiffness matrix of a 1D rod element
% with respect to the Global FOR

% alpha: angle made by the rod wrt horizontal
% E: Young's Modulus of the element material
% A: Cross-section area of the element
% L: Length of the element

% Assumptions:
% 1). Linear order element (2 nodes per element)
% 2). 2 DOFs per node (x and y)
% 3). alpha is is radians

% Element Stiffness Matrix of a 1D Rod Element
Ke = [(cos(alpha))^2,cos(alpha)*sin(alpha),-(cos(alpha))^2,-cos(alpha)*sin(alpha);
      cos(alpha)*sin(alpha),(sin(alpha))^2,-cos(alpha)*sin(alpha),-(sin(alpha))^2;
      -(cos(alpha))^2,-cos(alpha)*sin(alpha),(cos(alpha))^2,cos(alpha)*sin(alpha);
      -cos(alpha)*sin(alpha),-(sin(alpha))^2,cos(alpha)*sin(alpha),(sin(alpha))^2];
  
Ke = (E*A/L)*Ke;

end