% function to cycle through plot styles
% col is a character string of built-in colors
% sty is a cell array of line styles 

function styout = get_sty(var,col,sty)

if nargin < 3 || isempty(sty) 
    sty={'-',':','--','-.'};
end 

if nargin < 2 || isempty(sty) 
    col='kbrgcmy';
end 

clen=length(col);
slen=length(sty);
list=2:8;
i=find(var==list);

mycol=col(mod(i,clen)+1);
mysty=sty{mod(floor(i/clen),slen)+1};

styout=[mycol mysty];

end