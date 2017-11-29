% function for reading equilibrium B field data from psi.dat
% created 14 Nov 2017
%
% fname is a file name for a psi.dat file

function [vz,vr,vp]=read_b0(fname)
f=fopen(fname);

[~,~,~,nid,njd,~,~] = readGrid(f);

% treat case where reading from equilibrium (nkd = 0)
nijd = nid*njd;
dsize = [nijd 1];

fmtstr1='%E';

% peel off pressure data
fscanf(f,fmtstr1,dsize);

% read the vector field data
vz=fscanf(f,fmtstr1,dsize);
vr=fscanf(f,fmtstr1,dsize);
vp=fscanf(f,fmtstr1,dsize);

% reshape data from list onto grid
vz=reshape(vz,nid,njd);
vr=reshape(vr,nid,njd);
vp=reshape(vp,nid,njd);

fclose(f);
end