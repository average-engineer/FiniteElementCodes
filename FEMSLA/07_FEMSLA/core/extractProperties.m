function [eP, D, e0] = extractProperties(eType, i, prop)
% [eP, D, e0] = extractProperties(eType, i, prop)
% [eP, D] = extractProperties(eType, i, prop)
% [eP, ~, e0] = extractProperties(eType, i, prop)
% [eP] = extractProperties(eType, i, prop)
%--------------------------------------------------------------------------
% PURPOSE
%   Extracts property data from the structure prop and processes it for the
%   element functions.
%
% INPUT:    eType   (1x1)           element type
%           i       (1x1)           index of current element
%           prop    (struct)        element property structure
%
% OUTPUT:   eP      (1xn)           element property vector
%           D       (6x6)           constitutive matrix
%           e0      [xz yz zz]      orientation of local z-axis
%
%--------------------------------------------------------------------------
% LAST MODIFIED: Arnd Koeppe 2012-08-16
%--------------------------------------------------------------------------

 switch eType
     case {122} % bar, 2 Node, 2D 
         eP = [prop.Ep(i) prop.A(i)];            
     case {123} % bar, 2 Node, 3D
         eP = [prop.Ep(i) prop.A(i)];
     case {222} % beam, 2 Node, 2D
         eP = [prop.Ep(i) prop.A(i) prop.I(i) prop.zMax(i)];
     case {229} % beam, 2 Node, 2D
         eP = [prop.Ep(i) prop.Gq(i) prop.A(i) prop.I(i) prop.ks(i)];  
     case {223} % beam, 2 Node, 3D
         eP = [prop.Ep(i) prop.Gq(i) prop.A(i) prop.Iy(i) prop.Iz(i)...
               prop.Kv(i) prop.zMax(i) prop.yMax(i)];
         D = [];
         e0 = [prop.xz(i) prop.yz(i) prop.zz(i)];           
     case {332} % plane/membrane, 3 Node, 2D
         t = prop.t(i);
         ptype = 1;     % plane stress
         
         eP = [ptype t];
         
         Ep = prop.Ep(i);
         Es = prop.Es(i);
         nue = prop.nue(i);
         Gq = prop.Gq(i);
         phi = prop.phi(i);
         
		 DUD = orth3DConstitutive(Ep, Es, nue, Gq);
         D = constitutiveTrans(DUD, phi);
		 
		 %D = hooke(ptype, Ep, nue);
     case {342} % plane/membrane (isoparametric), 4 Node, 2D
         t = prop.t(i);
         ir = 2;
         ptype = 1;

         eP = [ptype t ir];
         
         Ep = prop.Ep(i);
         Es = prop.Es(i);
         nue = prop.nue(i);
         Gq = prop.Gq(i);
         phi = prop.phi(i);
		 
         DUD = orth3DConstitutive(Ep, Es, nue, Gq);
         D = constitutiveTrans(DUD, phi);
		 
		 %D = hooke(ptype, Ep, nue);
     case {382} % plane/membrane (isoparametric), 8 Node, 2D
         t = prop.t(i);
         ir = 3;
         ptype = 1;

         eP = [ptype t ir];          
         
         Ep = prop.Ep(i);
         Es = prop.Es(i);
         nue = prop.nue(i);
         Gq = prop.Gq(i);
         phi = prop.phi(i);
         
		 DUD = orth3DConstitutive(Ep, Es, nue, Gq);
         D = constitutiveTrans(DUD, phi);
		 
		 %D = hooke(ptype, Ep, nue);
     case {543} % shell (isoparametric), 4 Node, 3D
         t = prop.t(i);
         ir = 2;
         eP = [t ir];
         if isfield(prop, 'rho')
            rho = prop.rho(i);
            eP = [eP, rho];
         end
         if isfield(prop, 'a')
             a = prop.a(i);
             b = prop.b(i);
             eP = [eP a b];
         end

         Ep = prop.Ep(i);
         Es = prop.Es(i);
         nue = prop.nue(i);
         Gq = prop.Gq(i);
         phi = prop.phi(i);
         DUD = orth3DConstitutive(Ep, Es, nue, Gq);
         
         D = constitutiveTrans(DUD, phi);
     case {683} % solid (isoparametric), 8 Node, 3D
         ir = 2;

         eP = ir;
         
         Ep = prop.Ep(i);
         nue = prop.nue(i);

         D = iso3DConstitutive(Ep,nue);      
 end

end

