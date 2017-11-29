% function to read the grid from hym data files
% should be the first program run after opening a data file
% created 14 Nov 2017 
%
% f is a fileID from the fopen command
%
% for equilibrium files, ppts and nkd will return as empty and 0
% for vector or scalar files, ppts and nkd will return real values

function [zpts,rpts,ppts,nid,njd,nkd,t] = readGrid(f)

% strip header information
label = fgetl(f);

if ~contains(label,'equil')
    fgetl(f);
    tstr=fgetl(f);
    tcell=strsplit(tstr,'=');
    t=str2double(tcell{2});
else
    t = 0;
end

% get grid dimensions
dimstr=fgetl(f);
dimstr=strsplit(dimstr,' ');
nid=str2double(dimstr{2});
njd=str2double(dimstr{3});
if numel(dimstr) > 3
    nkd = str2double(dimstr{4});
else
    nkd = 0;
end

fmtstr='%f';

% get z,r points
zpts=fscanf(f,fmtstr,[nid 1]);
rpts=fscanf(f,fmtstr,[njd 1]);
ppts=fscanf(f,fmtstr,[nkd 1]);

end