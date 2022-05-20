function [Ke, fe] = shelli4e(eX, eY, eZ, eP, D, eQ)
% [Ke] = shelli4e(eX, eY, eZ, eP, D, eQ)
% [Ke, fe] = shelli4e(eX, eY, eZ, eP, D, eQ)
%--------------------------------------------------------------------------
% PURPOSE
%  Calculate the stiffness matrix for a 4 node isoparametric
%  shell element in 3D.
%
% INPUT:  eX = [x1 x2 x3 x4]  element coordinates
%         eY = [y1 y2 y3 y4]
%         eZ = [z1 z2 z3 z4]
%                             
%         eP =[t ir] element property 
%                           ir:  integration rule
%                           t :  thickness
%
%         D                   constitutive matrix
%
%         eQ = [bX; bY]       bx: body force in x direction
%                             by: body force in y direction
%
% OUTPUT: Ke : element stiffness matrix
%         fe : equivalent nodal forces
%--------------------------------------------------------------------------
% LAST MODIFIED: Arnd Koeppe 2012-08-16
%--------------------------------------------------------------------------

%-------- init body forces ----------------------------------------
 if nargin==5   
    b = zeros(2,1);  
 else
    b = eQ;
 end

%-------- init properties -----------------------------------------
 t = eP(1);
 I = t^3/12;
 ir = eP(2);
 ngp = ir*ir;  % number of gauss points
 sngp = 1;      % number of shear gauss points (reduced integration)

%--------- init element stiffness matrix --------------------- 
 Kel = zeros(24, 24);
 fel = zeros(24, 1);
 
 iMembrane = [1 2 7 8 13 14 19 20];
 iPlate = [3 4 5 9 10 11 15 16 17 21 22 23];
 iVar = [6 12 18 24];

%--------- Constitutive Matrix -----------------------------
 Dm = D([1 2 4], [1 2 4]);
 Ds = D([5 6], [5 6]);
  
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
 
%--------- gauss points --------------------------------------
 switch ir
    case {1}
        g1 = 0.0; 
        w1 = 2.0;
        gp = [ g1 g1 ];  
        w =[ w1 w1 ];
    case {2}
        g1 = 0.577350269189626; 
        w1 = 1;
        gp(:,1) = [-g1; g1;-g1; g1];  
        gp(:,2) = [-g1;-g1; g1; g1];
        w(:,1) = [ w1; w1; w1; w1];   
        w(:,2) = [ w1; w1; w1; w1];
    case{3}
        g1 = 0.774596669241483; 
        g2 = 0.;
        w1 = 0.555555555555555; 
        w2 = 0.888888888888888;
        gp(:,1) = [-g1;-g2; g1;-g1; g2; g1;-g1; g2; g1];
        gp(:,2) = [-g1;-g1;-g1; g2; g2; g2; g1; g1; g1];
        w(:,1) = [ w1; w2; w1; w1; w2; w1; w1; w2; w1];
        w(:,2) = [ w1; w1; w1; w2; w2; w2; w1; w1; w1];
     otherwise
        disp('Used number of integration points not implemented');
    return
 end
 wp = w(:,1) .* w(:,2);
 xsi = gp(:,1);
 eta = gp(:,2);
 r2 = ngp * 2;
 
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

%--------- MEMBRANE ELEMENT -------------------------------------
 for i = 1 : ngp    % Begin gauss integration
    B = zeros(3,8);     
    indx = [ 2*i-1; 2*i ];    % Jacobi Matrix index for GP number i
    detJ = det(JT(indx,:));
    if detJ < 10*eps
        disp('Jacobideterminant equal or less than zero!')
    end
    
    % dNx = [dN1/dx dN2/dx dN3/dx dN4/dx;
    %        dN1/dy dN2/dy dN3/dy dN4/dy] for current gauss point      
    %JTinv = inv(JT(indx,:));
    %dNx = JTinv * dNr(indx,:); % the following executes faster:
    dNx = JT(indx,:)\dNr(indx,:);
     
    B(1,1:2:8-1) = dNx(1,:);
    B(2,2:2:8) = dNx(2,:);
    B(3,1:2:8-1) = dNx(2,:);
    B(3,2:2:8)  = dNx(1,:);
    
    N2(1,1:2:8-1) = N(i,:);
    N2(2,2:2:8) = N(i,:);

    Kel(iMembrane,iMembrane) = Kel(iMembrane,iMembrane) + B' * Dm * B * detJ * wp(i) * t; % Gauss Integration step
    fel(iMembrane) = fel(iMembrane) + N2' * b * detJ * wp(i) * t; % Gauss Integration step
 end

