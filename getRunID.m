% function for converting n,l,v,sfx arguments into runid format
% n,l,v are numbers
% sfx is a string
% if n,l,v = 0,0,0, then the runid is simply the suffix

function [run,nstr,lstr,vstr] = getRunID(nn,ll,vv,sfx)

if nargin < 4
    sfx = '';
end

if nnz([nn ll vv]) < 3
    run = sfx;
else
    nstr=num2str(nn,'%d');
    lstr=num2str(ll,'%1.1f');
    % get the velocity string in the run name of the mode
    % some values of v need more than 1 decimal precision
    if mod(vv,.1)>1e-8
        vstr=num2str(vv,'%1.2f');
    else
        vstr=num2str(vv,'%1.1f');
    end
    
    % simulation data is stored in this format
    run=['n' nstr 'l' lstr 'v' vstr sfx];
end

end