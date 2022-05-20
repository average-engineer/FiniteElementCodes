function [eS]=beam3s(eX,eY,eZ,e0,eP,eD)
% [eS]=beam3s(eX,eY,eZ,e0,eP,eD)
%--------------------------------------------------------------------------
%	PURPOSE:
%		Calculates the maximum element stresses in three dimensional beam
%		element (beam3e).
%
%	INPUT:	eX = [x1 x2]       
%			eY = [y1 y2]      
%			eZ = [z1 z2]			node coordinates
%
%			e0 = [xz yz zz]			orientation of local z-axis  
%
%			eP = [E G A Iy Iz Kv]	element properties:
%										E:	Young's modulus
%										G:	Shear modulus 
%										A:	the cross section area
%										Iy: the moment of inertia, local y-axis
%										Iz: the moment of inertia, local z-axis
%										Kv: Saint-Venant's torsion constant
%
%			eD = [u1 ... u12]		global element displacement vector
%
%	OUTPUT:	eS = [sigX1 0 0 tauYZ1 0 0;
%				  sigX2 0 0 tauYZ1 0 0]		maximum element stresses 
%											at nodes  
%
%--------------------------------------------------------------------------
% LAST MODIFIED: Arnd Koeppe 2012-08-16
%--------------------------------------------------------------------------
 
 % properties and geometry
 E = eP(1);
 Gs = eP(2);
 zMax = eP(7);
 yMax = eP(8);
 
 b = [eX(2) - eX(1);...
	  eY(2) - eY(1);...
	  eZ(2) - eZ(1)];

 % length and coordinate system
 L = sqrt(b' * b);
  
 n1 = b / L;
 n3 = e0' / sqrt(e0 * e0');
 n2 = cross(n3, n1) / norm(cross(n3, n1));
 
 % bar part
 Bbar(1,1:2) = [-1/L, 1/L];

 % beam part
 BbeamY = -zMax * [-6/L^2, -4/L, 6/L^2, -2/L;...	% x = 0
				   6/L^2, 2/L, -6/L^2, 4/L];		% x = 1
 
 BbeamZ = -yMax * [-6/L^2, -4/L, 6/L^2, -2/L;...	% x = 0
				   6/L^2, 2/L, -6/L^2, 4/L];		% x = 1
 
 % torsion part
 Btorsion(1,1:2) = [-1/L, 1/L];
 
 % rotation matrix
 T0 = [n1, n2, n3];
 
 T = eye(12);
 
 T(1:3,1:3) = T0;
 T(4:6,4:6) = T0;
 T(7:9,7:9) = T0;
 T(10:12,10:12) = T0;
 
 % element stresses
% eS = E * B * T' * eD';	% rotation back to local

 lD = T' * eD';		% rotate back to local
 
 eSbar = E * Bbar * lD([1 7]);
 
 s = sign(eSbar);
 if s == 0
	 s = 1;	% if there is no longitudinal force
 end
 
 eSbeamZ =  s * abs(E * BbeamZ * lD([2 6 8 12]));	% same sign of eSbeam ( f(zMax) ) as eSbar is critical for eS
 eSbeamY =  s * abs(E * BbeamY * lD([3 5 9 11]));	% same sign of eSbeam ( f(zMax) ) as eSbar is critical for eS
 eStorsion = Gs * Btorsion * lD([4 10]);
 
 eS = zeros(2,6);
 eS(:,1) = eSbar + eSbeamZ + eSbeamY;	% superpose
 eS(:,5) = eStorsion;

end
