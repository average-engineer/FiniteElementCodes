function [es,edi,eci]=beam2ts(ex,ey,ep,ed,eq,n)
%        [es,edi,eci]=beam2ts(ex,ey,ep,ed,eq,n) 
%-------------------------------------------------------------
%    PURPOSE
%      Compute section forces in two dimensional
%      Timoshenko beam element (beam2te). 
% 
%    INPUT:  ex = [x1 x2];        
%            ey = [y1 y2];        element node coordinates
%
%            ep = [E G A I ks ];  element properties,
%                                   E: Young's modulus
%                                   G: shear modulus
%                                   A: cross section area
%                                   I: moment of inertia
%                                  ks: shear correction factor
%
%            ed = [u1 ... u6] element displacements
%                 
%
%            eq = [qx qy]     distributed loads, local directions
%
%
%	OUTPUT: eS = [sigX1;
%				  sigX2]		maximum element stresses at nodes      
%
%--------------------------------------------------------------------------
% LAST MODIFIED: Mauricio Chaves 2015-06-08
%--------------------------------------------------------------------------
 
 % properties and geometry
 E = ep(1);
 zMax = 5;
 alpha=0;
 
 b = [ex(2) - ex(1);...
	  ey(2) - ey(1)];

 % length and angles
 L = sqrt(b' * b);
  
 n = b / L;		% [cos; sin]
 
 % bar part
 Bbar(1,1:2) = [-1/L, 1/L];

 % Timoshenko beam part
 
 Bbeam = -zMax * [-6/L^2, -4/L, 6/L^2, -2/L;...	% x = 0
				  6/L^2, 2/L, -6/L^2, 4/L];		% x = 1
 
%  Bbeam = 1/(L^2+12*alpha) * [6*zMax,  -2*zMax*(-2*L-6*alpha/L),  -6*zMax,  -2*zMax*(-L+6*alpha/L);...	% x = 0
% 				            -6*zMax,  -2*zMax*(L-6*alpha/L),      6*zMax,  -2*zMax*(2*L+6*alpha/L)]     % x = 1
 
%  Bbeam = 1/(L^2+12*alpha) * [6*zMax, -12*alpha/L, -2*zMax*(-2*L-6*alpha/L), -6*alpha, -6*zMax, 12*alpha/L, -2*zMax*(-L+6*alpha/L), -6*alpha;...	    % x = 0
% 				            -6*zMax, -12*alpha/L, -2*zMax*(L-6*alpha/L),    -6*alpha,  6*zMax, 12*alpha/L, -2*zMax*(2*L+6*alpha/L), -6*alpha]     % x = 1
    
 % superposition
%  B = zeros(2, 6);
%  
%  B(1, 1) = Bbar(1, 1);
%  B(1, 2:3) = Bbeam(1, 1:2);
%  B(1, 4) = Bbar(1, 2);
%  B(1, 5:6) = Bbeam(1, 3:4);
%  
%  B(2, 1) = Bbar(1, 1);
%  B(2, 2:3) = Bbeam(2, 1:2);
%  B(2, 4) = Bbar(1,2);
%  B(2, 5:6) = Bbeam(2, 3:4);
 
 % rotation matrix
 T0 = eye(3);
 
 T0(1,1) = n(1);
 T0(2,2) = n(1);
 T0(2,1) = -n(2);
 T0(1,2) = n(2);
 
 T = eye(6);
 
 T(1:3,1:3) = T0;
 T(4:6,4:6) = T0;
 
 % element stresses
% eS = E * B * T' * eD';	% rotation back to local

 lD = T' * ed';		% rotate back to local
 
 eSbar = E * Bbar * lD([1 4]);
 
 s = sign(eSbar);
 if s == 0
	 s = 1;	% if there is no longitudinal force
 end
 
 eSbeam =  s * abs(E * Bbeam * lD([2:3 5:6]));	% same sign of eSbeam ( f(zMax) ) as eSbar is critical for eS
 
 es = eSbar + eSbeam;	% superpose
 
end
 
