%**********GLOBAL STIFFNESS MATRIX ASSEMBLY FOR 1D ROD ELEMENTS************

% Last Modified: 22nd April, 2022
% Author: Ashutosh Mukherjee
%**************************************************************************
%% Settings
clc
clearvars
close all
format short

%% Problem Definition:
% Number of Nodes
n = 4;
% Number of Elements: 6
% Type of Elements: 1D Rod Elements (Linear Order Elements): 2 Nodes per
% element
% Number of DOFs per Nodes
ndof = 2;

%% Element Properties
% For now set as unity
E = 1; % Young's Modulus (All elements have the same E)
A = 1; % Cross-Section (All elements have the same A)
L = 1; % Element Length

%% Creating the local element stiffness matrices (Problem Specific)
K1 = RodElementStiffnessMatrix(-pi/2,E,A,0.8*L); % 1st Element
K2 = RodElementStiffnessMatrix(-2.214,E,A,L); % 2nd Element
K3 = RodElementStiffnessMatrix(-pi,E,A,0.6*L); % 3rd Element
K4 = RodElementStiffnessMatrix(-0.9273,E,A,L); % 4th Element
K5 = RodElementStiffnessMatrix(-pi/2,E,A,0.8*L); % 5th Element
K6 = RodElementStiffnessMatrix(pi,E,A,0.6*L); % 6th Element

%% Storing the element stiffness matrices in one array
nelem = 6; % Number of Elements
elemStiff{1} = K1;
elemStiff{2} = K2;
elemStiff{3} = K3;
elemStiff{4} = K4;
elemStiff{5} = K5;
elemStiff{6} = K6;

%% Associated Nodes with each element
% Assumption: The angles the elements make is considered from lower global
% node to higher global node i.e. the lower numbered node in the element is
% considered to be on the horizontal axis, and then the angle with the
% horizontal which the rod element (line to the higher numbered node)
% subtends is the alpha angle

% 2 Nodes for each element
assNodes = NaN(nelem,2);

assNodes(1,:) = [1,3]; % Nodes associated with element 1
assNodes(2,:) = [1,4]; % Nodes associated with element 2
assNodes(3,:) = [1,2]; % Nodes associated with element 3
assNodes(4,:) = [2,3]; % Nodes associated with element 4
assNodes(5,:) = [2,4]; % Nodes associated with element 5
assNodes(6,:) = [3,4]; % Nodes associated with element 6

%% Assembling the Global Stiffness Matrix
KGlobal = zeros(n*ndof,n*ndof); % Assembled Global Stiffness Matrix
for ii = 1:nelem
   
    % Since each element stiffness matrix will contribute to the assembled
    % global stiffness matrix, for each element, a corresponding global 
    % stiffness matrix is constructed and finally all the stiffness
    % matrices are added together to get the final assembled global
    % stiffness matrix
    K{ii} = zeros(n*ndof,n*ndof); % System of Global Stiffness Matrices
    
    K{ii}(2*assNodes(ii,1)-1:2*assNodes(ii,1),2*assNodes(ii,1)-1:2*assNodes(ii,1)) = elemStiff{ii}(1:2,1:2);
    K{ii}(2*assNodes(ii,1)-1:2*assNodes(ii,1),2*assNodes(ii,2)-1:2*assNodes(ii,2)) = elemStiff{ii}(1:2,3:4);
    K{ii}(2*assNodes(ii,2)-1:2*assNodes(ii,2),2*assNodes(ii,1)-1:2*assNodes(ii,1)) = elemStiff{ii}(3:4,1:2);
    K{ii}(2*assNodes(ii,2)-1:2*assNodes(ii,2),2*assNodes(ii,2)-1:2*assNodes(ii,2)) = elemStiff{ii}(3:4,3:4);
    KGlobal = KGlobal + K{ii};
    
end



