% function to test if an optional argument was passed 
% and set to a nontrivial value 

function p = varIsEmpty(vstr) 
    p = 1; 
    if exist(vstr,'var')
        if ~isempty(eval(vstr))
            p = 0; 
        end 
    end 
end