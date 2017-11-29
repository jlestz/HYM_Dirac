% function to simply read and return a fort.20 file 
% input: n,l,v
% output: t=dat(:,1), en=dat(:,2)
function dat20 = read_fort20(n,l,v,sfx)

run=getRunID(n,l,v,sfx); 

dir='fort.20/';
fend='.fort.20';
fname=[dir run sfx fend] ;

dat20=load(fname);
end