function [eS, eT] = shelli4s(eX, eY, eZ, eP, D, eD)
% [eS, eT] = shelli4s(eX, eY, eZ, eP, D, eD)
%--------------------------------------------------------------------------
% PURPOSE
%  Calculate element normal and shear stress for a 4 node isoparametric 
%  shell element in plane stress in the corner points.
%
% INPUT:  eX = [x1 x2 x3 x4]  element coordinates
%         eY = [y1 y2 y3 y4]
%         eZ = [z1 z2 z3 z4]
%                             
%         eP =[t ir]    element property 
%                           ir: integration rule
%                           t : thickness
%
%         D                   constitutive matrix
%
%         eD = [u1 u2 ... u24]  element displacement vector
%
% OUTPUT: eS = [sigx1 sigy1 (sigz1) tauxy1 tauyz1 tauzx1; ...] element 
%                                                             stress vector
%         eT = [epsx1 epsy1 (epsz1) gamxy1 gamyz1 gamzx1; ...] element 
%                                                             strain vector
%--------------------------------------------------------------------------
% LAST MODIFIED: Arnd Koeppe 2012-08-16
%--------------------------------------------------------------------------

%-------- init properties -----------------------------------------
 t = eP(1); 

%--------- local coordinates -------------------------------
 v1 = [eX(2) - eX(1); eY(2) - eY(1); eZ(2) - eZ(1)];
 vt = [eX(4) - eX(1); eY(4) - eY(1); eZ(4) - eZ(1)];
 v3 = cross(v1, vt);
 v2 = cross(v3, v1);
 
 n1 = v1 / norm(v1);
 n2 = v2 / norm(v2);
 n3 = v3 / norm(v3);
 
 T1 = [n1, n2, n3];
 
 T0 = inv(T1);
 
 lCoords = T0 * [eX; eY; eZ];
 
 lX = lCoords(1,:);
 lY = lCoords(2,:);
 lZ = lCoords(3,:);
 if any(diff(lZ))   % check if any local Z values are different
      error('Element is not planar!');
 end
 
 T = eye(24);
 T(1:3, 1:3) = T0;
 T(7:9, 7:9) = T0;
 T(13:15, 13:15) = T0;
 T(19:21, 19:21) = T0;
 
 lD = (T * eD')';
 
%--------- evaluation points --------------------------------------
% most accurate for gauss points (--> shelli4e) but that would be
% a lot harder to display (9 points per element, thus 4 faces and
% no graphical interpolation between elements)

 points(:,1) = [-1, 1, 1, -1];
 points(:,2) = [-1, -1, 1, 1];
 xsi = points(:,1);
 eta = points(:,2);
 r2 = numel(points);
 np = size(points, 1);

%--------- init strain and stress --------------------------
 eS = zeros(np, 6);
 eT = zeros(np, 6);
 
%--------- shape functions -----------------------------------
% counter clock wise
 N(:,1) = (1-xsi).*(1-eta)/4;  
 N(:,2) = (1+xsi).*(1-eta)/4;
 N(:,3) = (1+xsi).*(1+eta)/4;  
 N(:,4) = (1-xsi).*(1+eta)/4; 
 
 % dNr = [dN1/dxsi dN2/dxsi dN3/dxsi dN4/dxsi;
 %        dN1/deta dN2/deta dN3/deta dN4/deta] for all GP COMBINATIONS
 dNr(1:2:r2,1) = -(1-eta)/4;    % dN1/dxsi
 dNr(1:2:r2,2) = (1-eta)/4;     % dN2/dxsi
 dNr(1:2:r2,3) = (1+eta)/4;     % dN3/dxsi
 dNr(1:2:r2,4) = -(1+eta)/4;    % dN4/dxsi
 dNr(2:2:r2+1,1) = -(1-xsi)/4;  % dN1/deta
 dNr(2:2:r2+1,2) = -(1+xsi)/4;  % dN2/deta
 dNr(2:2:r2+1,3) = (1+xsi)/4;   % dN3/deta
 dNr(2:2:r2+1,4) = (1-xsi)/4;   % dN4/deta
 
%-------- Jacobi Matrix ------------------------------------
% JT = [dx/dxsi dy/dxsi; 
%       dx/deta dy/deta]
%  with dx/dxsi = d/dxsi(sum(N(i)*lX(i)), Y and d/deta analog
 JT = dNr * [lX; lY]';

%--------- Constitutive Matrix -----------------------------
 Dm = D([1 2 4], [1 2 4]);
 Ds = D([5 6], [5 6]);
 
%--------- MEMBRANE ELEMENT ------------------------------------- 
 iMembrane = [1 2 7 8 13 14 19 20];
 B = zeros(3,8);
 for i = 1 : np    
    indx = [ 2*i-1; 2*i ];    % Jacobi Matrix index for point number i
    detJ = det(JT(indx,:));
    if detJ < 10*eps
        disp('Jacobideterminant equal or less than zero!')
    end
    
    % dNx = [dN1/dx dN2/dx dN3/dx dN4/dx;
    %        dN1/dy dN2/dy dN3/dy dN4/dy] for current gauss point      
    % JTinv = inv(JT(indx,:));
    % dNx = JTinv * dNr(indx,:); % the following executes faster:
    dNx = JT(indx,:)\dNr(indx,:);
     
    B(1,1:2:8-1) = dNx(1,:);
    B(2,2:2:8) = dNx(2,:);
    B(3,1:2:8-1) = dNx(2,:);
    B(3,2:2:8)  = dNx(1,:);
    
    eE = B * lD(1, iMembrane)';
    eT(i,[1 2 4]) = eT(i,[1 2 4]) +  eE';
    eS(i,[1 2 4]) = eS(i,[1 2 4]) + (Dm * eE)';
    
end

%--------- PLATE ELEMENT ----------------------------------------
 iPlate = [3 4 5 9 10 11 15 16 17 21 22 23];
 Bb = zeros(3,12);
 Bs = zeros(2,12);
 for i = 1 : np
    indx = [ 2*i-1; 2*i ];    % Jacobi Matrix index for point number i
    detJ = det(JT(indx,:));
    if detJ < 10*eps
        disp('Jacobideterminant equal or less than zero!')
    end
     
    % dNx = [dN1/dx dN2/dx dN3/dx dN4/dx;
    %        dN1/dy dN2/dy dN3/dy dN4/dy] for current gauss point
    % JTinv = inv(JT(indx,:));
    % dNx = JTinv * dNr(indx,:); % the following executes faster:
    dNx = JT(indx,:)\dNr(indx,:);
    
    % bending
    %Bb(1,3:3:12) = -dNx(1,:);     
    %Bb(2,2:3:12-1) = -dNx(2,:);
    %Bb(3,2:3:12-1)  = -dNx(1,:);
    %Bb(3,3:3:12) = -dNx(2,:);
    Bb(1,2:3:12-1) = dNx(1,:);
    Bb(2,3:3:12) = dNx(2,:);
    Bb(3,2:3:12-1) = dNx(2,:);
    Bb(3,3:3:12) = dNx(1,:);
    
    eEb = -t/2 * Bb * lD(iPlate)';
    eT(i,[1 2 4]) = eT(i,[1 2 4]) +  eEb';
    eS(i,[1 2 4]) = eS(i,[1 2 4]) + (Dm * eEb)';
     
    % shear
    Bs(1,1:3:12-2) = dNx(1,:);
    %Bs(1,3:3:12) = N(i,:);
    Bs(1,2:3:12-1) = -N(i,:);
    Bs(2,1:3:12-2) = dNx(2,:);
    %Bs(2,2:3:12-1) = N(i,:);
    Bs(2,3:3:12) = -N(i,:);
    
    eEs = Bs * lD(iPlate)';
    eT(i,[5 6]) = eT(i,[5 6]) +  eEs';
    eS(i,[5 6]) = eS(i,[5 6]) + (Ds * eEs)';
 end

end

