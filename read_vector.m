% function for reading vector data from data files such as b3.dat
% created 14 Nov 2017
%
% fname is a file name for a vector data file (such as b3.dat)

function [vz,vr,vp,t]=read_vector(fname)
f=fopen(fname);
if f < 0
    disp(['error: ' fname ' did not open properly, trying new suffix']);
    % if .dat is already on the end, strip it off
    s=strsplit(fname,'.');
    send=s{numel(s)};
    if strcmpi(send,'dat')
        f=fopen(fname(1:end-4));
    else
        f=fopen([fname '.dat']);
    end
end

[~,~,~,nid,njd,nkd,t] = readGrid(f);

% treat case where reading from equilibrium (nkd = 0)
nijkd = nid*njd*nkd;
dsize = [nijkd 1];

fmtstr1='%E';

% read the vector field data
vz=fscanf(f,fmtstr1,dsize);
vr=fscanf(f,fmtstr1,dsize);
vp=fscanf(f,fmtstr1,dsize);

% reshape data from list onto grid
vz=reshape(vz,nid,njd,nkd);
vr=reshape(vr,nid,njd,nkd);
vp=reshape(vp,nid,njd,nkd);

fclose(f);
end