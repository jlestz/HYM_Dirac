% function for getting psi contour (x,y) curves
% created 14 Nov 2017 
%
% r and z are vectors, not meshgrids 
function [x,y] = psiContours(r,z,psi,nlevs)

if nargin < 2 
    nlevs = 6; 
end 

minpsi=min(min(psi));
clevs=linspace(minpsi,0,nlevs+1);
C=contourc(r,z,psi,clevs);
[x,y]=C2xyz(C);

end