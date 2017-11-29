% function to archive data from a single axis interactively

function archInteractive(fname)
propList = {'xdata','ydata','zdata','cdata','levellist'};
np = numel(propList);

h = input('Click on an object to archive its data\n');
while isempty(findobj(h,'-property','xdata'))
    h = input('Invalid object, select another\n');
end

s = input('Name this data (must be a legal data path)\n');


for j = 1:np
    pstr = propList{j};
    x = getProp(h,pstr);
    if ~isempty(x)
        dname = [s '/' pstr];
        h5make(fname,dname,x);
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