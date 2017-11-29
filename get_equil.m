% function to read psi.dat and return equilibrium profiles 
% Last modified 14 Nov 2017 

function eqstruct = get_equil(nn,ll,vv,sfx,do_plot) 

if nargin < 5
    do_plot = 0; 
end 

run = getRunID(nn,ll,vv,sfx); 

f=fopen(['psi.dat/' run '.psi.dat']);

[zpts,rpts,~,nid,njd] = readGrid(f); 

fmtstr='%f';
sizevec=[nid njd]; 

% get profiles 
psi=fscanf(f,fmtstr,sizevec); % flux function 
Pb = fscanf(f,fmtstr,sizevec); % bulk pressure 
bz0 = fscanf(f,fmtstr,sizevec); % B_z
br0 = fscanf(f,fmtstr,sizevec); % B_r
bp0 = fscanf(f,fmtstr,sizevec); % B_phi
ni = fscanf(f,fmtstr,sizevec); % ion charge density 
jip = fscanf(f,fmtstr,sizevec); % ion current_phi 
nb = fscanf(f,fmtstr,sizevec); % bulk density 
jbz = fscanf(f,fmtstr,sizevec); % bulk current_z
jbr = fscanf(f,fmtstr,sizevec); % bulk current_r
jbp = fscanf(f,fmtstr,sizevec); % bulk current_p 

% finished reading, close psi.dat 
fclose(f);

% compute derived equilibrium quantities
b0 = sqrt(bz0.^2 + br0.^2 + bp0.^2); % |B|

gamma = 5/3; % adiabatic index 
% should this have a factor of 1/2 e.g. T = 1/2 mv^2, maybe even 3/2?
Ti = 0.168*vv^2;  
% for slowing down distribution F(v) = 1/v^3 +vc^3 with vc=v0/2, 
% <v^2> = int v^2 F(v) / int F(v) = .168 v0^2

Pi = ni*Ti; % assumes m,kappa_Boltzmann normalized to 1

Ptot = Pb + Pi; 
ntot = nb + ni; 

% compute Va^2 = B^2/rho
% no factor of 1/sqrt(4pi) needed due to code normalizations
Va = b0./sqrt(ntot); 
% compute Vs^2 = gamma P/rho
Vs = sqrt(gamma*Ptot./ntot); 

% interpolate for better resolution
rmin=min(rpts); 
rmax=max(rpts); 
rint=linspace(rmin,rmax,10*njd); 
zdex=floor(nid/2); 
psi_int=interp1(rpts,psi(zdex,:),rint); 
B_int=interp1(rpts,b0(zdex,:),rint); 
Va_int=interp1(rpts,Va(zdex,:),rint); 
Vs_int=interp1(rpts,Vs(zdex,:),rint); 

% return r0, location of magnetic axis (where psi=psimin) 
dex0 = find(psi_int==min(psi_int),1,'first'); 
r0=rint(dex0); 
B0=B_int(dex0); 
Va0=Va_int(dex0); 
Vs0=Vs_int(dex0); 

% return rT, locaiton of transp axis (where B=1)
dexT=find(min(abs(1-b0(zdex,:)))==abs(1-b0(zdex,:)),1,'first'); 
rT=rint(dexT); 
BT=B_int(dexT); 
VaT=Va_int(dexT); 
VsT=Vs_int(dexT); 

[rcut,psicut,qcut]=get_q(rpts,zpts,psi,bp0,sqrt(br0.^2+bz0.^2),do_plot); 

s = struct(); 
s.zpts = zpts; 
s.rpts = rpts; 
s.psi = psi; 
s.Pb = Pb; 
s.bz0 = bz0; 
s.br0 = br0; 
s.bp0 = bp0; 
s.ni = ni; 
s.jip = jip; 
s.nb = nb; 
s.jbz = jbz; 
s.jbr = jbr; 
s.jbp = jbp; 
s.b0 = b0; 
s.Pi = Pi; 
s.Ptot = Ptot; 
s.ntot = ntot; 
s.Va = Va; 
s.Vs = Vs; 
s.rcut = rcut; 
s.psicut = psicut; 
s.qcut = qcut; 

eqstruct = s; 

% plot profiles 
if do_plot 
    disp('no plotting yet in get_equil.m'); 
end

end