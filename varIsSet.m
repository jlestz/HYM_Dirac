% function to test if an optional argument was passed 
% and set to a nontrivial value 

function p = varIsSet(vstr) 
    p = 0; 
    if exist(vstr,'var')
        if ~isempty(eval(vstr))
            p = 1; 
        end 
    end 
end