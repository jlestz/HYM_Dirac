% function to store data from a list of handles with descriptive paths

function archList(fname,hlist,dlist)

nh = numel(hlist); 

propList = {'xdata','ydata','zdata','cdata','levellist','facealpha'};
np = numel(propList);

for i=1:nh
    h = hlist(i);
    nam = dlist{i}; 
    for j = 1:np
        pstr = propList{j};
        x = getProp(h,pstr);
        if ~isempty(x)
            dname = ['/' nam '/' pstr];
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