% function to fix colorbar axis
% created 14 Nov 2017 
%
% input 
% vmin is the min value to use 
% vmax is the max value to use 
%
% optional
% hleg is the handle to a colobar

function fix_cbar(vmin,vmax,hleg)

if nargin < 3
    hleg = colorbar; 
end 

if vmin ~= vmax
    caxis(max(abs([vmin vmax]))*[-1 1]);
    set(hleg,'limits',[vmin vmax]);
end

end