%--------- PLATE BENDING ELEMENT ------------------------------------
 for i = 1 : ngp     % begin gauss integration
    Bb = zeros(3,12);  
    indx = [ 2*i-1; 2*i ];    % Jacobi Matrix index for GP number i
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
    Bb(1,3:3:12) = -dNx(1,:);
    Bb(2,2:3:11) = dNx(2,:);
    Bb(3,2:3:11) = dNx(1,:);
    Bb(3,3:3:12) = -dNx(2,:);
     
    N2(1,2:3:12-1) = N(i,:);
    N2(2,3:3:12) = N(i,:); 
    
    Kel(iPlate,iPlate) = Kel(iPlate,iPlate)...
                           + Bb' * Dm * Bb * detJ * wp(i) * I; % gauss integration step
    fel(iPlate) = fel(iPlate) + N2' * b * detJ * wp(i); % gauss integration step
 end
 
%--------- REDUCED INTEGRATION -------------------------------

%--------- gauss points --------------------------------------
 sg1 = 0.0; 
 sw1 = 2.0;
 sgp = [sg1 sg1];  
 sw =[sw1 sw1];
 swp = sw(:,1) .* sw(:,2);
 sxsi = sgp(:,1);
 seta = sgp(:,2);
 sr2 = sngp * 2;
 
%--------- shape functions -----------------------------------
% counter clock wise
 Ns(:,1) = (1-sxsi).*(1-seta)/4;  
 Ns(:,2) = (1+sxsi).*(1-seta)/4;
 Ns(:,3) = (1+sxsi).*(1+seta)/4;  
 Ns(:,4) = (1-sxsi).*(1+seta)/4; 
 
 % dNr = [dNs1/dxsi dNs2/dxsi dNs3/dxsi dNs4/dxsi;
 %        dNs1/deta dNs2/deta dNs3/deta dNs4/deta] for all GP COMBINATIONS
 dNsr(1:2:sr2,1) = -(1-seta)/4;    % dNs1/dxsi
 dNsr(1:2:sr2,2) = (1-seta)/4;     % dNs2/dxsi
 dNsr(1:2:sr2,3) = (1+seta)/4;     % dNs3/dxsi
 dNsr(1:2:sr2,4) = -(1+seta)/4;    % dNs4/dxsi
 dNsr(2:2:sr2+1,1) = -(1-sxsi)/4;  % dNs1/deta
 dNsr(2:2:sr2+1,2) = -(1+sxsi)/4;  % dNs2/deta
 dNsr(2:2:sr2+1,3) = (1+sxsi)/4;   % dNs3/deta
 dNsr(2:2:sr2+1,4) = (1-sxsi)/4;   % dNs4/deta
 
%-------- Jacobi Matrix ------------------------------------
% JT = [dx/dxsi dy/dxsi; 
%       dx/deta dy/deta]
%  with dx/dxsi = d/dxsi(sum(N(i)*lX(i)), Y and d/deta analog
 JTs = dNsr * [lX; lY]';
 
%--------- SHEAR ELEMENT -----------------------------------------------
 for i = 1 : sngp     % begin gauss integration
    Bs = zeros(2,12);     
    indx = [ 2*i-1; 2*i ];    % Jacobi Matrix index for GP number i
    detJ = det(JTs(indx,:));
    if detJ < 10*eps
        disp('Jacobideterminant equal or less than zero!')
    end

    % dNsx = [dNs1/dx dNs2/dx dNs3/dx dNs4/dx;
    %         dNs1/dy dNs2/dy dNs3/dy dNs4/dy] for current gauss point
    % JTinv = inv(JTs(indx,:));
    % dNsx = JTinv * dNsr(indx,:); % the following executes faster:
    dNsx = JTs(indx,:)\dNsr(indx,:);
     
    % shear
    Bs(1,1:3:10) = dNsx(1,:);
    Bs(1,3:3:12) = Ns(i,:);
    Bs(2,1:3:10) = dNsx(2,:);
    Bs(2,2:3:11) = -Ns(i,:);
    
    Ns2(1,2:3:12-1) = Ns(i,:);
    Ns2(2,3:3:12) = Ns(i,:); 
    
    Kel(iPlate,iPlate) = Kel(iPlate,iPlate)...
                           + Bs' * Ds * Bs * detJ * swp(i) * t; % gauss integration step
    fel(iPlate) = fel(iPlate) + Ns2' * b * detJ * swp(i); % gauss integration step
 end
 
%--------- COMPATIBILITY  ----------------------------------------
 KelDiag = diag(Kel);
 KelDiag(KelDiag == 0) = []; % remove zero elements
 sf = min(KelDiag)/1000;
 Kel(iVar,iVar) = sf * eye(size(iVar,2));
 
%--------- Global Coordinates ------------------------------------
 T = eye(24);
 T(1:3, 1:3) = T0;
 T(4:6, 4:6) = T0;
 T(7:9, 7:9) = T0;
 T(10:12, 10:12) = T0;
 T(13:15, 13:15) = T0;
 T(16:18, 16:18) = T0;
 T(19:21, 19:21) = T0;
 T(22:24, 22:24) = T0;
 
 Ke = T' * Kel * T;
 fe = T * fel;
 
end

