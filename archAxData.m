% function to scrape plotted data off an axis for archiving in hdf5 files

function archAxData(fname,hax)

if nargin < 2
    hax = gca;
end

if exist(fname,'file') == 2
    delete(fname); 
end 

propList = {'xdata','ydata','zdata','cdata','levellist'};
np = numel(propList);

basnam = '/dat';

c = findobj(hax,'-property','xdata');
nc = numel(c);

for i=1:nc
    d = c(i);
    nam = [basnam num2str(i)];
    for j = 1:np
        pstr = propList{j};
        x = getProp(d,pstr);
        if ~isempty(x)
            dname = [nam '/' pstr];
            h5make(fname,dname,x);
        end
    end
end

end

function g = getProp(h,prop)
if ~isempty(findobj(h,'-property',prop))
    g = get(h,prop);
else 
    g = []; 
end 
end