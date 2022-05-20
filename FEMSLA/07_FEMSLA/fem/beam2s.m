function [eS] = beam2s(eX,eY,eP,eD)
% [eS] = beam2s(eX,eY,eP,eD)
%--------------------------------------------------------------------------
%	PURPOSE
%		Compute maximum element stresses in two dimensional beam element
%		(beam2e).
% 
%	INPUT:	eX = [x1 x2]
%			eY = [y1 y2]     element node coordinates
%
%			eP = [E A I zMax]	element properties,
%									E:		Young's modulus
%									A:		cross section area
%									I:		moment of inertia
%									zMax:	maximum z-distance of cross
%											section from center of mass
%
%            eD = [u1 ... u6]	element displacements
%
%	OUTPUT: eS = [sigX1;
%				  sigX2]		maximum element stresses at nodes      
%
%--------------------------------------------------------------------------
% LAST MODIFIED: Arnd Koeppe 2012-08-16
%--------------------------------------------------------------------------
 
 % properties and geometry
 E = eP(1);
 zMax = eP(4);
 
 b = [eX(2) - eX(1);...
	  eY(2) - eY(1)];

 % length and angles
 L = sqrt(b' * b);
  
 n = b / L;		% [cos; sin]
 
 % bar part
 Bbar(1,1:2) = [-1/L, 1/L];

 % beam part
 Bbeam = -zMax * [-6/L^2, -4/L, 6/L^2, -2/L;...	% x = 0
				  6/L^2, 2/L, -6/L^2, 4/L];		% x = 1
    
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

 lD = T' * eD';		% rotate back to local
 
 eSbar = E * Bbar * lD([1 4]);
 
 s = sign(eSbar);
 if s == 0
	 s = 1;	% if there is no longitudinal force
 end
 
 eSbeam =  s * abs(E * Bbeam * lD([2:3 5:6]));	% same sign of eSbeam ( f(zMax) ) as eSbar is critical for eS
 
 eS = eSbar + eSbeam;	% superpose
 
end
 
