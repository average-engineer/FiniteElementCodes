%% Script for computing all relevant information regarding a 2D triangular
% finite element

function [b,c,d,area,N,stiff,E_mat,B] = twoD_triangularElement(i,j,k,XYi,XYj,XYk,assumption,E,p,h)

% Function Inputs:
%               i,j,k: Element Node Numerations (i->j->k: Cyclic Permutations)
%               XYi,XYj,XYk: Node Location Coordinates (1x2 vector)
%               Assumption: Plane Stress (stress)/Plane Strain (strain)
%               E: Element Material Young's Modulus (can be a value or a symbol)
%               p: Element Material Poisson's Ratio (can be a value or a symbol)
%               h: Element thickness (can be a value or a symbol)

nodes = [i,j,k];

%% Coordinate Variables
% Follow Cyclic Permutations
b(i) = XYj(1)*XYk(2) - XYk(1)*XYj(2); 
b(k) = XYi(1)*XYj(2) - XYj(1)*XYi(2);
b(j) = XYk(1)*XYi(2) - XYi(1)*XYk(2);

c(i) = XYj(2) - XYk(2);
c(k) = XYi(2) - XYj(2);
c(j) = XYk(2) - XYi(2);

d(i) = XYk(1) - XYj(1);
d(k) = XYj(1) - XYi(1);
d(j) = XYi(1) - XYk(1);

%% Area of the Element
area = 0.5*((XYj(1)*XYk(2) - XYk(1)*XYj(2)) - XYi(1)*(XYk(2) - XYj(2)) + XYi(2)*(XYk(1) - XYj(1)));

%% Constructing Shape Functions
syms x
syms y

for ii = nodes
    N(ii) = (b(ii) + c(ii)*x + d(ii)*y)/(2*area);
end

%% Element Stiffness Submatrices
switch assumption
    case 'strain'
        for ii = nodes
            for jj = nodes
                stiff{ii,jj} = ((E*h)/(4*area*(1+p)*(1-2*p)))*[c(ii)*c(jj)*(1-p) + d(ii)*d(jj)*(0.5-p),c(ii)*d(jj)*p + c(jj)*d(ii)*(0.5-p);
                                                           c(jj)*d(ii)*p + c(ii)*d(jj)*(0.5-p),d(ii)*d(jj)*(1-p) + c(ii)*c(jj)*(0.5-p)];
            end
        end
    case 'stress'
        for ii = nodes
            for jj = nodes
                stiff{ii,jj} = ((E*h)/(4*area*(1-(p)^2)))*[c(ii)*c(jj) + d(ii)*d(jj)*((1-p)/2),c(ii)*d(jj)*p + c(jj)*d(ii)*((1-p)/2);
                                                           c(jj)*d(ii)*p + c(ii)*d(jj)*((1-p)/2),d(ii)*d(jj) + c(ii)*c(jj)*((1-p)/2)];                                                  
        
            end
        end
end
           
%% Elasticity Matrix 
% Assumption: Element material is linear elastic, homogeneous and isotropic
switch assumption
    case 'strain'
        E_mat = [1-p,p,0;
                 p,1-p,0;
                 0,0,(1-2*p)/2];
        E_mat = (E/((1+p)*(1-2*p)))*E_mat;
        
    case 'stress'
        E_mat = [1,p,0;
                 p,1,0;
                 0,0,(1-p)/2];
        E_mat = (E/(1 - p^2))*E_mat;
        
end

%% Cauchy Strain Vectors
% Differential Operator on displacement matrix
for ii = nodes
    B{ii} = (1/2*area)*[c(ii),0;
                        0,d(ii);
                        d(ii),c(ii)];
end
end